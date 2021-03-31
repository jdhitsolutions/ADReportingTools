# Changelog

This is a summary of major changes in the ADReportingTools module since it was released as a 1.0 product.

## 1.2.0

+ Revised help for `Show-DomainTree` to indicate it must be run in a console session and not the PowerShell ISE. (([Issue #23](https://github.com/jdhitsolutions/ADReportingTools/issues/23)))
+ Add function `New-ADGroupReport` and CSS file `groupreport.css`.
+ Added missing help for `Get-ADComputerReport`.
+ Added argument completer for `SERVER` parameter on all commands in this module and the `Get` commands from the ActiveDirectory module.
+ Updated `README.md`.

## 1.1.0

+ Fix typo in `$ADReportingHash` Note. ([Issue #22](https://github.com/jdhitsolutions/ADReportingTools/issues/22))
+ Added `Open-ADReportingToolsHelp` to launch a PDF with module documentation. ([Issue #2](https://github.com/jdhitsolutions/ADReportingTools/issues/2))
+ Fixed bad parameter in `New-ADChangeReport`. ([Issue #24](https://github.com/jdhitsolutions/ADReportingTools/issues/24))
+ Modified CSS parameter in `New-DomainReport`.
+ Modified `Show-DomainTree` to test for ConsoleHost as a match and not equal to. ([Issue #23](https://github.com/jdhitsolutions/ADReportingTools/issues/23))
+ Updated `README.md`.
+ Help updates.

## 1.0.0

+ First stable release.
+ Updated `README.md`.
+ Added command `Get-ADDepartment` and format file `addepartmentmember.format.ps1xml`.
+ Exporting a global variable called `$ADReportingHash` which is used as an argument completer for `Get-ADDepartment`.
+ Moved ANSI colors from `Show-DomainTree` to `$ADReportingToolsOptions`. ([Issue #17](https://github.com/jdhitsolutions/ADReportingTools/issues/17))
+ Added class coloring to ADBranch output.
+ Modified ADBranch output to show disabled user accounts in red.
+ Added command `Get-ADComputerReport` and format file `adcomputerreport.format.ps1xml`.
+ Modified `adgroupreport.format.ps1xml` to add member count to the default output. ([Issue #21](https://github.com/jdhitsolutions/ADReportingTools/issues/21))
+ Added a view called `summary` to  `adgroupreport.format.ps1xml`.
+ Added command `Get-NTDSInfo` and format file `adntds.format.ps1xml`. ([Discussion #18](https://github.com/jdhitsolutions/ADReportingTools/discussions/18))
+ Modified `Get-ADSummary` to better display PSBoundParameters with Verbose output in the PowerShell ISE.
+ Updated format files to ensure ANSI formatting only happens in a Console host.
+ Added command `Get-ADBackupStatus` and format file `adbackupstatus.format.ps1xml`.
+ Help updates.
