# -*- coding: utf-8 -*-
"""
Created on Tue Jul  7 09:24:08 2020

@author: thd7as
"""

from sys import platform as _platform
import importlib.util

from threading import *
from txt2actr.model2actr.cognitive_model_assembler import *
from txt2actr.environment2actr.obj_instantiator_for_ACTR_env import *
from txt2actr.environment2actr.ACTR_app_starter import *
from txt2actr.environment2actr.ACTR_interface import *
from txt2actr.environment2actr.log_based_updater import *

# =============================================================================
# The Operator class instantiates the Env class (connection to act-r model) and
# the Observer class (connection to data file/ cockpit protocol)
# It first reads the file parameter_setting.csv and defines the the lists required
# for the windows within the ACT-R environment (instantiated by the Env class)
# For the Observer instantiation, it passes the string data file path and name
# and the instantiated Env: If the Observer recognizes a change in the data file,
# it sends the new info to the Env (which in turn, updates the windows/ audio)
# =============================================================================


class Controller:

    def __init__(self, absolute_path_uc=os.path.dirname(os.path.abspath(__file__)),
                 absolute_path_mc=os.path.dirname(os.path.abspath(__file__)),
                 meta_info_file="meta_info.csv"):

        self.absolute_path_uc = absolute_path_uc
        self.absolute_path_mc = absolute_path_mc
        self.default_values = Default_Values_Specifier(absolute_path_uc, meta_info_file)
        self.set_file_names()

        self.log = File_Logger(self.output_file) if self.suppress_console_output else Console_and_File_Logger(self.output_file)

    def instantiate_default_obj(self):
        self.obj_instantiation = Obj_Instantiator_For_ACTR_Env(self.sounds_file, self.images_file,
                                                               self.windows_labels_file, self.buttons_file,
                                                               self.windows_specification_file)
        self.obj_instantiation.instantiate_objects_for_env()

    def construct_cognitive_model(self):

        if os.path.exists(self.cognitive_model_specifications_file):
            print(f'A new cognitive model will be constructed: {self.cognitive_model_file} will be the cognitive model')
            cma = Cognitive_Model_Assembler(self.absolute_path_uc, self.absolute_path_mc, self.cognitive_model_specifications_file,
                                       self.cognitive_model_file, self.show_display_labels,
                                       self.obj_instantiation.windows_dict, self.obj_instantiation.sounds_dict)
            cma.specify_and_assemble_components()
        else:
            print('No new cognitive model will be constructed')

    def do_run(self):

        ACTR_app_starter() if self.start_actr_internally is True \
            else print("Make sure that you started the ACT-R connection externally ... ")

        cognitive_model_file_transformed = self.cognitive_model_file.replace("/", ";")
        # get rid of any non-alphanumeric characters at the beginning of path to file string
        start_idx = re.search("[^\W\d]", cognitive_model_file_transformed).start()
        cognitive_model_file_transformed = cognitive_model_file_transformed[start_idx:] \
            if cognitive_model_file_transformed.startswith(";") else cognitive_model_file_transformed

        actr_interface = ACTR_interface(cognitive_model_file_transformed, self.obj_instantiation.windows_dict,
                                           self.obj_instantiation.sounds_dict,
                                           self.nr_of_decimals_in_values, self.show_display_labels,
                                           self.time_interval_to_new_val_in_msc, self.human_interaction,
                                           self.show_env_windows)
        actr_interface.connect_with_actr()

        env_simulator = None

        if self.ACTR_updates == 'log':
            env_simulator = Log_Based_Updater(actr_interface, self.column_separator,
                            self.sampling_rate, self.skip_rate_in_log, 1, self.col_start_idx_in_dataset)
        elif self.ACTR_updates == 'task':
            spec_file = importlib.util.spec_from_file_location('task_based_updater',self.log_file_folder)
            module = importlib.util.module_from_spec(spec_file)
            spec_file.loader.exec_module(module)
            task_based_updater = getattr(module, 'Task_Based_Updater')
            env_simulator = task_based_updater(actr_interface, self.sampling_rate, self.results_file)

        if os.path.isfile(self.log_file_folder):
            sim_run_time = self.new_sim_time(self.log_file_folder) if self.sim_run_time == 0 else self.sim_run_time
            print(f'{self.log_file_folder}', end ="")
            self.start_threads(actr_interface, env_simulator, sim_run_time, self.log_file_folder)
        elif os.path.isdir(self.log_file_folder):
            for log_file_name in [f for f in os.listdir(self.log_file_folder) if self.is_adequate_file(f)]:
                sim_run_time = self.new_sim_time(self.log_file_folder + log_file_name) if self.sim_run_time == 0 else self.sim_run_time
                actr_interface.reload_actr_code()  # reload actr code for the next simulation
                self.start_threads(actr_interface, env_simulator, sim_run_time, self.log_file_folder + log_file_name)
        else:
            print(f'{self.log_file_folder} is neither file nor path')

        actr_interface.stop_actr()

    def start_threads(self, actr_interface, env_simulator, sim_run_time, log_file_name=""):

        #actr_interface.reload_actr_code()
        actr_interface.set_actr_windows()
        actr_interface.log_file_name = log_file_name
        p1 = Thread(target=self.run_actr_model, args=(actr_interface, sim_run_time,
                                                      self.run_real_time, self.run_full_time))
        p2 = Thread(target=self.watch_log_file_and_pass_values, args=(env_simulator, log_file_name))
        try:
            print(f"{log_file_name} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ started")
            p1.start()
            p2.start()
            while actr_interface.actr_running():
                time.sleep(1)
            print(f" {log_file_name} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ done")
        except KeyboardInterrupt:
            del actr_interface
            del env_simulator
            sys.exit(0)
        except Exception as e:
            print(e)

    @staticmethod
    def watch_log_file_and_pass_values(env_simulator, log_file_name):  # Observes changes and passes them to ACTR
        env_simulator.specify_and_pass(log_file_name)

    @staticmethod
    def run_actr_model(actr_interface, n, real_time, full_time):
        actr_interface.run_actr(n, real_time, full_time)

    @staticmethod
    def do_task(task_execution):  # Observes changes and passes them to ACTR
        task_execution.observe_events()

    def is_adequate_file(self, file_name):
        return os.path.isfile(self.log_file_folder + file_name) and file_name.endswith('.csv') \
               and not file_name.startswith('.')

    def new_sim_time(self, file):
        with open(file) as f:
            lines = len(f.readlines())
        return int(lines)/100

    def set_file_names(self):

        self.ACTR_updates = self.default_values.ACTR_updates
        if not (self.ACTR_updates=='log' or self.ACTR_updates=='task'):
            sys.exit("You need to specify whether the simulation is log_based (log) or task_based (task)")

        self.start_actr_internally = self.default_values.start_actr_internally

        self.log_file_folder = self.default_values.log_file_folder
        self.cognitive_model_specifications_file = self.default_values.cognitive_model_specifications_file
        self.cognitive_model_file = self.default_values.cognitive_model_file

        self.windows_specification_file = self.default_values.windows_specification_file
        self.buttons_file = self.default_values.buttons_file
        self.images_file = self.default_values.images_file
        self.windows_labels_file = self.default_values.windows_labels_file
        self.sounds_file = self.default_values.sounds_file
        self.results_file = self.default_values.results_file

        self.column_separator = self.default_values.column_separator
        self.start_time_of_first_event = int(self.default_values.start_time_of_first_event)
        self.sampling_rate = int(self.default_values.sampling_rate)
        self.skip_rate_in_log = int(self.default_values.skip_rate_in_log)
        self.col_start_idx_in_dataset = int(self.default_values.col_start_idx_in_dataset)
        self.show_env_windows = self.default_values.show_env_windows
        self.show_display_labels = self.default_values.show_display_labels
        self.nr_of_decimals_in_values = int(self.default_values.nr_of_decimals_in_values)
        self.time_interval_to_new_val_in_msc = int(self.default_values.time_interval_to_new_val_in_msc)
        self.human_interaction = self.default_values.human_interaction
        self.sim_run_time = int(self.default_values.time_to_run_sim)
        self.run_full_time = self.default_values.run_full_time
        self.run_real_time = self.default_values.run_real_time
        self.suppress_console_output = self.default_values.suppress_console_output
        self.output_file = self.default_values.output_file

