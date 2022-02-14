import websocket #https://websoc    ket-client.readthedocs.io/en/latest/faq.html?highlight=subprotocol#using-subprotocols
import _thread
import time
import json
import random
from Writer import *

def connect():
    ws.connect("ws://localhost:2048/fsuipc/", subprotocols=["fsuipc"])
    print(*"Websocket Connected")
    offsets_declare = {
                "command": 'offsets.declare',
                "name": 'OffsetsWrite',
                "offsets": [
                    { "name": 'write', "address": 0x66D0, "type": 'int', "size": 4 },                                                                                                                                                                                                                                                                                                                                                                                      
                ]
                }
    ws.send(json.dumps(offsets_declare))
    primary_response_data= ws.recv()
    print(json.loads(primary_response_data))
    while True:
        time.sleep(1)
    

if __name__ == "__main__":
    ws = websocket.WebSocket()
    _thread.start_new_thread(connect, ())
    time.sleep(3)
    writer=Writer(ws)
    writer.write()
       
