---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Split-DistinguishedName

## SYNOPSIS

Split a distinguished name into its components.

## SYNTAX

```yaml
Split-DistinguishedName [-DistinguishedName] <String> [<CommonParameters>]
```

## DESCRIPTION

Split-DistinguishedName will take a disdinguishedname and break it down to its component elements. The command does not verify the name or any of its elements.

## EXAMPLES

### Example 1

```powershell
PS C:\>Get-ADGroup supporttech | Split-Distinguishedname


Name      : SupportTech
Branch    : Help Desk
BranchDN  : OU=Help Desk,OU=IT,DC=Company,DC=Pri
Domain    : Company
DomainDN  : DC=Company,DC=Pri
DomainDNS : Company.Pri
```

### Example 2

```powershell
PS C:\> Split-DistinguishedName "CN=Foo,OU=Bar,OU=Oz,DC=Research,DC=Globomantics,DC=com"


Name      : Foo
Branch    : Bar
BranchDN  : OU=Bar,OU=Oz,DC=Research,DC=Globomantics,DC=com
Domain    : Research
DomainDN  : DC=Research,DC=Globomantics,DC=com
DomainDNS : Research.Globomantics.com
```

## PARAMETERS

### -DistinguishedName

Enter an Active Directory DistinguishedName.

```yaml
Type: String
Parameter Sets: (All)
Aliases: dn

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### ADDistinguishedNameInfo

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS
