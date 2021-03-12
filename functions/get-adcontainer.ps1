Function Get-ADBranch {
    [cmdletbinding()]
    [OutputType("ADBranchMember")]
    Param (
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the distinguished name of the top level container or organizational unit.")]
        [string]$SearchBase,
        [Parameter(HelpMessage = "Only show objects of the matching classes")]
        [ValidateSet("User", "Computer", "Group")]
        [string[]]$ObjectClass,
        [switch]$IncludeDeletedObjects,
        [Parameter(HelpMessage = "Exclude containers like USERS. This will only have no effect unless your search base is the domain root.")]
        [switch]$ExcludeContainers,
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

        #define a hashtable of parameters for recursive calls to this command
        $recurse = @{}

        $params = "SearchBase", "ObjectClass", "ExcludeContainers", "IncludeDeletedObjects"
        foreach ($param in $params) {
            if ($PSBoundParameters.ContainsKey($param)) {
                $recurse.Add($param, $PSBoundParameters.Item($param))
            }
        }

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

        #begin defining the search filter
        [string]$filter = "objectclass -eq 'organizationalunit'"
        if ($ExcludeContainers) {
            Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Excluding containers"
        }
        else {
            $filter += " -or objectclass -eq 'container' -or objectclass -eq 'builtindomain'"
        }

        if ($ObjectClass) {
            foreach ($item in $ObjectClass) {
                $filter += " -or objectclass -eq '$item'"
            }
        }
        else {
            $filter += " -or objectclass -eq 'computer' -or objectclass -eq 'user' -or objectclass -eq 'group'"
        }
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Using filter $filter"
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Enumerating $searchBase"
    } #begin

    Process {
        $getParams = @{
            filter                = $filter
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
                ForEach-Object {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Recursive calling Get-ADBranch"
                    $recurse.searchBase = $_.DistinguishedName
                    Get-ADBranch @recurse

                }
            }

            #display containers
            if ($data.name -contains "container") {
                $data.where( { $_.name -eq 'container' }).group |
                ForEach-Object {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Recursive calling Get-ADBranch"
                    $recurse.searchBase = $_.DistinguishedName
                    Get-ADBranch @recurse
                }
            }
            #display builtin
            if ($data.name -contains "builtinDomain") {
                $data.where( { $_.name -eq 'BuiltInDomain' }).group |
                ForEach-Object {
                    Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Recursive calling Get-ADBranch"
                    $recurse.searchBase = $_.DistinguishedName
                    Get-ADBranch @recurse
                }
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

