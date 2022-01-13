# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 10:24:10 2020

@author: thd7as
"""

import re
from txt2actr.environment2actr import actr
import io
import math
import numbers
from contextlib import redirect_stdout
import sys
import time
# =============================================================================
# This class is all about setting up the ACT-R Environment, including adding
# goals to the (cognitive) ACT-R Model
# =============================================================================



class ACTR_interface:

    global clear_windows

    # nr_of_frac is the number of digits after comma
    def __init__(self, actr_env, cognitive_model_file, windows_dict, sounds_dict, nr_of_frac,
                 show_display_labels, time_interval_to_new_val_in_msc=1,
                 human_interaction=False, show_env_windows=False, analysis_module=None, py_functions_in_cm={}):

        self.actr_env = actr_env
        self.cognitive_model_file = cognitive_model_file
        self.windows_dict = windows_dict
        self.clear_windows = False

        self.sounds_dict = sounds_dict
        self.nr_of_frac = nr_of_frac
        self.show_display_labels = show_display_labels
        self.time_interval_to_new_val_in_msc = time_interval_to_new_val_in_msc
        self.human_interaction = human_interaction
        self.show_env_windows = show_env_windows
        self.analysis_module = analysis_module
        self.py_functions_in_cm = py_functions_in_cm

        self.actr_window_updater = "update_window_with_labels" if show_display_labels else "update_window"


    def get_actr_instance(self):
        return actr

    def connect_with_actr(self):

        actr.connection() if not actr.current_connection else actr.reset()
        self.add_actr_commands()

        #a= actr("act-r.vlab.eu.airbus.corp", 2650)
        #print(actr)
        #actr.start("act-r.vlab.eu.airbus.corp", 2650)
        # get rid of any non-alphanumeric characters at the beginning of path to file string
        start_idx = re.search("[^\W\d]", self.cognitive_model_file).start()
        # if the actr_env started from a docker, we need to load the model from the tutorial path
        if self.actr_env.startswith('d'):
            rel_path_to_file = self.cognitive_model_file.partition('use-cases')[2]
            #print("rel_path_to_file", rel_path_to_file)
            actr.load_act_r_code(f'/home/actr/actr7.x/tutorial{rel_path_to_file}')
        else:
            # for local act-r it seems that ';' is necessary as path seperator
            self.cognitive_model_file = self.cognitive_model_file[start_idx:].replace("/",";").replace("\\", ";")
            if self.human_interaction:
                actr.load_act_r_code("dummy_model.lisp")
            else:
                actr.load_act_r_code(self.cognitive_model_file)

        actr.add_word_characters(".")
        actr.add_word_characters("_")
        actr.add_word_characters("-")

    def add_actr_commands(self):

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
        actr.add_command("update_line", self.update_line, "updates line")

        if self.analysis_module:
            for function_name, description in self.py_functions_in_cm.items():
                actr.add_command(function_name, getattr(self.analysis_module, function_name), description)

    def reload_actr_code(self, compile=False):
        # actr.load_act_r_code(self.cognitive_model_file)
        actr.reload(compile)

    def set_actr_windows(self):

        for window in self.windows_dict.values():

            actr_window = actr.open_exp_window(window.name, visible=self.show_env_windows, width=window.width,
                                               height=window.length, x=window.x_loc, y=window.y_loc)
            window.actr_window = actr_window
            for i in window.images_dict.values():
                if i.label == "line":
                    actr.add_line_to_exp_window(actr_window, [i.x_loc,i.y_loc],
                                                [i.x_end, i.y_end], "black")
                else:
                    actr.add_image_to_exp_window(actr_window, i.name, i.color, i.x_loc, i.y_loc, i.x_end, i.y_end)

            window_labels_as_string = ", ".join(value for (_, [[value, x, y],_]) in window.labels_dict.items())
            actr.add_text_to_exp_window(actr_window, window_labels_as_string, x=window.x_text,
                                        y=window.y_text, font_size=window.font_size, color="black")
            for b in window.buttons_dict.values():
                actr.add_button_to_exp_window(actr_window, text=b.label, x=b.x_loc, y=b.y_loc, action=b.action,
                                              height=b.height, width=b.width, color=b.label)
            actr.install_device(actr_window)  # Install window

        #actr.install_device(["vision", "cursor"])
        #actr.install_device(["motor", "mouse"])

    def update_actr_env(self, changes_dict, schedule_time=None):

        for window in self.windows_dict.values():
            relevant_list = self.intersection(window.labels_dict, changes_dict)
            if relevant_list:
                clear_time = schedule_time - self.time_interval_to_new_val_in_msc \
                if schedule_time else schedule_time
                self.schedule_event(clear_time, "clear_window", params=[window.actr_window])
                window_labels_dict = window.labels_dict
                window_labels_dict.update((label, [window_labels_dict[label][0],
                                                   changes_dict[label]]) for label in relevant_list)
                for b in window.buttons_dict.values():
                    self.schedule_event(schedule_time, "update_button", params=[window.actr_window, b.label,
                                        b.x_loc, b.y_loc, b.action, b.height, b.width], time_in_ms=True)
                for i in window.images_dict.values():
                    if i.label == "line":
                        self.schedule_event(schedule_time, "update_image",
                                            params=[window.actr_window, i.name,
                                                    i.description[0], 0, 0, 200, 200],
                                            time_in_ms = True)
                        try:
                            roll = float(window_labels_dict[i.description[1]][1])
                            pitch = float(window_labels_dict[i.description[2]][1])
                        except Exception as e:
                            print("EXCEPTION", e)
                            print("dict", list(window_labels_dict.items()))
                        # x_start, y_shift, x_end
                        x_start, y_start, x_end, y_end = self.horizon(roll, pitch, i.x_loc, i.y_loc, i.x_end)
                        actr.add_line_to_exp_window(window.actr_window, [x_start, y_start], [x_end, y_end], i.color)
                        self.schedule_event(schedule_time, "update_line",
                                            params=[window.actr_window,
                                        [x_start, y_start], [x_end, y_end], i.color], time_in_ms=True)
                    if i.label == "pic":
                        self.schedule_event(schedule_time, "update_image",
                                            params=[window.actr_window, i.name, i.color, i.x_loc,
                                            i.y_loc, i.x_end, i.y_end])
                for index, (_, [[label, x, y], value]) in enumerate(window_labels_dict.items(), start=-2):
                    if str(x) == "nan" or str(x) == "":
                        x = window.x_text
                        y = window.y_text - (index * 24)
                    new_value = self.convert_val(value)
                    display_label = label
                    self.schedule_event(schedule_time, self.actr_window_updater,
                                        params=[window.actr_window, display_label, new_value,
                                        x, y, window.font_size], time_in_ms=True)
        # trying to find an efficient way to record changes in sounds
        new_tone_sounds = filter(lambda new: str(changes_dict.get(new[0])) == str(new[1]), self.sounds_dict)
        if new_tone_sounds:
            for key in new_tone_sounds:
                freq = self.sounds_dict[key].value
                duration = self.sounds_dict[key].duration
                sound_type = self.sounds_dict[key].sound_type
                word = self.sounds_dict[key].word
                print(schedule_time, freq, duration, sound_type, word)
                self.schedule_event(schedule_time, "update_sound",
                                    params=[sound_type, freq, duration, word], time_in_ms=True)
        self.clear_windows = True

    def schedule_event(self, schedule_time, function, params, time_in_ms=True):
        if schedule_time == None and actr.mp_queue_count() < 50:
            #actr.schedule_event_now("clear_window", params=[params[0]])
            #time.sleep(0.1)
            actr.schedule_event_now(function, params)
        elif schedule_time is not None:
            if function == "clear_window":
                actr.schedule_event_relative(schedule_time, function, params, time_in_ms=time_in_ms)
            elif actr.mp_queue_count() < 50:
                actr.schedule_event_relative(schedule_time, function, params, time_in_ms=time_in_ms)

    def horizon(self, roll, pitch, x_start=10, y_shift=50, x_end=200):

        f = -2.5 # px*180grad/ pi*rad, 1grad entspricht f pixel
        y_d = f*pitch
        #y_shift = y_shift if pitch < 0 else y_shift*-1
        ges = math.tan((roll*math.pi)/180)*200

        # x_start, y_start, x_end, y_end
        # as in old russian aircrafts
        #x_start, round(y_d + ges) + y_shift, x_end, round(y_d - ges) + y_shift
        # as in nowadays aicrafts
        return x_start, round(y_d+ges)+y_shift, x_end, round(y_d-ges)+y_shift

    def compute_value_from_string_eq(self, eq, dict):
        s = eq.find("$") + len("$")
        e = eq.rfind("$")
        var = eq[s:e]
        val = dict[var][1]
        eq = eq[:s - 1] + val + eq[e + 1:]
        try:
            return eval(eq)
        except Exception as e:
            print(e)

    @staticmethod
    def update_button(actr_window, label, x_loc, y_loc, action, height, width):
        actr.add_button_to_exp_window(actr_window, text=label, x=x_loc, y=y_loc, action=action, height=height,
                                      width=width, color='gray')


    @staticmethod
    def update_line(actr_window, start, end, color):
        actr.add_line_to_exp_window(actr_window, start, end, color)

    @staticmethod
    def update_image(actr_window, name, color, x_loc, y_loc, width, height):
        actr.add_image_to_exp_window(actr_window, name, color, x_loc, y_loc, width, height)

    @staticmethod
    def update_window(actr_window, display_label, new_value, x_text, y_text, font_size):
        actr.add_text_to_exp_window(actr_window,
                                    text=new_value,
                                    color=display_label, x=x_text,
                                    y=y_text,
                                    font_size=font_size, width=75)

    @staticmethod
    def update_window_with_labels(actr_window, display_label, new_value, x_text, y_text, font_size):
        actr.add_text_to_exp_window(actr_window,
                                    text=f'{display_label}: {new_value}',
                                    color=display_label,
                                    x=x_text,
                                    y=y_text,
                                    font_size=font_size,
                                    width=75)

    @staticmethod
    def clear_window(actr_window):
        actr.clear_exp_window(actr_window)
        # actr.remove_items_from_exp_window(actr_window, item)

    @staticmethod
    def update_sound(sound_type, freq, duration, word):
        if sound_type == "text":
            actr.new_word_sound(word)
        else:
            actr.new_tone_sound(int(freq), int(duration))

    @staticmethod
    def intersection(dict_a, dict_b):
        return [key for key in dict_a if key in dict_b]

    def convert_val(self, value):
        # test if value can be converted to float
        if isinstance(value, float) or re.match(r'^[-+]?(?:\b[0-9]+(?:\.[0-9]*)?|\.[0-9]+\b)(?:[eE][-+]?[0-9]+\b)?$', value): #re.match(r'[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?', value): # re.match(r'^-?\d+(?:\.\d+)$', value):
                return '{:.{prec}f}'.format(float(value), prec=self.nr_of_frac)

        return value

    @staticmethod
    def run_actr(n=100000, real_time=False, run_full_time=False):
        actr.run_full_time(n, real_time) if run_full_time else actr.run(n, real_time)

    def get_dm(self, ):

        f = io.StringIO()
        with redirect_stdout(f):
            for chunk in actr.sdm("-", "eventname", "nil"):
                actr.dm(chunk)
            return f.getvalue()

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
    def button_pressed(self, value):
        print("button pressed", value)

    @staticmethod
    # model parameter needed for act-r to understand
    def respond_to_key_press(model, key):
        global response
        print("key pressed", key)
        response = key