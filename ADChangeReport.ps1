#requires -version 5.1
#requires -module ActiveDirectory,DNSClient

# https://jdhitsolutions.com/blog/powershell/8087/an-active-directory-change-report-from-powershell/

#Reporting on deleted items requires the Active Directory Recycle Bin feature
[cmdletbinding()]
Param(
    [Parameter(Position = 0,HelpMessage = "Enter a last modified datetime for AD objects. The default is the last 4 hours.")]
    [ValidateNotNullOrEmpty()]
    [datetime]$Since = ((Get-Date).AddHours(-4)),
    [Parameter(HelpMessage = "What is the report title?")]
    [string]$ReportTitle = "Active Directory Change Report",
    [Parameter(HelpMessage = "Specify the path to an image file to use as a logo in the report.")]
    [ValidateScript({Test-Path $_})]
    [string]$Logo,
    [Parameter(HelpMessage = "Add a second grouping based on the object's container or OU.")]
    [switch]$ByContainer,
    [Parameter(HelpMessage = "Specify the path for the output file.")]
    [ValidateNotNullOrEmpty()]
    [string]$Path = ".\ADChangeReport.html",
    [Parameter(HelpMessage = "Specifies the Active Directory Domain Services domain controller to query. The default is your Logon server.")]
    [string]$Server = $env:LOGONSERVER.SubString(2),
    [Parameter(HelpMessage = "Specify an alternate credential for authentication.")]
    [pscredential]$Credential,
    [ValidateSet("Negotiate","Basic")]
    [string]$AuthType
)

#region helper functions

#a private helper function to convert the objects to html fragments
Function _convertObjects {
    Param([object[]]$Objects)
    #convert each table to an XML fragment so I can insert a class attribute
    [xml]$frag = $objects | Sort-Object -property WhenChanged |
    Select-Object -Property DistinguishedName,Name,WhenCreated,WhenChanged,IsDeleted |
    ConvertTo-Html -Fragment

    for ($i = 1; $i -lt $frag.table.tr.count;$i++) {
        if (($frag.table.tr[$i].td[2] -as [datetime]) -ge $since) {
            #highlight new objects in green
            $class = $frag.CreateAttribute("class")
            $class.value="new"
            [void]$frag.table.tr[$i].Attributes.append($class)
        } #if new

        #insert the alert attribute if the object has been deleted.
        if ($frag.table.tr[$i].td[-1] -eq 'True') {
            #highlight deleted objects in red
            $class = $frag.CreateAttribute("class")
            $class.value="alert"
            [void]$frag.table.tr[$i].Attributes.append($class)
        } #if deleted
    } #for

    #write the innerXML (ie HTML code) as the function output
    $frag.InnerXml
}

# private helper function to insert javascript code into my html
function _insertToggle {
    [cmdletbinding()]
    #The text to display, the name of the div, the data to collapse, and the heading style
    #the div Id needs to be simple text
    Param([string]$Text, [string]$div, [object[]]$Data, [string]$Heading = "H2", [switch]$NoConvert)

    $out = [System.Collections.Generic.list[string]]::New()
    if (-Not $div) {
        $div = $Text.Replace(" ", "_")
    }
    $out.add("<a href='javascript:toggleDiv(""$div"");' title='click to collapse or expand this section'><$Heading>$Text</$Heading></a><div id=""$div"">")
    if ($NoConvert) {
        $out.Add($Data)
    }
    else {
        $out.Add($($Data | ConvertTo-Html -Fragment))
    }
    $out.Add("</div>")
    $out
}

#endregion

#some report metadata
$reportVersion = "2.3.3"
$thisScript = Convert-Path $myinvocation.InvocationName

Write-Verbose "[$(Get-Date)] Starting $($myinvocation.MyCommand)"
Write-Verbose "[$(Get-Date)] Detected these bound parameters"
$PSBoundParameters | Out-String | Write-Verbose

#set some default parameter values
$params = "Credential","AuthType"

ForEach ($param in $params) {
    if ($PSBoundParameters.ContainsKey($param)) {
        Write-Verbose "[$(Get-Date)] Adding 'Get-AD*:$param' to script PSDefaultParameterValues"
        $script:PSDefaultParameterValues["Get-AD*:$param"] = $PSBoundParameters.Item($param)
    }
}

Write-Verbose "[$(Get-Date)] Getting current Active Directory domain"
$domain = Get-ADDomain

#create a list object to hold all of the HTML fragments
Write-Verbose "[$(Get-Date)] Initializing fragment list"
$fragments = [System.Collections.Generic.list[string]]::New()

