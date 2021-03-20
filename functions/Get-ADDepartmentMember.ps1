
Function Get-ADDepartment {

    [cmdletbinding()]
    [outputtype("ADDeptMember")]
    [alias("gdp")]

    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify one or more department names.")]
        [string[]]$Department,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("DC")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify alternate credentials for authentication.")]
        [Alias("runas")]
        [pscredential]$Credential
    )

    Write-Verbose "[$(Get-Date -Format G)] Starting $($myinvocation.mycommand)"

    #remove Department from bound parameters
    [void]$PSBoundParameters.remove("Department")

    #add additional parameters
    $Properties = "Title", "City", "State", "OfficePhone", "DisplayName", "Department", "Manager", "Country", "Enabled", "Description"
    $PSBoundParameters.Add("Properties", $Properties)

    if ($Server) {
        Write-Verbose "[$(Get-Date -Format G)] Connecting to domain controller $($server.toupper())"
    }
    If ($credential.username) {
        Write-Verbose "[$(Get-Date -Format G)] Connecting as $($credential.username)"
    }

    #create a list to hold results
    $list = [System.Collections.Generic.list[object]]::New()

    foreach ($dept in $department) {
        Write-Verbose "[$(Get-Date -Format G)] Getting users from the $dept department"
        $PSBoundParameters["filter"] = "Department -eq '$dept'"
        $users = Get-ADUser @PSBoundParameters
        if ($users.count -gt 0) {
            Write-Verbose "[$(Get-Date -Format G)] Retrieved $($users.count) members"
            foreach ($user in $users) {
                $obj = [pscustomobject]@{
                    PSTypename        = "ADDeptMember"
                    Department        = $user.Department
                    Name              = $user.Displayname
                    Title             = $user.Title
                    SamAccount        = $user.Samaccountname
                    Firstname         = $user.GivenName
                    Lastname          = $user.Surname
                    City              = $user.City
                    Phone             = $user.OfficePhone
                    OUPath            = ($user.distinguishedname -split ",", 2)[1]
                    Enabled           = $user.Enabled
                    Manager           = $user.manager
                    Description       = $user.Description
                    DistinguishedName = $user.DistinguishedName
                }
                $list.Add($obj)
            } #foreach user
            #clear $users so it isn't accidentally re-used
            Clear-Variable -Name users
        }
    } #foreach department

    #sort objects for output
    $list | Sort-Object -Property Manager, Name, City

    Write-Verbose "[$(Get-Date -Format G)] Ending $($myinvocation.mycommand)"
}

