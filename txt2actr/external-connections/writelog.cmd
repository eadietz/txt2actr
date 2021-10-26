:: run as writelog.cmd raw_data log_file
set raw_data=%1
set log_file=%2
set delay=%3
for /f "tokens=*" %%s in (%raw_data%) do (echo %%s; >>%log_file%)