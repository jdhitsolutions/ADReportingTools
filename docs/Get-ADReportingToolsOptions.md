---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADReportingToolsOptions

## SYNOPSIS

Get ADReportingTools color options

## SYNTAX

```yaml
Get-ADReportingToolsOptions [<CommonParameters>]
```

## DESCRIPTION

Many of the commands in the ADReportingTools module have custom format files that utilize ANSI escape sequences to highlight key elements. The module defaults are stored in a variable called ADReportingToolsOptions. Use this command to view the current settings. If you access the variable directly, you won't see the actual ANSI settings, and you might have to reset your console by typing "$([char]0x1b)[0m".

The ANSI sequences use the [char]0x1b escape character because it works in both Windows PowerShell and PowerShell 7.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADReportingToolsOptions

Name             Value
----             -----
Alert            $([char]0x1b)[91m
Warning          $([char]0x1b)[38;5;220m
DistributionList $([char]0x1b)[92m
```

The actual values will be color-coded with the ANSI sequence.

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### ADReportingToolsOption

## NOTES

An easy way to see ANSI samples is to install the PSScriptTools module from the PowerShell Gallery and use the Show-ANSISequence command.

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Set-ADReportingToolsOIptions](Set-ADReportingToolsOptions.md)
