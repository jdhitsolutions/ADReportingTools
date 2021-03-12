---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/3ctNioz
schema: 2.0.0
---

# Get-ADFSMO

## SYNOPSIS

Get FSMO holders.

## SYNTAX

```yaml
Get-ADFSMO [[-Identity] <String>] [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will display all FSMO role holders for the forest and domain at a glance.

## EXAMPLES

### Example 1

```dos
PS C:\> PS C:\> Get-ADFSMO


   Domain: Company.Pri
   Forest: Company.Pri


PDCEmulator          : DOM1.Company.Pri
RIDMaster            : DOM1.Company.Pri
InfrastructureMaster : DOM1.Company.Pri
SchemaMaster         : DOM1.Company.Pri
DomainNamingMaster   : DOM1.Company.Pri
```

Get the FSMO holders for the current domain and forest.

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

### ADFSMORole

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADSummary](Get-ADSummary.md)

[Get-ADDomain]()

[Get-ADForest]()
