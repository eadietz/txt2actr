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

        # self.ws = websocket.WebSocket()
        #_thread.start_new_thread(self.connect, ())
        time.sleep(3)

    def connect(self):

        self.ws.connect("ws://localhost:2048/fsuipc/", subprotocols=["fsuipc"])
        print(*"Websocket Connected")
        offsets_declare = {
                    "command": 'offsets.declare',
                    "name": 'OffsetsWrite',
                    "offsets": [
                        { "name": 'write', "address": 0x66D0, "type": 'int', "size": 4 },
                    ]
                    }
        self.ws.send(json.dumps(offsets_declare))
        primary_response_data= self.ws.recv()
        print(json.loads(primary_response_data))
        while True:
            time.sleep(1)

    # called by the cognitive model in act-r to compute similarity between two numbers
    def numberSimilarities(self, a, b):
        if isinstance(b, numbers.Number) and isinstance(a, numbers.Number):
            # similarity based on euclidean distance
            return 1 / (1 + np.sqrt(pow((a - b), 2)))
        else:
            return False

    def waiting(self):
        print("waiting")

    def print_read_data(self, label_and_value):
        print("the cognitive model reads", label_and_value)

    def pass_data_to_sim(self, label_and_value):

        print("send data to fs", label_and_value[1], isinstance(label_and_value[1], (int, float)))

        # n = random.randint(0,365)
        # offsets_write_dict = {
        #     "command": 'offsets.write',
        #     "name": 'OffsetsWrite',
        #     "offsets": [
        #         { "name": 'write', "value": n}
        #         ]
        #         }
        # self.ws.send(json.dumps(offsets_write_dict))
        # primary_response_data= self.ws.recv()
        # print(json.loads(primary_response_data))

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