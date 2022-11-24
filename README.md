# txt2actr

## General Info

txt2actr is developed with the goal
provide an interface to the cognitive architecture ACT-R.

txt2actr folder structure is as follows:
* txt2actr
 * environment2actr
 * external-connections
 * model2actr
* benchmarks
 * model-components
 * use-cases
  * driving-task
  * flight-task
  * paired-associates-task
 * suppression task

txt2actr provides the interface to ACT-R.
There are three different types of environment manipulations through ACT-R:
* task-based updates
* log-based updates/ server-based updates

benchmarks contains a few examples of task-based updates (paired-associates-task 
and suppression task) and log-based updates (driving-task and flight-task).


## Setup 
[this library is still in development and is incomplete]
1. Download and install python (tested with 3.8, https://www.python.org/downloads/) and ACT-R ( http://act-r.psy.cmu.edu/software/)
2. For Linux, create a link to run-act-r.bat and copy it into the txt2actr folder. For Windows, name the link run-act-r.bat.lnk. For Mac OS add ACT-R to your applications (should be accessible as /Applications/ACT-R/run-act-r.command)
3. run the simulation with run_simulation.py with the following parameters:
-c config.json (specify the config file)
-e (optional, if added, it will not start ACT-R, and you will have to start ACT-R yourself before starting the simulation)
-d (optional, if added and you are using server based simulation, it will not get the values from the server but just dummy values)
-m (optional, if added it will not load the model in ACT-R, and you will have to load the model in ACT-R before starting the simulation)


