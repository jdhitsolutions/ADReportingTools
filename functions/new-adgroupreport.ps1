Function New-ADGroupReport {
    [cmdletbinding()]
    [outputtype("System.IO.File")]
    Param (
        [parameter(Position = 0, HelpMessage = "Enter an AD Group name. Wildcards are allowed.")]
        [validatenotnullorEmpty()]
        [string]$Name = "*",
        [Parameter(HelpMessage = "Enter the distinguished name of the top-level container or organizational unit.")]
        [ValidateScript( {
                $testDN = $_
                Try {
                    [void](Get-ADObject -Identity $_ -ErrorAction Stop)
                    $True
                }
                Catch {
                    Write-Warning "Failed to verify $TestDN as a valid searchbase."
                    Throw $_.Exception.message
                    $False
                }
            })]
        [string]$SearchBase,
        [Parameter(HelpMessage = "Filter on the group category")]
        [ValidateSet("All", "Distribution", "Security")]
        [string]$Category = "All",
        [Parameter(HelpMessage = "Filter on group scope")]
        [ValidateSet("Any", "DomainLocal", "Global", "Universal")]
        [string]$Scope = "Any",
        [Parameter(HelpMessage = "Exclude BuiltIn and Users")]
        [switch]$ExcludeBuiltIn,
        [Parameter(Mandatory, HelpMessage = "Specify the output HTML file.")]
        [ValidateScript( {
                #validate the parent folder
                Test-Path (Split-Path $_)
            })]
        [string]$FilePath,
        [Parameter(HelpMessage = "Enter the name of the report to be displayed in the web browser")]
        [ValidateNotNullOrEmpty()]
        [string]$ReportTitle = "AD Group Report",
        [Parameter(HelpMessage = "Specify the path the CSS file. If you don't specify one, the default module file will be used.")]
        [ValidateScript( { Test-Path $_ })]
        [string]$CSSUri = "$PSScriptRoot\..\reports\groupreport.css",
        [Parameter(HelpMessage = "Embed the CSS file into the HTML document head. You can only embed from a file, not a URL.")]
        [switch]$EmbedCSS,
        [Parameter(HelpMessage = "Specify a domain controller to query.")]
        [alias("dc", "domaincontroller")]
        [string]$Server,
        [Parameter(HelpMessage = "Specify an alternate credential.")]
        [alias("RunAs")]
        [PSCredential]$Credential
    )

    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"

    #set some default parameter values
    $params = "Credential", "Server"
    ForEach ($param in $params) {
        if ($PSBoundParameters.ContainsKey($param)) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
            $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
        }
    } #foreach

    #region report metadata
    $cmd = Get-Command $myinvocation.InvocationName
    $thisScript = "{0}\{1}" -f $cmd.source, $cmd.name
    $reportVersion = ( $cmd).version.tostring()
    #who is running the report?
    if ($Credential.Username) {
        $who = $Credential.UserName
    }
    else {
        $who = "$($env:USERDOMAIN)\$($env:USERNAME)"
    }

    #where are they running the report from?
    Try {
        #disable verbose output from Resolve-DNSName
        $where = (Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction Stop -Verbose:$False).Name | Select-Object -Last 1
    }
    Catch {
        $where = $env:COMPUTERNAME
    }

    $post = @"
<table class='footer'>
    <tr align = "right"><td>Report run: <i>$(Get-Date)</i></td></tr>
    <tr align = "right"><td>Author: <i>$($Who.toUpper())</i></td></tr>
    <tr align = "right"><td>Source: <i>$thisScript</i></td></tr>
    <tr align = "right"><td>Version: <i>$ReportVersion</i></td></tr>
    <tr align = "right"><td>Computername: <i>$($where.toUpper())</i></td></tr>
</table>
"@

    #endregion

    #region HTML setup
    $head = @"
