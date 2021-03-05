# Changelog for ADReportingTools

## 0.4.0

+ Added `Get-ADCanonicalUser` with an alias of `Get-ADCNUser`. (Issue #11)
+ Modified `Get-ADGroupUser` to fix a bug that was not getting the user's Title. (Issue #10)
+ Modified `Get-ADDomainControllerHealth` to include computer name in the `Services` property. (Issue #9)
+ Added a view for `ADDomainControllerService` type to `addchealth.format.ps1xml`. (Issue #7)
+ Modified default view for `Get-ADFSMO` to be a list. (Issue #6)
+ Added command help. (Issue #1)
+ Added `Get-ADReportingTools` command. (Issue #5)
+ Modified `New-ADDomainReport` to fix bug converting file path. (Issue #4)
+ Added alias `fsmo` for `Get-ADFSMO`. (Issue #8)
+ Moved `_formatDN` to `private.ps1`.
+ Updated module manifest with private data.

## 0.3.0

+ Updated `Get-ADGroupUser` to get member detail depending on the class.
+ Modified `Get-ADBranch` to include an `Enabled` property.
+ Added private helper functions `_inserttoggle` and `_getpopData`.
+ Added `New-ADDomainReport`.

## 0.2.0

+ Added a default List view to `adgroupuser.format.ps1xml`.dir
+ Added format file `adsummary.format.ps1xml`.
+ Added `Get-ADDCHealth` and format file `addchealth.format.ps1xml`.

## 0.0.1

+ Initial files
