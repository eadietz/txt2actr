# =============================================================================
# This file is an adaptation of the file paired.py in the 
# ACT-R tutorial in the folder ACT-R/tutorial/python
# that can be downloaded here http://act-r.psy.cmu.edu/software/
# =============================================================================

import sys
import itertools
import time
import numpy as np
import os
import pandas as pd
import csv
import matplotlib.pyplot as plt
import seaborn as sns

class Task_Based_Updater:

    headers_list = values_list = None

    response = False
    response_time = False
    schedule_time = 3

    fact_set = ["essay", "not_essay", "library", "not_library"]

    def __init__(self, absolute_path_uc=None, analysis_class=None, actr_interface=None, column_separator=";", sampling_rate=100,
                 skip_rate_in_log=1, row_start_idx=1, col_start_idx=0, start_time=0,
                 results_file=None, nr_of_decimals_in_values=2, plot_results=None):

            if plot_results:
                self.plot_results()
            else:
                self.absolute_path_uc = absolute_path_uc
                self.actr_interface = actr_interface
                self.actr = self.actr_interface.get_actr_instance()
                print("actr instance", self.actr)
                self.actr.add_command("library-button",self.library_button,
                                 "suppression task key press response monitor")
                self.actr.monitor_command("output-key","library-button")
                self.actr.start_hand_at_mouse()

                # self.results_df = pd.DataFrame(columns=["Context", "Fact", "Response"])


    def specify_and_pass(self, log_file_name=""):
        for i in range(10):
            #self.exp("simple", 'If_essay_then_library', '----------')
            #self.exp("alternative", 'If_essay_then_library', 'If_textbook_then_library')
            self.exp("additional", 'If_essay_then_library', 'If_open_then_library')

        #self.results_df.to_csv(self.absolute_path_uc + "suppression-task/task/responses.csv", mode="w", index=False, sep=";")
        #self.plot_table()

    def exp(self, context, f_sentence, s_sentence):

        global response

        list_of_facts = self.fact_set

        for index, fact in enumerate(list_of_facts):
            self.actr.start_hand_at_mouse()
            self.actr.goal_focus("starting-goal")

            response = ''

            self.actr_interface.update_actr_env({'f-sentence': f_sentence,
                                                's-sentence': s_sentence,
                                                'fact': fact}, None)

            while response == '':
                self.actr.process_events()

            new_row = {'Context': context, 'Fact': fact, "Response": response}
            self.results_df = self.results_df.append(new_row, ignore_index=True)


    def plot_table(self):

        df_set = []

        for item in self.fact_set:
            df = self.results_df[self.results_df['Fact'] == item]
            df_set.append(df)

        idx = 0
        for df in df_set: #, not_essay_df, library_df, not_library_df]:
            g = df.groupby('Context')['Response']
            df = pd.concat([g.value_counts(), g.value_counts(normalize=True).mul(100)],
                                    axis=1, keys=('counts','percentage'))
            print(self.fact_set[idx])
            idx += 1
            print(df)
        #self.plot_results(self.results_df)

    #@staticmethod
    def respond_to_key_press(self, model, key):

        global response, response_time
        response_time = self.actr.get_time(model)
        response = key
        print

    @staticmethod
    def library_button(value):
        global response
        response = value
