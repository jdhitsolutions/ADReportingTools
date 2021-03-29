
Get-ChildItem -path $PSScriptRoot\Functions\*.ps1 |
Foreach-Object {
    . $_.FullName
}

#format and type updates
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

$ADUserReportingConfiguration = Get-Content $PSScriptRoot\configurations\aduser-categories.json | ConvertFrom-Json


#this needs to be defined in the background for performance purposes
# $ADReportingDepartments =  Get-ADUser -Filter  "Department -like '*'" -Properties Department | Select-Object -ExpandProperty Department -Unique | Sort-Object

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

        $global:ADReportingHash.Departments = Get-ADUser -Filter "Department -like '*'" -Properties Department | Select-Object -ExpandProperty Department -Unique | Sort-Object
        $global:ADReportingHash.DomainControllers = (Get-ADDomain).ReplicaDirectoryServers

        #simulate a large environment for testing purposes
        #Start-Sleep -Seconds 30
        $global:ADReportingHash.Add("LastUpdated", (Get-Date))
    })

$psCmd.Runspace = $newRunspace

$handle = $psCmd.BeginInvoke()

$ADReportingHash.Add("Handle", $handle)

#start a job to clean up the runspace
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


Register-ArgumentCompleter -CommandName Get-ADDepartment -ParameterName Department -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $global:ADReportingHash.Departments | Where-Object { $_ -like "$WordToComplete*" } |
    ForEach-Object {
        # completion text,listitem text,result type,Tooltip
        [System.Management.Automation.CompletionResult]::new("'$_'", $_, 'ParameterValue', $_)
    }
}

Export-ModuleMember -Variable ADUserReportingConfiguration,ADReportingToolsOptions,ADReportingDepartments

