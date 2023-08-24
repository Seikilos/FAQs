Set-StrictMode -Version 3

# Source https://stackoverflow.com/questions/47867949/how-can-i-check-for-a-pending-reboot/
function Test-PendingReboot {
    
    $cbsPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    
    if (Get-ChildItem $cbsPath -EA Ignore) {
        Write-Host("$cbsPath returned true")
        return $true  
    }

    $autoUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    if (Get-Item $autoUpdatePath -EA Ignore) {
        Write-Host("$autoUpdatePath returned true")
        return $true 
    }

    if (Test-PendingFileRename) {
        return $true
    }
    
    try { 
        $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
        $status = $util.DetermineIfRebootPending()
        if (($status -ne $null) -and $status.RebootPending) {
            Write-Host("WMI CCM_ClientUtilities requires reboot")
            return $true
        }
    }

    catch { }
    Write-Host("No reboot pending")
    return $false
}

function Test-PendingFileRename {
    [OutputType('bool')]
    [CmdletBinding()]
    param()
    $operations = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\').GetValue('PendingFileRenameOperations')
    if ($null -eq $operations) {
        $false
    }
    else {
        $trueOperationsCount = $operations.Length / 2
        $trueRenames = [System.Collections.Generic.Dictionary[string, string]]::new($trueOperationsCount)
        for ($i = 0; $i -ne $trueOperationsCount; $i++) {
            $operationSource = $operations[$i * 2]
            $operationDestination = $operations[$i * 2 + 1]
            if ($operationDestination.Length -eq 0) {
                Write-Verbose "Ignoring pending file delete '$operationSource'"
            }
            else {
                Write-Host "Found a true pending file rename (as opposed to delete). Source '$operationSource'; Dest '$operationDestination'"
                $trueRenames[$operationSource] = $operationDestination
            }
        }
        $trueRenames.Count -gt 0
    }
}


Test-PendingReboot
