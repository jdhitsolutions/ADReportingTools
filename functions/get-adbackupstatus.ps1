<#
 [/u:{domain\user}] [/pw:{password|*}]
 $b =repadmin /showbackup dom2 | where {$_} | Select -skip 2
 $b[1].trim() -split "\s+"
 LocalUSN 8509
 OriginatingDSA 5b0e0bf7-dd47-4ef8-b6ed-49158f613bca
 OriginatingUSN 13777
 Date 2021-01-25
 Time 14:27:01
 Version 1
 Attribute dSASignature
 #>

Function Get-ADBackupStatus {

    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify the name of a domain controller")]
        [string[]]$DomainController,
        [Parameter(HelpMessage = "Specify an alternate credential")]
        [pscredential]$Credential
    )

    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $splat = @{
        ErrorAction = "Stop"
        ScriptBlock = { repadmin /showbackup | Where-Object { $_ } | Select-Object -Skip 3 }
        Computername = ""
    }

    if ($credential.username) {
        Write-Verbose "Using alternate credential for $($credential.UserName)"
        $splat.Add("Credential",$Credential)
    }
    foreach ($dc in $DomainController) {
        Write-Verbose "Querying $($dc.ToUpper())"

        Try {
            $splat["Computername"] = $dc
            $data = Invoke-Command @splat

            If ($data) {
                $fqdn = _toTitleCase (_getDNSName $dc)
                Write-Verbose "Parsing readmin.exe results"
                for ($i = 0; $i -lt $data.count; $i += 2) {
                    Write-Verbose "Partition: $($data[$i])"
                    Write-Verbose "Splitting: $(($data[$i + 1]).trim())"
                    $details = $data[$i + 1].trim() -split "\s+"
                    $info = [PSCustomObject]@{
                        PSTypeName       = "ADBackupStatus"
                        Partition        = $data[$i]
                        LocalUSN         = $details[0]
                        OriginatingDSA   = $details[1]
                        OriginatingUSN   = $details[2]
                        Date             = "$($details[3]) $($details[4])" -as [datetime]
                        Version          = $details[5]
                        Signature        = $details[6]
                        DomainController = $fqdn
                    }
                    $Info
                } #for
            }
        }
        Catch {
            $_
        }
    } #foreach DC

    Write-Verbose "Ending $($MyInvocation.MyCommand)"
}

Update-TypeData -TypeName ADBackupStatus -MemberType ScriptProperty -MemberName Age -Value {New-TimeSpan -start $this.date -end (Get-Date)} -force