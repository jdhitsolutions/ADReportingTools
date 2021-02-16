
Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 |
Foreach-Object {
    . $_.FullName
}