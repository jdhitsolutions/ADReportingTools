---
external help file: ADReportingTools-help.xml
Module Name: ADReportingTools
schema: 2.0.0
---

# Get-ADDepartment

## SYNOPSIS

Get members of a department from Active Directory.

## SYNTAX

```yaml
Get-ADDepartment [-Department] <String[]> [-Server <String>] [-Credential <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION

Use this command to retrieve user account information from Active Directory for members of a specific department. You can specify multiple departments. User information is displayed in a grouped table by default.

When you import the ADReportingTools module, it will define a global variable called ADReportingHash, which is a hashtable. The variable has a key called Departments. This variable is used in an argument completer for the -Department parameter. This allows you to tab-complete the parameter value. If you add a department after loading the module, you will need to update the variable. You can manually add a department:

$ADReportingHash.Departments+='Bottle Washing'

Or reload the module:

Import-Module ADReportingTools -force

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-ADDepartment -Department sales -Server dom1 -Credential company\artd

   Department: Sales

Name                      Title                          City                 Phone
----                      -----                          ----                 -----
Sonya Smith               Account Executive              Omaha                x2345
Garret Guillary           Intern                         Omaha                x8877
Sam Smith                 Sales Support                  Omaha                x5678
Samantha Smith            Sales Assistant                Omaha                x9875
```

Get all members of the Sales department. This example queries a specific domain controller and uses alternate credentials. If your PowerShell session supports it, disabled accounts will be displayed in red.

### Example 2

```powershell
PS C:\> Get-ADDepartment Sales | Format-Table -view manager


   Manager: CN=Alfonso Dente,OU=Sales,DC=Company,DC=Pri [Sales]

Name                 Description               Title                City
----                 -----------               -----                ----
Sonya Smith          Sales                     Account Executive    Omaha


   Manager: CN=SamanthaS,OU=Sales,DC=Company,DC=Pri [Sales]

Name                 Description               Title                City
----                 -----------               -----                ----
Garret Guillary      sales intern              Intern               Omaha


   Manager: CN=SonyaS,OU=Sales,DC=Company,DC=Pri [Sales]

Name                 Description               Title                City
----                 -----------               -----                ----
Sam Smith            Sales                     Sales Support        Omaha
Samantha Smith       Sales                     Sales Assistant      Omaha
```

The command has a corresponding formatting file with a custom view.

## PARAMETERS

### -Credential

Specify alternate credentials for authentication.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: runas

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Department

Specify one or more department names.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
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
Aliases: DC

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

### ADDeptMember

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

## RELATED LINKS

[Get-ADUserCategory](Get-ADUserCategory.md)

[Get-ADUser]()
