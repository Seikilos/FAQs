Write-Output "Running winsat formal (output is supressed) ..."
. winsat formal | Out-Null

$item = Get-ChildItem "$env:SystemRoot\Performance\WinSat\DataStore" -Filter "*Formal*" | Sort-Object -Descending {$_.CreationTime} | Select-Object -First 1

[xml]$xml = Get-Content $item.FullName

Write-Output "SPR"
Write-Output $xml.WinSAT.WinSPR

Write-Output "==============================="


function print($depth, $node)
{
    $str = ("`t" * $depth) + $node.Name
   
    if($node.ChildNodes.Count -eq 1 -and $node.ChildNodes[0].Name -eq "#text")
    {
        $str += (": "+ $node.'#text'.Trim()) + " " + ($node.Attributes | Select-Object -ExpandProperty Value)
    }
    Write-Output $str

    if ($node.ChildNodes[0].Name -eq "#text")
    {
        return
    }

    $node.ChildNodes | ForEach-Object {
        print ($depth +1) $_
    }
}

print 0 $xml.WinSAT.Metrics
