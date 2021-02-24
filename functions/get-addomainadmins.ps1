

Function Get-ADDomainAdmin {
    [cmdletbinding()]
    [OutputType("ADDomainAdmin")]
    Param(
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting members of Domain Admins"
        $members = Get-ADGroupMember -identity "domain admins" -Recursive @PSBoundParameters

        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($members.count) members in total."
        #get details about each user
        foreach ($member in $members) {
            $user = Get-ADUser @PSBoundParameters -identity $member.distinguishedname -Properties PasswordLastSet,Description,title,Displayname,Department
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $($user.distinguishedname)"
            [pscustomobject]@{
                PSTypeName = "ADDomainAdmin"
                DistinguishedName = $user.DistinguishedName
                Displayname = $user.Displayname
                Name = $user.name
                Title = $user.title
                Department = $user.Department
                Description = $user.Description
                Enabled = $user.Enabled
                PasswordLastSet = $user.PasswordLastSet
            }
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-ADDomainAdmin