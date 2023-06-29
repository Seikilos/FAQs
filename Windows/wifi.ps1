# Two settings: Mode 1 -> short version, Mode 2 -> long version
# Sleep time: Reduce to 2 seconds to get more updates

# Bat file or cmd command: 
# powershell -command "Set-ExecutionPolicy Unrestricted -Scope Process ; . .\wifi.ps1"

Set-StrictMode -Version 3

$cmd = ((netsh wlan show interfaces) -Match '^\s+Signal' -Replace '^\s+Signal\s+:\s+' -Replace '%').Trim()

$mode = 1

while ($true) {

    $res = [int] $cmd

    if ($res -eq $false) {
        Write-Host ("(No data)")
    }
    else {

        $str1 = ("|" * $res + " ($res)")
        $str2 = 'O'
		
        $color = "Green"

        if ($res -lt 60) {
            $color = "Red"
        }
        elseif ($res -lt 80) {
            $color = "Yellow"
        }
		
        if ($mode -eq 1) {
            Write-Host $str1 -ForegroundColor $color
        }
        else {
            Write-Host $str2 -ForegroundColor $color -NoNewLine
        }
		
    }
    Start-Sleep -Seconds 2
}
