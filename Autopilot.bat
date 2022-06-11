@echo off

:autopilotInfoBlock
    :: **POWERSHELL CMDLETS** Creates HWID directory, declares execution policy,defines script path, installs packages, runs autopilot PS script, and creates autopilotInfo.csv to be renamed below.
    Powershell "& {set-executionpolicy -scope Process -executionpolicy remotesigned -force; new-item -type directory -path 'C:\HWID'; set-location -path "C:\HWID"; $env:Path += ';C:\Program Files\WindowsPowerShell\Scripts'; install-packageprovider -name NuGet -requiredversion 2.8.5.201 -force; install-package -name get-windowsautopilotinfo -force; get-windowsautopilotinfo -outputfile autopilotInfo.csv;}"
    goto :autopilotInfoConfirmation

:autopilotInfoConfirmation
    :: User confirmation for pass/fail of the powershell cmdlets.
    set confirmSuccess=
    set /p confirmSuccess=Did Autopilot install, run, and create autopilotInfo.csv in C:\HWID? (Y/[N]):
    if %confirmSuccess%==Y goto :csvRenameBlock
    if %confirmSuccess%==y goto :csvRenameBlock
    if %confirmSuccess%==N goto :autopilotFail
    if %confirmSuccess%==n goto :autopilotFail

:csvRenameBlock
    :: Pulls serial number from BIOS and creates a temporary variable.
    echo Autopilot marked success, renaming .csv file.
    for /f "usebackq skip=1 tokens=* delims= " %%a in (`wmic bios get serialnumber`) do if not defined tempVar set "tempvar=%%a"

    :: Removes all spaces from temporary variable and creates new variable.
    set serialVar=%tempVar: =%
    echo System Serial Number Acquired.

    :: Changes Directory to where autopilotInfo.csv is saved.
    cd C:\HWID

    :: Renames autopilotInfo.csv to a serial specific .csv file.
    rename "autopilotInfo.csv" "%serialVar%.csv"
    echo Rename Completed.

    :: User confirmation for correct file rename.
    set confirmComplete=
    set /p confirmComplete=Does the .csv file match the serial on the unit?(Y/[N]):
    if %confirmComplete%==Y goto :moveFile
    if %confirmComplete%==y goto :moveFile
    if %confirmComplete%==N goto :renameFallback
    if %confirmComplete%==n goto :renameFallback

:moveFile
    :: Copy renamed .csv to USB drive
    echo Looks like you have discovered a feature still under development. Please go away!
    pause    

:autopilotFail
    echo Find out why it failed. Fix it. Try again.
    :: research funtionality to possible create and save an error log from PS cmdlets.
    pause

:renameFallback
    echo It's seems the code has a few hidden flaws, rename the file manually.
    rem add if statement to check if %serialVar%.csv exists, if yes goto moveFile


