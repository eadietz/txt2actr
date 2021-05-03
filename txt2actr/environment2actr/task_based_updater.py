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
import itertools


class Task_Based_Updater:

    headers_list = values_list = None

    def __init__(self, actr_interface, time_interval_in_msec=1000):
            self.actr_interface = actr_interface
            self.time_interval_in_msec = time_interval_in_msec

    def specify_and_pass(self, log_file_name=""):

        pairs = list(zip(['bank', 'card', 'dart', 'face', 'game', 'hand', 'jack', 'king', 'lamb', 'mask',
                          'neck', 'pipe', 'quip', 'rope', 'sock', 'tent', 'vent', 'wall', 'xray', 'zinc'],
                         ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8',
                          '9']))

        schedule_time = 1
        for i in range(2):
            self.headers_list = ['number', 'letter']
            self.values_list = [""] * len(self.headers_list)
            for item in itertools.permutations(pairs[20 - 2:]):
                for (number, noun) in item:
                    self.actr_interface.update_actr_env({'value': f'{number}'}, schedule_time)
                    schedule_time = int(schedule_time) + int(self.time_interval_in_msec)
                    self.actr_interface.update_actr_env({'value': f'{noun}'}, schedule_time)
                    schedule_time = int(schedule_time) + int(self.time_interval_in_msec)
