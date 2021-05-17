from controller import Controller
import os
abs_path_of_model_components = f'{os.path.dirname(__file__)}/benchmarks/model-components/'
meta_info_file = 'meta_info.csv'

class Simulation():

    def __init__(self):
        #c = driving_task()
        c = flight_task()
        #c = paired_associate_task()
        c.instantiate_default_obj()
        c.construct_cognitive_model()
        c.do_run()

def paired_associate_task():

    abs_path_of_uc_and_model_specification = f'{os.path.dirname(__file__)}/benchmarks/use-cases/paired-associates-task/'

    return Controller(absolute_path_uc=abs_path_of_uc_and_model_specification,
                   absolute_path_mc=abs_path_of_model_components,
                      meta_info_file=meta_info_file)

def driving_task():

    abs_path_of_uc_and_model_specification = f'{os.path.dirname(__file__)}/benchmarks/use-cases/driving-task/'

    return Controller(absolute_path_uc=abs_path_of_uc_and_model_specification,
                   absolute_path_mc=abs_path_of_model_components,
                   meta_info_file=meta_info_file)


def flight_task():

    abs_path_of_uc_and_model_specification = f'{os.path.dirname(__file__)}/benchmarks/use-cases/flight-task/'

    return Controller(absolute_path_uc=abs_path_of_uc_and_model_specification,
                   absolute_path_mc=abs_path_of_model_components,
                   meta_info_file=meta_info_file)

Simulation()