param([string]$COMPUTER_FOLDER)

$MAX_ONLY = $True

if ($COMPUTER_FOLDER -eq $Null -or $COMPUTER_FOLDER.Length -eq 0) {
    $COMPUTER_FOLDER = $Env:COMPUTER_FOLDER
}


$dir = Get-ChildItem -Path $COMPUTER_FOLDER -Directory | Select-Object FullName | Where-Object {
        $_.FullName.split("\\")[-1] -match "\d\d*"
    } | ForEach-Object {@{path=$_.FullName;number=[int]($_.FullName.split("\\")[-1]);}}

if ($MAX_ONLY){
    $max = ($dir| ForEach-Object {$_.number}  | Measure-Object -Maximum).Maximum
    $target = ($dir | Where-Object -Property number -eq $max).path
    Write-Output "writing to: $($target)"

    Copy-Item -Force -Recurse $PSScriptRoot/* $target
} else {
    Write-Output 'NOT IMPLEMENTED'
}


#Write-Output $dir


