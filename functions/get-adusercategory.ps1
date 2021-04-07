#get user information based on a defined category.
#Category properties are defined in configuration json files.

Function Get-ADUserCategory {
    [cmdletbinding(DefaultParameterSetName = "filter")]
    [OutputType("ADUserCategory")]
    Param(
        [parameter(Position = 0, Mandatory, HelpMessage = "Enter an AD user identity", ParameterSetName = "id")]
        [validatenotnullorEmpty()]
        [string]$Identity,
        [parameter(HelpMessage = "Specify an AD filter like department -eq 'sales'. The default is all Enabled user accounts.", ParameterSetName = "filter")]
        [validatenotnullorEmpty()]
        [string]$Filter = "-not (UserAccountControl -BAND 0x2)",
        [Parameter(HelpMessage = "Enter the distinguished name of the top level container or organizational unit.", ParameterSetName = "filter")]
        [string]$SearchBase,
        [Parameter(Mandatory, HelpMessage = "Select a defined category.")]
        [ArgumentCompleter( { $ADUserReportingConfiguration.Name })]
        [ValidateScript( {
                If ($ADUserReportingConfiguration.Name -contains $_) {
                    $True
                }
                else {
                    Throw "You must select a valid name from `$ADUserReportingConfiguration."
                    $False
                }

            })]
        [string]$Category,
        [Parameter(HelpMessage = "Specify a domain controller to query for a list of domain controllers.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential. This will be used to query the domain and all domain controllers.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

        [void]($PSBoundParameters.Remove("Category"))

        #add the filter category if not bound
        if ($pscmdlet.ParameterSetName -eq 'filter' -AND (-not $PSBoundParameters.ContainsKey("filter"))) {
            $PSBoundParameters.Add("Filter", "-Not(UserAccountControl -BAND 0x2)")
        }
        $catProp = $ADUserReportingConfiguration.Where( { $_.name -eq $Category }).Properties
        if ($catProp) {
            $PSBoundParameters.Add("Properties", $catProp)
        }
        else {
            Write-Warning "Failed to find any properties for a category called $category. Using defaults."
        }
    } #begin

    Process {

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting user information for category $Category "

        if ($pscmdlet.ParameterSetName -eq 'id') {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting user $identity"
        }
        else {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Using filter $filter"
            if ($SearchBase) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Searching under $Searchbase"
            }
        }
        $PSBoundParameters | Out-String | Write-Verbose
        $users = Get-ADUser @PSBoundParameters

        if ($users) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $(($users | Measure-Object).count) user(s)"
            foreach ($user in $users) {
                #create a temp hashtable
                $h = [ordered]@{
                    PSTypeName        = "ADUserCategory.$category"
                    DistinguishedName = $user.DistinguishedName
                }

                #add category properties
                foreach ($prop in $catProp) {
                    $h.Add($prop, $user.$prop)
                }
                #write as a custom object
                New-Object -TypeName PSObject -Property $h
            }
        }
        else {
            Write-Warning "Failed to find any matching user accounts."
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-ADUserCategory