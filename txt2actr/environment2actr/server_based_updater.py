from asyncio import events
import json
import asyncio
import websockets
import time
from websockets.typing import Subprotocol
from websockets import client
from argparse import ArgumentParser  # Direkt aus terminal Arguments übergeben

fsuipc_protocol = Subprotocol("fsuipc")  # as stated in documentation


class Server_Based_Updater:

    def __init__(self, actr_interface=None, hostname="localhost", port="2048", relevant_labels_list=["altitude"],
                 sampling_rate=100, start_time_of_first_event=0):
        self.hostname = hostname
        self.port = port
        self.actr_interface = actr_interface
        self.relevant_labels_list = relevant_labels_list
        self.sampling_rate = sampling_rate
        self.start_time = start_time_of_first_event
        self.idx = 0

    async def show_offset_values(self, payload):

        payload_data = payload.get("data")

        AP = "ON" if payload_data.get("AP1STS") == 1 else "OFF"

        heading = round(int(payload_data.get("heading")) * 360 / (65536 * 65536), 0)
        altitude = round(int(payload_data.get("altitude")) / (65535 * 65535) * 3.28084)
        speed = round(int(payload_data.get("speed")) / 128)

        vals_of_interest_dict = {"ALTITUDE": f"{altitude}", "SPEED": f"{speed}", "HEADING": f"{heading}", "AP": AP,
                                 "MW": f"{0}"}
        self.idx += 1
        self.actr_interface.update_actr_env(vals_of_interest_dict)
        time.sleep(0.01)
        # print("Scheduled Time", schedule_time)

        # print(f"Heading: {heading}, Altitude: {altitude}, Speed: {speed}, Autopilot 1: {AP}")

    async def handle_offset_receive(self, payload):
        if "command" in payload:
            if payload.get("command") == "offsets.declare":  # Server answering that offsets have been declared
                print("* Offset declared successful.")
                print(f"Dump: {json.dumps(payload)}")

            elif payload.get("command") == "offsets.read" and payload.get("name") == "myOffsets":
                # Read custom offset -> print out
                await self.show_offset_values(payload=payload)

    async def client_loop(self, hostname, port, regular_updates):
        print("test")
        # URL aufbauen
        server_url = f"ws://{hostname}:{port}/fsuipc/"
        print(f"* Connecting to server at '{server_url}'")

        # Connect to server
        async with client.connect(server_url, subprotocols=[fsuipc_protocol]) as websocket:

            print("* Websocket connected")

            # Send declare request
            await websocket.send(json.dumps({
                "command": 'offsets.declare',
                "name": 'myOffsets',
                "offsets": [
                    {"name": 'altitude', "address": 0x0570, "type": 'int', "size": 8},
                    {"name": 'heading', "address": 0x0580, "type": 'uint', "size": 4},
                    {"name": 'speed', "address": 0x02BC, "type": 'int', "size": 4},
                    # local variable
                    {"name": 'AP1STS', "address": 0x66E1, "type": 'int', "size": 4},
                ]
            }))

            # Send Read request
            await websocket.send(json.dumps({
                "command": 'offsets.read',
                "name": 'myOffsets',
                "interval": regular_updates
            }))

            #####################receive_count = 0 #for use with receive_count < 100

            while True:

                # Read data
                response_data = json.loads(await websocket.recv())

                if response_data.get("success", False):
                    ######################### print("* Receive data. Webserver responded successful")

                    # Print data
                    # await show_offset_values(payload=response_data)
                    await self.handle_offset_receive(payload=response_data)



                else:
                    print("[ERROR]", response_data.get("errorCode"), response_data.get("errorMessage"))
                    break

                #####################receive_count += 1
                ####################if receive_count > 100:
                ######################################break

            # Send stop request
            await websocket.send(json.dumps({
                "command": 'offsets.stop',
                "name": 'myOffsets'
            }))

            await websocket.close()

        print("* Websocket disconnecting")
        await asyncio.sleep(3)

    def specify_and_pass(self, logname=None):

        try:

            print("* Start running main task")

            event_loop = asyncio.new_event_loop()  # event_loop = asyncio.get_event_loop() #könnte hier alternativ verwendet werden - get_event will get the current thread’s default event loop object as long as being in the main thread
            event_loop.run_until_complete(  # will also handle all queued futures until all are finished
                self.client_loop(hostname=self.hostname, port=self.port, regular_updates=35)
            )

        except KeyboardInterrupt:

            # Stop event loop if running -- end program using Ctrl C
            if event_loop.is_running():
                event_loop.stop()

# sbu = Server_Based_Updater()
# sbu.specify_and_pass()