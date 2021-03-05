---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Show-DomainTree

## SYNOPSIS

Display the domain in a tree format.

## SYNTAX

```yaml
Show-DomainTree [[-Name] <String>] [-UseDN] [-Server <String>]
[-Credential <PSCredential>] [-Containers] [<CommonParameters>]
```

## DESCRIPTION

This command will display your domain in a tree view at the console. By default the command will use color-coded ANSI formatting. The default display uses the organizational names. If you use -Containers, containers like Users will be included.

## EXAMPLES

### Example 1

```powershell
PS C:\> Show-DomainTree

DC=Company,DC=Pri
│
├── Accounting
│   ├── Banking
│   ├── Finance
│       ├── Corp Investment
│   ├── Payroll
├── Dev
│   ├── Ops
├── Domain Controllers
├── Employees
│   ├── Exec
│       ├── VIP
│   ├── Temporary Hires
├── IT
│   ├── Help Desk
│       ├── TechStaff
│           ├── Test
│   ├── SecOps
├── JEA_Operators
├── Marketing
│   ├── Agency
├── Research
├── Sales
│   ├── InsideSales
│   ├── OutsideSales
├── Servers
│   ├── AppDev
│   ├── DMZ
│   ├── Web
│       ├── Staging
└── Suspended
```

Output will color-coded using ANSI escape sequences.

## PARAMETERS

### -Containers

Include containers and non-OU elements. Items with a GUID in the name will be omitted.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cn

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

### -Name

Specify the domain name. The default is the user domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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

### -UseDN

Display the domain tree using distinguished names.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: dn

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

### String

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[New-ADDomainReport](New-ADDomainReport.md)
