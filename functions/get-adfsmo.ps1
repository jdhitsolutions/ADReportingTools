Function Get-ADFSMO {
    [cmdletbinding()]
    [outputtype("ADFSMORole")]
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
            PSTypeName                   = "ADFSMORole"
            Domain                           = $domain.DNSRoot
            Forest                              = $forest.Name
            PDCEmulator                  = $domain.PDCEmulator
            RIDMaster                       = $domain.RIDMaster
            InfrastructureMaster       = $domain.InfrastructureMaster
            SchemaMaster                = $forest.SchemaMaster
            DomainNamingMaster   = $forest.DomainNamingMaster
        }

    } #process

    End {
        Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
    } #end

} #close Get-ADFSMO
