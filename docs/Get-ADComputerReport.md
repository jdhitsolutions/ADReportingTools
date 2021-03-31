---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADComputerReport

## SYNOPSIS

Get AD Computer account information

## SYNTAX

```yaml
Get-ADComputerReport [[-Name] <String>] [-Category <String>] [-Location <String>] [-SearchBase <String>] [-Server <String>]
[-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Get-ADComputerReport will gather information about computer objects in Active Directory. The default is to find all objects. But you can filter on a category of Server or Desktop. The filtering is done based on the operating system value.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADComputerReport

Name            Description           Location IPAddress       LastLogonDate
----            -----------           -------- ---------       -------------
DOM1       HQ domain controllers       hqdc    192.168.3.10    3/26/2021 3:12...
DOM2       HQ domain controllers       hqdc    192.168.3.11    3/26/2021 3:21...
Mail01
SRV1       corp resource server        hqdc    192.168.3.50    3/26/2021 10:4...
SRV2                                  Omaha    192.168.3.51    3/26/2021 10:4...
...
```

If you are running in a PowerShell console, domain controllers and member servers will be highlighted with an ANSI sequence.

### Example 2

```powershell
PS C:\> Get-ADComputerReport -Name srv1 | select *


Name              : SRV1
DNSHostname       : SRV1.Company.Pri
Description       : corp resource server
OperatingSystem   : Windows Server 2016 Standard Evaluation
IsServer          : True
Location          : hqdc
LastLogonDate     : 3/26/2021 10:45:27 AM
IPAddress         : 192.168.3.50
Created           : 1/25/2021 1:33:02 PM
Modified          : 3/26/2021 9:04:03 PM
DistinguishedName : CN=SRV1,CN=Computers,DC=Company,DC=Pri
```

Get all report properties.

## PARAMETERS

### -Category

Filter by the operating system.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Any, Server, Desktop

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Specify an alternate credential.
This will be used to query the domain and all domain controllers.

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

### -Location

Filter by location.

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

### -Name

Enter an AD conmputer identity.
Wildcard are allowed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

Specify a domain controller to query for a list of domain controllers.

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

### System.String

## OUTPUTS

### ADComputerInfo

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADDomainControllerHealth](Get-ADDomainControllerHealth.md)
