---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/3eE8o6t
schema: 2.0.0
---

# Get-ADUserCategory

## SYNOPSIS

Get AD User information based on category

## SYNTAX

### filter (Default)

```yaml
Get-ADUserCategory [[-Filter] <String>] [-SearchBase <String>] -Category <String> [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

### id

```yaml
Get-ADUserCategory [-Identity] <String> -Category <String> [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Get-ADUserCategory is based on the concept of getting user information from a pre-defined category. For example, you might want to get the properties DisplayName, Name, Title, Department, and Manager for a Department category. The ADReportingTools module will define a set of pre-defined categories that you can reference through $ADUserReportingConfiguration.

These are the current defaults.

Department
  DisplayName,Name,Title,Department,Manager
Basic
  DisplayName,Name,SamAccountname,UserPrincipalName,Enabled,WhenCreated,WhenChanged
Address
  DisplayName,Name,TelephoneNumber,Office,StreetAddress,POBox,City,State,PostalCode
Organization
  DisplayName,Name,Title,Department,Manager,Company,Office
Pwinfo
  DisplayName,Name,PasswordExpired,PasswordLastSet,PasswordNeverExpires

The user's distinguishedname will always be included.

You don't have to remember what property names to include or reference.

## EXAMPLES

### Example 1

```dos
PS C:\> Get-ADUserCategory artd -Category basic


DistinguishedName : CN=ArtD,OU=IT,DC=Company,DC=Pri
DisplayName       : Art Deco
Name              : ArtD
SamAccountname    : ArtD
UserPrincipalName : artd@company.com
Enabled           : True
WhenCreated       : 1/25/2021 1:32:35 PM
WhenChanged       : 3/11/2021 6:32:58 PM
```

### Example 2

```dos
PS C:\> Get-ADUserCategory -filter "department -eq 'sales'" -Category Department


DistinguishedName : CN=SamS,OU=Sales,DC=Company,DC=Pri
DisplayName       : Sam Smith
Name              : SamS
Title             :
Department        : Sales
Manager           : CN=SonyaS,OU=Sales,DC=Company,DC=Pri

DistinguishedName : CN=SonyaS,OU=Sales,DC=Company,DC=Pri
DisplayName       : Sonya Smith
Name              : SonyaS
Title             : Account Executive
Department        : Sales
Manager           :

DistinguishedName : CN=SamanthaS,OU=Sales,DC=Company,DC=Pri
DisplayName       : Samantha Smith
Name              : SamanthaS
Title             : Sales Assistant
Department        : Sales
Manager           : CN=SonyaS,OU=Sales,DC=Company,DC=Pri
```

### Example 3

```dos
PS C:\> $ADUserReportingConfiguration += [pscustomobject]@{Name="Custom";Properties="DisplayName","Description"}
PS C:\> Get-ADUserCategory -filter "givenname -like 'a*'" -Category custom

DistinguishedName                              DisplayName       Description
-----------------                              -----------       -----------
CN=AaronS,OU=Accounting,DC=Company,DC=Pri      Aaron Smith       Accountant
CN=Al Fresco,OU=Dev,DC=Company,DC=Pri          Al Fresco
CN=A.Henaire,OU=Employees,DC=Company,DC=Pri    Alexander Henaire
CN=Alfonso Dente,OU=Sales,DC=Company,DC=Pri    Alfonso Dente
CN=AndreaS,OU=Accounting,DC=Company,DC=Pri     Andrea Smith      Accountant
CN=AndyS,OU=Accounting,DC=Company,DC=Pri       Andy Smith        Accountant
CN=Anthony Stark,OU=Research,DC=Company,DC=Pri Tony Stark
CN=AprilS,OU=IT,DC=Company,DC=Pri              April Showers     PowerShell Guru
CN=A.Fieldhouse,OU=Employees,DC=Company,DC=Pri Aron Fieldhouse   sample user ...
CN=ArtD,OU=IT,DC=Company,DC=Pri                Art Deco          PowerShell E...
CN=Art Frame,OU=Accounting,DC=Company,DC=Pri   Art Frame         Test User
```

The first command is adding a new category. The second command uses the category.

## PARAMETERS

### -Category

Select a defined category.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
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

### -Filter

Specify an AD filter like "department -eq 'sales'".
The default is all Enabled user accounts.

```yaml
Type: String
Parameter Sets: filter
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity

Enter an AD user identity

```yaml
Type: String
Parameter Sets: id
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase

Enter the distinguished name of the top-level container or organizational unit.

```yaml
Type: String
Parameter Sets: filter
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

### System.Object

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADUser]()
