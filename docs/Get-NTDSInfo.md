---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-NTDSInfo

## SYNOPSIS

Get information about the NTDS.dit and related files.

## SYNTAX

```yaml
Get-NTDSInfo [-Computername] <String[]> [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Get-NTDSInfo will query a domain controller using PowerShell remoting to get information about the NTDS.dit and related files. You might use this to track the size of the file or to check on backups. A high log count might indicate a backup is needed.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-NTDSInfo -computername dom1 | format-list

DomainController : DOM1.Company.Pri
Path             : C:\NTDS\ntds.dit
Size             : 16777216
FileDate         : 3/26/2021 1:13:26 PM
LogCount         : 34
Date             : 3/26/2021 4:15:00 PM
```

The default display is a table. The LogCount is the number of temp edb files in the NTDS folder. The FileDate is the timestamp of ntds.dit, and the Date property reflects when you ran the command.

## PARAMETERS

### -Computername

Specify a domain controller name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credential

Specify an alternate credential.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### NTDSInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADBackupStatus](Get-ADBackupStatus.md)
