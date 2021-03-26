---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADBackupStatus

## SYNOPSIS

Get an Active Directory backup status

## SYNTAX

```yaml
Get-ADBackupStatus [-DomainController] <String[]> [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

There aren't any explicit PowerShell commands to tell if Active Directory has been backed up. One indirect approach is to use the command-line tool repadmin.exe. This command has a /showbackup parameter which will indicate when the different Active Directory partitions have been backed up. This command is a PowerShell wrapper for repadmin.exe that runs on the specified domain controller in a PowerShell remoting session.

If running in a console host, the date value may be shown in red, if the date is beyond the backup limit of 3 days. This is a user-customizable value in $ADReportingHash.

$ADReportinghash.BackupLimit = 5

If you want a limit like this all the time, in your PowerShell profile script import the module and add this line.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADBackupStatus dom1

   DomainController: Dom1.Company.Pri

Partition                              LocalUSN OriginUSN                 Date
---------                              -------- ---------                 ----
DC=ForestDnsZones,DC=Company,DC=Pri       13777     13777   01/25/2021 14:27:01
DC=DomainDnsZones,DC=Company,DC=Pri       13776     13776   01/25/2021 14:27:01
CN=Schema,CN=Configuration,DC=Comp....    13775     13775   01/25/2021 14:27:01
CN=Configuration,DC=Company,DC=Pri        13774     13774   01/25/2021 14:27:01
DC=Company,DC=Pri                         13773     13773   01/25/2021 14:27:01
```

Any date that is beyond the number of days that is beyond $ADReportingHash.BackupLimit, will be displaySed in red, if running in a console host.

## PARAMETERS

### -Credential

Specify an alternate credential

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DomainController

Specify the name of a domain controller

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
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

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-NTDSInfo](Get-NTDSInfo.md)

[repadmin.exe]()
