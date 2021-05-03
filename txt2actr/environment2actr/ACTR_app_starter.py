import subprocess
import os
from sys import platform as _platform
from txt2actr.environment2actr import actr
import time
import sys


class ACTR_app_starter:

    actr_link = actr_cmd = actr_script_running = None

    def __init__(self, actr_link="run-act-r.bat.lnk", actr_cmd=None):

        self.actr_link = actr_link

        if actr_cmd:
            self.actr_cmd = actr_cmd
        else:
            if _platform.startswith('darwin'):
                self.actr_cmd = "open /Applications/ACT-R/run-act-r.command"
            elif _platform.startswith('linux'):
                self.actr_cmd = "run-act-r.command"
            elif _platform.startswith('win'):
                self.actr_cmd = "runactr.cmd"

        self.execute_actr_app()

    def execute_actr_app(self):
        if not actr.current_connection:
            if _platform.startswith('darwin') or _platform.startswith('linux'):
                os.system(self.actr_cmd)
            elif _platform.startswith('win'):
                with open(f'../{self.actr_cmd}', 'w') as actr_script:
                    actr_script.write(self.actr_link)
                self.actr_script_running = subprocess.Popen(self.actr_cmd,
                                                            stdout=subprocess.PIPE,
                                                            stderr=subprocess.PIPE,
                                                            cwd='external_connections')
            else:
                sys.exit('Could not identify operating system. Exit.')

            print("A connection to ACT-R will be established now... "
                  "waiting for 15 seconds until ACT-R is ready ...")
            time.sleep(15)