class Default_Values_Specifier:

    def __init__(self, absolute_path_of_use_case_specs, meta_infos_file):

        self.mac_vs_ws = "\\" if _platform.startswith('win') else "/"
        path = absolute_path_of_use_case_specs.replace("/", self.mac_vs_ws)
        path = path + self.mac_vs_ws if not path.endswith(self.mac_vs_ws) else path

        # specify default values

        self.start_actr_internally = False

        self.column_separator = ";"
        self.start_time_of_first_event = 1
        self.sampling_rate = 100
        self.skip_rate_in_log = 50
        self.col_start_idx_in_dataset = 0
        self.show_env_windows = True
        self.show_display_labels = True
        self.nr_of_decimals_in_values = 2
        self.time_interval_to_new_val_in_msc = 1
        self.human_interaction= False

        self.time_to_run_sim = 1000
        self.run_full_time = False
        self.run_real_time = True
        self.suppress_console_output = False
        self.output_file = 'output.txt'

        self.set_csv_values_into_lists(path, meta_infos_file) if \
            os.path.exists(path + meta_infos_file) else sys.exit(f'{path + meta_infos_file} does not exist')

        sys.exit(0) if not self.verify_if_files_exist([self.log_file_folder, self.windows_specification_file,
                                                       self.cognitive_model_file, self.buttons_file, self.images_file,
                                                       self.windows_labels_file, self.sounds_file]) else True

    def set_csv_values_into_lists(self, path, meta_infos_file):

        with open(path + meta_infos_file, 'r') as file_open:

            self.ACTR_updates = file_open.readline().split(";")[1]
            if not (self.ACTR_updates == 'log' or self.ACTR_updates == 'task'):
                sys.exit("You need to specify whether the simulation is log_based (log) or task_based (task)")

            if file_open.readline().split(";")[1].startswith('y'):
                self.start_actr_internally = True

            self.log_file_folder = path + file_open.readline().split(";")[1]
            self.cognitive_model_specifications_file = path + file_open.readline().split(";")[1]
            self.cognitive_model_file = path + file_open.readline().split(";")[1]

            self.windows_specification_file = path + file_open.readline().split(";")[1]
            self.buttons_file = path + file_open.readline().split(";")[1]
            self.images_file = path + file_open.readline().split(";")[1]
            self.windows_labels_file = path + file_open.readline().split(";")[1]
            self.sounds_file = path + file_open.readline().split(";")[1]
            self.results_file = path + file_open.readline().split(";")[1]

            identify_col_sep = file_open.readline().split(";")[1]
            self.column_separator = ";" if not identify_col_sep else identify_col_sep

            identify_start_time_of_first_event = file_open.readline().split(";")[1]
            if self.check_if_number(identify_start_time_of_first_event):
                self.start_time_of_first_event = int(identify_start_time_of_first_event)
            identify_sampling_rate = file_open.readline().split(";")[1]
            if self.check_if_number(identify_sampling_rate):
                self.sampling_rate = int(identify_sampling_rate)
            identify_skip_rate_in_log = file_open.readline().split(";")[1]
            if self.check_if_number(identify_skip_rate_in_log):
                self.skip_rate_in_log = int(identify_skip_rate_in_log)
            identify_col_start_idx_in_dataset =  file_open.readline().split(";")[1]
            if self.check_if_number(identify_col_start_idx_in_dataset):
                self.col_start_idx_in_dataset = int(identify_col_start_idx_in_dataset)
            identify_show_env_windows =  file_open.readline().split(";")[1]
            if identify_show_env_windows.startswith('n'):
                self.show_env_windows = False
            identify_show_display_labels =  file_open.readline().split(";")[1]
            if identify_show_display_labels.startswith('n'):
                self.show_display_labels = False
            identify_nr_of_decimals_in_values =  file_open.readline().split(";")[1]
            if self.check_if_number(identify_nr_of_decimals_in_values):
                self.nr_of_decimals_in_values = int(identify_nr_of_decimals_in_values)
            identify_time_interval_to_new_val_in_msc =  file_open.readline().split(";")[1]
            if self.check_if_number(identify_time_interval_to_new_val_in_msc):
                self.time_interval_to_new_val_in_msc = int(identify_time_interval_to_new_val_in_msc)
            identify_human_interaction = file_open.readline().split(";")[1]
            if identify_human_interaction.startswith('y'):
                self.human_interaction = True
            identify_time_to_run_sim = file_open.readline().split(";")[1]
            if self.check_if_number(identify_time_to_run_sim):
                self.time_to_run_sim = int(identify_time_to_run_sim)
            identify_run_full_time = file_open.readline().split(";")[1]
            if identify_run_full_time.startswith('y'):
                self.run_full_time = True
            identify_run_real_time = file_open.readline().split(";")[1]
            if identify_run_real_time.startswith('n'):
                self.run_real_time = False
            suppress_console_output = file_open.readline().split(";")[1]
            if suppress_console_output.startswith('y'):
                self.suppress_console_output = True
            output_file = file_open.readline().split(";")[1]
            if output_file:
                self.output_file = path + output_file

    @staticmethod
    def check_if_number(val):
        return True if re.match(r'[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?', val) else False

    @staticmethod
    def verify_if_files_exist(file_list):

        for file in file_list:
            if not os.path.exists(file):
                print(f'{file} does not exist')
                return False
        return True


class Console_and_File_Logger(object):

    def __init__(self, filename="output.txt", mode="w"):
        self.stdout = sys.stdout
        self.file = open(filename, mode)
        sys.stdout = self

    def __del__(self):
        self.close()

    def __enter__(self):
        pass

    def __exit__(self, *args):
        self.close()

    def write(self, message):
        self.stdout.write(message)
        self.file.write(message)

    def flush(self):
        self.stdout.flush()
        self.file.flush()
        os.fsync(self.file.fileno())

    def close(self):
        if self.stdout != None:
            sys.stdout = self.stdout
            self.stdout = None

        if self.file != None:
            self.file.close()
            self.file = None

class File_Logger(object):

    def __init__(self, filename="output.txt", mode="w"):
        self.stdout = sys.stdout
        self.file = open(filename, mode)
        sys.stdout = self

    def __del__(self):
        self.close()

    def __enter__(self):
        pass

    def __exit__(self, *args):
        self.close()

    def write(self, message):
        self.file.write(message)

    def flush(self):
        self.file.flush()
        os.fsync(self.file.fileno())

    def close(self):
        if self.file != None:
            self.file.close()
            self.file = None