import requests
import time


class Server_Based_Updater:

    def __init__(self, url, actr_interface, relevant_labels_list,
                 sampling_rate, start_time_of_first_event):

        self.url = url
        self.actr_interface = actr_interface
        self.relevant_labels_list = relevant_labels_list
        self.sampling_rate = sampling_rate
        self.start_time_of_first_event = start_time_of_first_event

    def specify_and_pass(self, log_file_name):

        print(f"Data from: {self.url}")
        self.actr_interface.first_update_actr_env({"CASS": "Test"}, self.start_time_of_first_event)
        idx = 0
        while True:
            for item in self.relevant_labels_list:
                print(idx, item)
                schedule_time = self.start_time_of_first_event + int(idx / self.sampling_rate * 1000)
                self.actr_interface.update_actr_env({item: f"{idx}"}, schedule_time)
                idx += 1