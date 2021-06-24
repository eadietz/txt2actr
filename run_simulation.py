from controller import Controller
import os
from sys import platform as _platform


class Simulation():

    def __init__(self):

        self.path_sep = "\\" if _platform.startswith('win') else "/"
        self.abs_path = f'{os.path.dirname(__file__)}' if _platform.startswith('win') else f'{os.path.dirname(__file__)}/'

        self.model_components_path = f'{self.abs_path}benchmarks{self.path_sep}model-components{self.path_sep}'
        self.meta_info_file = 'meta_info.csv'

        c = self.driving_task()
        #c = self.flight_task()
        #c = self.paired_associate_task()
        c.instantiate_default_obj()
        c.construct_cognitive_model()
        c.do_run()

    def paired_associate_task(self):

        uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}paired-associates-task{self.path_sep}'

        print("uc path", uc_path)

        return Controller(absolute_path_uc=uc_path,
                       absolute_path_mc=self.model_components_path,
                          meta_info_file=self.meta_info_file)

    def driving_task(self):

        uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}driving-task{self.path_sep}'

        print("uc path", uc_path)

        return Controller(absolute_path_uc=uc_path, absolute_path_mc=self.model_components_path,
                       meta_info_file=self.meta_info_file)


    def flight_task(self):

        uc_path = f'{self.abs_path}benchmarks{self.path_sep}use-cases{self.path_sep}flight-task{self.path_sep}'

        print("uc path", uc_path)

        return Controller(absolute_path_uc=uc_path,
                       absolute_path_mc=self.model_components_path,
                       meta_info_file=self.meta_info_file)

Simulation()