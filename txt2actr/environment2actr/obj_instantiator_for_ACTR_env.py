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


class Obj_Instantiator_For_ACTR_Env:

    sounds_dict = windows_dict = window_headers_labels_dict = None

    def __init__(self, sounds_file, images_file, windows_labels_file, buttons_file, windows_specification_file):

        self.sounds_file = sounds_file
        self.images_file = images_file
        self.windows_labels_file = windows_labels_file
        self.buttons_file = buttons_file
        self.windows_specification_file = windows_specification_file

    def instantiate_objects_for_env(self):

        sounds_df = pd.read_csv(self.sounds_file, delimiter=";")
        keys = zip(sounds_df["label"], sounds_df["value"])
        values = [sounds_df["label"], sounds_df["sound value"], sounds_df["duration in milliseconds"],
                  sounds_df["sound type"], sounds_df["word"]]
        self.sounds_dict = Obj_Dict(keys, Sound, *values).obj_dict

        df = pd.read_csv(self.images_file, delimiter=";",
                         dtype={'x start':'int', 'y start':'int',
                                'x end':'int', 'y end':'int'})
        keys = tuple(zip(df['window'], map(str, df['image'])))
        values = [df['image'], df['x start'], df['y start'],
                  df['x end'], df['y end'], df['color'], df['label'], df['appearance']]
        temp_images_dict = Obj_Dict(keys, Image, *values).obj_dict

        # read mapping between labels and how they should be represented in ACTR windows
        windows_labels_df = pd.read_csv(self.windows_labels_file, delimiter=";")
        # lambda x : x is the identity function, mapping x to x
        windows_labels_dict = Obj_Dict(windows_labels_df["key"], lambda x: x, *[windows_labels_df["value"]]).obj_dict

        buttons_df = pd.read_csv(self.buttons_file, delimiter=";")
        keys = tuple(zip(buttons_df['window'], map(str, buttons_df['button'])))
        values = [buttons_df['button'], buttons_df['y position'], buttons_df['x position'],
                  buttons_df['height'], buttons_df['width'], buttons_df['label'], buttons_df['action']]
        temp_buttons_dict = Obj_Dict(keys, Button, *values).obj_dict

        for key, button in temp_buttons_dict.items():
            if str(button.action) == "nan":
                button.action = button.name
            if "," in button.action:
                button.action = eval(button.action)  # converts string into list
                response = button.action[1]
                button.action = [button.action[0], response]

        windows_specification_df = pd.read_csv(self.windows_specification_file, delimiter=";",
                                               dtype={'x position': 'int', 'y position': 'int',
                                                      'width': 'int', 'length': 'int', 'fontsize': 'int',
                                                      'x text position': 'int', 'y text position': 'int'})

        keys = map(str, windows_specification_df["vision"])
        values = [windows_specification_df["vision"], windows_specification_df["y position"],
                  windows_specification_df["x position"], windows_specification_df["width"],
                  windows_specification_df["length"], windows_specification_df["fontsize"],
                  windows_specification_df["x text position"], windows_specification_df["y text position"]]
        self.windows_dict = Obj_Dict(keys, Window, *values).obj_dict

        # defines which windows will show which values from which headers in data file
        values = [str(d).split(",") for d in windows_specification_df["header labels"]]
        self.window_headers_labels_dict = Obj_Dict(windows_specification_df["vision"], lambda x: x, values).obj_dict

        for window in self.windows_dict.values():
            setattr(window, "labels_dict", self.window_labels(windows_labels_dict, window.name))
            setattr(window, "buttons_dict", {b.name: b for k, b in temp_buttons_dict.items() if k[0] == window.name})
            setattr(window, "images_dict", {i.name: i for k, i in temp_images_dict.items() if k[0] == window.name})

    def window_labels(self, mapping, window_name):

        list_of_window_labels = self.window_headers_labels_dict[window_name]
        window_mapping = {key: [value, ""] for key, value in mapping.items()
                          if key in list_of_window_labels}
        return {k: self.replace_nan_val_with_key(k, v) for k, v in window_mapping.items()}

    @staticmethod
    def replace_nan_val_with_key(key, value):
        value[0] = key if str(value[0]) == "nan" else value[0]
        return value


class Obj_Dict:
    def __init__(self, keys, obj, *args):
        self.obj_dict = dict(zip(keys, map(obj, *args)))
