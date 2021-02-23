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
    } #begin

    Process {
        Write-Verbose "[PROCESS] Getting domain information for $Identity"

        Try {
            $domain = Get-ADDomain @PSBoundParameters -ErrorAction Stop
        }
        Catch {
            throw $_
        }

        if ($domain.name) {
            Write-Verbose "[PROCESS] Getting forest information for $($domain.forest)"
            $PSBoundParameters["Identity"] = $domain.forest
            Try {
                $forest = Get-ADForest @psboundparameters -ErrorAction Stop
            }
            Catch {
                throw $_
            }
        }
        [pscustomobject]@{
            PSTypeName = "ADSummary"
            Domain = $domain.DNSRoot
            Forest = $forest.name
            RootDomain = $forest.RootDomain
            Domains = $forest.Domains
            DomainControllers = $domain.ReplicaDirectoryServers
            DomainMode = $domain.DomainMode
            ForestMode = $forest.ForestMode
            GlobalCatalogs = $forest.GlobalCatalogs
            SiteCount = $forest.sites.count
        }
    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

    } #close Get-ADSummary