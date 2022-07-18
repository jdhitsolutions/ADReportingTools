---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/3gf6iKM
schema: 2.0.0
---

# Get-ADManager

## SYNOPSIS

Get a manager from Active Directory

## SYNTAX

```yaml
Get-ADManager [[-Name] <String>] [-Detail <String>] [-ObjectClass <String[]>]
[-SearchBase <String>] [-Server <String>] [-Credential <PSCredential>]
[<CommonParameters>]
```

## DESCRIPTION

In Active Directory, you can designate a manager for users and objects. From the manager account's perspective, users are designated as DirectReports, and items such as Computers, Groups, and OrganizationalUnits are referred to as ManagedObjects. Get-ADManager is a simple way to get a manager account and view everything that they manage. The default is to get all users and all objects, but you can filter using command parameters. Note that if you filter to show only DirectReports or only ManagedObjects, the other property will show a count of 0, even if there are managed items.

If you are running in a PowerShell console host, the default output will be colorized with ANSI escape sequences.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADManager artd

Name            : CN=ArtD,OU=IT,DC=Company,DC=Pri [ArtD]
Title           : IT Operations Lead
Description     : PowerShell Engineer
Direct Reports  : 1

   User: CN=GladysK,OU=IT,DC=Company,DC=Pri [GladysK]

DisplayName          Description                    Title                     Department
-----------          -----------                    -----                     ----------
Gladys Kravitz       Senior AD and Identity Goddess AD Operations Lead        IT



Managed Objects : 11

 Computer

     CN=DOM2,OU=Domain Controllers,DC=Company,DC=Pri [DOM2.Company.Pri]
 Name           Location   IPAddress      OperatingSystem       Description
 ----           --------   ---------      ---------------       -----------
 DOM2           hqdc       192.168.3.11   Windows Server 2019   HQ domain controllers

      CN=RX-ba-3465-fb,CN=Computers,DC=Company,DC=Pri []
 Name           Location   IPAddress      OperatingSystem       Description
 ----           --------   ---------      ---------------       -----------
 RX-ba-3465-fb

...
```

Get the manager account ArtD and show all direct reports and managed objects.Disabled computer and user accounts will be shown in Red.

### Example 2

```powershell
PS C:\> Get-ADManager Gladysk -Detail DirectReports

Name            : CN=GladysK,OU=IT,DC=Company,DC=Pri [GladysK]
Title           : AD Operations Lead
Description     : Senior AD and Identity Goddess
Direct Reports  : 4

   User: CN=Darren Stevens,OU=Help Desk,OU=IT,DC=Company,DC=Pri [Darren Stevens]

DisplayName          Description                    Title                     Department
-----------          -----------                    -----                     ----------
Darren Stevens       Darren 1                       IT Audit                  Information Services


   User: CN=Gustav Klimt,OU=Help Desk,OU=IT,DC=Company,DC=Pri [Gustav Klimt]

DisplayName          Description                    Title                     Department
-----------          -----------                    -----                     ----------
Gustav Klimt         Help Desk Staff                Tier I
...
```

Only display the managers direct reports.

### Example 3

```powershell
PS C:\> Get-ADManager Gladysk -Detail ManagedObjects -ObjectClass Group,OU

Name            : CN=GladysK,OU=IT,DC=Company,DC=Pri [GladysK]
Title           : AD Operations Lead
Description     : Senior AD and Identity Goddess
Direct Reports  : 0
Managed Objects : 6

 Computer
 OrganizationalUnit


    DistinguishedName: OU=Research,DC=Company,DC=Pri

 Name                      Description
 ----                      -----------
 Research


    DistinguishedName: OU=TechStaff,OU=Help Desk,OU=IT,DC=Company,DC=Pri

 Name                      Description
 ----                      -----------
 TechStaff                 Help and Support Staff accounts


 Group


    Group: CN=AcctTalk,OU=Accounting,DC=Company,DC=Pri [Universal|Distribution]

 Name                           Description
 ----                           -----------
 AcctTalk                       company finance mail list

    Group: CN=JEA Operators,OU=JEA_Operators,DC=Company,DC=Pri [Global|Security]

 Name                           Description
 ----                           -----------
 JEA Operators                  Trusted JEA users
...
```

Display Groups and Organizational Units managed by the specified user. OUs not marked for protection from deletion will be shown in red. Universal and Distribution groups will be highlighted by color as well.

## PARAMETERS

### -Credential

Specify an alternate credential.
This will be used to query the domain and all domain controllers.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: RunAs

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detail

Specify what managed detail you want.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, DirectReports, ManagedObjects

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Enter an Active Directory account's SAMAccountname.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ObjectClass

Specify what managed object class you want. The default is everything. This parameter has no effect if you only get Direct Reports.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: All, Group, Computer, OU

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase

Enter the distinguished name of the top-level container or organizational unit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server

Specify a domain controller to query for a list of domain controllers.

```yaml
Type: String
Parameter Sets: (All)
Aliases: dc, domaincontroller

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### ADManager

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADGroupReport](Get-ADGroupReport.md)

[Get-ADComputerReport](Get-ADComputerReport.md)
