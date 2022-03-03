# -*- coding: utf-8 -*-
"""

@author: thd7as
"""
import ast
import math
import os
from sys import platform as _platform

chunk_type_display = {'chunk-type': 'display-info', 'slots': ['name', 'screen-x', 'screen-y']}
chunk_type_button = {'chunk-type': 'button-info', 'slots': ['name', 'screen-x', 'screen-y']}
chunk_type_image = {'chunk-type': 'image-info', 'slots': ['name', 'screen-x', 'screen-y']}
chunk_type_sound = {'chunk-type': 'sound-info', 'slots': ['name']}

class Cognitive_Model_Assembler:

    show_display_labels = trace_detail = path_mc = actr_model_file = None

    def __init__(self, absolute_path_uc, absolute_path_mc, cognitive_model_file, show_display_labels,
                 windows_dict=None, sounds_dict=None):

        self.cognitive_model_file = cognitive_model_file
        self.show_display_labels = show_display_labels
        self.windows_dict = windows_dict
        self.sounds_dict = sounds_dict
        self.mac_vs_ws = "\\" if _platform.startswith('win') else "/"

        self.path_mc = self.set_path(absolute_path_mc)
        self.path_uc = self.set_path(absolute_path_uc)

        # set default values
        self.chunk_types_file = self.path_mc + "chunk-types.lisp"
        self.def_val_in_imaginal_file = self.path_mc + "default-values-in-imaginal.lisp"
        self.gdr_file = self.path_mc + "goal-driven-with-coordinates.lisp"
        self.ddr_file = self.path_mc + "data-driven.lisp"

    def set_path(self, path):
        path = path.replace("/", self.mac_vs_ws)
        return path + self.mac_vs_ws if not path.endswith(self.mac_vs_ws) else path


    def specify_components_from_json(self, cm_config_df):

        self.cm_name = cm_config_df["cognitive_model_name"]
        self.model_params_dict = cm_config_df["model_params_dict"]
        self.default_val_dict = cm_config_df["default_val_dict"]
        self.include_chunk_types = cm_config_df["include_chunk_types"]
        self.include_chunks = cm_config_df["include_chunks"]
        self.include_instantiated_chunks = cm_config_df["include_instantiated_chunks"]
        self.to_be_attended_in_routine = cm_config_df["to_be_attended_names"]
        self.default_goal_slots_and_values = cm_config_df["default_goal_slots_and_values"]
        self.uc_specific_list_of_files = cm_config_df["uc_specific_list_of_files"]

        self.temp_gdr_file = cm_config_df["gdr_file"]
        self.temp_ddr_file = cm_config_df["ddr_file"]

    def specify_components_from_csv(self, cognitive_model_specifications_file):

        with open(cognitive_model_specifications_file, 'r') as file_open:

            self.cm_name = file_open.readline().split(";")[1]

            self.model_params_dict = ast.literal_eval(file_open.readline().split(";")[1])
            default_val = file_open.readline().split(";")[1]

            try:
                self.default_val_dict = ast.literal_eval(default_val)
            except Exception as e:
                self.default_val_dict = {}

            self.include_chunk_types = True if file_open.readline().split(";")[1].startswith('y') else False
            self.include_chunks = True if file_open.readline().split(";")[1].startswith('y') else False
            self.include_instantiated_chunks = True if file_open.readline().split(";")[1].startswith('y') else False

            to_be_attended_names = file_open.readline().split(";")[1]

            # included condition d.strip() so that there are no empty elements in list
            self.to_be_attended_in_routine = [d for d in to_be_attended_names.split(',') if d.strip()]

            default_goal = file_open.readline().split(";")[1]
            self.default_goal_slots_and_values = "" if default_goal.startswith("n") else default_goal

            self.uc_specific_list_of_files = ast.literal_eval(file_open.readline().split(";")[1])

            self.temp_gdr_file = file_open.readline().split(";")[1]
            self.temp_ddr_file = file_open.readline().split(";")[1]

    def assemble_components(self):

        self.gdr_file = self.path_mc + self.temp_gdr_file if os.path.isfile(self.path_mc + self.temp_gdr_file) else ""
        self.ddr_file = self.path_mc + self.temp_ddr_file if os.path.isfile(self.path_mc + self.temp_ddr_file) else ""

        uc_specific = ""
        for file_name in self.uc_specific_list_of_files:
            file = self.path_uc + file_name
            uc_specific += self.file_as_str(file) if os.path.exists(file) else ""

        first_item_to_be_attend = f'\n(set-buffer-chunk \'retrieval \'{self.to_be_attended_in_routine[0]}-info) \n' \
            if self.to_be_attended_in_routine else ""

        chunk_types = self.chunk_types_as_str() if self.include_chunk_types else ""
        chunks = self.chunks_as_str() if self.include_chunks else ""
        dm = self.instantiated_chunks_as_str(self.to_be_attended_in_routine) if self.include_instantiated_chunks else ""
        gdr = first_item_to_be_attend + "\n" + self.file_as_str(self.gdr_file) if self.gdr_file else ""
        ddr = self.file_as_str(self.ddr_file) if self.ddr_file else ""
        goal = self.goal_as_str(self.default_goal_slots_and_values) if self.default_goal_slots_and_values else ""

        self.set_cognitive_model_params(self.model_params_dict)
        production_rule_default_val = self.set_def_values_in_imaginal(self.default_val_dict) if self.default_val_dict else ""

        self.construct_cognitive_model(self.cm_name, "\n\n" + chunk_types + chunks + goal + dm +
                                       production_rule_default_val + gdr + ddr + uc_specific)

    @staticmethod
    def goal_as_str(default_goal_slots_and_values):

        goal_stream = f'(add-dm (starting-goal isa goal ' + default_goal_slots_and_values + ')) \n ' \
                                                                                  '(goal-focus starting-goal) \n'

        return goal_stream + "\n\n"

    def file_as_str(self, file):

        stream = ""

        with open(file, 'r+') as file_open:
            stream += " ".join(map(str, file_open.readlines()))

        return stream + "\n\n"

    def set_def_values_in_imaginal(self, default_val_dict):

        def_val = self.convert_dict_as_slot_structure(default_val_dict)

        return self.replace_var_by_instantiated_val(self.def_val_in_imaginal_file, "DICT_OF_TEMP_VAL", def_val) + "\n\n"

    def convert_dict_as_slot_structure(self, dict):

        slot_str = ""
        for key, val in dict.items():
            slot_str += f'\t  {key} \t {val} \n'

        return slot_str

    @staticmethod
    def replace_var_by_instantiated_val(file, var, instantiated_val):

        replaced_text = ""

        with open(file, 'r+') as file_open:
            temp = file_open.readlines()
            for line in temp:
                if var in line:
                    line = instantiated_val
                replaced_text += line

        return replaced_text


    def set_cognitive_model_params(self, model_params):

        with open(self.cognitive_model_file, 'r+') as file_open:
            temp = file_open.readlines()
            replaced_text = []
            file_open.truncate(0)
            for line in temp:
                for key, val in model_params.items():
                    if key in line:
                        val_as_string = " ".join(map(str, val))
                        line = f'   :{val_as_string} ;; {key} \n'
                replaced_text.append(line)
            file_open.seek(0)
            file_open.writelines(replaced_text)

    def construct_cognitive_model(self, cm_name, string_stream):

        with open(self.cognitive_model_file, "r+") as file_open:
            lines = file_open.readlines()
            for idx, line in enumerate(lines):
                if line.startswith("(define-model"):
                    lines[idx] = f"(define-model {cm_name}\n"
                if line.startswith(";; --->"):
                    lines = lines[:idx + 1]
                    lines.insert(idx + 1, string_stream + "\n\n )")
                    break
            file_open.truncate(0)
            file_open.seek(0)
            file_open.writelines(lines)

    def chunk_types_as_str(self):
        chunk_types_stream = ';; Define the chunk types for the chunks \n'

        with open(self.chunk_types_file, 'r+') as file_open:
            lines = file_open.readlines()
            for line in lines:
                chunk_type_dict = ast.literal_eval(line)
                chunk_type = chunk_type_dict['chunk-type']
                slots = " ".join(map(str, chunk_type_dict['slots']))
                chunk_types_stream += f'(chunk-type {chunk_type} {slots}) \n'
                self.test_if_default_chunk_type(chunk_type_dict)

        return chunk_types_stream + "\n\n"

    def test_if_default_chunk_type(self, chunk_type_dict):

        chunk_type = chunk_type_dict['chunk-type']

        if chunk_type == "display-info":
            self.chunk_type_display = chunk_type_dict
        elif chunk_type == "button-info":
            self.chunk_type_button = chunk_type_dict
        elif chunk_type == "image-info":
            self.chunk_type_image = chunk_type_dict
        elif chunk_type == "sound-info":
            self.chunk_type_sound = chunk_type_dict

    def chunks_as_str(self):
        chunks_stream = '(define-chunks ;; define the chunk for each item (label)' + ' \n'

        for window in self.windows_dict.values():
            for label in window.labels_dict:
                display_label = window.labels_dict[label][0][0]
                chunks_stream += f'({display_label}) \n'
            for image in window.images_dict.values():
                image_name = image.name
                chunks_stream += f'({image_name}) \n'
            for button in window.buttons_dict.values():
                button_name = button.name
                chunks_stream += f'({button_name}) \n'

        for sound in self.sounds_dict.values():
            sound_label = sound.label
            chunks_stream += f'({sound_label}) \n' if sound_label not in chunks_stream else ""

        return chunks_stream + ")"  + "\n\n"

    def instantiated_chunks_as_str(self, to_be_attended_list):

        dm_stream = '(add-dm ;; the location specification for each item (label) value' + ' \n'

        # window refers to the act-r window and display_name refers to the individual values that are shown in that window
        for window in self.windows_dict.values():
            for label in window.labels_dict:
                label_info = window.labels_dict[label][0]
                display_name = label_info[0]
                x_loc = float(window.x_text) if label_info[1]=="" else float(label_info[1])
                y_loc = float(window.y_text) if label_info[2]=="" else float(label_info[2])
                dict_idx = list(window.labels_dict.keys()).index(label) - 2
                # 7, because one character is the (horizontal) size of 7 pixels + 4*7 (because of the symbols
                #  ' ', ':', ' ' and the first character of the value). Else if there are no
                # display labels, then just add 7 pixels as this is the minimum size of the value
                #  + 3 * 7 + 1
                extra_l = (len(display_name) * 7) if self.show_display_labels else 7
                x_pos = float(window.x_loc + extra_l) #+ x_loc
                # 24, because 24 pixels is the (vertical) distance between lines #
                y_pos = float(window.y_loc - (dict_idx * 24) + window.font_size / 2) + y_loc
                slot = self.chunk_type_display['slots']
                display_label_coordinates = f' ({display_name}-info isa display-info {slot[0]} ' \
                                            f'{display_name} {slot[1]} {x_pos} {slot[2]} {y_pos})'
                dm_stream += display_label_coordinates + ' \n'
            for button in window.buttons_dict.values():
                x_pos = float(window.x_loc + button.x_loc + (button.width / 2))
                y_pos = float(window.y_loc + button.y_loc + (button.height / 2))
                slot = self.chunk_type_button['slots']
                button_label_coordinates = f' ({button.name}-info isa button-info {slot[0]} ' \
                                           f'{button.name} {slot[1]} {x_pos} {slot[2]} {y_pos})'
                dm_stream += button_label_coordinates + ' \n'
            for image in window.images_dict.values():
                x_pos = math.floor(window.x_loc + image.x_loc + (image.width / 2))
                y_pos = math.floor(window.y_loc + image.y_loc + (image.height / 2))
                slot = self.chunk_type_image['slots']
                image_label_coordinates = f' ({image.name}-info isa image-info {slot[0]} ' \
                                          f'{image.name} {slot[1]} {x_pos} {slot[2]} {y_pos})'
                dm_stream += image_label_coordinates + ' \n'

        if to_be_attended_list:
            dm_stream += self.item_list_to_be_attended_in_gdr(to_be_attended_list) + "\n"

        return dm_stream + ')' + "\n\n"

    @staticmethod
    def item_list_to_be_attended_in_gdr(list_of_items):

        chunks_list_of_items = ';; the list of items that are to be attended in a routine loop \n'
        for item in list_of_items:
            if len(list_of_items) - 1 == list_of_items.index(item):
                next_item = list_of_items[0]
            else:
                next_item = list_of_items[list_of_items.index(item) + 1]
            chunks_list_of_items += f'({item}-{list_of_items.index(item)} ' \
                                     f'ISA list-info current-on-list {item} next-on-list {next_item}) \n '

        return chunks_list_of_items #+ f'\n(set-buffer-chunk \'retrieval \'{first_item})'
