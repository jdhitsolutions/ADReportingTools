
<#
Get group membership report
#>
Function Get-ADGroupReport {
    [cmdletbinding()]
    [OutputType("ADGroupReport")]
    Param(
        [parameter(Position = 0, HelpMessage = "Enter an AD Group name. Wildcards are allowed.")]
        [validatenotnullorEmpty()]
        [string]$Name = "*",
        [Parameter(HelpMessage = "Enter the distinguished name of the top level container or organizational unit.")]
        [ValidateScript( {
                $testDN = $_
                Try {
                    [void](Get-ADObject -Identity $_ -ErrorAction Stop)
                    $True
                }
                Catch {
                    Write-Warning "Failed to verify $TestDN as a valid searchbase."
                    Throw $_.Exception.message
                    $False
                }
            })]
        [string]$SearchBase,
        [Parameter(HelpMessage = "Filter on the group category")]
        [ValidateSet("All", "Distribution", "Security")]
        [string]$Category = "All",
        [Parameter(HelpMessage = "Filter on group scope")]
        [ValidateSet("Any", "DomainLocal", "Global", "Universal")]
        [string]$Scope = "Any",
        [Parameter(HelpMessage="Exclude BuiltIn and Users")]
        [switch]$ExcludeBuiltIn,
        [Parameter(HelpMessage = "Specify a domain controller to query for a list of domain controllers.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential. This will be used to query the domain and all domain controllers.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        #set some default parameter values
        $params = "Credential", "Server"

        ForEach ($param in $params) {
            if ($PSBoundParameters.ContainsKey($param)) {
                Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
                $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
            }
        } #foreach

        if ($ExcludeBuiltIn) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Excluding CN=Users and CN=BuiltIn"
            $Exclude = {$_.DistinguishedName -notMatch "CN\=(Users)|(BuiltIn)"}
        }
        else {
            #Exclude these items using late filtering to keep the AD filter from getting out of control
            $Exclude ={ @("Domain Users","Domain Computers", "Domain Guests") -notcontains $_.name}
        }

        $filter = "Name -like '$name'"
        if ($Category -ne "All") {
            $filter += " -AND GroupCategory -eq '$Category'"
        }
        if ($scope -ne "Any") {
            $filter += " -AND GroupScope -eq '$Scope'"
        }
        $get = @{
            Filter      = $filter
            Properties  = @("Description", "Created", "Modified","ManagedBy")
            ErrorAction = "Stop"
        }

        if ($SearchBase) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Searching for group(s) under $SearchBase"
            $get.Add("Searchbase", $SearchBase)
        }

    } #begin

    Process {
        if ($PSCmdlet.ParameterSetName -eq 'id') {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting group $Identity"
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Searching for groups with filter $filter"
        }

        Try {
            $group = Get-ADGroup @get | Where-Object $Exclude
            if ($group) {
                foreach ($item in $Group ) {

                    #get group members recursively
                    $Members =Get-ADGroupUser -name $item.distinguishedName

                    [PSCustomObject]@{
                        PSTypeName        = "ADGroupReport"
                        DistinguishedName = $item.DistinguishedName
                        Name              = $item.Name
                        Category          = $item.GroupCategory
                        Scope             = $item.GroupScope
                        Description       = $item.Description
                        Branch            = (Split-DistinguishedName -dn $item.DistinguishedName).branchdn
                        Created           = $item.Created
                        Modified          = $item.Modified
                        Members           = $members
                        ManagedBy         = $item.ManagedBy
                    }
                } #foreach item
            } #if $group
            else {
                Write-Warning "No matching groups found."
            }
        } #try
        Catch {
            Write-Warning $_.Exception.Message
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Get-ADGroupReport

<#
These have been exported to a types file
Update-TypeData -TypeName "ADGroupReport" -MemberType AliasProperty -MemberName DN -Value DistinguishedName -force
Update-TypeData -TypeName "ADGroupReport" -MemberType ScriptProperty -MemberName MemberCount -Value {($this.members | Measure-Object).Count} -force
Update-TypeData -TypeName "ADGroupReport" -MemberType ScriptProperty -MemberName Age -value ({New-Timespan -Start $this.Modified -end (Get-Date)})
#>

