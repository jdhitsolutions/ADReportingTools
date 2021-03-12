Function Get-ADSiteSummary {
    [cmdletbinding()]
    [OutPutType("ADSiteSummary")]
    Param(
        [Parameter(Position = 0,HelpMessage = "Specify the name of an Active Directory site. The default is all sites.")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $getParams = @{
        ErrorAction = "Stop"
        Properties  = "Subnets", "WhenChanged", "WhenCreated"
    }
    if ($Name) {
        Write-Verbose "Getting site $Name"
        $getparams.Add("Identity",$Name)
    }
    else {
        Write-Verbose "Getting all sites"
        $getParams.Add("Filter", "*")
    }

    if ($server) {
        Write-Verbose "Querying domain controller $server"
        $getParams.Add("server", $server)
    }
    if ($Credential.UserName) {
        Write-Verbose "Using alternate credential for $($credential.username)"
        $getParams.Add("Credential", $Credential)
    }

    try {
        Write-Verbose "Getting AD Replication sites"
        #get sites first and then subnets for each site. This will make grouping and formatting
        #results easier

        $sites = Get-ADReplicationSite @getParams

        Write-Verbose "Found $(($sites | Measure-Object).count) sites"
        $getParams["Properties"] = "Name", "Description", "Location", "WhenChanged", "WhenCreated"

        $getParams.Remove("Identity")
        $getParams.Remove("filter")
        foreach ($site in $sites) {
            Write-Verbose "Getting subnets associated with $($site.name)"

            #"site -eq $($site.distinguishedname)"
            Write-Verbose "Found $($site.subnets.count) subnets"

            $data = $site.subnets | Sort-Object | Get-ADReplicationSubnet @getParams
            foreach ($item in $data) {
                [pscustomobject]@{
                    PSTypename        = "ADSiteSummary"
                    Site              = $site.Name
                    SiteDescription   = $site.Description
                    Subnet            = $item.Name
                    SubnetDescription = $item.Description
                    SubnetLocation    = $item.Location
                    SiteCreated       = $site.WhenCreated
                    SiteModified      = $site.WhenChanged
                    SubnetCreated     = $item.WhenCreated
                    SubnetModified    = $item.WhenChanged
                }
            } #foreach item
        } #foreach site
    }
    Catch {
        throw $_
    }

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}

Function Get-ADSiteDetail {
    [cmdletbinding()]
    [OutPutType("ADSiteDetail")]
    Param(
        [Parameter(Position = 0,HelpMessage = "Specify the name of an Active Directory site. The default is all sites.")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )
    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $data = Get-ADSiteSummary @psboundparameters | Group-Object -Property Site

    if ($data) {
        foreach ($item in $data) {
            #create a new custom object
            [PSCustomObject]@{
                PSTypename  = "ADSiteDetail"
                Name        = $item.Name
                Description = $item.group[0].SiteDescription
                SubnetCount = $item.count
                Subnets     = $item.group.subnet
                Created     = $item.group[0].SubnetCreated
                Modified    = $item.group[0].SubnetModified
            }
        }
    }
    else {
        Write-Warning "Failed to get site and subnet information."
    }

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}