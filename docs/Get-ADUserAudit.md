---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADUserAudit

## SYNOPSIS

Audit AD user management events.

## SYNTAX

```yaml
Get-ADUserAudit [[-DomainController] <String[]>] [-Since <DateTime>]
[-Events <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will search the Security event logs on your domain controllers for specific user-related events. These activities are not replicated, so you have to search each domain controller.

Be aware that you may see related events for some actions. For example, if you create and enable a new user, you'll see multiple entries for the same event.

The output will show you the user accounts that match the search criteria, and the domain account that was responsible. Although, this command can't tell you which administrator is responsible for which activity. The best you can learn is that for a given time frame, these user accounts were managed. Or these administrators did something. You would need to search the event log on the domain controller for more information.

You may need to enable logging, and/or increase the size of the Security event log.

## EXAMPLES

### Example 1

```powershell
PS C:\> get-aduseraudit -Events Created -Since 2/1/2021


   DomainController: DOM1.Company.Pri


EventType      : UserCreated
Since          : 2/1/2021 12:00:00 AM
TargetCount    : 10
Targets        : {COMPANY\darrens, COMPANY\S.Talone, COMPANY\ntesla, COMPANY...}
Administrators : {COMPANY\ArtD, COMPANY\Administrator, COMPANY\GladysK, COMP...}



   DomainController: DOM2.Company.Pri


EventType      : UserCreated
Since          : 2/1/2021 12:00:00 AM
TargetCount    : 6
Targets        : {COMPANY\astark, COMPANY\georgejet, COMPANY\maef, COMPANY\bo..}
Administrators : {COMPANY\GladysK, COMPANY\ArtD}
```

Find all user accounts created since February 1, 2021.

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

Specify one or more domain controllers to query. The default is all domain controllers in the user domain.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Events

Select one or more user account events

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Created, Deleted, Enabled, Disabled, Changed

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Since

Find all matching user management events since what date and time?

```yaml
Type: DateTime
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

### None

## OUTPUTS

### System.Object

## NOTES

An earlier version of this command was first published at:
http://bit.ly/ADUserAudit

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-WinEvent]()
