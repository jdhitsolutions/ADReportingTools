---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Set-ADReportingToolsOptions

## SYNOPSIS

Change an ADReportingToolsOptions setting.

## SYNTAX

```yaml
Set-ADReportingToolsOptions [-Name] <String> -ANSI <String> [<CommonParameters>]
```

## DESCRIPTION

Many of the commands in the ADReportingTools module have custom format files that utilize ANSI escape sequences to highlight key elements. The module defaults are stored in a variable called ADReportingToolsOptions. Use this command to modify a current setting.

## EXAMPLES

### Example 1

```powershell
PS C:\> Set-ADReportingToolsOptions DistributionList -ANSI "$([char]0x1b)[36m"
```

This will change the color value for DistributionList entries. The change is not persistent unless you put it in a PowerShell profile script.

## PARAMETERS

### -ANSI

Specify the opening ANSI sequence. The module uses the [char]0x1b escape sequence because it works in both Windows PowerShell and PowerShell 7.x.

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

### -Name

Specify an option.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: DistributionList, Alert, Warning

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

### None

## NOTES

An easy way to see ANSI samples is to install the PSScriptTools module from the PowerShell Gallery and use the Show-ANSISequence command.

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADReportingToolsOptions](Get-ADReportingToolsOptions.md)
