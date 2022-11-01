# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 09:54:53 2020

@author: thd7as
"""

import pandas as pd


class Button:
    
    def __init__(self, name, y_loc, x_loc, height, width, label, action=None):
        
        self.name = name
        self.y_loc = y_loc
        self.x_loc = x_loc
        self.height = height
        self.width = width
        self.action = action
        
        self.label = name if pd.isnull(label) else label
