# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 10:24:10 2020

@author: thd7as
"""

import re
from txt2actr.environment2actr import actr


# =============================================================================
# This class is all about setting up the ACT-R Environment, including adding
# goals to the (cognitive) ACT-R Model
# =============================================================================


class ACTR_interface:

    # nr_of_frac is the number of digits after comma
    def __init__(self, cognitive_model_file, windows_dict, sounds_dict, nr_of_frac,
                 show_display_labels, time_interval_to_new_val_in_msc=1,
                 human_interaction=False, show_env_windows=False):

        self.cognitive_model_file = cognitive_model_file
        self.windows_dict = windows_dict

        self.sounds_dict = sounds_dict
        self.nr_of_frac = nr_of_frac
        self.show_display_labels = show_display_labels
        self.time_interval_to_new_val_in_msc = time_interval_to_new_val_in_msc
        self.human_interaction = human_interaction
        self.show_env_windows = show_env_windows

        self.actr_window_updater = "update_window" if not show_display_labels else "update_window_with_labels"

    def get_actr_instance(self):
        return actr

    def connect_with_actr(self):

        actr.connection() if not actr.current_connection else actr.reset()
        # get rid of any non-alphanumeric characters at the beginning of path to file string
        start_idx = re.search("[^\W\d]", self.cognitive_model_file).start()
        self.cognitive_model_file = self.cognitive_model_file[start_idx:].replace("/",";").replace("\\", ";")
        actr.load_act_r_code(self.cognitive_model_file)
        actr.add_word_characters(".")
        actr.add_word_characters("_")

        actr.add_command("update_window_with_labels", self.update_window_with_labels,
                         "updates window with params actr_window, "
                         "display_label, new_value, idx, x_text, y_text, font_size")

        actr.add_command("update_window", self.update_window,
                         "updates window with params actr_window, "
                         "display_label, new_value, idx, x_text, y_text, font_size")

        actr.add_command("clear_window", self.clear_window, "cleares window with params actr_window")
        actr.add_command("update_sound", self.update_sound, "produces tone sound with params freq, duration")
        actr.add_command("update_button", self.update_button, "updates button")
        actr.add_command("update_image", self.update_image, "updates image")

        #actr.add_command("add_result", self.add_result, "adding result to list")

    def reload_actr_code(self, compile=False):
        # actr.load_act_r_code(self.cognitive_model_file)
        actr.reload(compile)

    def set_actr_windows(self):

        for window in self.windows_dict.values():
            actr_window = actr.open_exp_window(window.name, visible=self.show_env_windows, width=window.width,
                                               height=window.length, x=window.x_loc, y=window.y_loc)
            window.actr_window = actr_window
            window_labels_as_string = "" if not self.show_display_labels else \
                                      ", ".join(value[0] for (_, value) in window.labels_dict.items())
            actr.add_text_to_exp_window(actr_window, window_labels_as_string, x=window.x_text,
                                        y=window.y_text, font_size=window.font_size)
            for b in window.buttons_dict.values():
                actr.add_button_to_exp_window(actr_window, text=b.label, x=b.x_loc, y=b.y_loc, action=b.action,
                                              height=b.height, width=b.width, color='gray')
            for i in window.images_dict.values():
                actr.add_image_to_exp_window(actr_window, i.name, i.color, i.x_loc, i.y_loc, i.x_end, i.y_end)
            actr.install_device(actr_window)  # Install window

        #actr.install_device(["vision", "cursor"])
        #actr.install_device(["motor", "keyboard"])

    def update_actr_env(self, changes_dict, schedule_time):

        for window in self.windows_dict.values():
            relevant_list = self.intersection(window.labels_dict, changes_dict)
            if relevant_list:
                for b in window.buttons_dict.values():
                    actr.schedule_event(schedule_time, "update_button", params=[window.actr_window, b.label,
                                        b.x_loc, b.y_loc, b.action, b.height, b.width], time_in_ms=True)
                for i in window.images_dict.values():
                    if i.appearance == 'True':
                        actr.schedule_event(schedule_time, "update_image", params=[window.actr_window, i.name, i.color,
                                             i.x_loc, i.y_loc, i.x_end, i.y_end], time_in_ms=True)
                window_labels_dict = window.labels_dict
                window_labels_dict.update((label, [window_labels_dict[label][0],
                                                   changes_dict[label]]) for label in relevant_list)
                actr.schedule_event(schedule_time - self.time_interval_to_new_val_in_msc,
                                    "clear_window", params=[window.actr_window], time_in_ms=True)
                for index, (_, value) in enumerate(window_labels_dict.items(), start=-2):
                    new_value = self.convert_val(value[1])
                    display_label = value[0]
                    for i in window.images_dict.values():
                        if i.label == display_label and self.convert_val(f'{i.appearance}') == new_value:
                            actr.schedule_event(schedule_time, "update_image", params=[window.actr_window, i.name,
                                                i.color, i.x_loc, i.y_loc, i.x_end, i.y_end], time_in_ms=True)
                    actr.schedule_event(schedule_time, self.actr_window_updater, params=[window.actr_window,
                                                display_label, new_value, index, window.x_text,
                                                window.y_text, window.font_size], time_in_ms=True)
        # trying to find an efficient way to record changes in sounds
        new_tone_sounds = filter(lambda new: str(changes_dict.get(new[0])) == str(new[1]), self.sounds_dict)
        if new_tone_sounds:
            for key in new_tone_sounds:
                freq = self.sounds_dict[key].value
                duration = self.sounds_dict[key].duration
                sound_type = self.sounds_dict[key].sound_type
                word = self.sounds_dict[key].word
                print(schedule_time, freq, duration, sound_type, word)
                actr.schedule_event(schedule_time, "update_sound",
                                    params=[float(sound_type), freq, duration, word], time_in_ms=True)

    # update_actr_env excluding clear_window
    def first_update_actr_env(self, changes_dict, schedule_time):

        for window in self.windows_dict.values():
            relevant_list = self.intersection(window.labels_dict, changes_dict)
            if relevant_list:
                for b in window.buttons_dict.values():
                    actr.schedule_event(schedule_time, "update_button", params=[window.actr_window, b.label,
                                        b.x_loc, b.y_loc, b.action, b.height, b.width], time_in_ms=True)
                for i in window.images_dict.values():
                    if i.appearance == 'True':
                        actr.schedule_event(schedule_time, "update_image", params=[window.actr_window, i.name, i.color,
                                             i.x_loc, i.y_loc, i.x_end, i.y_end], time_in_ms=True)
                window_labels_dict = window.labels_dict
                window_labels_dict.update((label, [window_labels_dict[label][0],
                                                   changes_dict[label]]) for label in relevant_list)
                for index, (_, value) in enumerate(window_labels_dict.items(), start=-2):
                    new_value = self.convert_val(value[1])
                    display_label = value[0]
                    for i in window.images_dict.values():
                        if i.label == display_label and self.convert_val(f'{i.appearance}') == new_value:
                            actr.schedule_event(schedule_time, "update_image", params=[window.actr_window, i.name,
                                                i.color, i.x_loc, i.y_loc, i.x_end, i.y_end], time_in_ms=True)
                    actr.schedule_event(schedule_time, self.actr_window_updater, params=[window.actr_window,
                                                display_label, new_value, index, window.x_text,
                                                window.y_text, window.font_size], time_in_ms=True)
        # trying to find an efficient way to record changes in sounds
        new_tone_sounds = filter(lambda new: str(changes_dict.get(new[0])) == str(new[1]), self.sounds_dict)
        if new_tone_sounds:
            for key in new_tone_sounds:
                freq = self.sounds_dict[key].value
                duration = self.sounds_dict[key].duration
                sound_type = self.sounds_dict[key].sound_type
                word = self.sounds_dict[key].word
                print(schedule_time, freq, duration, sound_type, word)
                actr.schedule_event(schedule_time, "update_sound",
                                    params=[float(sound_type), freq, duration, word], time_in_ms=True)

    @staticmethod
    def update_button(actr_window, label, x_loc, y_loc, action, height, width):
        actr.add_button_to_exp_window(actr_window, text=label, x=x_loc, y=y_loc, action=action, height=height,
                                      width=width, color='gray')

    @staticmethod
    def update_image(actr_window, name, color, x_loc, y_loc, width, height):
        actr.add_image_to_exp_window(actr_window, name, color, x_loc, y_loc, width, height)

    @staticmethod
    def update_window(actr_window, display_label, new_value, idx, x_text, y_text, font_size):
        actr.add_text_to_exp_window(actr_window,
                                    text=new_value,
                                    color=display_label, x=x_text,
                                    y=y_text - (idx * 24),
                                    font_size=font_size, width=75)

    @staticmethod
    def update_window_with_labels(actr_window, display_label, new_value, idx, x_text, y_text, font_size):
        actr.add_text_to_exp_window(actr_window,
                                    text=f'{display_label}: {new_value}',
                                    color=display_label,
                                    x=x_text,
                                    y=y_text - (idx * 24),
                                    font_size=font_size,
                                    width=75)

    @staticmethod
    def clear_window(actr_window):
        actr.clear_exp_window(actr_window)
        # actr.remove_items_from_exp_window(actr_window, item)

    @staticmethod
    def update_sound(sound_type, freq, duration, word):
        if sound_type == "text":
            print(sound_type, word)
            actr.new_word_sound(word)
        else:
            print(freq, duration)
            actr.new_tone_sound(int(freq), int(duration))

    @staticmethod
    def intersection(dict_a, dict_b):
        return [key for key in dict_a if key in dict_b]

    def convert_val(self, value):
        if re.match(r'[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?', value): # re.match(r'^-?\d+(?:\.\d+)$', value):
            return '{:.{prec}f}'.format(float(value), prec=self.nr_of_frac)
        return value

    @staticmethod
    def run_actr(n=10000, real_time=False, run_full_time=False):
        actr.run_full_time(n, real_time) if run_full_time else actr.run(n, real_time)

    @staticmethod
    def actr_running():
        return actr.running()

    @staticmethod
    def stop_actr():
        actr.stop()


    @staticmethod
    # model parameter needed for act-r to understand
    def respond_to_key_press(model, key):
        global response
        print("key pressed", key)
        response_time = actr.get_time(model)
        response = key

class Task_Execution:

    done = response = None

    def __init__(self):
        self.done = False
        self.response = ""

    def specify_task(self):
        actr.add_command("nbt-button-pressed", self.button_pressed, "Choice button action for the n-back task")
        actr.add_command("nbt-key-pressed", self.respond_to_key_press, "Choice button action for the n-back task")
        actr.monitor_command("output-key", "nbt-key-pressed")

    def observe_events(self):
        while not self.done:
            actr.process_events()

    @staticmethod
    def do_experiment():
        print("to be implemented")

    @staticmethod
    def button_pressed(value):
        print("button pressed", value)

    @staticmethod
    # model parameter needed for act-r to understand
    def respond_to_key_press(model, key):
        global response
        print("key pressed", key)
        response = key
