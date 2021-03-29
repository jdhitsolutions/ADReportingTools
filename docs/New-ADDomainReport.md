---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/3exlja5
schema: 2.0.0
---

# New-ADDomainReport

## SYNOPSIS

Create an HTML report of your domain.

## SYNTAX

```yaml
New-ADDomainReport [[-Name] <String>] -FilePath <String>
[-ReportTitle <String>] [-CSSUri <String>] [-EmbedCSS] [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command will create an HTML report of your domain. The report layout is by container and organizational unit. Underneath each branch will be a table display of users, computers, and groups. Beneath each group will be a table of recursive group members. You should get detail about users and computers if you hover the mouse over the distinguished name.

The ADReportingTools module includes a CSS file which will be used by default. But you can specify an alternate CSS file. If you want to make the file portable, you can opt to embed the CSS into the HTML file. You can only embed from a file, not a URL reference.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-ADDomainReport -filepath c:\work\company.html -embedcss
```

Create the HTML report and embed the default CSS file.

## PARAMETERS

### -CSSUri

Specify the path to the CSS file. If you don't specify one, the default module file will be used. The default file is in the Reports folder of this module.

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

Embed the CSS file into the HTML document head.
You can only embed from a file, not a URL.

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

Specify the domain name. The default is the user domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases: domain

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportTitle

Enter the name of the report to be displayed in the web browser.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Domain Report
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

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Show-DomainTree](Show-DomainTree.md)
