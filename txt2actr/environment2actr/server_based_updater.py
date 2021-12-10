from asyncio import events
import json
import asyncio
#import websockets
#from websockets.typing import Subprotocol
#from websockets import client
from argparse import ArgumentParser  # Direkt aus terminal Arguments übergeben

#fsuipc_protocol = Subprotocol("fsuipc")  # as stated in documentation


class Server_Based_Updater:

    def __init__(self, hostname="localhost", port="2048", actr_interface=None, relevant_labels_list=["altitude"],
                 sampling_rate=100, start_time_of_first_event=0):
        self.hostname = hostname
        self.port = port
        self.actr_interface = actr_interface
        self.relevant_labels_list = relevant_labels_list
        self.sampling_rate = sampling_rate
        self.start_time_of_first_event = start_time_of_first_event


    async def show_offset_values(self, payload):

        # print(f"Dump: {json.dumps(payload)}")
        payload_data = payload.get("data")

        if payload_data.get("AP1STS") == 1:
            AP1StatusPrint = "ON"
        elif payload_data.get("AP1STS") == 0:
            AP1StatusPrint = "OFF"

        heading = round(int(payload_data.get("heading")) * 360 / (65536 * 65536), 0)
        altitude = round(int(payload_data.get("altitude")) / (65535 * 65535) * 3.28084)
        speed = round(int(payload_data.get("speed")) / 128)

        print(
            f"Heading: {heading}, Altitude: {altitude}, Speed: {speed}, Autopilot 1: {AP1StatusPrint}"
        )


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

            print(f"* Websocket connected")

            # Send declare request
            await websocket.send(json.dumps({
                "command": 'offsets.declare',
                "name": 'myOffsets',
                "offsets": [
                    {"name": 'altitude', "address": 0x0570, "type": 'int', "size": 8},
                    {"name": 'heading', "address": 0x0580, "type": 'uint', "size": 4},
                    {"name": 'speed', "address": 0x02BC, "type": 'int', "size": 4},
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

            if self.actr_interface != None:
                self.actr_interface.first_update_actr_env({"altitude": "Test"}, self.start_time_of_first_event)

            idx = 0

            while True:

                # Read data
                response_data = json.loads(await websocket.recv())

                if response_data.get("success", False):
                    ######################### print("* Receive data. Webserver responded successful")

                    # Print data
                    # await show_offset_values(payload=response_data)
                    await self.handle_offset_receive(payload=response_data)

                    if self.actr_interface != None:
                        schedule_time = self.start_time_of_first_event + int(idx / self.sampling_rate * 1000)
                        self.actr_interface.update_actr_env({"altitude": f"{idx}"}, schedule_time)
                        idx += 1

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
        argparser = ArgumentParser(
            description="fsuipc python connector client - by Aurel Beheschti")  # Setup Argument Parser for Execution in CMD

        # Add Argument Parser for Hostname
        argparser.add_argument(
            "-H",
            "--hostname",
            type=str,
            action="store",
            dest="hostname",
            default=self.hostname,
            help="Hostname of fsuipc websocket server"
        )
        # Add Argument Parser for Port -- std is set to 2048. Ausführung sollte also ohne Übergabe der Werte aus dem Terminal funktionieren
        argparser.add_argument(
            "-P",
            "--port",
            type=int,
            action="store",
            dest="port",
            default=self.port,
            help="Port of fsuipc websocket server"
        )

        options = argparser.parse_args()  # Parsing input Arguments into format: options.argument

        try:

            print("* Start running main task")
            event_loop = asyncio.new_event_loop()  # event_loop = asyncio.get_event_loop() #könnte hier alternativ verwendet werden - get_event will get the current thread’s default event loop object as long as being in the main thread
            event_loop.run_until_complete(  # will also handle all queued futures until all are finished
                self.client_loop(hostname=options.hostname, port=options.port, regular_updates=35)
            )

        except KeyboardInterrupt:

            # Stop event loop if running -- end program using Ctrl C
            if event_loop.is_running():
                event_loop.stop()


sbu = Server_Based_Updater()
#sbu.specify_and_pass()

