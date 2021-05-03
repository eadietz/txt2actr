# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 08:21:21 2020

@author: thd7as
"""


class Window:
    
    def __init__(self, name, y_loc, x_loc, width, length, font_size, x_text, y_text, buttons_dict=None,
                 images_dict=None, labels_dict=None, actr_window=None, dynamic_items_list=None):

        self.name = name
        self.labels_dict = labels_dict
        self.y_loc = y_loc
        self.x_loc = x_loc
        self.width = width
        self.length = length
        self.font_size = font_size
        self.x_text = x_text
        self.y_text = y_text
        self.buttons_dict = buttons_dict
        self.images_dict = images_dict
        self.actr_window = actr_window
        self.dynamic_items_list = dynamic_items_list
