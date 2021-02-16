$here = Split-Path -Path $MyInvocation.MyCommand.Path
$parent = Split-Path -Path $here
$module = Split-Path -Path $parent -Leaf

Write-Host "Importing module $module from $parent" -ForegroundColor Cyan

Import-Module $parent -force

InModuleScope $Module {
Describe ADReportingTools {
    It "does something useful" {
        $true | Should Be $true
    }
 }
}