if ($Logo) {
    #need to use full path
    $imagefile = Convert-Path -path $logo
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

$fragments.Add("<H2>$($domain.dnsroot)</H2>")
$fragments.Add("<a href='javascript:toggleAll();' title='Click to toggle all sections'>+/-</a>")

Write-Verbose "[$(Get-Date)] Querying $($domain.dnsroot)"
$filter = {(objectclass -eq 'user' -or objectclass -eq 'group' -or objectclass -eq 'organizationalunit' ) -AND (WhenChanged -gt $since )}

Write-Verbose "[$(Get-Date)] Filtering for changed objects since $since"
$items = Get-ADObject -filter $filter -IncludeDeletedObjects -Properties WhenCreated,WhenChanged,IsDeleted -OutVariable all | Group-Object -property objectclass

Write-Verbose "[$(Get-Date)] Found $($all.count) total items"

if ($items.count -gt 0) {
    foreach ($item in $items) {
        $category = "{0}{1}" -f $item.name[0].ToString().toUpper(),$item.name.Substring(1)
        Write-Verbose "[$(Get-Date)] Processing $category [$($item.count)]"

        if ($ByContainer) {
            Write-Verbose "[$(Get-Date)] Organizing by container"
            $subgroup = $item.group | Group-Object -Property { $_.distinguishedname.split(',', 2)[1] } | Sort-Object -Property Name
            $fraghtml = [System.Collections.Generic.list[string]]::new()
            foreach ($subitem in $subgroup) {
                Write-Verbose "[$(Get-Date)] $($subItem.name)"
                $fragGroup = _convertObjects $subitem.group
                $divid = $subitem.name -replace "=|,",""
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

#my embedded CSS
    $head = @"
<Title>$ReportTitle</Title>
<style>
h2 {
    width:95%;
    background-color:#7BA7C7;
    font-family:Tahoma;
    color: #fffc35;
    font-size:16pt;
}
h4 {
    width:95%;
    background-color:#b5f144;
}
body {
    background-color:#FFFFFF;
    font-family:Tahoma;
    font-size:12pt;
}
td, th {
    border:1px solid black;
    border-collapse:collapse;
}
th {
    color:white;
    background-color:black;
}
table, tr, td, th {
    padding-left: 10px;
    margin: 0px
}
tr:nth-child(odd) {background-color: lightgray}
table {
    width:95%;
    margin-left:5px;
    margin-bottom:20px;
}
.alert { color:red; }
.new { color:green; }
table.footer tr,
table.footer td {
    background-color: white;
    border-collapse: collapse;
    border: none;
}
table.footer {
    width: 25%;
    padding-left: 10px;
    margin-left: 70%;
    font-size: 10pt;
    cellpadding: 0;
}
td.size {
    text-align: right;
    padding-right: 25px;
}
.center {
  display: block;
  margin-left: auto;
  margin-right: auto;
  width: 50%;
}
table.header tr,
table.header td {
    background-color:white;
    border-collapse: collapse;
    border: none;
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
    $where = (Resolve-DnsName -Name $env:COMPUTERNAME -Type A -ErrorAction Stop -verbose:$False).Name | Select-Object -last 1
}
Catch {
    $where = $env:COMPUTERNAME
}
#a footer for the report. This could be styled with CSS
    $post = @"
<table class='footer'>
    <tr align = "right"><td>Report run: <i>$(Get-Date)</i></td></tr>
    <tr align = "right"><td>Report version: <i>$ReportVersion</i></td></tr>
    <tr align = "right"><td>Source: <i>$thisScript</i></td></tr>
    <tr align = "right"><td>Author: <i>$($Who.toUpper())</i></td></tr>
    <tr align = "right"><td>Computername: <i>$($where.toUpper())</i></td></tr>
</table>
"@

    #text to display in the report
    $content = @"
Active Directory changes since $since as reported from domain controller $($Server.toUpper()). Replication-only changes may be included in this report.
You will need to view event logs for more detail about these changes, including who made the change.
"@
    $htmlParams = @{
        Head = $head
        precontent = $content
        Body =($fragments | Out-String)
        PostContent = $post
    }
    Write-Verbose "[$(Get-Date)] Creating report $ReportTitle version $reportversion saved to $path"
    ConvertTo-HTML @htmlParams | Out-File -FilePath $Path
    Get-Item -Path $Path
}
else {
    Write-Warning "No modified objects found in the $($domain.dnsroot) domain since $since."
}

Write-Verbose "[$(Get-Date)] Ending $($myinvocation.MyCommand)"