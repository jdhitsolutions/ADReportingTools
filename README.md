# ADReportingTools

This module contains a collection of PowerShell tools that you can use to generate reports and gather information about your Active Directory domain. Many of these commands will require the ActiveDirectory module.

## Completed

+ Get-ADBranch
+ Get-ADCanonicalUser
+ Get-ADGroupUser
+ Get-ADFSMO
+ Get-ADSiteDetail
+ Get-ADSiteSummary
+ Get-ADSummary
+ Get-ADUserAudit
+ Get-ADDomainControllerHealth
+ New-ADDomainReport
+ Show-DomainTree
+ Get-ADReportingTools
+ Get-ADUserCategory

## Format and Type Extensions

```powershell
Get-ADUser artd | Select-Object Names
```

Or use a defined view for Active Directory user objects.

```powershell
Get-ADUser -SearchBase "ou=employees,dc=company,dc=pri" -filter * |
Format-Table -view names
```

## Planned

+ Get-ADGroupReport
  + group type
  + group scope
  + group members

## Possible

+ Get-ADPasswordPending (look at Get-ADUserResultantPasswordPolicy)

## Magical Thinking

+ a toolset to build HTML reports on the fly
+ a WPF based OU browser or a simplified version of ADUC

*__This project is in development and not ready for the PowerShell Gallery__*

last updated 2021-03-11 23:42:00Z
