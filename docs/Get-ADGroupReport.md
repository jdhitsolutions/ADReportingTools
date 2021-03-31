---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADGroupReport

## SYNOPSIS

Create a custom group report

## SYNTAX

```yaml
Get-ADGroupReport [[-Name] <String>] [-SearchBase <String>][-Category <String>]
[-Scope <String>] [-ExcludeBuiltIn] [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Get-ADGroupReport will create a custom report for a group showing members. Get-ADGroupUser is intended to display group membership details Get-ADGroupReport focuses on the group, although members are also displayed. Members are always gathered recursively. You can filter for specific types of groups. You can also opt to exclude groups under CN=Users and CN=BuiltIn. The groups "Domain Users", "Domain Computers", and "Domain Guests" are always excluded from this command.

If your PowerShell hosts supports it, ANSI color schemes will be used to highlight things such as Distribution groups and disabled user accounts.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADGroupReport sales

Name        : CN=Sales,OU=Sales,DC=Company,DC=Pri [Global|Security]
ManagedBy   : CN=SamanthaS,OU=Sales,DC=Company,DC=Pri
Description : Sales Force Resources
________________________________________________________________________________


Displayname    Name      Description DistinguishedName
-----------    ----      ----------- -----------------
Sam Smith      SamS      Sales       CN=SamS,OU=Sales,DC=Company,DC=Pri
Sonya Smith    SonyaS    Sales       CN=SonyaS,OU=Sales,DC=Company,DC=Pri
Samantha Smith SamanthaS Sales       CN=SamanthaS,OU=Sales,DC=Company,DC=Pri
```

If your PowerShell host supports it, Disabled user accounts will display the distinguished name in red.

### Example 2

```powershell
PS C:\> Get-ADGroupReport  -ExcludeBuiltIn | Format-Table -View age

Name       Members Created                 Modified                            Age
----       ------- -------                 --------                            ---
IT               5 1/25/2021 1:32:44 PM    3/15/2021 5:42:50 PM           17:04:02
Sales            3 1/25/2021 1:32:44 PM    3/16/2021 9:52:29 AM           00:54:23
Marketing        3 1/25/2021 1:32:44 PM    3/16/2021 9:52:29 AM           00:54:24
Accounting       3 1/25/2021 1:32:44 PM    3/4/2021 9:25:39 AM         12.01:21:14
JEA Operators    4 1/25/2021 1:32:44 PM    1/28/2021 11:34:57 AM       46.23:11:56
Web Servers      1 1/25/2021 1:32:45 PM    3/15/2021 5:42:33 PM           17:04:20
DevOpsPrimary    0 1/25/2021 4:47:53 PM    1/27/2021 10:35:11 AM       48.00:11:42
DevOpsBackup     3 1/25/2021 4:48:02 PM    3/16/2021 10:12:01 AM          00:34:52
...
```

If your console supports it, Distribution Lists will be displayed in green, and a member count of 0 will be displayed in red.

### Example 3

```powershell
PS C:\> Get-ADGroupReport -ExcludeBuiltIn | Format-Table -view summary


   DistinguishedName: CN=IT,OU=IT,DC=Company,DC=Pri

Name                              Members Category        Scope       Branch
----                              ------- --------        -----       ------
IT                                      5 Security        Global      OU=IT,DC=Company,DC=Pri


   DistinguishedName: CN=Sales,OU=Sales,DC=Company,DC=Pri

Name                              Members Category        Scope       Branch
----                              ------- --------        -----       ------
Sales                                   3 Security        Global      OU=Sales,DC=Company,DC=Pri


   DistinguishedName: CN=Marketing,OU=Marketing,DC=Company,DC=Pri

Name                              Members Category        Scope       Branch
----                              ------- --------        -----       ------
Marketing                               3 Security        Global      OU=Marketing,DC=Company,DC=Pri
...`
```

Get groups and format with a custom view. If your console session supports it, some of the output will be color-coded with ANSI sequences.

## PARAMETERS

### -Category

Filter on the group category

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Distribution, Security

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Specify an alternate credential. This will be used to query the domain and all domain controllers.

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

### -ExcludeBuiltIn

Exclude BuiltIn and Users. Domain Users, Domain Guests, and Domain Computers are always excluded regardless of this parameter.

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

### -Name

Enter an AD Group name. Wildcards are allowed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Scope

Filter on group scope

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Any, DomainLocal, Global, Universal

Required: False
Position: Named
Default value: Any
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

### ADGroupReport

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADGroupUser](Get-ADGroupUser.md)

[New-ADGroupReport](New-ADGroupReport.md)

[Get-ADGroup]()

[Get-ADGroupMember]()
