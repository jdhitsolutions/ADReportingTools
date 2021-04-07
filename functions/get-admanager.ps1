Function Get-ADManager {
    [cmdletbinding()]
    [OutputType("ADManager")]
    Param(
        [parameter(Position = 0, HelpMessage = "Enter an AD user SAMAccountname")]
        [validatenotnullorEmpty()]
        [string]$Name,
        [Parameter(HelpMessage = "Specify what managed detail you want.")]
        [ValidateSet("All", "DirectReports", "ManagedObjects")]
        [string]$Detail = "All",
        [Parameter(HelpMessage = "Specify what managed object class you want. The default is everything. This parameter has no effect if you only get Direct Reports.")]
        [ValidateSet("All", "Group", "Computer", "OU")]
        [string[]]$ObjectClass = "All",
        [Parameter(HelpMessage = "Enter the distinguished name of the top level container or organizational unit.")]
        [ValidateNotNullOrEmpty()]
        [string]$SearchBase,
        [Parameter(HelpMessage = "Specify a domain controller to query for a list of domain controllers.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential. This will be used to query the domain and all domain controllers.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )

    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($MyInvocation.MyCommand)"
    #set some default parameter values
    $params = "Credential", "Server"

    ForEach ($param in $params) {
        if ($PSBoundParameters.ContainsKey($param)) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
            $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
        }
    } #foreach

    $properties = "Title", "Description", "DisplayName", "Enabled"
    Switch ($Detail) {
        "DirectReports" { $properties += "DirectReports" }
        "ManagedObjects" { $properties += "ManagedObjects" }
        "All" { $properties += "ManagedObjects", "DirectReports" }
    }
    $get = @{
        Filter      = ""
        Properties  = $properties
        ErrorAction = "Stop"
    }

    if ($Name) {
        Write-Verbose "[$((Get-Date).TimeofDay)] Searching for user $Name"
        $get.Filter = "name -eq '$Name'"
    }
    else {
        Write-Verbose "[$((Get-Date).TimeofDay)] Searching for any manager"
        $get.filter = "DirectReports -like '*' -OR ManagedObjects -like '*'"
    }

    if ($SearchBase) {
        Write-Verbose "[$((Get-Date).TimeofDay)] Limiting search to $SearchBase"
        $get.Add("SearchBase", $SearchBase)
    }

    Try {
        $managers = Get-ADUser @get
    }
    Catch {
        Write-Warning $_.Exception.Message
    }

    if ($managers.name) {
        Write-Verbose "[$((Get-Date).TimeofDay)] Found $($managers.name.count) manager(s)"
        $results = [System.Collections.Generic.list[Object]]::new()
        foreach ($manager in $managers) {
            Write-Verbose "[$((Get-Date).TimeofDay)] $($manager.distinguishedname)"
            Write-Verbose "[$((Get-Date).TimeofDay)] Processing DirectReports"
            $direct = $manager.DirectReports |
            Get-ADUser -Properties Title, Description, Department, DisplayName, Enabled |
            Sort-Object -Property DistinguishedName |
            ForEach-Object {
                [pscustomobject]@{
                    PSTypeName        = "ADDirect"
                    DistinguishedName = $_.DistinguishedName
                    Name              = $_.Name
                    DisplayName       = $_.DisplayName
                    Title             = $_.Title
                    Description       = $_.Description
                    Department        = $_.Department
                    Enabled           = $_.Enabled
                    SamAccountName    = $_.SamAccountname
                }
            }

            Write-Verbose "[$((Get-Date).TimeofDay)] Processing Managed Objects"
            $managed = Foreach ($item in $manager.managedObjects) {
                $adobj = Get-ADObject -Identity $item
                Switch ($adobj.ObjectClass) {
                    "group" {
                        if ($ObjectClass -contains "All" -OR $ObjectClass -contains "Group") {
                            Write-Verbose "[$((Get-Date).TimeofDay)] Getting managed group $item"
                            $grp = Get-ADGroup -Identity $item -Properties GroupScope, GroupCategory, Description
                            [pscustomobject]@{
                                PSTypeName        = "ADManaged.$($adobj.ObjectClass)"
                                DistinguishedName = $adobj.DistinguishedName
                                Name              = $adobj.Name
                                Class             = $adobj.objectClass
                                Scope             = $grp.GroupScope
                                Category          = $Grp.GroupCategory
                                Description       = $grp.Description
                            }
                        }
                    }
                    "computer" {
                        if ($ObjectClass -contains "All" -OR $ObjectClass -contains "Computer") {
                            Write-Verbose "[$((Get-Date).TimeofDay)] Getting managed computer $item"
                            $member = Get-ADComputer -Identity $item -Property OperatingSystem, IPv4Address, Enabled, Description, Location, DNSHostName
                            [pscustomobject]@{
                                PSTypeName        = "ADManaged.$($adobj.ObjectClass)"
                                DistinguishedName = $adobj.DistinguishedName
                                Name              = $adobj.Name
                                DNSHostName       = $member.DNSHostName
                                Class             = $adobj.objectClass
                                OperatingSystem   = $member.OperatingSystem
                                Description       = $member.Description
                                IPAddress         = $member.IPv4Address
                                Location          = $member.Location
                                Enabled           = $member.Enabled
                            }
                        }
                    }
                    "OrganizationalUnit" {
                        if ($ObjectClass -contains "All" -OR $ObjectClass -contains "OU") {
                            Write-Verbose "[$((Get-Date).TimeofDay)] Getting managed OU $item"
                            $ou = Get-ADOrganizationalUnit -Identity $item -Properties ProtectedFromAccidentalDeletion, Description
                            [pscustomobject]@{
                                PSTypeName        = "ADManaged.$($adobj.ObjectClass)"
                                DistinguishedName = $adobj.DistinguishedName
                                Name              = $adobj.Name
                                Class             = $adobj.objectClass
                                Description       = $ou.Description
                                Protected         = $ou.ProtectedFromAccidentalDeletion
                            }
                        }
                    }
                }
            } #foreach item

            $mgr = [pscustomobject]@{
                PSTypeName        = "ADManager"
                DistinguishedName = $manager.Distinguishedname
                Name              = $Manager.name
                SamAccountName    = $Manager.SamAccountName
                DisplayName       = $manager.DisplayName
                Title             = $Manager.Title
                Description       = $manager.Description
                DirectReports     = $Direct
                ManagedObjects    = $managed | Sort-Object -Property Class, DistinguishedName
                Enabled           = $manager.Enabled
            }

            if ($Detail -eq "All") {
                $results.Add($mgr)
            }
            elseif ($detail -eq "DirectReports" -AND $mgr.DirectReports.count -gt 0) {
                $results.Add($mgr)
            }
            elseif ($detail -eq "ManagedObjects" -AND $mgr.ManagedObjects.count -gt 0) {
                $results.Add($mgr)
            }

        } #foreach manager
        $results

    } #if managers
    else {
        Write-Warning "No matching user(s) found."
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($MyInvocation.MyCommand)"
}