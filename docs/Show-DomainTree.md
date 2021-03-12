---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version: https://bit.ly/2PXbvfo
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

This command will display your domain in a tree view at the console. By default, Show-DomainTree will use color-coded ANSI formatting. The default display uses the organizational unit names. Although, you can use the distinguishedname of each branch. If you use -Containers, containers like Users will be included.

## EXAMPLES

### Example 1

```dos
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

### Example 2

```dos
PS C:\> PS C:\> Show-DomainTree -usedn

DC=Company,DC=Pri
│
├── OU=Accounting,DC=Company,DC=Pri
│   ├── OU=Banking,OU=Accounting,DC=Company,DC=Pri
│   ├── OU=Finance,OU=Accounting,DC=Company,DC=Pri
│       ├── OU=Corp Investment,OU=Finance,OU=Accounting,DC=Company,DC=Pri
│   ├── OU=Payroll,OU=Accounting,DC=Company,DC=Pri
├── OU=Dev,DC=Company,DC=Pri
│   ├── OU=Ops,OU=Dev,DC=Company,DC=Pri
├── OU=Domain Controllers,DC=Company,DC=Pri
├── OU=Employees,DC=Company,DC=Pri
│   ├── OU=Exec,OU=Employees,DC=Company,DC=Pri
│       ├── OU=VIP,OU=Exec,OU=Employees,DC=Company,DC=Pri
│   ├── OU=Temporary Hires,OU=Employees,DC=Company,DC=Pri
├── OU=IT,DC=Company,DC=Pri
│   ├── OU=Help Desk,OU=IT,DC=Company,DC=Pri
│       ├── OU=TechStaff,OU=Help Desk,OU=IT,DC=Company,DC=Pri
│           ├── OU=Test,OU=TechStaff,OU=Help Desk,OU=IT,DC=Company,DC=Pri
│   ├── OU=SecOps,OU=IT,DC=Company,DC=Pri
...
```

Display the domain tree using distinguishednames.

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
