To process the CSV file:
bash /path/to/super_script.sh --csv /path/to/cases.csv


To process a single repository:
bash super_script.sh \
  <GITHUB_URL> \
  <COMMIT_HASH> \
  <DIRECTORY_PATH>
  
  
The CSV file should contain the following columns:
repo_url,commit_sha,modules

Example CSV file:
repo_url,commit_sha,modules
https://github.com/Accenture/mercury,6b744cdbb2206feca62848df92b3bf542f890be5,extensions/rest-automation-lib
https://github.com/Accenture/mercury,8586dc79f8bf75a929896f0aac03fe95824d9578,system/platform-core
https://github.com/Accenture/mercury,e659caf000c2a714d921a52cbc85e13f56cef981,system/platform-core

Edit the super script and update paths:
LOG_DIR - where you want the logs saved
JAVA11_HOME - Path to your Java 11 installation
Step script paths (step_one.sh, step_two.sh, step_three.sh, step_four.sh)






