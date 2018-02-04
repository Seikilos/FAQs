param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$path)

if (! (Test-Path -path $path))
{
    throw "Path does not exist $path"
}
Write-Host "Checking $path for symlinks"

function Test-ReparsePoint([string]$path) 
{
    $file = Get-Item $path -Force -ea SilentlyContinue
    return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

Write-Host "List of symlinks"

Get-ChildItem -Recurse -Path $path | Where {

    if (Test-ReparsePoint $_.FullName )
    {
        Write-Host $_.FullName
    }

}

Write-Host "End of list"
