# =============================================================================
# This file is an adaptation of the file paired.py in the 
# ACT-R tutorial in the folder ACT-R/tutorial/python
# that can be downloaded here http://act-r.psy.cmu.edu/software/
# =============================================================================

import sys
import itertools
import time

class Task_Based_Updater:

    headers_list = values_list = None

    response = False
    response_time = False

    pairs = list(zip(['bank', 'card', 'dart', 'face', 'game', 'hand', 'jack', 'king', 'lamb', 'mask',
                      'neck', 'pipe', 'quip', 'rope', 'sock', 'tent', 'vent', 'wall', 'xray', 'zinc'],
                     ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8',
                      '9']))

    latencies = [0.0, 2.158, 1.967, 1.762, 1.680, 1.552, 1.467, 1.402]
    probabilities = [0.0, .526, .667, .798, .887, .924, .958, .954]

    def __init__(self, actr_interface, time_interval_in_msec=5000, results_file=None):
            self.time_interval_in_msec = time_interval_in_msec
            self.actr_interface = actr_interface
            self.actr = self.actr_interface.get_actr_instance()
            self.actr.add_command("paired-response",self.respond_to_key_press,
                             "Paired associate task key press response monitor")
            self.actr.monitor_command("output-key","paired-response")

    def specify_and_pass(self, log_file_name=""):

        trials = 3
        size = 2
        result = []
        model = True
        schedule_time = 3

        self.headers_list = ['number', 'letter']
        self.values_list = [""] * len(self.headers_list)

        for i in range(trials):
            score = 0
            time = 0

            for prompt, associate in self.actr.permute_list(self.pairs[20 - size:]):


                self.actr_interface.update_actr_env({'item': str(prompt)}, schedule_time)
                global response
                response = ''

                start = schedule_time
                schedule_time = int(schedule_time) + int(self.time_interval_in_msec)

                while self.actr.get_time(model) < (int(schedule_time)-int(2)):
                    self.actr.process_events()

                if response == associate:
                    score += 1
                    time += response_time - start

                self.actr_interface.update_actr_env({'item': str(associate)}, schedule_time)
                schedule_time = int(schedule_time) + int(self.time_interval_in_msec)

                while self.actr.get_time(model) < (int(schedule_time)-int(2)):
                    self.actr.process_events()

            average_time = time / score / 1000.0 if score > 0 else 0

            result.append((score / size, average_time))

        print(result)

    #@staticmethod
    def respond_to_key_press(self, model, key):

        global response, response_time
        response_time = self.actr.get_time(model)
        response = key