@ECHO off
REM NOTE: Please gracefully shutdown any running VM's before executing this script,
REM       The virtual machine management service (VMMS) will be stopped.

REM Find current date
for /f "skip=1" %%i in ('wmic os get localdatetime') do if not defined fulldate set fulldate=%%i
set year=%fulldate:~0,4%
set month=%fulldate:~4,2%
set day=%fulldate:~6,2%

REM NOTE: Please set parameters below.

REM Map drive & Authenticate network share (Optional, Remove ::)
::net use B: \\192.168.1.254\Hyper-V /user:USERNAME PASSWORD

REM Source OS directory
set sourceDirectory_OS="X:\Hyper-V"
REM Source Data directory
set sourceDirectory_DATA="X:\Hyper-V"

REM Target OS directory
set targetDirectory_OS="X:\Hyper-V %day%-%month%-%year%\OS Backup"
REM Target Data directory
set targetDirectory_DATA="X:\Hyper-V %day%-%month%-%year%\DATA Backup"

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

REM Create target directory
md %targetDirectory_OS%
@ECHO[
ECHO Directory %targetDirectory_OS% created..
@ECHO[
@REM 10 second timeout to confirm directory is created correctly
timeout 10
@ECHO[

REM Copy Source directory to Target directory
ECHO Copying OS directory
REM /MIR will replicate data for changed files, 
REM /SEC will replicate security for changed files, 
REM /SECFIX will update security for unchanged files.
ROBOCOPY %sourceDirectory_OS% %targetDirectory_OS% /MIR /SEC /SECFIX /R:0 /W:0 /LOG:%targetDirectory_OS%/Backup_Logfile_%day%-%month%-%year%.log
@ECHO[
ECHO Copy complete
@ECHO[
@REM 20 second timeout to confirm directory has copied correctly
timeout 20

REM Create target Data directory
md %targetDirectory_DATA%
@ECHO[
ECHO Directory %targetDirectory_DATA% created..
@ECHO[
@REM 10 second timeout to confirm directory is created correctly
timeout 10
@ECHO[

REM Copy Source Data directory to Target Data directory
ECHO Copying directory
REM /MIR will replicate data for changed files, 
REM /SEC will replicate security for changed files, 
REM /SECFIX will update security for unchanged files.
ROBOCOPY %sourceDirectory_DATA% %targetDirectory_DATA% /MIR /SEC /SECFIX /R:0 /W:0 /LOG:%targetDirectory_DATA%/Backup_Logfile_%day%-%month%-%year%.log
@ECHO[
ECHO Copy complete
@ECHO[
@REM 20 second timeout to confirm directory has copied correctly
timeout 20

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