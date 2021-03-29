Function Open-ADReportingToolsHelp {
    [cmdletbinding()]
    [outputtype("None")]
    Param()
    Write-Verbose "Starting $($myinvocation.mycommand)"
    $modBase = (Get-Module ADReportingTools).ModuleBase
    $pdf = Join-Path -path $modBase -ChildPath ADReportingToolsManual.pdf
    Write-Verbose "Testing the path $pdf"
    if (Test-Path -Path $pdf) {
        Try {
            write-Verbose "Invoking the PDF"
            Invoke-Item -Path $pdf -ErrorAction Stop
        }
        Catch {
            Write-Warning "Failed to automatically open the PDF. You will need to manually open $pdf."
        }
    }
    else {
        Write-Warning "Can't find $pdf."
    }
    Write-Verbose "Ending $($myinvocation.MyCommand)"
}