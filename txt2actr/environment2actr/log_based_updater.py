"""
Created on Tue Jul 14 09:36:48 2020
@author: thd7as
"""

# =============================================================================
# This class is all about the data stream and passing the relevant parameters
#  through the ACT-R Environment
# log_file_name is the name of the file that contains the (dynamic) flight log information
# =============================================================================

import sys
from itertools import islice


class Log_Based_Updater:

    headers_list = values_list = None

    def __init__(self, actr_interface, column_separator=",",
                 sampling_rate=100, skip_rate_in_log=5, start_idx=1, col_start_idx=0):

        self.actr_interface = actr_interface
        self.sampling_rate = sampling_rate
        self.skip_rate_in_log = skip_rate_in_log
        self.start_idx = start_idx
        self.column_separator = column_separator
        self.col_start_idx = col_start_idx

    def specify_and_pass(self, log_file_name):

        idx = self.start_idx
        skip_rate_in_log = self.skip_rate_in_log
        sampling_rate = self.sampling_rate

        try:
            with open(log_file_name, 'r') as log_file:
                # read and set header of log file
                line = log_file.readline()
                self.headers_list = line.strip().split(self.column_separator)[0:]
                self.values_list = [""] * len(self.headers_list)
                log_file.readline()
                for line in islice(log_file, idx, None, skip_rate_in_log):
                    # float('{:.{prec}f}'.format(float(idx/sampling_rate), prec=3))
                    schedule_time = int(idx / sampling_rate * 100)
                    self.pass_new_data_to_actr_env(line.strip().split(self.column_separator)[self.col_start_idx:],
                                                   schedule_time)
                    idx += skip_rate_in_log
        except IOError:
            print('IOError: %s' % sys.exc_info()[0])
            log_file.close()
            sys.exit(1)
        except Exception as e:
            print(e)
            print("closing...")

    def pass_new_data_to_actr_env(self, new_values_list, schedule_time):

        dict_of_changes = {self.headers_list[idx]: value for idx, value in
                           enumerate(new_values_list) if self.values_list[idx] != value}

        self.values_list = new_values_list
        if dict_of_changes:
            try:
                self.actr_interface.update_actr_env(dict_of_changes, schedule_time)
            except Exception as e:
                print(e)
