
import asyncio
import websockets
from websockets import client
import json
import sys
import random


async def eventloop():

        server_url = f"ws://localhost:2048/fsuipc/"
        async with client.connect(server_url, subprotocols=['fsuipc']) as websocket:
            print("* Websocket connected")

            offsets_declare = {
                "command": 'offsets.declare',
                "name": 'OffsetsWrite',
                "offsets": [
                    { "name": 'write', "address": 0x66D0, "type": 'int', "size": 4 },                                                                                                                                                                                                                                                                                                                                                                                      
                ]
                }

            await websocket.send(json.dumps(offsets_declare))

            primary_response_data=await websocket.recv()
            print(json.loads(primary_response_data))

            if json.loads(primary_response_data).get("success"):
                print(*"Offsets Declared Successful")


                while True: 
                
                    n = random.randint(0,365)
                    offsets_write_dict = {
                        "command": 'offsets.write',
                        "name": 'OffsetsWrite',
                        "offsets": [
                            { "name": 'write', "value": n}                                                                                                                                                                                                                                                                                                                                                                                      
                            ]
                            }
                    await websocket.send(json.dumps(offsets_write_dict))
                    primary_response_data2=await websocket.recv()
                    print(primary_response_data2)
                    primary_response_data2_json = json.loads(primary_response_data2)
                    primary_response_data2_data = primary_response_data2_json.get("data")
                    
                    if primary_response_data2_data == None:
                        counter = counter + 1

                        print("* ERROR: NO DATA RETURNED")
                        if counter == 3:
                            print(*"NO DATA HAS BEEN RETURED AFTER WRITING OFFSET")
                            break
                    else:
                        primary_response_data2_value = primary_response_data2_data.get("write")
                        counter=0
                        print(f"Offset written with value {primary_response_data2_value}")


            else:  
                print(json.loads(primary_response_data).get("success", "* No Success Message has been returned"))
                print("[ERROR] Offsets have not been declared correctly")
                print("[ERROR] Error Message", json.loads(primary_response_data).get("errorMessage"), "Error Code", json.loads(primary_response_data).get("errorCode"))


def main():
    print("* Start running main task")

    try:
        print('* run eventloop')

        asyncio.run(eventloop())

        print('* close eventloop')
    except:
        print('* The Connection could not be established')

if __name__ == "__main__":

    main()