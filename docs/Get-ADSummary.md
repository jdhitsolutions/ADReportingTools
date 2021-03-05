---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADSummary

## SYNOPSIS

Get a sumamry report of your AD domain and forest.

## SYNTAX

```yaml
Get-ADSummary [[-Identity] <String>] [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This simple command will give you a snapshot-sized summary of your Active Directory domain and forest.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADSummary


   Forest: Company.Pri [Windows2016Forest]


RootDomain        : Company.Pri
Domains           : {Company.Pri}
Domain            : Company.Pri
DomainMode        : Windows2016Domain
DomainControllers : {DOM1.Company.Pri, DOM2.Company.Pri}
GlobalCatalogs    : {DOM1.Company.Pri, DOM2.Company.Pri}
SiteCount         : 2
```

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

### -Identity

Specify the domain name. The default is the user domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases: name

Required: False
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

### ADSummary

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADFSMO](Get-ADFSMO.md)

[Get-ADDomain]()

[Get-ADForest]()
