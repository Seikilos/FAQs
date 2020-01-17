# Script to rename the AppX database that can prevent Sysprep from running
# so that Windows will rebuild the AppX databse from scratch the the correct
# information and thus allowing Sysprep to complete successfully.
# Stop the service
Stop-Service -Name "StateRepository" -Force
# Disable the State Repository Service so that the files can be renamed
Set-Service -Name "StateRepository" -StartupType Disabled
# Export the existing permissions
icacls C:\ProgramData\Microsoft\Windows\AppRepository /save AclFile /T
# Take ownership of specific files
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd-shm
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd-wal
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd-shm
takeown /F C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd-wal
# Rename the files
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment_corrupted.srd -Force
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd-shm C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment_corrupted.srd-shm -Force
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment.srd-wal C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment_corrupted.srd-wal -Force
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine_corrupted.srd -Force
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd-shm C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine_corrupted.srd-shm -Force
Rename-Item C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine.srd-wal C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine_corrupted.srd-wal -Force
# Import the permissions back
icacls C:\ProgramData\Microsoft\Windows\AppRepository /restore AclFile
# Re-Enable the service
Set-Service -Name "StateRepository" -StartupType Manual
# Re-Start the State Repository Service
Start-Service -Name "StateRepository"
# Try and verify that everything is really working
if (Test-Path C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Deployment_corrupted.srd)
{
if (Test-Path C:\ProgramData\Microsoft\Windows\AppRepository\StateRepository-Machine_corrupted.srd)
{
# If the two database files have been renamed and the service is running again then delete the scheduled task
if ((Get-Service -Name "StateRepository").Status -eq "Running")
{
# Delete the scheduled task
schtasks /delete /TN Reset-AppX /F
}
}
}
