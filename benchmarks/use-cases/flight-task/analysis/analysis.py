import pathlib
import pandas as pd
import re
import math
import numbers
from txt2actr.environment2actr import actr
import os
import io
import numpy as np
from contextlib import redirect_stdout
from ast import literal_eval
from sklearn.metrics import mean_squared_error
from math import sqrt



class Analysis:


    def __init__(self, path):

        self.rmse_collector = 0
        self.flag = True
        self.current_state = None
        self.path = path
        self.sep = ";"
        self.compared_df = pd.DataFrame()
        self.idx = 0
        self.false_stick_input = 0
        self.false_other_val = 0
        self.features = [] # "PTCH", "ROLL", "ALT", "CAS", "LONG", "LATG", "VRTG"
        self.mental_model_dict = {}
        self.dist = {'LOWEST': -6, 'LOWER': -3, 'LOW': -1, 'NEUTRAL-LOW': -0.5,
             'NEUTRAL': 0, 'NEUTRAL-HIGH': 0.5, 'HIGH': 1, 'HIGHER': 3,
             'HIGHEST': 6, 'nil': 0}
    # called by the cognitive model in act-r to compute similarity between two numbers

    def get_next_val(self):
        self.flag = False

    def numberSimilarities(self, a, b):
        if isinstance(b, numbers.Number) and isinstance(a, numbers.Number):
            # similarity based on euclidean distance
            return 1/ (1 + np.sqrt(pow((a-b),2)) )
        else:
            return False

    def pass_data_to_sim(self, value):
        print(value)

    # called by the cognitive model in act-r
    def add_result(self, results):
        if self.compared_df.empty:
            self.set_df()
        self.write_new_data_to_df(self.compared_df, results, self.results_file)

    def write_new_data_to_df(self, df, content, file_name):
        df.loc[df.shape[0] + 1] = content

    def reset(self, log_file=None):
        # write back old data to file before reseting variables
        if not self.compared_df.empty:
            print(f"total predictions:{self.idx}, "
                  f"false stick input predictions:{self.false_stick_input}, "
                  f"percentage of false stick input predictions:{self.false_stick_input/self.idx}, "
                  f"false other input predictions:{self.false_other_val}",
                  f"rmse value: {self.rmse_collector/self.idx}")
            self.compared_df.to_csv(self.path + self.results_file, mode=self.write_mode, index=False, sep=self.sep)

        if self.mental_model_dict:
            for key, value in self.mental_model_dict.items():
                print(key, value)

            print("length of dict", len(self.mental_model_dict.keys()))

        if log_file:

            self.log_file = log_file
            self.write_mode = "w"
            self.results_file = self.log_file[:-4] + "_results.csv"


    def set_df(self):

        features_pred = [f'PRED {feature}' for feature in self.features]

        features_cols = [item for tuple in list(zip(self.features, features_pred)) for item in tuple]
        columns = ["TIME"] + features_cols

        self.compared_df = pd.DataFrame(columns=columns)
