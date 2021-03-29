
# An earlier version was first described at https://jdhitsolutions.com/blog/powershell/8087/an-active-directory-change-report-from-powershell/

#Reporting on deleted items requires the Active Directory Recycle Bin feature
Function New-ADChangeReport {
    [cmdletbinding()]
    [outputtype("System.IO.FileInfo")]
    Param(
        [Parameter(Position = 0, HelpMessage = "Enter a last modified datetime for AD objects. The default is the last 4 hours.")]
        [ValidateNotNullOrEmpty()]
        [datetime]$Since = ((Get-Date).AddHours(-4)),
        [Parameter(HelpMessage = "What is the report title?")]
        [string]$ReportTitle = "Active Directory Change Report",
        [Parameter(HelpMessage = "Specify the path to an image file to use as a logo in the report.")]
        [ValidateScript( { Test-Path $_ })]
        [string]$Logo,
        [Parameter(HelpMessage = "Specify the path to the CSS file. If you don't specify one, the default module file will be used.")]
        [ValidateScript( { Test-Path $_ })]
        [string]$CSSUri = "$PSScriptRoot\..\reports\changereport.css",
        [Parameter(HelpMessage = "Embed the CSS file into the HTML document head. You can only embed from a file, not a URL.")]
        [switch]$EmbedCSS,
        [Parameter(HelpMessage = "Add a second grouping based on the object's container or OU.")]
        [switch]$ByContainer,
        [Parameter(HelpMessage = "Specify the path for the output file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = ".\ADChangeReport.html",
        [Parameter(HelpMessage = "Specifies the Active Directory Domain Services domain controller to query. The default is your Logon server.")]
        [ValidateNotNullOrEmpty()]
        [string]$Server = $env:LOGONSERVER.Substring(2),
        [Parameter(HelpMessage = "Specify an alternate credential for authentication.")]
        [pscredential]$Credential,
        [ValidateSet("Negotiate", "Basic")]
        [string]$AuthType
    )

    Begin {

        Write-Verbose "[$(Get-Date)] Starting $($myinvocation.MyCommand)"
        #some report metadata
        $reportVersion = (Get-Module ADReportingTools).Version.toString()
        $thisScript = $($myinvocation.MyCommand)

        Write-Verbose "[$(Get-Date)] Detected these bound parameters"
        $PSBoundParameters | Out-String | Write-Verbose

        #set some default parameter values
        $params = "Credential", "AuthType","Server"

        ForEach ($param in $params) {
            if ($PSBoundParameters.ContainsKey($param)) {
                Write-Verbose "[$(Get-Date)] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
                $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
            }
        }

          #who is running the report?
          if ($Credential) {
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

        #What Domain controller was queried?
        $dc = (Resolve-DnsName -Name $server -Type A | Select-Object -first 1).Name.ToUpper()
        #text to display in the report
        $content = @"
<br/>Active Directory changes since $since as reported from domain controller $($Server.toUpper()). Replication-only changes may be included in this report.
You will need to view event logs for more detail about these changes, including who made the change.
"@

        #a footer for the report. This could be styled with CSS
        $post = @"
<table class='footer'>
<tr align = "right"><td>Report run: <i>$(Get-Date)</i></td></tr>
<tr align = "right"><td>Report version: <i>$ReportVersion</i></td></tr>
<tr align = "right"><td>Source: <i>$thisScript</i></td></tr>
<tr align = "right"><td>Author: <i>$($Who.toUpper())</i></td></tr>
<tr align = "right"><td>Computername: <i>$($where.toUpper())</i></td></tr>
<tr align = "right"><td>DomainController: <i>$dc</i></td></tr>
</table>
"@

        #my default head
        $head = @"
<Title>$ReportTitle</Title>
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

$htmlParams = @{
    Head        = $head
    Precontent  = $content
    Body        = ""
    PostContent = $post
}

        If ($EmbedCSS) {
            if (Test-Path -Path $CSSUri) {
                Write-Verbose "[$(Get-Date)] Embedding CSS content from $CSSUri"
                $cssContent = Get-Content -Path $CSSUri | Where-Object { $_ -notmatch "^@" }
                $head += @"
<style>
$cssContent
</style>
"@
            }
            else {
                Write-Error "Failed to find a CSS file at $CSSUri. You can only embed from a file."
                #bail out
                Write-Verbose "[$(Get-Date)] Ending $($myinvocation.mycommand)"
                return
            }
        }
        else {
            Write-Verbose "[$(Get-Date)] Adding CSSPath $CSSUri"
            $htmlParams.Add("CSSUri", $CSSUri)
        }

        #create a list object to hold all of the HTML fragments
        Write-Verbose "[$(Get-Date)] Initializing fragment list"
        $fragments = [System.Collections.Generic.list[string]]::New()

        if ($Logo) {
            #need to use full path
            $imagefile = Convert-Path -Path $logo
            Write-Verbose "[$(Get-Date)] Using logo file $imagefile"
            #encode the graphic file to embed into the HTML
            $ImageBits = [Convert]::ToBase64String((Get-Content $imagefile -Encoding Byte))
            $ImageHTML = "<img alt='logo' class='center' src=data:image/png;base64,$($ImageBits)/>"
            $top = @"
<table class='header'>
<tr>
<td>$imageHTML</td>
<td><H1>$ReportTitle</H1></td>
</tr>
</table>
"@
        $fragments.Add($top)
    }
    else {
        $fragments.Add("<H1>$ReportTitle</H1>")
    }

    $fragments.Add("<a href='javascript:toggleAll();' title='Click to toggle all sections'>+|-</a>")

    Write-Verbose "[$(Get-Date)] Getting current Active Directory domain"
    $domain = Get-ADDomain
    $fragments.Add("<H2>$($domain.dnsroot)</H2>")

} #begin
Process {
    Write-Verbose "[$(Get-Date)] Querying $($domain.dnsroot)"
    $filter = { (objectclass -eq 'user' -or objectclass -eq 'group' -or objectclass -eq 'organizationalunit' ) -AND (WhenChanged -gt $since ) }

    Write-Verbose "[$(Get-Date)] Filtering for changed objects since $since"
    $items = Get-ADObject -Filter $filter -IncludeDeletedObjects -Properties WhenCreated, WhenChanged, IsDeleted -OutVariable all | Group-Object -Property objectclass

    Write-Verbose "[$(Get-Date)] Found $($all.count) total items"

    if ($items.count -gt 0) {
        foreach ($item in $items) {
            $category = "{0}{1}" -f $item.name[0].ToString().toUpper(), $item.name.Substring(1)
            Write-Verbose "[$(Get-Date)] Processing $category [$($item.count)]"

            if ($ByContainer) {
                Write-Verbose "[$(Get-Date)] Organizing by container"
                $subgroup = $item.group | Group-Object -Property { $_.distinguishedname.split(',', 2)[1] } | Sort-Object -Property Name
                $fraghtml = [System.Collections.Generic.list[string]]::new()
                foreach ($subitem in $subgroup) {
                    Write-Verbose "[$(Get-Date)] $($subItem.name)"
                    $fragGroup = _convertObjects $subitem.group
                    $divid = $subitem.name -replace "=|,", ""
                    $fraghtml.Add($(_inserttoggle -Text "$($subItem.name) [$($subitem.count)]" -div $divid -Heading "H4" -Data $fragGroup -NoConvert))
                } #foreach subitem
            } #if by container
            else {
                Write-Verbose "[$(Get-Date)] Organizing by distinguishedname"
                $fragHtml = _convertObjects $item.group
            }
            $code = _insertToggle -Text "$category [$($item.count)]" -div $category -Heading "H3" -Data $fragHtml -NoConvert
            $fragments.Add($code)
        } #foreach item

        Write-Verbose "[$(Get-Date)] Creating report $ReportTitle version $reportversion saved to $path"

        $htmlParams.Body = $fragments | Out-String

        ConvertTo-Html @htmlParams | Out-File -FilePath $Path
        Get-Item -Path $Path
    }
    else {
        Write-Warning "No modified objects found in the $($domain.dnsroot) domain since $since."
    }
} #process
End {
    Write-Verbose "[$(Get-Date)] Ending $($myinvocation.MyCommand)"
}
} #close function