<title>$ReportTitle</Title>
<style>
td[tip]:hover {
    color: #2112f1cc;
    position: relative;
}
td[tip]:hover:after {
    content: attr(tip);
    left: 0;
    top: 100%;
    margin-left: 80px;
    margin-top: 10px;
    width: 400px;
    padding: 3px 8px;
    position: absolute;
    color: #111111;
    font-family: 'Courier New', Courier, monospace;
    font-size: 10pt;
    background-color: #dcdc0d;
    white-space: pre-wrap;
}
th.dn {
    width:40%;
}
</style>
<script type='text/javascript' src='https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js'>
</script>
<script type='text/javascript'>
function toggleDiv(divId) {
`$("#"+divId).toggle();
}
function toggleAll() {
var divs = document.getElementsByTagName('div');
for (var i = 0; i < divs.length; i++) {
var div = divs[i];
`$("#"+div.id).toggle();
}
}
</script>
"@

    #parameters to splat to ConvertTo-Html
    $cHtml = @{
        Head        = $head
        Body        = ""
        PostContent = $post
    }

    If ($EmbedCSS) {
        if (Test-Path -Path $CSSUri) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Embedding CSS content from $CSSUri"
            $cssContent = Get-Content -Path $CSSUri | Where-Object { $_ -notmatch "^@" }
            $head += @"
<style>
$cssContent
</style>
"@
            #update the hashtable
            $cHtml.Head = $head
        }
        else {
            Write-Error "Failed to find a CSS file  at $CSSUri. You can only embed from a file."
            #bail out
            Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
            return
        }
    } #if embedCSS
    else {
        $cHtml.add("CSSUri", $CSSUri)
    }

    #endregion

    #region get group data
    $splat = @{
        ErrorAction    = "Stop"
        Name           = $Name
        Scope          = $Scope
        Category       = $Category
        ExcludeBuiltIn = $ExcludeBuiltIn
    }

    if ($SearchBase) {
        $splat.Add("SearchBase", $SearchBase)
    }
    Try {
        $data = Get-ADGroupReport @splat | Sort-Object -Property Branch, Name
    }
    Catch {
        Throw $_
    }

    #endregion

    #region format data
    if ($data) {
        Write-Verbose "[$((Get-Date).TimeofDay)] Processing $($data.name.count) groups."
        #get domain root
        Try {
            Write-Verbose "[$((Get-Date).TimeofDay)] Getting domain root."
            $root = Get-ADDomain -ErrorAction stop
        }
        Catch {
            Write-Warning "Failed to get domain information. $($_.Exception.message)"
            Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
            #bail out
            return
        }

        Write-Verbose "[$((Get-Date).TimeofDay)] Creating HTML"
        $Fragments = [System.Collections.Generic.List[string]]::new()
        $fragments.Add("<H1>$($root.dnsroot)</H1>")
        $fragments.Add("<H1>Group Membership Report</H1>")

        #show report parameters
        $splat.Remove("ErrorAction")
        if ($PSBoundParameters.ContainsKey("Server")) {
            $splat.Add("Server",$server)
        }

        $fragments.Add("<a href='javascript:toggleAll();' title='Click to toggle all group sections'>+/-</a>")
        $Fragments.Add("<br><H3>Report Parameters</H3>")
        $fragments.Add( $([pscustomobject]$splat | ConvertTo-Html -as List -Fragment ))

        ForEach ($group in $data) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Processing group $($group.distinguishedname)"
            $fragGroup = [System.Collections.Generic.List[string]]::new()
            $div = $group.DistinguishedName -replace "\W", ""
            $heading = $group.DistinguishedName
            [xml]$html = $group | Select-Object -Property Name, Category, Scope, Description, Created, Modified |
            ConvertTo-Html -As table -Fragment

            for ($i = 1; $i -le $html.table.tr.count - 1; $i++) {
                $pop1 = $html.CreateAttribute("tip")
                $pop1.Value = "Managed by: $($group.ManagedBy)"
                [void]($html.table.tr[$i].ChildNodes[0].Attributes.append($pop1))
                $pop2 = $html.CreateAttribute("tip")
                $pop2.Value = "Age: $($group.age)"
                [void]($html.table.tr[$i].ChildNodes[5].Attributes.append($pop2))
            }

            #add members
            $fragGroup.Add($html.InnerXml)

            if ($group.members.count -gt 0) {
                $fragGroup.Add("<H3>Members</H3>")

                [xml]$html = $group.members |
                Select-Object -Property DistinguishedName, Name, Description, Enabled |
                ConvertTo-Html -Fragment -As Table

                #insert class to set first column width
                $th = $html.CreateAttribute("class")
                $th.Value = "dn"
                [void]($html.table.tr[0].childnodes[0].attributes.append($th))

                #process member HTML daa
                for ($i = 1; $i -le $html.table.tr.count - 1; $i++) {
                    $dn = $html.table.tr[$i].ChildNodes[0]."#text"

                    $pop = $html.CreateAttribute("tip")
                    $pop.value = (_getPopData -Identity $dn | Format-List | Out-String).Trim()
                    [void]($html.table.tr[$i].ChildNodes[0].Attributes.append($pop))

                    if ($html.table.tr[$i].ChildNodes[3].'#text' -eq 'False') {
                        #flag the account as disabled
                        Write-Verbose "[$((Get-Date).TimeofDay)] Flagging $dn as disabled"
                        $class = $html.CreateAttribute("class")
                        $class.value = "alert"
                       [void]$html.table.tr[$i].Attributes.Append($class)
                    }
                }
                $fragGroup.Add($html.InnerXml)
            }
            else {
                $fragGroup.Add("<H3 class='alert'>No Members</H3>")
            }
            $H = _inserttoggle -Text $heading -div $div -Heading "H2" -Data $fragGroup -NoConvert
            $Fragments.add($H)
        }
    }
    else {
        Write-Warning "No group data found to build a report with."
    }
    #endregion

    #region create report
    if ($Fragments.count -gt 0) {
        $cHtml.Body = $Fragments

        #convert filepath to a valid filesystem name
        $parent = (Split-Path -Path $filePath)
        $file = Join-Path -Path $parent -ChildPath (Split-Path -Path $filePath -Leaf)

        Write-Verbose "[$((Get-Date).TimeofDay)] Saving file to $file"
        ConvertTo-Html @cHtml | Out-File -FilePath $file
    }

    #endregion

    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"

} #close function