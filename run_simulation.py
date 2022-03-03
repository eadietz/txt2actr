import argparse
import json
import os

from controller import Controller


class Simulation():

    # for windows ...

    def __init__(self, json_bool=True):

        self.path_sep = "/"
        self.abs_path = f'{os.path.dirname(os.path.abspath(__file__))}/'
        self.abs_path = self.abs_path[2:] if self.abs_path.startswith("C:") else self.abs_path

        self.model_components_path = f'{self.abs_path}benchmarks{self.path_sep}model-components{self.path_sep}'

        parser = argparse.ArgumentParser(description = "Description for my parser")
        parser.add_argument("-c", "--Config", required = False, default = "")
        parser.add_argument("-e", "--External" , required = False, default = "")
        parser.add_argument("-d", "--Dummy", required = False, default = "")
        parser.add_argument("-m", "--Model", required = False, default = "")

        args = parser.parse_args()

        config_file = args.Config if args.Config else "config-bst.json"
        actr_external = True if args.External else False
        dummy_run = True if args.Dummy else False
        load_model = True if args.Model else False

        uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}'

        with open(uc_path + config_file, 'r') as file_open:
            json_data = json.load(file_open)
            for use_case in json_data:
                c = Controller(absolute_path_uc=uc_path,
                               absolute_path_mc=self.model_components_path,
                               config_specs=use_case, json_bool=json,
                               actr_external=actr_external,
                               dummy_run=dummy_run, load_cog_model=load_model)
                c.instantiate_default_obj()
                c.construct_cognitive_model()
                c.do_run()


Simulation()
