---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADSiteSummary

## SYNOPSIS

Get summary information about AD sites.

## SYNTAX

```yaml
Get-ADSiteSummary [[-Server] <String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will display a summary report of each Active Directory site.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADSiteSummary


   Site: Default-First-Site-Name
   Description: Home Office

Subnet             Description                    Location
------             -----------                    --------
192.168.3.0/24     Employees
192.168.99.0/24    Datacenter                     HQDC


   Site: NoCal
   Description: Bay Area Office

Subnet             Description                    Location
------             -----------                    --------
172.17.0.0/16
```

## PARAMETERS

### -Credential

Specify an alternate credential.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: RunAs

Required: False
Position: 1
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
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### ADSiteSummary

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADSiteDetail]()

[Get-ADReplicationSite]()
