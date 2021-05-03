# -*- coding: utf-8 -*-
"""

@author: thd7as
"""
import math
import re
from sys import platform as _platform
import os


class Cognitive_Model_Constructor:
    show_display_labels = trace_detail = path = actr_model_file = None

    def __init__(self, absolute_path_mc, meta_infos_file, cognitive_model_file, human_interaction, windows_dict=None):

        # self.actr_model_file = actr_file if not human_interaction \
        #    else 'model2act-r;dummy_model.lisp'

        self.absolute_path_mc = absolute_path_mc
        self.meta_infos_file = meta_infos_file
        self.cognitive_model_file = cognitive_model_file
        self.windows_dict = windows_dict
        self.mac_vs_ws = "\\" if _platform.startswith('win') else "/"

        path = absolute_path_mc.replace("/", self.mac_vs_ws)
        path = path + self.mac_vs_ws if not path.endswith(self.mac_vs_ws) else path
        self.path = path

    def cognitive_model_construction(self):

        with open(self.meta_infos_file, 'r') as file_open:

            self.show_display_labels = True if file_open.readline().split(";")[1].startswith('y') else False
            self.trace_detail = file_open.readline().split(";")[1]

            chunk_types_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            chunks_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            dm_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            routine_loop_gdr_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            routine_loop_ddr_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            goal_file = self.path + file_open.readline().split(";")[1].replace("/", self.mac_vs_ws)
            uc_specific_file = "/".join(self.cognitive_model_file.split(self.mac_vs_ws)[:-1]
                                        + [file_open.readline().split(";")[1]])

            file_list_to_be_added = filter(os.path.isfile, [chunk_types_file, chunks_file, dm_file, uc_specific_file,
                                                            routine_loop_gdr_file, routine_loop_ddr_file, goal_file])
            self.files_added_to_cognitive_meta_model(self.cognitive_model_file.replace(";", self.mac_vs_ws),
                                                     file_list_to_be_added)

            default_names_and_values = file_open.readline().split(";")[1]
            default_tuples_list = [tuple(d.split(',')) for d in default_names_and_values.split(":")] \
                if default_names_and_values else []

            default_goal_slots_and_values = file_open.readline().split(";")[1]

            to_be_attended_names = file_open.readline().split(";")[1]
            # included condition d.strip() so that there are no empty elements in list
            to_be_attended_list = [d for d in to_be_attended_names.split(',') if d.strip()]

        # add chunk for each window label
        if os.path.exists(chunks_file):
            with open(chunks_file, 'r+') as file_open:
                file_open.truncate(0)
                file_open.writelines(self.chunks_as_str())

        # add location specifications for each chunk (window label) to declarative memory
        if os.path.exists(dm_file):
            with open(dm_file, 'r+') as file_open:
                file_open.truncate(0)
                file_open.writelines(self.declarative_memory(to_be_attended_list))

        # add goal to model if a goal is specified
        if os.path.exists(goal_file):
            with open(goal_file, 'r+') as file_open:
                file_open.truncate(0)
                content = self.goal_as_str(default_goal_slots_and_values) if default_goal_slots_and_values else ""
                file_open.writelines(content)

        # replace all %name in routine_loop_files and additional model files by default value if they exist
        for file in [routine_loop_gdr_file, routine_loop_ddr_file, uc_specific_file]:
            if os.path.exists(file):
                with open(file, 'r+') as file_open:
                    temp = replaced_text = file_open.read()
                    file_open.truncate(0)
                    for (name, value) in default_tuples_list:
                        replaced_text = re.sub(f'%{name}', value, temp)
                        temp = replaced_text
                    file_open.seek(0)
                    file_open.writelines(replaced_text)

    def files_added_to_cognitive_meta_model(self, cognitive_model_specifications_file, list_of_files):

        with open(cognitive_model_specifications_file, 'r+') as file_open:
            temp = file_open.readlines()
            replaced_text = []
            file_open.truncate(0)
            for line in temp:
                if ';; model-output' in line:
                    line = f'\t:v {self.trace_detail} ;; model-output \n'
                replaced_text.append(line)
            file_open.seek(0)
            file_open.writelines(replaced_text)

        with open(cognitive_model_specifications_file, "r+") as file_open:
            lines = file_open.readlines()
            for idx, line in enumerate(lines):
                if line.startswith(";; --->"):
                    lines = lines[:idx + 1]
                    lines.insert(idx + 1, self.files_to_be_added_as_str(list_of_files) + ")")
                    break
            file_open.truncate(0)
            file_open.seek(0)
            file_open.writelines(lines)

    def files_to_be_added_as_str(self, list_of_files):
        files_stream = ''
        for file in list_of_files:
            # print(file.split(self.mac_vs_ws)[-1]) to get rid of the relative path directory
            file_path_and_name_in_lisp = file.replace(self.mac_vs_ws, '/')
            files_stream += f'(load (merge-pathnames \"{file_path_and_name_in_lisp}\" *load-truename*)) \n'
        return files_stream

    def declarative_memory(self, to_be_attended_list):

        dm_stream = '(add-dm \n  ;; the location specification for each item (label) value \n'

        for window in self.windows_dict.values():
            for label in window.labels_dict:
                display_label = window.labels_dict[label][0]
                dict_idx = list(window.labels_dict.keys()).index(label) - 2
                # 7, because one character is the (horizontal) size of 7 pixels + 4*7 (because of the symbols
                #  ' ', ':', ' ' and the first character of the value). Else if there are no
                # display labels, then just add 7 pixels as this is the minimum size of the value
                extra_l = (len(display_label) * 7 + 4 * 7) if self.show_display_labels else 7
                x_pos = math.floor(window.x_loc + window.x_text + extra_l)
                # 24, because 24 pixels is the (vertical) distance between lines
                y_pos = math.floor(window.y_loc + window.y_text - (dict_idx * 24) + window.font_size / 2)
                display_label_coordinates = f' ({display_label}-info isa display-info info ' \
                                            f'{display_label} screenx {x_pos} screeny {y_pos})'
                dm_stream += display_label_coordinates + ' \n'
            for button in window.buttons_dict.values():
                x_pos = math.floor(window.x_loc + button.x_loc + (button.width / 2))
                y_pos = math.floor(window.y_loc + button.y_loc + (button.height / 2))
                button_label_coordinates = f' ({button.label}-info isa display-info info ' \
                                           f'{button.label} screenx {x_pos} screeny {y_pos})'
                dm_stream += button_label_coordinates + ' \n'

        if to_be_attended_list:
            dm_stream += self.item_list_to_be_attended_in_gdr(to_be_attended_list)

        return dm_stream + ')'

    def chunks_as_str(self):

        chunks_stream = '(define-chunks \n ;; the chunk for each item (label) \n'

        for window in self.windows_dict.values():
            for label in window.labels_dict:
                display_label = window.labels_dict[label][0]
                chunks_stream += f'({display_label}) \n'
            for button in window.buttons_dict.values():
                button_label = button.label
                chunks_stream += f'({button_label}) \n'

        return chunks_stream + ')'

    @staticmethod
    def goal_as_str(default_goal_slots_and_values):

        goal_stream = f'(chunk-type goal {default_goal_slots_and_values}) \n' \
                      '(add-dm (goal isa goal ' + default_goal_slots_and_values + ')) \n ' \
                                                                                  '(goal-focus goal) \n'
        return goal_stream

    @staticmethod
    def item_list_to_be_attended_in_gdr(list_of_items):

        chunnks_list_of_items = ';; the list of items that are to be attended \n'

        for item in list_of_items:
            if len(list_of_items) - 1 == list_of_items.index(item):
                next_item = list_of_items[0]
            else:
                next_item = list_of_items[list_of_items.index(item) + 1]
            chunnks_list_of_items += f'({item}-{list_of_items.index(item)} ' \
                                     f'ISA list-info current-on-list {item} next-on-list {next_item}) \n '

        return chunnks_list_of_items
