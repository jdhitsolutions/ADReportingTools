---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADBranch

## SYNOPSIS

Get a listing of members in an AD branch.

## SYNTAX

```YAML
Get-ADBranch [-SearchBase] <String> [-IncludeDeletedObjects] [-Server <String>]
 [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will get all users, groups, and computers from a given Active Directory organizational unit or container and display a hierarchical report. The search is recursive from the starting search base.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADBranch "OU=IT,DC=company,DC=pri"

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=AprilS,OU=IT,DC=Company,DC=Pri           AprilS          PowerShell Guru


   Branch: OU=It,DC=Company,DC=Pri [User]

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=ArtD,OU=IT,DC=Company,DC=Pri             ArtD            PowerShell Engineer
CN=GladysK,OU=IT,DC=Company,DC=Pri          GladysK         Senior AD and Ide...
CN=MaryL,OU=IT,DC=Company,DC=Pri            MaryL           Main IT
CN=MikeS,OU=IT,DC=Company,DC=Pri            MikeS           Backup IT


   Branch: OU=It,DC=Company,DC=Pri [Group]

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=IT,OU=IT,DC=Company,DC=Pri               IT
CN=Web Servers,OU=IT,DC=Company,DC=Pri      Web Servers
...
```

Get members of the IT organizational unit. There is a formatting bug where the first item isn't properly grouped.

### Example 2

```powershell
PS C:\> Get-ADBranch "Ou=accounting,Dc=company,dc=pri" | where class -eq group

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=Accounting,OU=Accounting,              Accounting        Company Accounting DC=Company,DC=Pri


   Branch: OU=Corp Investment,OU=Finance,OU=Accounting,DC=Company,DC=Pri [Group]

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=StrategyDL,OU=Corp                       StrategyDL      Strategic plann... Investment,OU=Finance,OU=Accounting,
DC=Company,DC=Pri


   Branch: OU=Payroll,OU=Accounting,DC=Company,DC=Pri [Group]

DistinguishedName                           Name            Description
-----------------                           ----            -----------
CN=Payroll Managers,OU=Payroll,             Payroll Managers
OU=Accounting,DC=Company,DC=Pri
```

Get only groups in the Accounting OU tree.

## PARAMETERS

### -Credential

Specify an alternate credential.

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

### -IncludeDeletedObjects

Show deleted objects. This parameter has no effect unless you are searching from the domain root.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase

Enter the distinguished name of the top-level container or organizational unit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server

Specify a domain controller to query.

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

### ADBranchMember

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Show-Domain](Show-Domain.md)
