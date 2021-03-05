

Function Get-ADCanonicalUser {
    [cmdletbinding()]
    [OutputType("Microsoft.ActiveDirectory.Management.ADUser")]
    [Alias("Get-ADCNUser")]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, HelpMessage = "Enter the username in the form domain\username.")]
        [ValidatePattern('^\S+\\\S+$')]
        [string]$Name,
        [Parameter(HelpMessage = "Enter one or more user properties or * to select everything.")]
        [string[]]$Properties,
        [Parameter(HelpMessage = "Search deleted objects if the user account can't be found.")]
        [switch]$IncludeDeletedObjects,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
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

        $get = @{
            ErrorAction = "Stop"
            Identity    = ""
        }
        if ($Properties) {
            $get.Add("Properties", $properties)
        }
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting the AD user account for $Name"
        $sam = $Name.split("\")[1]
        $get["Identity"] = $sam

        Try {
            Get-ADUser @get
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            if ($IncludeDeletedObjects) {
                #check for a deleted user account
                Try {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Searching for deleted objects"
                    $get.remove("Identity")
                    $get["filter"] = "samaccountname -eq '$sam'"
                    $user = Get-ADObject @get -IncludeDeletedObjects
                    $get.remove("filter")
                    If ($user) {
                        $user
                    }
                    else {
                        Write-Warning "Failed to find a user account called $Name."
                    }
                }
                Catch {
                    Write-Warning $_.exception.message
                }
            }
            else {
                Write-Warning "Failed to find a user account called $Name."
            }
        }
        Catch {
            #all other errors from Get-ADUser
            Write-Warning $_.exception.message
        }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-ADCanonicalUser