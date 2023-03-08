import json
import numbers
import time

import numpy as np
import pandas as pd


class Analysis:

    def __init__(self, path):

        self.rmse_collector = 0
        self.flag = True
        self.current_state = None
        self.path = path
        self.sep = ";"
        self.compared_df = pd.DataFrame()
        self.idx = 0

    # called by the cognitive model in act-r to compute similarity between two numbers
    def numberSimilarities(self, a, b):
        if isinstance(b, numbers.Number) and isinstance(a, numbers.Number):
            # similarity based on euclidean distance
            return 1 / (1 + np.sqrt(pow((a - b), 2)))
        else:
            return False

    def print_read_data(self, label_and_value):
        print("the cognitive model reads", label_and_value)

    # write results into file
    def reset(self, log_file=None):
        # write back old data to file before reseting variables
        if not self.compared_df.empty:
            print("write to csv")
            self.compared_df.to_csv(self.path + self.results_file, mode=self.write_mode, index=False, sep=self.sep)

        if log_file:
            self.log_file = log_file
            self.write_mode = "w"
            self.results_file = self.log_file[:-4] + "_results.csv"