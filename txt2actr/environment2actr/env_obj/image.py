# -*- coding: utf-8 -*-
"""
Created on Tue Sep  8 08:21:21 2020
@author: thd7as
"""

import pandas as pd

class Image():

    def __init__(self, name, x_loc, y_loc, x_end, y_end, color='black', label=None, appearance=True, description=[]):
        self.name = name
        self.x_loc = x_loc  # the x and y coordinates where the image starts
        self.y_loc = y_loc
        self.x_end = x_end
        self.y_end = y_end
        self.color = color
        self.appearance = appearance
        self.description = description

        self.width = x_end
        self.height = y_end
        self.label = name if pd.isnull(label) else label
