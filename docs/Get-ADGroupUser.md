---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/38wecuU
schema: 2.0.0
---

# Get-ADGroupUser

## SYNOPSIS

Get user members of an AD group.

## SYNTAX

```yaml
Get-ADGroupUser [-Name] <String> [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will display all users of a given Active Directory group. The search is automatically recursive. The default output is a formatted table that will highlight disabled accounts in red.

## EXAMPLES

### Example 1

```dos
PS C:\> Get-ADGroupUser sales


   DistinguishedName: CN=SamS,OU=Sales,DC=Company,DC=Pri [Sam Smith]

Name            Title              Description                  PasswordLastSet
----            -----             -----------                    --------------
SamS                               Sales Staff             1/25/2021 1:32:36 PM


   DistinguishedName: CN=SonyaS,OU=Sales,DC=Company,DC=Pri [Sonya Smith]

Name            Title              Description                  PasswordLastSet
----            -----              -----------                   --------------
SonyaS          Account Executive  Sales                   1/25/2021 1:32:37 PM


   DistinguishedName: CN=SamanthaS,OU=Sales,DC=Company,DC=Pri [Samantha Smith]

Name            Title              Description                  PasswordLastSet
----            -----              -----------                   --------------
SamanthaS       Sales Assistant    Sales Staff             1/25/2021 1:32:37 PM
```

Disabled accounts will have their distinguished name displayed in red.

### Example 2

```dos
PS C:\> Get-ADGroupUser sales | format-list


   Group: CN=Sales,OU=Sales,DC=Company,DC=Pri


DistinguishedName : CN=SamS,OU=Sales,DC=Company,DC=Pri
Name              : SamS
Displayname       : Sam Smith
Description       : Sales Staff
Title             :
Department        : Sales
Enabled           : False
PasswordLastSet   : 3/4/2021 4:03:23 PM

DistinguishedName : CN=SonyaS,OU=Sales,DC=Company,DC=Pri
Name              : SonyaS
Displayname       : Sonya Smith
Description       : Sales
Title             : Account Executive
Department        : Sales
Enabled           : True
PasswordLastSet   : 1/25/2021 1:32:37 PM
...
```

Using the defined list view.

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

### -Name

Enter the name of an Active Directory group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### System.String

## OUTPUTS

### ADGroupUser

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADGroupReport](Get-ADGroupReport.md)

[Get-ADGroupMember]()
