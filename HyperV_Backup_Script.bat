@ECHO off
REM NOTE: Please gracefully shutdown any running VM's before executing this script,
REM       The virtual machine management service (VMMS) will be stopped.

REM NOTE: Please set variables below.

REM Source directory
set sourceDirectory="A:\Hyper-V"
REM Target directory
set targetDirectory="A:\Hyper-V Backup %day%-%month%-%year%"
REM VM Name
set VMNAME="VMNAME1.vhdx"
REM VM ID
set VMID="12345678-1234-1234-1234-123456789ABC"

REM Script start's here
@ECHO on
@REM Stop virtual machine management service (VMMS)
@REM This will changes the working directory to System32
@sc stop vmms
@ECHO[
@REM 2 min timeout to ensure service is stopped before continuing
@ECHO Wait 120 seconds and confirm service has stopped..
@timeout 120
@ECHO[
@REM Confirm service has stopped
@sc query vmms

@ECHO off
REM Change the working directory back to the script location
SET localpath=%~dp0
cd %localpath%

REM Find current date
for /f "skip=1" %%i in ('wmic os get localdatetime') do if not defined fulldate set fulldate=%%i
set year=%fulldate:~0,4%
set month=%fulldate:~4,2%
set day=%fulldate:~6,2%
REM Create target directory
md %targetDirectory%
@ECHO[
ECHO Directory %targetDirectory% created..
@ECHO[
@REM 10 second timeout to confirm directory is created correctly
timeout 10
@ECHO[

REM Copy Source directory to Target directory
ECHO Copying directory
REM /MIR will replicate data for changed files, 
REM /SEC will replicate security for changed files, 
REM /SECFIX will update security for unchanged files.
ROBOCOPY /MIR /SEC /SECFIX %sourceDirectory% %targetDirectory%
@ECHO[
ECHO Copy complete
@ECHO[
@REM 20 second timeout to confirm directory has copied correctly
timeout 20

REM Remove double quotes from variables for concatenation further on
setlocal enabledelayedexpansion
set target=!targetDirectory:~1,-1!
set vm=!VMNAME:~1,-1!
REM Restore Hyper V security permissons
ECHO Resore VM security permissions
ECHO icacls "!target!\VHD\!vm!" /grant %VMID%:(F)
@REM 10 second timeout to confirm directory is created correctly
timeout 10

@ECHO on
@REM Start virtual machine management service (VMMS)
@REM This changes the working directory to System32
@sc start vmms
@ECHO[
@REM 2 min timeout to ensure service is stopped before continuing
@ECHO Wait 120 seconds and confirm service has started..
@timeout 120
@ECHO[
@REM Confirm service has stopped
@sc query vmms
REM Script end's here