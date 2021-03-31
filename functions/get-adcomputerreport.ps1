Function Get-ADComputerReport {
    [cmdletbinding()]
    [OutputType("ADComputerInfo")]
    Param (
        [parameter(Position = 0, HelpMessage = "Enter an AD computer identity. Wildcard are allowed.", ValueFromPipeline)]
        [validatenotnullorEmpty()]
        [string]$Name= "*",

        [Parameter(HelpMessage = "Filter by the operating system")]
        [ValidateSet("Any","Server","Desktop")]
        [string]$Category = "Any",

        [Parameter(HelpMessage = "Filter by location")]
        [ArgumentCompleter({(Get-ADSiteSummary).subnetLocation})]
        [ValidateNotNullOrEmpty()]
        [string]$Location,

        [Parameter(HelpMessage = "Enter the distinguished name of the top-level container or organizational unit.")]
        [string]$SearchBase,

        [Parameter(HelpMessage = "Specify a domain controller to query for a list of domain controllers.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,

        [Parameter(HelpMessage = "Specify an alternate credential. This will be used to query the domain and all domain controllers.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

        $properties = "DNSHostname", "OperatingSystem", "LastLogonDate", "Created", "Modified", "Location", "Description", "IPv4Address"
        [void]$PSBoundParameters.Add("Properties",$Properties)
        [void]$PSBoundParameters.Remove("Category")
        [void]$PSBoundParameters.Remove("location")

        $results = [System.Collections.Generic.list[object]]::new()
    } #begin
    Process {

        [void]$PSBoundParameters.Remove("Name")

        $filter = "name -like '$Name'"
        if ($Category -eq "server") {
            $filter += " -AND OperatingSystem -like '*Server*'"
        }
        elseif ($category -eq 'Desktop') {
            $filter += " -AND OperatingSystem -notlike '*Server*'"
        }

        if ($Location) {
            $filter += " -AND Location -eq '$location'"
        }

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Searching with filter $filter"
        $PSBoundParameters.Add("filter",$filter)

        $computers = Get-ADComputer @PSBoundParameters
        if ($computers) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $(($computers | Measure-Object).count) computer(s)"
            foreach ($computer in $computers) {
                #create a custom object
                $r = [PSCustomObject]@{
                    PSTypeName        = "ADComputerInfo"
                    Name              = $Computer.name
                    DNSHostname       = $computer.DNSHostname
                    Description       = $computer.Description
                    OperatingSystem   = $computer.OperatingSystem
                    IsServer          = $computer.OperatingSystem -match "Server"
                    Location          = $computer.Location
                    LastLogonDate     = $computer.LastLogonDate
                    IPAddress         = $computer.IPv4Address
                    Created           = $computer.Created
                    Modified          = $computer.Modified
                    DistinguishedName = $computer.DistinguishedName
                }

                $results.add($r)
            } #foreach computer

            #sort results and write to the pipeline
            $results | Sort-Object -Property DistinguishedName

        } #if computers

    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end
}