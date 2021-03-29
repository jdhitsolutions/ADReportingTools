---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# New-ADChangeReport

## SYNOPSIS

Create an HTML change report.

## SYNTAX

```yaml
New-ADChangeReport [[-Since] <DateTime>] [-ReportTitle <String>]
[-Logo <String>] [--CSSUri <String>] [-EmbedCSS] [-ByContainer]
[-Path <String>] [-Server <String>] [-Credential <PSCredential>]
[-AuthType <String>] [<CommonParameters>]
```

## DESCRIPTION

New-ADChangeReport will create an HTML report showing changes to Active Directory users, computers, and groups since a given date and time. The command uses Get-ADObject to query the WhenChanged property. The objects are organized by class and/or container and written to an HTML file. The command uses a CSS file from the ADReportingTools module, although you can specify your own. To make the HTML file portable, you can opt to embed the CSS content from a file source.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-ADChangeReport -Since "3/1/2021" -Path C:\work\March-2021-Change.html -ReportTitle "March AD Change Report" -EmbedCSS
```

This example will create a report called March-2021-Change.html with Active Directory changes since March 1, 2021l. The HTML report will use the default CSS file from the ADReportingTools module and embed it into the file.

## PARAMETERS

### -AuthType

Specifies the authentication method to use. Possible values for this parameter include:

    Negotiate or 0

    Basic or 1

    The default authentication method is Negotiate.

    A Secure Sockets Layer (SSL) connection is required for the Basic authentication method.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Negotiate, Basic

Required: False
Position: Named
Default value: Negotiate
Accept pipeline input: False
Accept wildcard characters: False
```

### -ByContainer

Add a second grouping based on the object's container or OU.

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

### --CSSUri

Specify the path to the CSS file. If you don't specify one, the default module file will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: changereport.css
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Specify an alternate credential for authentication.

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

### -Logo

Specify the path to an image file to use as a logo in the report.

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

### -Path

Specify the path for the output file.

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

### -ReportTitle

What is the report title?

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: "Active Directory Change Report"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server

Specifies the Active Directory Domain Services domain controller to query. The default is your Logon server.

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

### -Since

Enter a last modified datetime for AD objects. The default is the last 4 hours.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

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

### System.IO.FileInfo

## NOTES

An earlier version of this command was first described at https://jdhitsolutions.com/blog/powershell/8087/an-active-directory-change-report-from-powershell/

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADObject]()

