import websocket #https://websoc    ket-client.readthedocs.io/en/latest/faq.html?highlight=subprotocol#using-subprotocols
import _thread
import time
import json
import random

class Writer:
    def __init__(self, ws):
        self.ws=ws
    def write(self):
        while True:
            n = random.randint(0,365)
            offsets_write_dict = {
                "command": 'offsets.write',
                "name": 'OffsetsWrite',
                "offsets": [
                    { "name": 'write', "value": n}                                                                                                                                                                                                                                                                                                                                                                                      
                    ]
                    }
            self.ws.send(json.dumps(offsets_write_dict))
            primary_response_data= self.ws.recv()
            print(json.loads(primary_response_data))
            time.sleep(0.5)