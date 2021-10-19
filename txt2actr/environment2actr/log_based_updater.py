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

    global values_list
    global headers_list

    def __init__(self, actr_interface, column_separator=",",
                 sampling_rate=100, skip_rate_in_log=5, row_start_idx=1,
                 col_start_idx=0, start_time=0):

        self.actr_interface = actr_interface
        self.column_separator = column_separator
        self.sampling_rate = sampling_rate
        self.skip_rate_in_log = skip_rate_in_log
        self.row_start_idx = row_start_idx
        self.col_start_idx = col_start_idx
        self.start_time = start_time

    def specify_and_pass(self, log_file_name):

        global values_list
        global headers_list

        sampling_rate = self.sampling_rate
        skip_rate_in_log = self.skip_rate_in_log
        row_start_idx = self.row_start_idx
        col_start_idx = self.col_start_idx
        start_time = self.start_time

        try:
            with open(log_file_name, 'r') as log_file:
                # read and set header of log file
                line = log_file.readline()
                headers_list = line.strip().split(self.column_separator)[0:]
                values_list = [""] * len(headers_list)
                schedule_time = start_time
                # this can surely be made nicer...
                for i in range(row_start_idx):
                    line = log_file.readline()
                # schedule first event
                self.pass_first_data_to_actr_env(line.strip().split(self.column_separator)[col_start_idx:],
                                                 schedule_time)
                for line in islice(log_file, row_start_idx, None, skip_rate_in_log):
                    # float('{:.{prec}f}'.format(float(idx/sampling_rate), prec=3))
                    schedule_time = start_time + int(row_start_idx / sampling_rate * 1000)
                    self.pass_new_data_to_actr_env(line.strip().split(self.column_separator)[col_start_idx:],
                                                   schedule_time)
                    row_start_idx += skip_rate_in_log
        except IOError:
            print('IOError: %s' % sys.exc_info()[0])
            log_file.close()
            sys.exit(1)
        except Exception as e:
            print(e)
            print("closing...")


    def pass_new_data_to_actr_env(self, new_values_list, schedule_time):

        global values_list
        global headers_list

        dict_of_changes = {headers_list[idx]: value for idx, value in
                           enumerate(new_values_list) if values_list[idx] != value}

        values_list = new_values_list

        if dict_of_changes:
            try:
                self.actr_interface.update_actr_env(dict_of_changes, schedule_time)
            except Exception as e:
                print(e)

    def pass_first_data_to_actr_env(self, new_values_list, schedule_time):

        global values_list
        global headers_list

        dict_of_changes = {headers_list[idx]: self.set_mod_value(headers_list[idx], value)
                           for idx, value in enumerate(new_values_list) if values_list[idx] != value}

        values_list = new_values_list
        if dict_of_changes:
            try:
                self.actr_interface.first_update_actr_env(dict_of_changes, schedule_time)
            except Exception as e:
                print(e)

    def set_mod_value(self, name, value):
        if (name == "ASU") and (value != ""):
            if float(value) > 1.5:
                return "2.0"
            else:
                return "1.0"
        return value