"""
Created on Tue Jul 14 09:36:48 2020
@author: thd7as
"""

# =============================================================================
# This class is all about the data stream and passing the relevant parameters
#  through the ACT-R Environment
# log_file_name is the name of the file that contains the (dynamic) flight log information
# =============================================================================


class Task_Based_Updater:

    headers_list = values_list = None

    def __init__(self, actr_interface, time_interval_in_msec=1000):
            self.actr_interface = actr_interface
            self.time_interval_in_msec = time_interval_in_msec

    def specify_and_pass(self, log_file_name=""):
        print("this function needs to be adjusted according to the task")

