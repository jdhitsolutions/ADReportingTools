---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/3uthsPX
schema: 2.0.0
---

# New-ADGroupReport

## SYNOPSIS

Create an HTML report of AD groups

## SYNTAX

```yaml
New-ADGroupReport [[-Name] <String>] [-SearchBase <String>]
[-Category <String>] [-Scope <String>] [-ExcludeBuiltIn] -FilePath <String>
-ReportTitle <String>] [-CSSUri <String>] [-EmbedCSS] [-Server <String>]
[-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

New-ADGroupReport will create an HTML report of specified groups from Active Directory. This function is based on Get-ADGroupReport and converts the output to an HTML file. You can specify a CSS file or use the default from the module.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-ADGroupReport -excludeBuiltIn -embedCSS -server dom2 -category security -filepath c:\work\secgroup.html
```

This example will create a new HTML report of all Security groups, excluding the built-in groups. Disabled user accounts will be highlighted in red since the command is using the module's CSS file, which is also being embedded. User detail will pop-up when the mouse hovers over the user's distinguishedname.

## PARAMETERS

### -CSSUri

Specify the path the CSS file. If you don't specify one, the default module file will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: groupreport.css
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category

Filter on the group category.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Distribution, Security

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -EmbedCSS

Embed the CSS file into the HTML document head. You can only embed from a file, not a URL.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeBuiltIn

Exclude BuiltIn and Users containers.  Domain Users, Domain Guests, and Domain Computers are always excluded regardless of this parameter.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath

Specify the output HTML file.

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

Enter an AD Group name. Wildcards are allowed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ReportTitle

Enter the name of the report to be displayed in the web browser

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: AD Group Report
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope

Filter on group scope

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Any, DomainLocal, Global, Universal

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase

Enter the distinguished name of the top-level container or organizational unit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

### System.IO.File

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADGroupReport](Get-ADGroupReport.md)
