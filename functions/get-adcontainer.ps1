Function Get-ADBranch {
    [cmdletbinding()]
    Param (
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the distinguished name of the top level container or organizational unit.")]
        [string]$SearchBase,
        [switch]$IncludeDeletedObjects,
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

        #define a private helper function
        function _getbranchmember {
            [cmdletbinding()]
            Param ( [object[]]$Items, $parent)

            foreach ($item in $items) {
                #write-verbose $item.distinguishedname
                [pscustomobject]@{
                    PSTypeName        = "ADBranchMember"
                    DistinguishedName = $item.DistinguishedName
                    Name              = $item.Name
                    Description       = $item.Description
                    Class             = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($item.objectClass)
                    Parent            = _formatdn $Parent
                    Deleted           = $item.Deleted
                    Enabled           = -Not(( $item.UserAccountControl -band 0x2) -as [bool])
                }
            }
        } # _getbranchmember

        function _formatdn {
            #format a distinguished name to look nicer
            [CmdletBinding()]
            Param([string]$DN)

            $parts = $dn -split "\,"
            $updates = [System.Collections.Generic.list[string]]::new()
            foreach ($part in $parts) {
                $split = $part -split "\="
                $name = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($split[1].trim().toLower())
                $transform = "{0}={1}" -f $split[0].trim().toUpper(), $name
                $updates.Add($transform)
            }
            $updates -join ","
        }

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Enumerating $searchBase "
        $getParams = @{
            filter                = "objectclass -eq 'computer' -or objectclass -eq 'user' -or objectclass -eq 'group' -or objectclass -eq 'container' -or objectclass -eq 'organizationalunit' -or objectclass -eq 'builtindomain'"
            SearchScope           = "OneLevel"
            SearchBase            = $SearchBase
            ErrorAction           = "Stop"
            Properties            = "Description", "UserAccountControl"
            IncludeDeletedObjects = $IncludeDeletedObjects
        }
        Try {
            $data = Get-ADObject @getParams | Sort-Object DistinguishedName | Group-Object -Property ObjectClass

            #display users
            if ($data.name -contains "user") {
                $item = $data.where( { $_.name -eq 'user' })
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $(($item.group | Measure-Object).count) user[s]"
                _getbranchmember -Items $item.group -parent $searchBase
            } #if user

            #display groups
            if ($data.name -contains "group") {
                $item = $data.where( { $_.name -eq 'group' })
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $(($item.group | Measure-Object).count) group[s]"
                _getbranchmember -Items $item.group -parent $searchBase
            } #if group

            #display computers
            if ($data.name -contains "computer") {
                $item = $data.where( { $_.name -eq 'computer' })
                Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Found $(($item.group | Measure-Object).count) computer[s]"
                _getbranchmember -Items $item.group -parent $searchBase
            } #if user

            #display organizational units
            if ($data.name -contains "organizationalUnit") {
                $data.where( { $_.name -eq 'organizationalUnit' }).group |
                ForEach-Object { Get-ADBranch -SearchBase $_.distinguishedname }
            }

            #display containers
            if ($data.name -contains "container") {
                $data.where( { $_.name -eq 'container' }).group |
                ForEach-Object { Get-ADBranch -SearchBase $_.distinguishedname -IncludeDeletedObjects:$IncludeDeletedObjects }
            }
            #display builtin
            if ($data.name -contains "builtinDomain") {
                $data.where( { $_.name -eq 'BuiltInDomain' }).group |
                ForEach-Object { Get-ADBranch -SearchBase $_.distinguishedname -IncludeDeletedObjects:$IncludeDeletedObjects }
            }
        }
        Catch {
            Write-Warning "Failed to enumerate $SearchBase. $($_.exception.message)"
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end
}

Update-TypeData -TypeName ADBranchMember -MemberType AliasProperty -MemberName DN -Value DistinguishedName -Force

