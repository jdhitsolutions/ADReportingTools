

Function Get-ADGroupUser {
    [cmdletbinding()]
    [OutputType("ADGroupUser")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of an Active Directory group.",ValueFromPipelineByPropertyName,ValueFromPipeline)]
        [string]$Name,
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
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting members of $Name"
        $group= Get-ADGroup -identity  "$($Name)"
        if ($group) {
        $members = $group   |  Get-ADGroupMember  -Recursive

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($members.count) members in total."
        #get details about each user
        foreach ($member in $members) {
            $user = Get-ADUser -Identity $member.distinguishedname -Properties PasswordLastSet, Description, Title, Displayname, Department
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $($user.distinguishedname)"
            [pscustomobject]@{
                PSTypeName        = "ADGroupUser"
                DistinguishedName = $user.DistinguishedName
                Displayname       = $user.Displayname
                Name              = $user.name
                Title             = $user.title
                Department        = $user.Department
                Description       = $user.Description
                Enabled           = $user.Enabled
                PasswordLastSet   = $user.PasswordLastSet
                Group = $group.DistinguishedName
            }
        } #foreach
    } #if group was found
    else {
        Write-Warning "Failed to find an Active Directory group called $Name"
    }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-ADGroupUser