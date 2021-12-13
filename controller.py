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
from txt2actr.environment2actr.server_based_updater import *


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
    py_functions_in_cm = {}

    def __init__(self, absolute_path_uc=os.path.dirname(os.path.abspath(__file__)),
                 absolute_path_mc=os.path.dirname(os.path.abspath(__file__)),
                 config_specs=None, json_bool=True):

        self.absolute_path_uc = absolute_path_uc
        self.absolute_path_mc = absolute_path_mc
        self.json_bool = json_bool

        self.default_values = Default_Values_Specifier(absolute_path_uc, config_specs, json_bool)
        self.set_file_names()

        self.log = File_Logger(self.output_file) if self.suppress_console_output else Console_and_File_Logger(
            self.output_file)

    def instantiate_default_obj(self):

        self.objs_inst = Obj_Instantiator_For_ACTR_Env(self.sounds_specs, self.images_specs,
                                                       self.windows_labels_specs, self.buttons_specs,
                                                       self.windows_specs)

        self.objs_inst.inst_dicts_from_json() if self.json_bool else self.objs_inst.inst_dicts_from_csv()

        self.objs_inst.instantiate_objects_for_env()

    def construct_cognitive_model(self):

        print(f'A new cognitive model will be constructed: {self.cognitive_model_file} will be the cognitive model')

        cma = Cognitive_Model_Assembler(f'{self.absolute_path_uc}{self.use_case_folder}',
                                        self.absolute_path_mc,
                                        self.cognitive_model_file, self.show_display_labels,
                                        self.objs_inst.windows_dict, self.objs_inst.sounds_dict)

        cma.specify_components_from_json(self.cognitive_model_config_df) if self.json_bool \
            else cma.specify_components_from_csv(self.cognitive_model_specifications_file)

        cma.assemble_components()

    def do_run(self):

        ACTR_app_starter(self.actr_env)

        cognitive_model_file_transformed = self.cognitive_model_file
        # get rid of any non-alphanumeric characters at the beginning of path to file string
        # start_idx = re.search("[^\W\d]", cognitive_model_file_transformed).start()
        # cognitive_model_file_transformed = cognitive_model_file_transformed[start_idx:] \
        #    if cognitive_model_file_transformed.startswith(";") else cognitive_model_file_transformed

        analysis_class = None
        if os.path.exists(f'{self.absolute_path_da}analysis.py'):
            analysis_class = self.get_module(f'{self.absolute_path_da}analysis.py', 'analysis',
                                              'Analysis', self.abs_path_analysis_results)
        else:
            print("No data_analysis_folder specified. No analysis will be done.")

        actr_interface = ACTR_interface(self.actr_env, cognitive_model_file_transformed,
                                        self.objs_inst.windows_dict,
                                        self.objs_inst.sounds_dict,
                                        self.nr_of_decimals_in_values, self.show_display_labels,
                                        self.time_interval_to_new_val_in_msc, self.human_interaction,
                                        self.show_env_windows, analysis_class, self.py_functions_in_cm)
        actr_interface.connect_with_actr()

        env_simulator = None
        if self.ACTR_updates == 'log':
            env_simulator = Log_Based_Updater(actr_interface, self.column_separator,
                                              self.sampling_rate, self.skip_rate_in_log, self.row_start_idx_in_dataset,
                                              self.col_start_idx_in_dataset,
                                              self.start_time_of_first_event)
        elif self.ACTR_updates == 'task':
            env_simulator = self.get_module(f'{self.log_file_folder}',
                                                 'task_based_updater', 'Task_Based_Updater', analysis_class,
                                                 self.absolute_path_uc, actr_interface, self.column_separator,
                                                self.sampling_rate,
                                                self.skip_rate_in_log, self.row_start_idx_in_dataset,
                                                self.col_start_idx_in_dataset, self.start_time_of_first_event,
                                                self.nr_of_decimals_in_values)
        elif self.ACTR_updates == 'server':
            env_simulator = Server_Based_Updater(actr_interface, self.hostname, self.port,
                                                 self.default_values.list_of_values_from_server,
                                                 self.sampling_rate,
                                                 self.start_time_of_first_event)

        print(self.log_file_folder)

        if os.path.isfile(self.log_file_folder):
            if analysis_class:
                analysis_class.reset(os.path.basename(self.log_file_folder))
            sim_run_time = self.new_sim_time(self.log_file_folder) if self.sim_run_time == 0 else self.sim_run_time
            self.start_threads(actr_interface, env_simulator, sim_run_time,
                               self.log_file_folder, self.abs_path_analysis_results)
            if analysis_class:
                analysis_class.reset()

        elif os.path.isdir(self.log_file_folder):
            for log_file_name in [f for f in os.listdir(self.log_file_folder) if self.is_adequate_file(f)]:
                if analysis_class:
                    analysis_class.reset(log_file_name)
                sim_run_time = self.new_sim_time(
                    self.log_file_folder + log_file_name) if self.sim_run_time == 0 else self.sim_run_time
                # reload actr code for the next simulation
                actr_interface.reload_actr_code()
                self.start_threads(actr_interface, env_simulator, sim_run_time,
                                   self.log_file_folder + log_file_name, self.abs_path_analysis_results)
                if analysis_class:
                    analysis_class.reset()
        else:
            print(f'{self.log_file_folder} is neither file nor path')

        actr_interface.stop_actr()

    def get_module(self, path_to_py_file, module_name, class_name, *obj_pars):
        spec_file = importlib.util.spec_from_file_location(module_name, path_to_py_file)
        module = importlib.util.module_from_spec(spec_file)
        spec_file.loader.exec_module(module)
        object = getattr(module, class_name)

        return object(*obj_pars)

    def start_threads(self, actr_interface, env_simulator, sim_run_time, log_file_name, abs_path_analysis_results):

        actr_interface.set_actr_windows()
        actr_interface.log_file_name = log_file_name
        p1 = Thread(target=self.run_actr_model, args=(actr_interface, sim_run_time,
                                                      self.run_real_time, self.run_full_time,
                                                      log_file_name, abs_path_analysis_results))
        p2 = Thread(target=self.watch_log_file_and_pass_values, args=(env_simulator, log_file_name))
        try:
            print(
                f"{log_file_name} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ started")
            p1.start()
            p2.start()
            while actr_interface.actr_running():
                time.sleep(1)
            print(f" {log_file_name} @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ done")
        except KeyboardInterrupt:
            del actr_interface
            del env_simulator
            # sys.exit(0)
        except Exception as e:
            print(e)

    @staticmethod
    def watch_log_file_and_pass_values(env_simulator, log_file_name):  # Observes changes and passes them to ACTR
        env_simulator.specify_and_pass(log_file_name)

    @staticmethod
    def run_actr_model(actr_interface, n, real_time, full_time, log_file_name, abs_path_analysis_results):

        actr_interface.run_actr(n, real_time, full_time)

        if abs_path_analysis_results:
            # .split('\\').split('/')[-1] to get rid of path and [:-4 ] to get rid of the file type extension + '.'
            file_name = f'{log_file_name[:-4]}'.split('\\')[-1].split('/')[-1]

            #with open(f'{abs_path_analysis_results}DM_test_{file_name}.txt', 'w+') as output_file:
            #    output_file.write(actr_interface.get_dm())

    @staticmethod
    def do_task(task_execution):  # Observes changes and passes them to ACTR
        task_execution.observe_events()

    def is_adequate_file(self, file_name):

        return os.path.isfile(self.log_file_folder + file_name) and file_name.endswith('.csv') \
               and not file_name.startswith('.')

    def new_sim_time(self, file):
        with open(file) as f:
            lines = len(f.readlines())
        return int(lines / 100)

    def set_file_names(self):

        self.ACTR_updates = self.default_values.ACTR_updates
        if not (self.ACTR_updates == 'log' or self.ACTR_updates == 'task'or self.ACTR_updates == 'server'):
            sys.exit("You need to specify whether the simulation is log_based (log) or task_based (task)")

        if self.ACTR_updates=='server':
            self.list_of_values_from_server = self.default_values.list_of_values_from_server
            self.hostname = self.default_values.hostname
            self.port = self.default_values.port

        self.actr_env = self.default_values.actr_env

        self.log_file_folder = self.default_values.log_file_folder
        self.absolute_path_da = self.default_values.absolute_path_da

        if self.default_values.cognitive_model_specifications_file:
            self.cognitive_model_specifications_file = self.default_values.cognitive_model_specifications_file
        self.cognitive_model_file = self.default_values.cognitive_model_file
        self.cognitive_model_config_df = self.default_values.cognitive_model_config_df

        self.windows_specs = self.default_values.windows_specs
        self.buttons_specs = self.default_values.buttons_specs
        self.images_specs = self.default_values.images_specs
        self.windows_labels_specs = self.default_values.windows_labels_specs
        self.sounds_specs = self.default_values.sounds_specs

        self.column_separator = self.default_values.column_separator
        self.start_time_of_first_event = int(self.default_values.start_time_of_first_event)
        self.sampling_rate = int(self.default_values.sampling_rate)
        self.skip_rate_in_log = int(self.default_values.skip_rate_in_log)
        self.col_start_idx_in_dataset = int(self.default_values.col_start_idx_in_dataset)
        self.row_start_idx_in_dataset = int(self.default_values.row_start_idx_in_dataset)
        self.show_env_windows = self.default_values.show_env_windows
        self.show_display_labels = self.default_values.show_display_labels
        self.nr_of_decimals_in_values = int(self.default_values.nr_of_decimals_in_values)
        self.time_interval_to_new_val_in_msc = int(self.default_values.time_interval_to_new_val_in_msc)
        self.human_interaction = self.default_values.human_interaction
        self.sim_run_time = int(self.default_values.time_to_run_sim)
        self.run_full_time = self.default_values.run_full_time
        self.run_real_time = self.default_values.run_real_time
        self.py_functions_in_cm = self.default_values.py_functions_in_cm
        self.suppress_console_output = self.default_values.suppress_console_output
        self.output_file = self.default_values.output_file

        self.use_case_folder = self.default_values.use_case_folder

        self.absolute_path_da = self.default_values.absolute_path_da
        self.abs_path_analysis_results = self.default_values.abs_path_analysis_results

        if self.json_bool:
            self.windows_specs = self.default_values.windows_specs
            self.buttons_specs = self.default_values.buttons_specs
            self.images_specs = self.default_values.images_specs
            self.windows_labels_specs = self.default_values.windows_labels_specs
            self.sounds_specs = self.default_values.sounds_specs


