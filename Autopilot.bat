@echo off

:autopilotInfoBlock
    :: **POWERSHELL CMDLETS** Creates HWID directory, declares execution policy, defines script path, installs packages, runs autopilot PS script, and creates autopilotInfo.csv to be renamed below.
    Powershell "& {set-executionpolicy -scope Process -executionpolicy remotesigned -force; new-item -type directory -path 'C:\HWID'; set-location -path "C:\HWID"; $env:Path += ';C:\Program Files\WindowsPowerShell\Scripts'; install-packageprovider -name NuGet -requiredversion 2.8.5.201 -force; install-package -name get-windowsautopilotinfo -force; get-windowsautopilotinfo -outputfile autopilotInfo.csv;}"
    goto :autopilotInfoConfirmation

:autopilotInfoConfirmation
    :: Check for pass/fail of the powershell cmdlets.
    if exist C:\HWID\autopilotInfo.csv (
        goto :csvRenameBlock
    ) else (
        goto :autopilotFail
    )

:csvRenameBlock
    :: Pulls serial number from BIOS and creates a temporary variable.
    echo Autopilot marked success, renaming .csv file.
    for /f "usebackq skip=1 tokens=* delims= " %%a in (`wmic bios get serialnumber`) do if not defined tempVar set "tempvar=%%a"

    :: Removes all spaces from temporary variable and creates new variable.
    set serialVar=%tempVar: =%
    echo System Serial Number Acquired.

    :: Renames autopilotInfo.csv to a serial specific .csv file.
    rename C:\HWID\autopilotInfo.csv %serialVar%.csv
    echo Rename Completed.

    :: Check for correct file rename to proceed with copying to removable drive.
    if exist C:\HWID\%serialVar%.csv goto :copyFile

:copyFile
    :: Checks for removable drive and folder to copy file to.
    if exist D:\HWID (
        echo Copying file to removable drive.
        copy C:\HWID\%serialVar%.csv D:\HWID
    ) else (
        powershell write-host -fore Red Removable drive cannot be detected, or path is incorrect.
    )
    pause
    goto :eof  

:autopilotFail
    :: Returns error to user and quits session.
    echo .csv file has failed to be created. This is likely due to the script not installing correctly, or not being run as administrator. Try again.
    pause


