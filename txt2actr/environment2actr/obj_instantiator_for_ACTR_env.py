# -*- coding: utf-8 -*-
"""
Created on Wed Nov  18

@author: thd7as
"""
import pandas as pd

from txt2actr.environment2actr.env_obj.window import Window
from txt2actr.environment2actr.env_obj.button import Button
from txt2actr.environment2actr.env_obj.sound import Sound
from txt2actr.environment2actr.env_obj.image import Image
import ast


class Obj_Instantiator_For_ACTR_Env:

    sounds_dict = images_dict = windows_labels_dict = \
        buttons_dict = windows_dict = window_headers_labels_dict = {}

    def __init__(self, sounds_specs, images_specs, windows_labels_specs, buttons_specs, windows_specs):

        self.sounds_specs = sounds_specs
        self.images_specs = images_specs
        self.windows_labels_specs = windows_labels_specs
        self.buttons_specs = buttons_specs
        self.windows_specs = windows_specs

    def inst_dicts_from_csv(self):

        temp_sounds_df = pd.read_csv(self.sounds_specs, delimiter=";")
        keys = zip(temp_sounds_df["label"], temp_sounds_df["value"])
        values = [temp_sounds_df["label"], temp_sounds_df["sound value"],
                  temp_sounds_df["duration in milliseconds"],
                  temp_sounds_df["sound type"], temp_sounds_df["word"]]
        self.sounds_dict = Obj_Dict(keys, Sound, *values).obj_dict

        temp_images_df = pd.read_csv(self.images_specs, delimiter=";",
                         dtype={'x start':'int', 'y start':'int',
                                'x end':'int', 'y end':'int'})
        keys = tuple(zip(temp_images_df['window'], map(str, temp_images_df['image'])))
        values = [temp_images_df['image'], temp_images_df['x start'],
                  temp_images_df['y start'], temp_images_df['x end'],
                  temp_images_df['y end'], temp_images_df['color'],
                  temp_images_df['label'], temp_images_df['appearance'], temp_images_df['description']]
        self.images_dict = Obj_Dict(keys, Image, *values).obj_dict

       # read mapping between labels and how they should be represented in ACTR windows
        windows_labels_df = pd.read_csv(self.windows_labels_specs, delimiter=";")

        if not windows_labels_df.empty:
            if "x_loc" not in windows_labels_df:
                windows_labels_df["x_loc"] = ""
            if "y_loc" not in windows_labels_df:
                windows_labels_df["y_loc"] = ""
            values = [windows_labels_df["value"], windows_labels_df["x_loc"],
                      windows_labels_df["y_loc"]]
            self.windows_labels_dict = Obj_Dict(windows_labels_df["key"], lambda val, x, y: [val, x, y],*values).obj_dict

        temp_buttons_df = pd.read_csv(self.buttons_specs, delimiter=";")
        keys = tuple(zip(temp_buttons_df['window'], map(str, temp_buttons_df['button'])))
        values = [temp_buttons_df['button'], temp_buttons_df['y position'],
                  temp_buttons_df['x position'], temp_buttons_df['height'],
                  temp_buttons_df['width'], temp_buttons_df['label'], temp_buttons_df['action']]
        self.buttons_dict = Obj_Dict(keys, Button, *values).obj_dict

        temp_windows_df = pd.read_csv(self.windows_specs, delimiter=";",
                                      dtype={'x position': 'int', 'y position': 'int',
                                                      'width': 'int', 'length': 'int', 'fontsize': 'int',
                                                      'x text position': 'int', 'y text position': 'int'})

        keys = map(str, temp_windows_df["vision"])
        values = [temp_windows_df["vision"], temp_windows_df["y position"],
                  temp_windows_df["x position"], temp_windows_df["width"],
                  temp_windows_df["length"], temp_windows_df["fontsize"],
                  temp_windows_df["x text position"], temp_windows_df["y text position"]]
        self.windows_dict = Obj_Dict(keys, Window, *values).obj_dict

        # defines which windows will show which values from which headers in data file
        values = [str(d).split(",") for d in temp_windows_df["header labels"]]
        self.window_headers_labels_dict = Obj_Dict(temp_windows_df["vision"], lambda x: x, values).obj_dict

    def inst_dicts_from_json(self):

        temp_sounds_df = pd.DataFrame(self.sounds_specs)
        if not temp_sounds_df.empty:
            keys = zip(temp_sounds_df["label"], temp_sounds_df["value"])
            values = [temp_sounds_df["label"], temp_sounds_df["sound_value"],
                      temp_sounds_df["duration_in_milliseconds"],
                      temp_sounds_df["sound_type"], temp_sounds_df["word"]]
            self.sounds_dict = Obj_Dict(keys, Sound, *values).obj_dict


        temp_images_df = pd.DataFrame(self.images_specs)
        if not temp_images_df.empty:
            keys = tuple(zip(temp_images_df['window'], map(str, temp_images_df['image'])))
            values = [temp_images_df['image'], temp_images_df['x_start'],
                      temp_images_df['y_start'], temp_images_df['x_end'],
                      temp_images_df['y_end'], temp_images_df['color'],
                      temp_images_df['label'], temp_images_df['appearance'], temp_images_df['description']]
            self.images_dict = Obj_Dict(keys, Image, *values).obj_dict

        # read mapping between labels and how they should be represented in ACTR windows

        windows_labels_df = pd.DataFrame(self.windows_labels_specs)
        if not windows_labels_df.empty:
            if "x_loc" not in windows_labels_df:
                windows_labels_df["x_loc"] = ""
            if "y_loc" not in windows_labels_df:
                windows_labels_df["y_loc"] = ""
            values = [windows_labels_df["value"], windows_labels_df["x_loc"],
                      windows_labels_df["y_loc"]]
            self.windows_labels_dict = Obj_Dict(windows_labels_df["key"], lambda val, x, y: [val,x,y], *values).obj_dict

        temp_buttons_df = pd.DataFrame(self.buttons_specs)
        if not temp_buttons_df.empty:
            keys = tuple(zip(temp_buttons_df['window'], map(str, temp_buttons_df['button'])))
            values = [temp_buttons_df['button'], temp_buttons_df['y_position'],
                      temp_buttons_df['x_position'], temp_buttons_df['height'],
                      temp_buttons_df['width'], temp_buttons_df['label'], temp_buttons_df['action']]
            self.buttons_dict = Obj_Dict(keys, Button, *values).obj_dict

        temp_windows_df = pd.DataFrame(self.windows_specs)
        if not temp_windows_df.empty:
            keys = map(str, temp_windows_df["vision"])
            values = [temp_windows_df["vision"], temp_windows_df["y_position"],
                      temp_windows_df["x_position"], temp_windows_df["width"],
                      temp_windows_df["length"], temp_windows_df["fontsize"],
                      temp_windows_df["x_text_position"], temp_windows_df["y_text_position"]]
            self.windows_dict = Obj_Dict(keys, Window, *values).obj_dict

            # defines which windows will show which values from which headers in data file
            values = [str(d).split(",") for d in temp_windows_df["header_labels"]]
            self.window_headers_labels_dict = Obj_Dict(temp_windows_df["vision"], lambda x: x, values).obj_dict

    def instantiate_objects_for_env(self):

        for key, button in self.buttons_dict.items():
            if str(button.action) == "nan" or str(button.action) == "":
                button.action = button.name
            if "," in button.action:
                button.action = eval(button.action)  # converts string into list
                response = button.action[1]
                button.action = [button.action[0], response]

        for window in self.windows_dict.values():
            setattr(window, "labels_dict", self.window_labels(self.windows_labels_dict, window.name))
            setattr(window, "buttons_dict", {b.name: b for k, b in self.buttons_dict.items() if k[0] == window.name})
            setattr(window, "images_dict", {i.name: i for k, i in self.images_dict.items() if k[0] == window.name})


    def window_labels(self, mapping, window_name):

        list_of_window_labels = self.window_headers_labels_dict[window_name]
        window_mapping = {key: [value, ""] for key, value in mapping.items()
                          if key in list_of_window_labels}
        return {k: self.replace_nan_val_with_key(k, v) for k, v in window_mapping.items()}

    @staticmethod
    def replace_nan_val_with_key(key, value):
        value[0][0] = key if str(value[0][0]) == "nan" or str(value[0][0]) == "" else value[0][0]
        return value

class Obj_Dict:
    def __init__(self, keys, obj, *args):
        self.obj_dict = dict(zip(keys, map(obj, *args)))
