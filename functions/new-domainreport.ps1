

#todo show disabled accounts in orange or red

Function New-ADDomainReport {
    [cmdletbinding()]
    [outputtype("System.IO.File")]
    Param (
        [Parameter(Position = 0, HelpMessage = "Specify the domain name. The default is the user domain.")]
        [ValidateNotNullOrEmpty()]
        [alias("domain")]
        [string]$Name = $env:USERDOMAIN,
        [Parameter(Mandatory, HelpMessage = "Specify the output HTML file.")]
        [ValidateScript({
            #validate the parent folder
            Test-Path (Split-Path $_)
        })]
        [string]$FilePath,
        [Parameter(HelpMessage = "Enter the name of the report to be displayed in the web browser")]
        [ValidateNotNullOrEmpty()]
        [string]$ReportTitle = "Domain Report",
        [Parameter(HelpMessage = "Specify the path the CSS file. If you don't specify one, the default module file will be used.")]
        [ValidateScript( { Test-Path $_ })]
        [string]$CSSPath = "$PSScriptRoot\..\formats\domainreport.css",
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

    #region setup
    $progParams = @{
        Activity = $myinvocation.MyCommand
        Status = "Preparing"
        CurrentOperation ="Initializing variables"
    }

    Write-Progress @progParams

    #set some default parameter values
    $params = "Credential", "Server"
    ForEach ($param in $params) {
        if ($PSBoundParameters.ContainsKey($param)) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
            $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
        }
    } #foreach

    #some report metadata
    $cmd = Get-Command $myinvocation.InvocationName
    $thisScript ="{0}\{1}" -f $cmd.source,$cmd.name
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
    background-color: rgba(210, 212, 198, 0.897);
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
        if (Test-Path -Path $CSSPath) {
            Write-Verbose "[$((Get-Date).TimeofDay)] Embedding CSS content from $CSSPath"
            $cssContent = Get-Content -Path $CssPath | Where-Object { $_ -notmatch "^@" }
            $head += @"
<style>
$cssContent
</style>
"@
            #update the hashtable
            $cHtml.Head = $head
        }
        else {
            Write-Error "Failed to find a CSS file  at $CSSPath. You can only embed from a file."
            #bail out
            Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
            return
        }
    } #if embedCSS
    else {
        $cHtml.add("CSSUri", $cssPath)
    }

    #endregion

    #region get data
    Write-Verbose "[$((Get-Date).TimeofDay)] Getting base information for $Name"

    $progParams.status = "Getting domain information"
    $progParams.CurrentOperation =" Get-ADDomain -Identity $Name"
    Write-Progress @progParams
    Try {
        $root = Get-ADDomain -Identity $Name -erroraction stop
    }
    Catch {
        Write-Warning "Failed to get domain information for $Name. $($_.Exception.message)"
        Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
        #bail out
        return
    }

    $progParams.CurrentOperation = "Get-ADBranch -searchbase $root.DistinguishedName"
    Write-Progress @progParams
    Write-Verbose "[$((Get-Date).TimeofDay)] Getting ADBranch data for $($root.distinguishedname)"
    $dom = Get-ADBranch -searchbase $root.DistinguishedName

    $fragments = [System.Collections.Generic.List[string]]::New()
    $fragments.Add("<H1>$($root.dnsroot)</H1>")
    $fragments.Add("<a href='javascript:toggleAll();' title='Click to toggle all sections'>+/-</a>")
    $grouped = $dom | Sort-Object -Property Parent | Group-Object -Property Parent

    $progParams.Status = "Processing domain branches"

    foreach ($branch in $grouped) {
        $heading = $branch.name
        $progParams.CurrentOperation = $heading
        Write-Progress @progParams
        $div = $branch.name -replace "\W", ""
        $classGroup = $branch.group | Sort-Object -Property Class, Name | Group-Object -Property Class
        $fragGroup = foreach ($item in $classGroup) {
            if ($item.name -eq 'group') {
                $childDiv = (New-Guid).guid -replace "-", "X"
                $child = foreach ($groupItem in $item.group) {
                    if ($groupItem.name -notmatch "Domain Users|Domain Computers") {
                        $groupchildDiv = (New-Guid).guid -replace "-", "X"
                        $groupText = $groupitem.Name

                        [xml]$html = Get-ADGroup -Identity $groupitem.distinguishedname -Properties members, WhenChanged -OutVariable g |
                        Select-Object -Property DistinguishedName, GroupScope, GroupCategory, @{Name = "MemberCount"; Expression = { $_.members.count } }, WhenChanged |
                        ConvertTo-Html -Fragment
                        #insert class to set first column width
                        $th = $html.CreateAttribute("class")
                        $th.Value = "dn"
                        [void]($html.table.tr[0].childnodes[0].attributes.append($th))

                        $groupData = $html.innerxml
                        if ($g.members) {
                            $groupData += "<H5>Members</H5>"
                            $grpUserData = Get-ADGroupUser $groupitem.distinguishedname |
                            Select-Object -Property distinguishedname, name, description,Enabled
                            if (-Not $grpuserdata) {
                                #must be a special group
                                $grpUserData = Get-ADGroupMember -Identity $groupItem.DistinguishedName  |
                                Sort-Object DistinguishedName |
                                Select-Object DistinguishedName, Name, SamAccountName, SID, ObjectClass
                            }
                            [xml]$html = $grpUserData | ConvertTo-Html -Fragment
                            #insert class to set first column width
                            if ($html.table) {
                                $th = $html.CreateAttribute("class")
                                $th.Value = "dn"
                                [void]($html.table.tr[0].childnodes[0].attributes.append($th))
                            }
                            for ($i = 1; $i -le $html.table.tr.count - 1; $i++) {
                                $dn = $html.table.tr[$i].ChildNodes[0]."#text"
                                $pop = $html.CreateAttribute("tip")
                                $pop.value = (_getPopData -Identity $dn | Format-List | Out-String).Trim()
                                [void]($html.table.tr[$i].ChildNodes[0].Attributes.append($pop))
                            }
                            $groupData += $html.InnerXml
                        } #if g.members
                        _insertToggle -Text $groupText -div $groupchildDiv -Heading "H4" -data $groupData -NoConvert
                    }
                } #foreach groupitem
            } #if group
            else {
                [xml]$html = $item.group | Select-Object -Property DistinguishedName, Name, Description,Enabled | ConvertTo-Html -Fragment
                #insert class to set first column width
                $th = $html.CreateAttribute("class")
                $th.Value = "dn"
                [void]($html.table.tr[0].childnodes[0].attributes.append($th))
                for ($i = 1; $i -le $html.table.tr.count - 1; $i++) {
                    $dn = $html.table.tr[$i].ChildNodes[0]."#text"

                    $pop = $html.CreateAttribute("tip")
                    $pop.value = (_getPopData -Identity $dn | Format-List | Out-String).Trim()
                    [void]($html.table.tr[$i].ChildNodes[0].Attributes.append($pop))
                }
                $child = $html.InnerXml
            }
            _insertToggle -Text "$($item.name)s [$($item.count)]" -div $childDiv -Heading "H3" -data $child -NoConvert

        } #foreach item in classgroup
        $fragments.Add($(_inserttoggle -Text $heading -div $div -Heading "H2" -Data $fragGroup -NoConvert))
    } #foreach branch

    #endregion

    #region create report
    $cHtml.Body = $Fragments

    #convert filepath to a valid filesystem name
    $parent =  (Split-Path -Path $filePath)
    $file = Join-Path -path $parent -ChildPath (Split-Path -Path $filePath -leaf)

    Write-Verbose "[$((Get-Date).TimeofDay)] Saving file to $file"
    ConvertTo-Html @cHtml  | Out-File -FilePath $file

    #endregion

    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"

} #New-ADDomainReport