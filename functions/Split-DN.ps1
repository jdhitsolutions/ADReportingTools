

Function Split-DistinguishedName {
    [cmdletbinding()]
    [Alias("Parse-DN")]
    [outputtype("ADDistinguishedNameInfo")]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Enter an Active Directory DistinguisdedName.")]
        [alias("dn")]
        [string]$DistinguishedName
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        $data = _formatdn $DistinguishedName
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Splitting $data "
        $split = $DistinguishedName -split ","
        $dc = $split | Where-Object { $_ -match "^DC" }
        $domainDN = $dc -join ','
        [pscustomobject]@{
            PSTypename = "ADDistinguishedNameInfo"
            Name       = ($split[0]).split("=")[-1]
            Branch     = ($split[1]).split("=")[-1]
            BranchDN   = ($split | Select-Object -Skip 1) -join ','
            Domain     = ($dc[0]).split("=")[-1]
            DomainDN   = $domainDN
            DomainDNS  = $domaindn.replace("DC=", "").replace(",", ".")
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close function

<#

DistinguishedName = CN=SupportTech,OU=Help Desk,OU=IT,DC=Company,DC=Pri
Name = SupportTech
Branch = Help Desk
BranchDN = OU=Help Desk,OU=IT,DC=Company,DC=Pri
Domain = Company
DomainDN = DC=Company,DC=Pri
$$DomainDNS = Company.pri

#>