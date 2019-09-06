function Get-NETVersion {
<#
.SYNOPSIS
    Returns a list of .NET Framework versions installed on a PC.
.DESCRIPTION
    This command returns a list of .NET Framework versions installed on a remote PC, or returns the local PC's results if no remote host is given.
.PARAMETER ComputerName
    Specifies the remote computer to get the .NET version of.
.EXAMPLE
    PS C:\> Get-NETVersion
    
    Major  Minor  Build  Revision
    -----  -----  -----  --------
    2      0      50727  4927
    2      0      50727  4927
    3      0      30729  4926
    3      0      30729  4926
    3      0      30729  4926
    3      0      4506   4926
    3      0      6920   4902
    3      5      30729  4926
    3      5      30729  4926
    4      7      2558   -1
    4      7      2558   -1
    4      7      2558   -1
    4      7      2558   -1
    4      0      0      0

    The above shows the command as run on localhost, without any arguments. All .NET versions are returned.
.EXAMPLE
    PS C:\> Get-NETVersion -ComputerName RemoteHost
    
    Major  Minor  Build  Revision PSComputerName
    -----  -----  -----  -------- --------------
    2      0      50727  4927     RemoteHost
    2      0      50727  4927     RemoteHost
    3      0      30729  4926     RemoteHost
    3      0      30729  4926     RemoteHost
    3      0      30729  4926     RemoteHost
    3      0      4506   4926     RemoteHost
    3      0      6920   4902     RemoteHost
    3      5      30729  4926     RemoteHost
    3      5      30729  4926     RemoteHost
    4      7      2558   -1       RemoteHost
    4      7      2558   -1       RemoteHost
    4      7      2558   -1       RemoteHost
    4      7      2558   -1       RemoteHost
    4      0      0      0        RemoteHost

    The above shows the command run against a remote PC (RemoteHost). A list of the .NET versions installed on that PC is returned.
.INPUTS
    System.Object

    You can input a string representing a remote hostname if desired.
.OUTPUTS
    PSObject[]

    An array of System.Version objects is returned.
.NOTES
    This is highly dependent on Microsoft keeping the same .NET installation model across versions and may no longer work once .NET Core is adopted.
#>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$ComputerName
    )

    $Command = {(Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -Recurse | Get-ItemProperty -Name 'Version' -ErrorAction SilentlyContinue | ForEach-Object {$_.Version -as [System.Version]})}
    
    if ($ComputerName){
        foreach ($computer in $ComputerName) {
            if(Test-NetConnection -InformationLevel Quiet -ComputerName $computer){
                Invoke-Command -ComputerName $computer -ScriptBlock $Command 
            }
            else {
                Write-Warning "Unable to connect to the target system. Please check the hostname and try again."
                break
            }
        }
    }
    else {
        & $Command
    }
}
