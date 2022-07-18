#
# Module manifest for module 'ADReportingTools'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'ADReportingTools.psm1'

# Version number of this module.
ModuleVersion = '1.4.0'

# Supported PSEditions
CompatiblePSEditions = @("Desktop","Core")

# ID used to uniquely identify this module
GUID = '1e812b1f-dbe7-4d21-b4ea-7aff65d854ba'

# Author of this module
Author = 'Jeff Hicks'

# Company or vendor of this module
CompanyName = 'JDH Information Technology Solutions, Inc.'

# Copyright statement for this module
Copyright = '(c)2021 JDH Information Technology Solutions, Inc.'

# Description of the functionality provided by this module
Description = 'A set of PowerShell commands to gather information and create reports from Active Directory.'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.1'

# Minimum version of the PowerShell host required by this module
PowerShellHostVersion = '5.1'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @("ThreadJob")

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @(
    'types\aduser.types.ps1xml',
    'types\adgroupreport.types.ps1xml'
)

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @(
'formats\adaudittrail.format.ps1xml',
'formats\adfsmorole.format.ps1xml',
'formats\adsitesummary.format.ps1xml',
'formats\adgroupuser.format.ps1xml',
'formats\adbranchmember.format.ps1xml',
'formats\adsummary.format.ps1xml',
'formats\addchealth.format.ps1xml',
'formats\adreportingtool.format.ps1xml',
'formats\aduser.format.ps1xml',
'formats\adgroup.format.ps1xml',
'formats\adgroupreport.format.ps1xml',
'formats\addepartmentmember.format.ps1xml',
'formats\adcomputerreport.format.ps1xml',
'formats\adntds.format.ps1xml',
'formats\adbackup.format.ps1xml',
'formats\admanager.format.ps1xml'
)

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Show-DomainTree','Get-ADUserAudit','Get-ADSummary','Get-ADFSMO','Get-ADSiteSummary','Get-ADSiteDetail',
'Get-ADGroupUser','Get-ADBranch','Get-ADDomainControllerHealth','New-ADDomainReport','Get-ADReportingTools','Get-ADCanonicalUser',
'Get-ADUserCategory','Get-ADGroupReport','Split-DistinguishedName','New-ADChangeReport',
'Get-ADReportingToolsOptions','Set-ADReportingToolsOptions','Get-ADDepartment','Get-ADComputerReport', 'Get-NTDSInfo',
'Get-ADBackupStatus','Open-ADReportingToolsHelp','New-ADGroupReport','Get-ADManager'

# Variables to export from this module
VariablesToExport = 'ADUserReportingConfiguration','ADReportingToolsOptions','ADReportingDepartments'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'dt','fsmo','Get-ADCnUser','Parse-DN'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("ActiveDirectory","html","reporting")

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/jdhitsolutions/ADReportingTools/blob/main/LICENSE.txt'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/jdhitsolutions/ADReportingTools'

        # A URL to an icon representing this module.
         IconUri = 'https://raw.githubusercontent.com/jdhitsolutions/ADReportingTools/main/images/2PopulatedDomain01.png'

        # ReleaseNotes of this module
        ReleaseNotes = 'See the changelog at https://github.com/jdhitsolutions/ADReportingTools/blob/main/Changelog.md'

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false

        # External dependent modules of this module
        ExternalModuleDependencies = @("ActiveDirectory","DNSClient")

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

