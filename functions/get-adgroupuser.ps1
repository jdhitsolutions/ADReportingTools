Function Get-ADGroupUser {
    [cmdletbinding()]
    [OutputType("ADGroupUser")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the name of an Active Directory group.", ValueFromPipelineByPropertyName, ValueFromPipeline)]
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
        $group = Get-ADGroup -Identity "$($Name)"
        if ($group) {
            $members = $group | Get-ADGroupMember -Recursive

            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $($members.name.count) members in total."
            #get details about each group member
            $getParams = @{
                properties = 'PasswordLastSet', 'Description', 'Title', 'Displayname', 'Department'
                Identity   = ""
            }
            foreach ($member in $members) {
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] member is a $($member.objectclass)"
                $getParams.Identity = $member.distinguishedname

                <#
                    Not using Get-ADObject because it can't return the passwordLastSet property
                #>
                if ($member.objectclass -eq "user") {
                    $grpMember = Get-ADUser @getparams
                }
                elseif ($member.objectclass -eq "computer") {
                    $grpMember = Get-ADComputer @getparams
                }

                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] $($grpMember.distinguishedname)"
                [pscustomobject]@{
                    PSTypeName        = "ADGroupUser"
                    DistinguishedName = $grpMember.DistinguishedName
                    Displayname       = $grpMember.Displayname
                    Name              = $grpMember.name
                    Title             = $grpMember.title
                    Department        = $grpMember.Department
                    Description       = $grpMember.Description
                    Enabled           = $grpMember.Enabled
                    PasswordLastSet   = $grpMember.PasswordLastSet
                    Group             = $group.DistinguishedName
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