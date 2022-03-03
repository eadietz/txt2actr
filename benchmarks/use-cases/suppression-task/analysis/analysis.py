
import pathlib

import pandas as pd


class Analysis:

    def __init__(self, path):

        # is the following line really necessary?
        pathlib.Path(path).mkdir(parents=True, exist_ok=True)
        self.path = path
        self.sep = ";"
        self.results_df = None
        self.content_df = None

    # called by the cognitive model in act-r

    def add_content(self, content):
        self.write_new_data_to_df(self.content_df, content)

    def write_new_data_to_df(self, df, content):
        new_row = {'Fact': content[0], 'Interpretation': content[1], "Position": content[2],
                   "Counter": content[3], "Strongest": content[4]}
        self.content_df = self.content_df.append(new_row, ignore_index=True)

    def reset(self, log_file=None):
        # write back old data to file before reseting variables
        if self.content_df is not None:
            self.content_df.to_csv(self.path + self.content_file, mode=self.write_mode, index=False, sep=self.sep)

        if log_file:
            self.log_file = log_file
            self.write_mode = "w"

            content_cols = ["Fact", "Context", "Argument", "Counter", "Strongest"]
            self.content_df = pd.DataFrame(columns=content_cols)
            self.content_file = "detailed_results.csv"

    def add_result(self, content):
        print(content)