class Default_Values_Specifier:

    def __init__(self, absolute_path_of_use_case_specs, config_specs, json_bool):

        self.mac_vs_ws = "\\" if _platform.startswith('win') else "/"
        temp_path = absolute_path_of_use_case_specs.replace("/", self.mac_vs_ws)
        path = temp_path if temp_path.endswith(self.mac_vs_ws) else f'{temp_path}{self.mac_vs_ws}'

        # specify default values
        self.cognitive_model_specifications_file = None
        self.cognitive_model_config_df = None
        self.actr_env = 'e'
        self.column_separator = ";"
        self.start_time_of_first_event = False
        self.sampling_rate = 100
        self.skip_rate_in_log = 50
        self.col_start_idx_in_dataset = 0
        self.row_start_idx_in_dataset = 1
        self.show_env_windows = True
        self.show_display_labels = True
        self.nr_of_decimals_in_values = 2
        self.time_interval_to_new_val_in_msc = 1
        self.human_interaction = False

        self.time_to_run_sim = 1000
        self.run_full_time = False
        self.run_real_time = True
        self.suppress_console_output = False
        self.output_file = 'output.txt'

        self.py_functions_in_cm = {}

        self.set_json_values(path, config_specs) if json_bool else self.set_csv_values_into_lists(path, config_specs)

        if json_bool:
            sys.exit(0) if not self.verify_if_files_exist([self.absolute_path_da,self.log_file_folder]) else True
        elif not json_bool:
            sys.exit(0) if not self.verify_if_files_exist([self.absolute_path_da, self.log_file_folder, self.windows_specs,
                                                           self.cognitive_model_file, self.buttons_specs,
                                                           self.images_specs, self.windows_labels_specs,
                                                           self.sounds_specs]) else True

    def set_json_values(self, path, json_data):

        #with open(path + config_file, 'r') as file_open:
            #json_data = json.load(file_open)[0]

        self.ACTR_updates = json_data["simulationType"]
        if not (self.ACTR_updates == 'log' or self.ACTR_updates == 'task' or self.ACTR_updates == 'server'):
            sys.exit("You need to specify whether the simulation is log_based (log) or task_based (task)")

        if (self.ACTR_updates == 'server'):
            self.list_of_values_from_server = json_data["valuesList"]
            self.hostname = json_data["hostname"]
            self.port = json_data["port"]

        self.actr_env = json_data["startACTR"]
        json_paths_obj = json_data["paths"]
        self.use_case_folder = json_paths_obj["use_case_folder"]

        path = self.set_os_path_sep(path + self.use_case_folder)
        path = path + self.mac_vs_ws if not path.endswith(self.mac_vs_ws) else path

        logs = self.set_os_path_sep(path + json_paths_obj["simulationSpecifications"])
        self.log_file_folder = logs if (
                    logs.endswith(self.mac_vs_ws) or os.path.isfile(logs)) else f'{logs}{self.mac_vs_ws}'

        if "cognitiveModelSpecifications" in json_paths_obj:
            self.cognitive_model_specifications_file = self.set_os_path_sep(
                path + json_paths_obj["cognitiveModelSpecifications"])
        self.cognitive_model_file = self.set_os_path_sep(path + json_paths_obj["cognitiveModel"])
        self.cognitive_model_config_df = json_data["cognitive_model_config"]

        # the assignment of the following five file names is not necessary if
        # their specifications have been assigned in the json file directly.
        if "windowsSpecification" in json_paths_obj:
            self.windows_specs = self.set_os_path_sep(path + json_paths_obj["windowsSpecification"])
        if "buttonsSpecification" in json_paths_obj:
            self.buttons_specs = self.set_os_path_sep(path + json_paths_obj["buttonsSpecification"])
        if "imagesSpecification" in json_paths_obj:
            self.images_specs = self.set_os_path_sep(path + json_paths_obj["imagesSpecification"])
        if "windowsLabelMapping" in json_paths_obj:
            self.windows_labels_specs = self.set_os_path_sep(path + json_paths_obj["windowsLabelMapping"])
        if "soundsLabelMapping" in json_paths_obj:
            self.sounds_specs = self.set_os_path_sep(path + json_paths_obj["soundsLabelMapping"])

        temp_path_da = self.set_os_path_sep(path + json_paths_obj["data_analysis_folder"])
        self.absolute_path_da = temp_path_da if temp_path_da.endswith(self.mac_vs_ws) else f'{temp_path_da}{self.mac_vs_ws}'

        self.rel_path_results_folder = self.set_os_path_sep(json_paths_obj["resultsFolder"])
        temp_path_res = f'{self.absolute_path_da}{self.rel_path_results_folder}'
        self.abs_path_analysis_results = {temp_path_res} if temp_path_res.endswith(self.mac_vs_ws) else f'{temp_path_res}{self.mac_vs_ws}'

        output_file = json_paths_obj["consoleOutputACTR"]

        if output_file:
            self.output_file = path + output_file

        json_params_obj = json_data["params"]

        self.windows_specs = json_params_obj["windows_specification"]
        self.buttons_specs = json_params_obj["buttons_specification"]
        self.images_specs = json_params_obj["images_specification"]
        self.windows_labels_specs = json_params_obj["windows_labels_mapping"]
        self.sounds_specs = json_params_obj["sounds_and_speech_labels_mapping"]

        self.column_separator = json_data["columnSeparator"]

        if "scheduleNextPossibleEvent" in json_data:
            self.start_time_of_first_event = json_data["scheduleNextPossibleEvent"]
        if isinstance(json_data["startTimeFirstEvent"], int):
            self.start_time_of_first_event = json_data["startTimeFirstEvent"]
        if isinstance(json_data["samplingRateHz"], int):
            self.sampling_rate = int(json_data["samplingRateHz"])
        if isinstance(json_data["skipRateInLog"], int):
            self.skip_rate_in_log = int(json_data["skipRateInLog"])
        if isinstance(json_data["columnStartIndex"], int):
            self.col_start_idx_in_dataset = json_data["columnStartIndex"]
        if isinstance(json_data["rowStartIndex"], int):
            self.row_start_idx_in_dataset = json_data["rowStartIndex"]
        if isinstance(json_data["environmentWindows"], bool):
            self.show_env_windows = json_data["environmentWindows"]
        if isinstance(json_data["displayLabels"], bool):
            self.show_display_labels = json_data["displayLabels"]
        if isinstance(json_data["decimalNumbers"], int):
            self.nr_of_decimals_in_values = json_data["decimalNumbers"]
        if isinstance(json_data["timeIntervalMilliseconds"], int):
            self.time_interval_to_new_val_in_msc = json_data["timeIntervalMilliseconds"]
        if isinstance(json_data["humanInteraction"], bool):
            self.human_interaction = json_data["humanInteraction"]
        if isinstance(json_data["simulationTimeSeconds"], int):
            self.time_to_run_sim = json_data["simulationTimeSeconds"]
        if isinstance(json_data["fulltimeACTR"], bool):
            self.run_full_time = json_data["fulltimeACTR"]
        if isinstance(json_data["realtimeACTR"], bool):
            self.run_real_time = json_data["realtimeACTR"]
        if isinstance(json_data["pyFunctionsInCognitiveModel"], dict):
            self.py_functions_in_cm = json_data["pyFunctionsInCognitiveModel"]
        if isinstance(json_data["consoleOutput"], bool):
            self.suppress_console_output = json_data["consoleOutput"]

    def set_csv_values_into_lists(self, path, config_file):

        if not os.path.exists(path + config_file):
            sys.exit(f'{path + config_file} does not exist')

        with open(path + config_file, 'r') as file_open:

            self.ACTR_updates = file_open.readline().split(";")[1]
            if not (self.ACTR_updates == 'log' or self.ACTR_updates == 'task' or self.ACTR_updates == 'server'):
                sys.exit("You need to specify whether the simulation is log_based (log) or task_based (task)")

            self.actr_env = file_open.readline().split(";")[1]

            self.log_file_folder = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.cognitive_model_specifications_file = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.cognitive_model_file = self.set_os_path_sep(path + file_open.readline().split(";")[1])

            self.windows_specs = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.buttons_specs = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.images_specs = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.windows_labels_specs = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.sounds_specs = self.set_os_path_sep(path + file_open.readline().split(";")[1])

            # relative path to data analysis folder
            temp_path_da = self.set_os_path_sep(path + file_open.readline().split(";")[1])
            self.absolute_path_da = f'{temp_path_da}' if temp_path_da.endswith(self.mac_vs_ws) else f'{temp_path_da}{self.mac_vs_ws}'

            # relative path to results folder
            temp_path_res = f'{self.absolute_path_da}{self.set_os_path_sep(file_open.readline().split(";")[1])}'
            self.abs_path_analysis_results = f'{temp_path_res}' if temp_path_res.endswith(
                self.mac_vs_ws) else f'{temp_path_res}{self.mac_vs_ws}'

            self.use_case_folder = ""

            self.set_os_path_sep(file_open.readline().split(";")[1])

            identify_start_time_of_first_event = file_open.readline().split(";")[1]
            if self.check_if_number(identify_start_time_of_first_event):
                self.start_time_of_first_event = int(identify_start_time_of_first_event)
            identify_sampling_rate = file_open.readline().split(";")[1]
            if self.check_if_number(identify_sampling_rate):
                self.sampling_rate = int(identify_sampling_rate)
            identify_skip_rate_in_log = file_open.readline().split(";")[1]
            if self.check_if_number(identify_skip_rate_in_log):
                self.skip_rate_in_log = int(identify_skip_rate_in_log)
            identify_col_start_idx_in_dataset = file_open.readline().split(";")[1]
            if self.check_if_number(identify_col_start_idx_in_dataset):
                self.col_start_idx_in_dataset = int(identify_col_start_idx_in_dataset)
            identify_row_start_idx_in_dataset = file_open.readline().split(";")[1]
            if self.check_if_number(identify_row_start_idx_in_dataset):
                self.row_start_idx_in_dataset = int(identify_row_start_idx_in_dataset)
            identify_show_env_windows = file_open.readline().split(";")[1]
            if identify_show_env_windows.startswith('n'):
                self.show_env_windows = False
            identify_show_display_labels = file_open.readline().split(";")[1]
            if identify_show_display_labels.startswith('n'):
                self.show_display_labels = False
            identify_nr_of_decimals_in_values = file_open.readline().split(";")[1]
            if self.check_if_number(identify_nr_of_decimals_in_values):
                self.nr_of_decimals_in_values = int(identify_nr_of_decimals_in_values)
            identify_time_interval_to_new_val_in_msc = file_open.readline().split(";")[1]
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

            self.py_functions_in_cm = ast.literal_eval(file_open.readline().split(";")[1])
            suppress_console_output = file_open.readline().split(";")[1]
            if suppress_console_output.startswith('y'):
                self.suppress_console_output = True
            output_file = file_open.readline().split(";")[1]
            if output_file:
                self.output_file = path + output_file

    @staticmethod
    def set_os_path_sep(path_to_file):
        return path_to_file.replace("/", "\\") if _platform.startswith("win") else path_to_file.replace("\\", "/")

    @staticmethod
    def check_if_number(val):

        return isinstance(val, int) or isinstance(val, float)

        # return True if re.match(r'[+-]?(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?', val) else False

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
