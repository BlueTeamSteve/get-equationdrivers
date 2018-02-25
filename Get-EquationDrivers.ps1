$url = "https://raw.githubusercontent.com/x0rz/EQGRP_Lost_in_Translation/master/windows/Resources/Ep/drv_list.txt"
$tmpfile = New-TemporaryFile

Invoke-WebRequest -Uri $url -OutFile $tmpfile
$drvList = Import-Csv -Path $tmpfile -Header Name, Description

Write-Host "Getting Drivers, this may take a while..."
$liveDrvList = Get-WindowsDriver -Online | Select-Object -Property Driver, OriginalFileName, ClassName, ProviderName, Date

foreach ($drv in $liveDrvList) {
    $drvName = Split-Path -Leaf $drv.OriginalFileName
    $drvName = $drvName.TrimEnd(".inf")
    Add-Member -InputObject $drv -Name Name -Value $drvName -MemberType NoteProperty
}

$matched = Compare-Object $liveDrvList $drvList -property Name -IncludeEqual -ExcludeDifferent

Write-Host "Matched drivers below"
foreach ($match in $matched) {
    $mName = $match.Name
    $drvList.Where({$PSItem.Name -eq $mName})
}