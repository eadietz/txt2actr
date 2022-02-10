import pathlib
import pandas as pd
import re
import math
import numbers
from txt2actr.environment2actr import actr
import os
import io
import numpy as np
# from contextlib import redirect_stdout
# from ast import literal_eval
# from sklearn.metrics import mean_squared_error
# from math import sqrt
import asyncio
import websockets
from websockets import client
import json
import sys
import random


class Analysis:

    def __init__(self, path):

        self.rmse_collector = 0
        self.flag = True
        self.current_state = None
        self.path = path
        self.sep = ";"
        self.compared_df = pd.DataFrame()
        self.idx = 0

        self.server_url = f"ws://127.0.0.1:2048/fsuipc/"
        self.websocket = client.connect(self.server_url, subprotocols=['fsuipc'])
        self.counter = 0

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
        try:
            print('* run write')
            asyncio.run(self.write(label_and_value))
            print('* close write')
        except Exception as e:
            print(e)
            print('* The Connection could not be established')

    async def write(self, new_val):

        global counter
        n = random.randint(0, 365)
        offsets_write_dict = {
            "command": 'offsets.write',
            "name": 'OffsetsWrite',
            "offsets": [
                {"name": 'write', "value": n}
            ]
        }

        print("start await websocket", self.websocket)
        await self.websocket.send(json.dumps(offsets_write_dict))
        primary_response_data2 = await self.websocket.recv()
        print(primary_response_data2)
        primary_response_data2_json = json.loads(primary_response_data2)
        primary_response_data2_data = primary_response_data2_json.get("data")

        if primary_response_data2_data == None:
            counter = counter + 1

            print("* ERROR: NO DATA RETURNED")
            if counter == 3:
                print(*"NO DATA HAS BEEN RETURED AFTER WRITING OFFSET")

        else:
            primary_response_data2_value = primary_response_data2_data.get("write")
            counter = 0
            print(f"Offset written with value {primary_response_data2_value}")

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