
Function Show-DomainTree {
  [cmdletbinding()]
  [OutputType("String")]
  [alias("dt")]
  Param(
    [Parameter(Position = 0, HelpMessage = "Specify the domain name. The default is the user domain.")]
    [ValidateNotNullOrEmpty()]
    [string]$Name = $env:USERDOMAIN,
    [Parameter(HelpMessage = "Specify a domain controller to query.")]
    [alias("dc", "domaincontroller")]
    [string]$Server,
    [Parameter(HelpMessage = "Specify an alternate credential.")]
    [alias("RunAs")]
    [PSCredential]$Credential,
    [Parameter(HelpMessage = "Display the domain tree using distinguished names.")]
    [alias("dn")]
    [switch]$UseDN,
    [Parameter(HelpMessage = "Include containers and non-OU elements. Items with a GUID in the name will be omitted.")]
    [alias("cn")]
    [switch]$Containers
  )

  Write-Verbose "Starting $($myinvocation.MyCommand)"

  Function Get-OUTree {
    [cmdletbinding()]
    Param(
      [string]$Path = (Get-ADDomain).DistinguishedName,
      [string]$Server,
      [Parameter(HelpMessage = "Specify an alternate credential")]
      [PSCredential]$Credential,
      [Parameter(HelpMessage = "Display the distinguishedname")]
      [switch]$UseDN,
      [Parameter(HelpMessage = "Include containers")]
      [alias("cn")]
      [switch]$Containers,
      [Parameter(HelpMessage = "Used in recursion only. You don't need to specify anything")]
      [Int]$Indent = 1,
      [Parameter(HelpMessage = "Used in recursion only. You don't need to specify anything")]
      [switch]$Children
    )

    Write-Verbose "Searching path $path"
    function GetIndentString {
      [CmdletBinding()]
      Param([int]$Indent)

      $charHash = @{
        upperLeft  = [char]0x250c
        upperRight = [char]0x2510
        lowerRight = [char]0x2518
        lowerLeft  = [char]0x2514
        horizontal = [char]0x2500
        vertical   = [char]0x2502
        join       = [char]0x251c
      }

      if ($Children) {

        if ($indent -eq 5) {
          $indent += 2
        }
        elseif ($indent -eq 7) {
          $indent += 4
        }

        $pad = " " * ($Indent)

        if ($script:IsLast) {
          #write-Host "LAST" -ForegroundColor magenta
          $str += " $pad{0}{1} " -f $charHash.join, ([string]$charHash.horizontal * 2 )
        }
        else {
          $str += "{0}$pad{1}{2} " -f $charHash.vertical, $charHash.join, ([string]$charHash.horizontal * 2 )
        }

      }
      else {
        if ($script:IsLast) {
          $c = $charHash.lowerleft
        }
        else {
          $c = $charHash.join
        }
        $str = "{0}{1} " -f $c, ([string]$charHash.horizontal * 2 )

      }

      $str
    }

    #GUID Regex
    [regex]$Guid = "\w{8}-(\w{4}-){3}\w{12}"
    #parameters to splat for the search
    if ($Containers) {
      $filter = "(|(objectclass=container)(objectclass=organizationalUnit))"
    }
    else {
      $filter = "objectclass=organizationalUnit"
    }
    $search = @{
      LDAPFilter  = $filter
      SearchScope = "OneLevel"
      SearchBase  = $path
      Properties  = "ProtectedFromAccidentalDeletion"
    }

    "Server", "Credential" | ForEach-Object {
      if ($PSBoundParameters.ContainsKey($_)) {
        $search.Add($_, $PSBoundParameters[$_])
      }
    }

    $data = Get-ADObject @search | Sort-Object -Property DistinguishedName

    if ($Containers) {
      #filter out GUID named entries
      $data = $data | Where-Object { $_.name -notmatch $GUID }
    }
    if ($path -match "^DC\=") {
      $top = $data
      $last = $top[-1].distinguishedname
      $script:IsLast = $False
      Write-Verbose "Last top level is $last"
    }
    if ($data ) {
      $data | ForEach-Object {
        if ($UseDN) {
          $name = $_.distinguishedname
        }
        else {
          $name = $_.name
        }

        if ($script:IsLast) {
          Write-Verbose "Processing last items"
        }
        else {
          $script:IsLast = $_.distinguishedname -eq $last

        }

        if ($_.ProtectedFromAccidentalDeletion) {
          #display protected OUs in color
          $nameValue = "$($ADReportingToolsOptions.Protected)$name$([char]0x1b)[0m"
        }
        elseif ($_.objectclass -eq 'container') {
          $nameValue = "$($ADReportingToolsOptions.Container)$name$([char]0x1b)[0m"
        }
        elseif ($_.objectclass -eq 'organizationalUnit') {
          #display non-OU and non-Container in a different color
          $nameValue = "$($ADReportingToolsOptions.OrganizationalUnit)$name$([char]0x1b)[0m"
        }
        else {
          $nameValue = "$($ADReportingToolsOptions.Other)$name$([char]0x1b)[0m"
        }

        "{0}{1}" -f (GetIndentString -indent $indent), $nameValue

        $PSBoundParameters["Path"] = $_.DistinguishedName
        $PSBoundParameters["Indent"] = $Indent + 2
        $PSBoundParameters["children"] = $True
        #call the nested function recursively
        Get-OUTree @PSBoundParameters
      }
    } #if $data

  }

  if ($host.name -match 'ConsoleHost') {
    $getAD = @{
      ErrorAction = "stop"
      Identity    = $Name
    }
    "Server", "Credential" | ForEach-Object {
      if ($PSBoundParameters.ContainsKey($_)) {
        $getAD.Add($_, $PSBoundParameters[$_])
      }
    }

    Try {
      Write-Verbose "Getting distinguished name for $($Name.toUpper())"
      $getAD | Out-String | Write-Verbose
      [string]$Path = (Get-ADDomain @getAD).DistinguishedName
      #Passing these bound parameters to another function which needs the Path
      $PSBoundParameters.add("Path", $Path)
      [void]($PSBoundParameters.remove("Name"))
    }
    Catch {
      Throw $_
    }
    #display to top level container and then get children
    $top = @"

$($ADReportingToolsOptions.DomainDNS)$Path$([char]0x1b)[0m
$([char]0x2502)
"@

    $top
    #get child OUs
    Get-OUTree @PSBoundParameters

    #display a footer
    $tz = Get-TimeZone
    if ((Get-Date).IsDaylightSavingTime()) {
      $tzname = $tz.daylightName
    }
    else {
      $tzname = $tz.StandardName
    }
    $date = Get-Date -Format g
    $footer = @"

$($ADReportingToolsOptions.OrganizationalUnit)Organizational Units$([char]0x1b)[0m
$($ADReportingToolsOptions.Protected)Protected from Deletion$([char]0x1b)[0m
$($ADReportingToolsOptions.Container)Containers$([char]0x1b)[0m
$($ADReportingToolsOptions.Other)Other$([char]0x1b)[0m

$date $tzname
"@

    $footer
  }
  else {
    Write-Host "This command should be run in a PowerShell Console host. It will NOT run in the PowerShell ISE or VS Code." -ForegroundColor magenta
  }
  Write-Verbose "Ending $($myinvocation.MyCommand)"
}
