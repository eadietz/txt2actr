from controller import Controller
import os
from sys import platform as _platform
import sys
import json


class Simulation():

    # for windows ...

    def __init__(self, json_bool=True):

        self.path_sep = "/"
        self.abs_path = f'{os.path.dirname(os.path.abspath(__file__))}/'
        self.abs_path = self.abs_path[2:] if self.abs_path.startswith("C:") else self.abs_path

        self.model_components_path = f'{self.abs_path}benchmarks{self.path_sep}model-components{self.path_sep}'
        self.config_file = 'meta_info.csv'

        if json_bool:
            config_file = str(sys.argv[1]) if len(sys.argv)>1 else "config-flight-sim.json" #test_by_event.json"
            actr_env = str(sys.argv[2]) if len(sys.argv)>2 else None
            uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}'

            with open(uc_path + config_file, 'r') as file_open:
                json_data = json.load(file_open)
                for use_case in json_data:
                    c = Controller(absolute_path_uc=uc_path,
                                   absolute_path_mc=self.model_components_path,
                                   config_specs=use_case, json_bool=json,
                                   actr_env=actr_env)
                    c.instantiate_default_obj()
                    c.construct_cognitive_model()
                    c.do_run()
        else:
            self.config_file = f"meta_info.csv"
            # name of the folder of the use case
            #use_case_folder = 'paired-associates-task'
            #use_case_folder = 'driving-task'
            #use_case_folder = 'flight-task'
            use_case_folder = 'automation-surprise-in-flight'
            uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}{use_case_folder}{self.path_sep}'
            c = Controller(absolute_path_uc=uc_path,
                           absolute_path_mc=self.model_components_path,
                           config_specs=self.config_file, json_bool=json_bool)
            c.instantiate_default_obj()
            c.construct_cognitive_model()
            c.do_run()



Simulation()
