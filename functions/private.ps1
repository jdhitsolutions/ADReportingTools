#private helper functions

# private helper function to insert javascript code into my html
function _insertToggle {
    [cmdletbinding()]
    #The text to display, the name of the div, the data to collapse, and the heading style
    #the div Id needs to be alphanumeric text
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

Function _getPopData {
    [cmdletbinding()]
    param([string]$Identity)

    Try {
        $class = (Get-ADObject -Identity $identity -ErrorAction stop).objectclass
    }
    Catch {
        #don't do anything
    }
    if ($class -eq 'user') {
        $props = 'SamAccountName','Displayname', 'Title', 'Department', 'PasswordLastSet', 'LastLogonDate','Enabled', 'WhenCreated', 'WhenChanged'
        Get-ADUser -Identity $identity -Property $props | Select-Object -Property $props
    }
    elseif ($class -eq 'computer') {
        $props = 'DnsHostName', 'OperatingSystem','IPv4Address','Location', 'Enabled', 'WhenCreated', 'WhenChanged'
        Get-ADComputer -Identity $identity -Property $props | Select-Object -Property $props
    }

}