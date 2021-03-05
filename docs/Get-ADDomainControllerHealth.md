---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
online version:
schema: 2.0.0
---

# Get-ADDomainControllerHealth

## SYNOPSIS

Get a summary view of domain controller healthg

## SYNTAX

```yaml
Get-ADDomainControllerHealth [[-Server] <String>] [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

This command is intended to give you a quick summary of the overall health of your Active Directory domain controllers. The concept of "health" is based on the following:

How much free space remains on drive C:\?
How much free physical memory?
What percentage of the Security event log is in use?
Are any critical services not running?

The services checked are ntds,kdc,adws,dfs,dfsr,netlogon,samss, and w32time. Not every organization runs DNS and/or DHCP on their domain controllers so those services have been omitted.

Output will be color-coded using ANSI escape sequences.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADDomainControllerHealth


   DC: DOM1.Company.Pri [192.168.3.10]

Uptime            PctFreeC   PctFreeMem    PctSecLog  ServiceAlert
------            --------   ----------    ---------  ------------
12.22:29:47          89.61        25.17         33.8      False


   DC: DOM2.Company.Pri [192.168.3.11]

Uptime            PctFreeC   PctFreeMem    PctSecLog  ServiceAlert
------            --------   ----------    ---------  ------------
5.16:38:00           90.63        48.36        14.56      True
```

Get a health snapshot of your domain controllers. A ServiceAlert of True means that one of the defined critical services is not running.

Output might be color coded. A ServiceAlert value of True will be displayed in Red.  Free space on C and percent free physical memory will be shown in red if the value is 10% or less. A percent free less than 30$ will be displayed in an orange/yellow color. The percent Security log usage threshholds are 15% and 50%.

### Example 2

```powershell
PS C:\> Get-ADDomainControllerHealth | Format-Table -view info


   Domain Controller: CN=DOM1,OU=Domain Controllers,DC=Company,DC=Pri

OperatingSystem                     IsGC    IsRO    Roles
---------------                     ----    ----    -----
Windows Server 2019 Standard        True    False   {SchemaMaster,DomainNam...


   Domain Controller: CN=DOM2,OU=Domain Controllers,DC=Company,DC=Pri

OperatingSystem                     IsGC    IsRO    Roles
---------------                     ----    ----    -----
Windows Server 2019 Standard        True    False   {}
```

Get domain controller health using a custom table view.

### Example 3

```powershell
PS C:\> Get-ADDomainControllerHealth | Select-Object -Expand Services


   Computername: DOM1.Company.Pri

ProcessID Displayname                      Name     State   StartMode Started
--------- -----------                      ----     -----   --------- -------
2544      Active Directory Web Services    ADWS     Running Auto      True
2652      DFS Namespace                    Dfs      Running Auto      True
2624      DFS Replication                  DFSR     Running Auto      True
660       Kerberos Key Distribution Center Kdc      Running Auto      True
660       Netlogon                         Netlogon Running Auto      True
660       Active Directory Domain Services NTDS     Running Auto      True
660       Security Accounts Manager        SamSs    Running Auto      True
1028      Windows Time                     W32Time  Running Auto      True
...
```

View the service status for each domain controller.

## PARAMETERS

### -Credential

Specify an alternate credential. This will be used to query the domain and all domain controllers.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: RunAs

Required: False
Position: 1
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

### ADDomainControllerHealth

## NOTES

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADDomainController]()
