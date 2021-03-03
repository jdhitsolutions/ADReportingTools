Function Get-ADDomainControllerHealth {
    [cmdletbinding()]
    [OutputType("ADDomainControllerHealth")]
    Param(
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
        if ($PSBoundParameters.ContainsKey("Server")) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Adding 'Get-AD*:Server' to script PSDefaultParameterValues"
            $script:PSDefaultParameterValues["Get-AD*:Server"] = $PSBoundParameters.Item("server")
        }

        #use the credential with any command that supports alternate credentials
        if ($PSBoundParameters.ContainsKey("Credential")) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Adding '*:Credential' to script PSDefaultParameterValues"
            $script:PSDefaultParameterValues["*:Credential"] = $PSBoundParameters.Item("Credential")
        }

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting a list of all domain controllers"
        $dcs = Get-ADDomainController -Filter *
        Foreach ($dc in $dcs) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting health detail for $($dc.hostname)"

            #create a temporary cimSession
            Try {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Creating a temporary CIMSession"
                $tmpCS = New-CimSession -ComputerName $dc.name -ErrorAction Stop
                $cimParam = @{
                    CimSession = $tmpCS
                    Classname  = ""
                    Property   = ""
                }
            }
            Catch {
                Write-Warning "Failed to create a temporary CIMSession to $($dc.name). $($_.Exception.message)"
                Remove-Variable -Name tmpCS -ErrorAction SilentlyContinue
            }

            if ($tmpCS) {
                #get additional information via CIM
                $cimParam["Classname"] = "win32_logicaldisk"
                $cimParam["filter"] = "deviceid='c:'"
                $cimParam["Property"] = "Freespace", "Size"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting free space on C:"
                $c = Get-CimInstance @cimParam

                $cimParam["Classname"] = "win32_NTEventLogFile"
                $cimParam["filter"] = "logfilename='security'"
                $cimParam["Property"] = "FileSize", "MaxFileSize"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting security log percent used"
                $seclog = Get-CimInstance @cimParam

                $cimParam["Classname"] = "win32_service"
                $cimParam["filter"] = "name='ntds' or name='kdc' or name='adws' or name='dfsr' or name='dfs' or name='netlogon' or name = 'samss' or name='w32time'"
                $cimParam["Property"] = "Displayname","Name", "State", "ProcessID", "StartMode", "Started"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting critical service satus"
                $services = Get-CimInstance @cimParam | Select-Object -Property $cimParam.property

                $cimParam["Classname"] = "win32_operatingsystem"
                $cimParam.remove("filter")
                $cimParam["Property"] = "LastBootUpTime", "TotalVisibleMemorySize", "FreePhysicalMemory"
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting uptime and memory utilization"
                $os = Get-CimInstance @cimParam

                #remove the temporary cimsession
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Removing the temporary CIMSession"
                $tmpCS | Remove-CimSession
            }
            #create a custom object
            [pscustomobject]@{
                PSTypename      = "ADDomainControllerHealth"
                Hostname        = $dc.hostname
                IPAddress       = $dc.IPv4Address
                OperatingSystem = $dc.OperatingSystem
                Uptime          = (New-TimeSpan -Start $os.LastBootUpTime -End (Get-Date))
                PctFreespace    = [math]::Round(($c.Freespace / $c.Size) * 100, 2)
                PctFreeMemory   = [math]::Round(($os.FreePhysicalMemory / $os.TotalVisibleMemorySize) * 100, 2)
                PctSecurityLog  = [math]::Round( ($seclog.filesize/$seclog.MaxFileSize)*100,2 )
                Services        = $Services
                Roles           = $dc.OperationMasterRoles
                IsGlobalCatalog = $dc.IsGlobalCatalog
                IsReadOnly      = $dc.IsReadOnly
                DistinguishedName = $dc.ComputerObjectDN
            }
        } #foreach DC

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Get-ADDomainControllerHealth

Update-TypeData -TypeName "ADDomainControllerHealth" -MemberType ScriptProperty -MemberName "ServiceAlert" -Value {
    $list = "Stopped","StartPending","StopPending","ContinuePending","PausePending","Paused"
    if ($this.services.state.where({$list -contains $_})) {
        $True
    }
    Else {
        $False
    }
} -force