---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADSiteDetail

## SYNOPSIS

Get a more detailed AD site report.

## SYNTAX

```yaml
Get-ADSiteDetail [[-Server] <String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will present a summary report of your Active Directory sites showing a description, associated subnets, and when the site object was created and last modified.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADSiteDetail


   Name: Default-First-Site-Name

Description        Subnets                 Created                Modified
-----------        -------                 -------                --------
Home Office        {192.168.3.0/24, 19... 2/23/2021 3:36:58 PM   2/23/2021...


   Name: NoCal

Description        Subnets                 Created                Modified
-----------        -------                 -------                --------
Bay Area Office    172.17.0.0/16           2/23/2021 3:38:33 PM   2/23/2021...
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

### ADSiteDetail

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADSiteSummary]()

[Get-ADReplicationSite]()
