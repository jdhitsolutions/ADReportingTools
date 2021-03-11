Function Get-ADSummary {
    [cmdletbinding()]
    [OutPutType("ADSummary")]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify the domain name. The default is the user domain.")]
        [ValidateNotNullOrEmpty()]
        [alias("name")]
        [string]$Identity = $env:USERDOMAIN,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )

    Begin {
        Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
        if (-Not $PSBoundParameters.ContainsKey("ErrorAction")) {
            $PSBoundParameters.Add("ErrorAction", "Stop")
        }
    } #begin

    Process {
        Write-Verbose "[PROCESS] Getting domain information for $Identity"
        Write-Verbose "[PROCESS] Using these PSBoundParameters:"
        if ($VerbosePreference -eq 'continue') {
            #I want to make this output looks like a continuation of the previous line
            New-Object psobject -Property $PSBoundParameters | Out-String |
            Write-Host -ForegroundColor $host.PrivateData.VerboseForegroundColor
        }

        Try {
            $domain = Get-ADDomain @PSBoundParameters
        }
        Catch {
            Write-Warning $_.Exception.message
        }

        if ($domain.name) {
            Write-Verbose "[PROCESS] Getting forest information for $($domain.forest)"
            #update PSBoundParameters
            $PSBoundParameters["Identity"] = $domain.forest
            Write-Verbose "[PROCESS] Using these PSBoundParameters:"
            if ($VerbosePreference -eq 'continue') {
                New-Object psobject -Property $PSBoundParameters | Out-String |
                Write-Host -ForegroundColor $host.PrivateData.VerboseForegroundColor
            }

            Try {
                $forest = Get-ADForest @PSBoundParameters
            }
            Catch {
                Write-Warning $_.exception.message
            }
            #create a custom object
            [pscustomobject]@{
                PSTypeName        = "ADSummary"
                Domain            = $domain.DNSRoot
                Forest            = $forest.name
                RootDomain        = $forest.RootDomain
                Domains           = $forest.Domains
                DomainControllers = $domain.ReplicaDirectoryServers
                DomainMode        = $domain.DomainMode
                ForestMode        = $forest.ForestMode
                GlobalCatalogs    = $forest.GlobalCatalogs
                SiteCount         = $forest.sites.count
            }
        } #if domain name
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

} #close Get-ADSummary