
#an earlier version of this function can be found at  https://gist.github.com/jdhitsolutions/a4e6291741ec95e3bfe53f15a380da47

<#
you might need to increase the size of the Security eventlog
 limit-eventlog -LogName security -ComputerName dom2,dom1 -MaximumSize 1024MB
#>

Function Get-ADUserAudit {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify one or more domain controllers to query.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$DomainController = (Get-ADDomain).ReplicaDirectoryServers,
        [Parameter(HelpMessage = "Find all matching user management events since what date and time?")]
        [Datetime]$Since = (Get-Date).Addhours(-24),
        [Parameter(HelpMessage = "Select one or more user account events")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Created", "Deleted", "Enabled", "Disabled", "Changed")]
        [string[]]$Events = "Created",
        [Parameter(HelpMessage = "Specify an alterate credential")]
        [PSCredential]$Credential
    )

    Function _getNames {
        # a private helper function to parse out names from the eventlog message
        [cmdletbinding()]
        Param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [System.Diagnostics.Eventing.Reader.EventLogRecord]$Data
        )

        Process {
            #convert the record to XML which makes it easier to parse
            [xml]$r = $data.toxml()

            #Target is the user account
            #Subject is the admin who performed the operation
            $target = "{0}\{1}" -f ($r.Event.EventData.Data.Where( { $_.name -eq 'TargetDomainName' }).'#text'), ($r.Event.EventData.Data.Where( { $_.name -eq 'TargetUserName' }).'#text')
            $admin = "{0}\{1}" -f ($r.Event.EventData.Data.Where( { $_.name -eq 'SubjectDomainName' }).'#text'), ($r.Event.EventData.Data.Where( { $_.name -eq 'SubjectUserName' }).'#text')
            [pscustomobject]@{
                Target        = $target
                Administrator = $admin
                TimeCreated   = $data.timeCreated
            }
        } #process
    } # close _getNames

    # a hashtable of user management event IDs for the Security event log
    $ADEvent = @{
        UserChanged  = 4738
        UserCreated  = 4720
        UserDeleted  = 4726
        UserEnabled  = 4722
        UserDisabled = 4725
    }

    $EventIDs = @()
    Switch ($events) {
        "Created" { $EventIDs += $adevent.getenumerator().Where( { $_.name -match "created" }) }
        "Deleted" { $eventIDs += $adevent.getenumerator().Where( { $_.name -match "deleted" }) }
        "Enabled" { $eventIDs += $adevent.getenumerator().Where( { $_.name -match "enabled" }) }
        "Disabled" { $eventIDs += $adevent.getenumerator().Where( { $_.name -match "disabled" }) }
        "Changed" { $eventIDs += $adevent.getenumerator().Where( { $_.name -match "changed" }) }
    }

    #this hashtable filter will be used by Get-WinEvent
    $filter = @{LogName = 'Security'; ID = 0; StartTime = $Since }

    #parameters to eventually splat to Get-WinEvent
    $getParams = @{
        ErrorAction     = "Stop"
        FilterHashtable = $filter
        Computername    = ""
    }
    if ($Credential.UserName) {
        $getParams.add("Credential", $Credential)
    }

    Write-Verbose "Searching for AD log entries since $since"
    #Searching the Security event log on each domain controller
    foreach ($dc in $DomainController) {
        Write-Verbose "Processing $dc"
        foreach ($evt in $eventIDs) {
            $filter.ID = $evt.value
            $getParams.FilterHashtable = $filter
            $getParams.Computername = $DC
            Write-Verbose "...Looking for $($evt.name) events"
            Try {
                $logs = Get-WinEvent @getParams
                Write-Verbose "Found $($logs.count) log records"
            }
            Catch {
                Write-Warning "No matching $($evt.name) events $since found on $dc."
            }

            if ($logs.count -gt 0) {
                $names = $logs | _getnames
                $targets = ($names | Select-Object -Property Target -Unique).target
                $admins = ($names | Select-Object -Property Administrator -Unique).administrator
                [pscustomobject]@{
                    PSTypeName       = "ADAuditTrail"
                    DomainController = $dc
                    ID               = $evt.Value
                    EventType   = $evt.Name
                    LogCount    = $logs.count
                    Since            = $Since
                    Targets         = $targets
                    Administrators   = $admins
                }
                Remove-Variable -Name logs
            }
        }
    }
} #close function

Update-TypeData -TypeName ADAuditTrail -MemberType ScriptProperty -MemberName TargetCount -Value { $($this.targets).count } -Force

