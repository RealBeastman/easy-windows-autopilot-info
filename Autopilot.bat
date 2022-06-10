

:: Powershell cmdlets. Creates HWID directory, declares execution policy, installs necessary packages, runs autopilot PS script, and creates a serial specific .csv file.
REM Powershell "& {set-executionpolicy -scope Process -executionpolicy remotesigned -force; new-item -type directory -path 'C:\HWID'; set-location -path "C:\HWID"; $env:Path += ';C:\Program Files\WindowsPowerShell\Scripts'; install-packageprovider -name NuGet -requiredversion 2.8.5.201 -force; install-package -name get-windowsautopilotinfo -force; get-windowsautopilotinfo -outputfile serialRename.csv;}"
