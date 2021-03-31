
# dot source functions
Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 |
Foreach-Object {
    . $_.FullName
}

#region format and type updates
Update-TypeData -TypeName ADBranchMember -MemberType AliasProperty -MemberName DN -Value DistinguishedName -Force

Update-TypeData -TypeName "ADDomainControllerHealth" -MemberType ScriptProperty -MemberName "ServiceAlert" -Value {
    $list = "Stopped","StartPending","StopPending","ContinuePending","PausePending","Paused"
    if ($this.services.state.where({$list -contains $_})) {
        $True
    }
    Else {
        $False
    }
} -force

#endregion

#region define module variables

$ADUserReportingConfiguration = Get-Content $PSScriptRoot\configurations\aduser-categories.json | ConvertFrom-Json

#use $([char]0x1b) because it will work in Windows PowerShell and PowerShell 7.

$ADReportingToolsOptions = @{
    DistributionList   = "$([char]0x1b)[92m"
    Alert              = "$([char]0x1b)[91m"
    Warning            = "$([char]0x1b)[38;5;220m"
    Universal          = "$([char]0x1b)[38;5;170m"
    DomainLocal        = "$([char]0x1b)[38;5;191m"
    Other              = "$([char]0x1b)[38;5;212m"
    Protected          = "$([char]0x1b)[38;5;199m"
    Container          = "$([char]0x1b)[38;5;1456m"
    OrganizationalUnit = "$([char]0x1b)[38;5;191m"
    DomainDNS          = "$([char]0x1b)[1;4;38;5;227m"
    UserClass          = "$([char]0x1b)[30;104m"
    GroupClass         = "$([char]0x1b)[30;48;5;94m"
    ComputerClass      = "$([char]0x1b)[30;48;5;50m"
    IsDC               = "$([char]0x1b)[38;5;155m"
    IsServer           = "$([char]0x1b)[38;5;50m"
}

#endregion

#region import runspace

#launch a runspace to gather department information in the background
$newRunspace = [RunspaceFactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
[void]$newRunspace.Open()
$Global:ADReportingHash = [hashtable]::Synchronized(@{
        Note        = "This hashtable is used by the ADReportingTools module. Do not delete."
        Departments = @()
        DomainControllers = @()
        BackupLimit = 3
    }
)
$newRunspace.SessionStateProxy.SetVariable("ADReportingHash", $ADReportingHash)

$psCmd = [PowerShell]::Create()

[void]$pscmd.AddScript( {
    #this code will run in the background upon module import. Values will populate
    #the synchronized hashtable.
        $global:ADReportingHash.Departments = Get-ADUser -Filter "Department -like '*'" -Properties Department | Select-Object -ExpandProperty Department -Unique | Sort-Object
        $global:ADReportingHash.DomainControllers = (Get-ADDomain).ReplicaDirectoryServers

        #simulate a large environment for testing purposes
        #Start-Sleep -Seconds 30
        $global:ADReportingHash.Add("LastUpdated", (Get-Date))
    })

$psCmd.Runspace = $newRunspace

$handle = $psCmd.BeginInvoke()

$ADReportingHash.Add("Handle", $handle)

#start a job to clean up the runspace after it closes
[void](Start-ThreadJob -ScriptBlock {
        param($handle, $ps, $sleep)
        Write-Host "[$(Get-Date)] Sleeping in $sleep second loops"
        Write-Host "Watching this runspace"
        Write-Host ($ps.runspace | Out-String)
        do {
            Start-Sleep -Seconds $sleep
        } Until ($handle.IsCompleted)
        Write-Host "[$(Get-Date)] Closing runspace"

        $ps.runspace.close()
        Write-Host "[$(Get-Date)] Disposing runspace"
        $ps.runspace.Dispose()
        Write-Host "[$(Get-Date)] Disposing PowerShell"
        $ps.dispose()

        Write-Host "[$(Get-Date)] Ending job"
    } -ArgumentList $handle, $pscmd, 10)

#endregion

#region Other
Register-ArgumentCompleter -CommandName Get-ADDepartment -ParameterName Department -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $global:ADReportingHash.Departments | Where-Object { $_ -like "$WordToComplete*" } |
    ForEach-Object {
        # completion text,listitem text,result type,Tooltip
        [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
    }
}

#Add auto complete for SERVER parameter to these commands
$cmds = 'Get-ADBranch','Get-ADCanonicalUser','Get-ADComputerReport','Get-ADDepartment','Get-ADDomainControllerHealth','Get-ADFSMO','Get-ADGroupR
eport','Get-ADGroupUser','Get-ADSiteDetail','Get-ADSiteSummary','Get-ADSummary','Get-ADUserCategory','New-ADChangeReport','New-ADDomain
Report','New-ADGroupReport','Show-DomainTree','Get-ADAccountAuthorizationGroup','Get-ADAccountResultantPasswordReplicationPolicy','Get-
ADAuthenticationPolicy','Get-ADAuthenticationPolicySilo','Get-ADCentralAccessPolicy','Get-ADCentralAccessRule','Get-ADClaimTransformPol
icy','Get-ADClaimType','Get-ADComputer','Get-ADComputerServiceAccount','Get-ADDefaultDomainPasswordPolicy','Get-ADDomain','Get-ADDomain
Controller','Get-ADDomainControllerPasswordReplicationPolicy','Get-ADDomainControllerPasswordReplicationPolicyUsage','Get-ADFineGrained
PasswordPolicy','Get-ADFineGrainedPasswordPolicySubject','Get-ADForest','Get-ADGroup','Get-ADGroupMember','Get-ADObject','Get-ADOptiona
lFeature','Get-ADOrganizationalUnit','Get-ADPrincipalGroupMembership','Get-ADReplicationAttributeMetadata','Get-ADReplicationConnection
','Get-ADReplicationQueueOperation','Get-ADReplicationSite','Get-ADReplicationSiteLink','Get-ADReplicationSiteLinkBridge','Get-ADReplic
ationSubnet','Get-ADResourceProperty','Get-ADResourcePropertyList','Get-ADResourcePropertyValueType','Get-ADRootDSE','Get-ADServiceAcco
unt','Get-ADTrust','Get-ADUser','Get-ADUserResultantPasswordPolicy'

foreach ($cmd in $cmds) {

    Register-ArgumentCompleter -CommandName $cmd  -ParameterName Server -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

        $global:ADReportingHash.DomainControllers | Where-Object { $_ -like "$WordToComplete*" } |
        ForEach-Object {
            # completion text,listitem text,result type,Tooltip
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Export-ModuleMember -Variable ADUserReportingConfiguration,ADReportingToolsOptions,ADReportingDepartments

#endregion

