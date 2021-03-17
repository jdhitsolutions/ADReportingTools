
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


Export-ModuleMember -Variable ADUserReportingConfiguration,ADReportingToolsOptions