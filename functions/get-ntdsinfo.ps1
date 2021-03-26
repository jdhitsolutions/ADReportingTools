

Function Get-NTDSInfo {
    [cmdletbinding()]
    [outputType("NTDSInfo")]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, HelpMessage = "Specify a domain controller name.")]
        [Alias("name")]
        [string[]]$Computername,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [PSCredential]$Credential
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

        $sb = {
            $dsa = Get-ItemProperty -path 'HKLM:\system\CurrentControlSet\Services\ntds\Parameters'

            #send a hashtable of data
            @{
                ntds         = Get-Item -Path $dsa.'DSA Database File'
                logs         = Get-ChildItem -Path $dsa.'Database log files path' -Filter edb*.log
                computername = $env:computername
            }
        }
    } #begin

    Process {
        foreach ($Computer in $Computername) {

            Try {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting NTDS data from $($Computer.toUpper())."
                Invoke-Command -ScriptBlock $sb -ComputerName $computer -HideComputerName -ErrorAction Stop |
                ForEach-Object {
                    #disable Verbose output from Resolve-DNSName because it adds no value here.
                    [pscustomobject]@{
                        PSTypename       = "NTDSInfo"
                        DomainController = (Resolve-DnsName -Type A -Name $_.computername -Verbose:$false).Name
                        Path             = $_.ntds.FullName
                        Size             = $_.ntds.Length
                        FileDate         = $_.ntds.LastWriteTime
                        LogCount         = $_.logs.count
                        Date             = (Get-Date)
                    }
                } #foreach-object
            }#try
            Catch {
                Write-Warning "Error getting data from $($computer.toUpper()). $($_.Exception.Message)."
            }
        } #foreach computer
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-NTDSInfo