---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/38yrc2R
schema: 2.0.0
---

# Get-ADCanonicalUser

## SYNOPSIS

Get an AD user account using a canonical name.

## SYNTAX

```yaml
Get-ADCanonicalUser [-Name] <String> [-Properties <String[]>] [-IncludeDeletedObjects] [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Often you will find user names in the form domain\username. This command makes it easier to find the Active Directory user account using this value. If you have enabled the Active Directory Recycle Bin feature, you can use the IncludeDeletedObjects parameter to search for the user account if it can't be found with the initial search.

There is an assumption that you will know the domain controller responsible for the given domain component. Or that all accounts are in your current user domain.

## EXAMPLES

### Example 1

```dos
PS C:\> Get-ADCanonicalUser company\gladysk -Properties title,description,department


Department        : IT
Description       : Senior AD and Identity Goddess
DistinguishedName : CN=GladysK,OU=IT,DC=Company,DC=Pri
Enabled           : True
GivenName         : Gladys
Name              : GladysK
ObjectClass       : user
ObjectGUID        : 445c8817-3c53-4861-9221-407b5af8bdc6
SamAccountName    : GladysK
SID               : S-1-5-21-493037332-564925384-1585924867-1105
Surname           : Kravitz
Title             : AD Operations Lead
UserPrincipalName : gladysk@Company.Pri
```

Get the Active Directory user account for Company\Gladysk and some select properties.

### Example 2

```dos
PS C:\> $a = Get-ADUserAudit -Since "2/1/2021" -Events Disabled
PS C:\> $a.targets | Get-Unique | Get-ADCanonicalUser |
Select-Object DistinguishedName

DistinguishedName
-----------------
CN=MaryL,OU=IT,DC=Company,DC=Pri
CN=E.Ratti,OU=Employees,DC=Company,DC=Pri
CN=Roy Biv,OU=Accounting,DC=Company,DC=Pri
CN=D.Monroy,OU=Employees,DC=Company,DC=Pri
CN=MaryL,OU=IT,DC=Company,DC=Pri
CN=S.Montbriand,OU=Employees,DC=Company,DC=Pri
CN=R.Freil,OU=Employees,DC=Company,DC=Pri
CN=N.Wobser,OU=Employees,DC=Company,DC=Pri
CN=Y.Graffney,OU=Employees,DC=Company,DC=Pri
CN=D.Waldow,OU=Employees,DC=Company,DC=Pri
```

The first command is using the Get-ADUserAudit command to find all user accounts disabled since February 1. The resulting targets in the canonical name format. These values are piped to Get-ADCanonicalUser to retrieve the corresponding distinguished name values.

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

Search deleted objects if the user account can't be found.

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

Enter the username in the form domain\username.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Properties

Enter one or more user properties or * to select everything.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### System.String

## OUTPUTS

### Microsoft.ActiveDirectory.Management.ADUser

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADUser]()

[Get-ADObject]()
