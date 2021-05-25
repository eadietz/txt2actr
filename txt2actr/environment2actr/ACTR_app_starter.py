import subprocess
import os
from sys import platform as _platform
from txt2actr.environment2actr import actr
import time
import sys


class ACTR_app_starter:

    actr_link = actr_cmd = actr_script_running = None
    p_flags =  "-p 4000:4000 -p 2650:2650"
    docker_lnx = "docker run -i -v ~/act-r-tutorial:/home/actr/actr7.x/tutorial db30/act-r-container"
    docker_lnx_web = f"docker run -i {p_flags} -v ~/Documents/GitHub/txt2actr/benchmarks/use-cases:/home/actr/actr7.x/tutorial db30/act-r-container"
    docker_win = "docker run -i -v %homedrive%%homepath%\act-r-tutorial:/home/actr/actr7.x/tutorial db30/act-r-container"
    docker_win_web = f"docker run -i {p_flags} -v %homedrive%%homepath%\act-r-tutorial:/home/actr/actr7.x/tutorial db30/act-r-container"

    def __init__(self, how_to_start_actr, actr_lnk="run-act-r.bat.lnk", actr_cmd=None):

        self.actr_lnk = actr_lnk
        self.actr_lnk = 'actr_script.sh'

        self.how_to_start_actr = how_to_start_actr

        if actr_cmd:
            self.actr_cmd = actr_cmd
        elif how_to_start_actr == 'e':
                print("Make sure that you started the ACT-R connection externally ... ")
        else:
            if how_to_start_actr == 'i':
                if _platform.startswith('darwin'):
                    self.actr_cmd = "open /Applications/ACT-R/run-act-r.command"
                elif _platform.startswith('linux'):
                    self.actr_cmd = "run-act-r.command"
                elif _platform.startswith('win'):
                    self.actr_cmd = "run-act-r.cmd"
            elif how_to_start_actr == 'dw':
                if _platform.startswith('darwin') or _platform.startswith('linux'):
                    self.actr_cmd = self.docker_lnx_web
                elif _platform.startswith('win'):
                    self.actr_cmd = self.docker_win_web
            elif how_to_start_actr == 'd':
                if _platform.startswith('darwin') or _platform.startswith('linux'):
                    self.actr_cmd = self.docker_lnx
                elif _platform.startswith('win'):
                    self.actr_cmd = self.docker_win
            self.execute_actr_app()

    def execute_actr_app(self):
        if not actr.current_connection:
            if _platform.startswith('darwin') or _platform.startswith('linux'):
                with open(f'../{self.actr_lnk}', 'w') as actr_script:
                    actr_script.write(self.actr_cmd)
                execute = ["bash", f'../{self.actr_lnk}']
                #self.actr_script_running = subprocess.Popen(["bash", f'../{self.actr_lnk}'], stdout=subprocess.PIPE,
                #                                       stderr=subprocess.PIPE)
            elif _platform.startswith('win'):
                #with open(f'{self.actr_lnk}', 'w') as actr_script:
                #    actr_script.write(self.actr_cmd)
                execute = f'../{self.actr_lnk}'
                #self.actr_script_running = subprocess.Popen(f'../{self.actr_lnk}',
                #                                            stdout=subprocess.PIPE,
                #                                            stderr=subprocess.PIPE,
                #                                            cwd='external_connections')
            else:
                sys.exit('Could not identify operating system. Exit.')

            self.actr_script_running = subprocess.Popen(execute, stdout=subprocess.PIPE,
                                                        stderr=subprocess.PIPE)

            print("A connection to ACT-R will be established now... "
                  "waiting for 15 seconds until ACT-R is ready ...")
            time.sleep(15)
