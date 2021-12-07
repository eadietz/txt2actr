import requests
import time


class Server_Based_Updater:

    def __init__(self, url, actr_interface, relevant_labels_list):

        self.url = url
        self.actr_interface = actr_interface
        self.relevant_labels_list = relevant_labels_list

    def specify_and_pass(self, log_file_name):

        print(f"Data from: {self.url}")
        self.actr_interface.first_update_actr_env({"CASS": "Test"})
        idx = 0
        while True:
            for item in self.relevant_labels_list:
                print(idx, item)
                self.actr_interface.update_actr_env({item: f"{idx}"})
                idx += 1