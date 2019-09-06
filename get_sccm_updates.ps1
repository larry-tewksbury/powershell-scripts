<#
.SYNOPSIS
    Returns a list of Windows Updates available through SCCM (Software Center) on a system.
.DESCRIPTION
    This command returns a list updates available via SCCM's Software Center to a PC or server. Alternatively, it can be used to simply install all updates against a list of computers.
.PARAMETER ComputerName
    Specifies the remote computer to get the .NET version of.
.EXAMPLE
    PS C:\> Get-SCCMUpdates -ComputerName RemoteHost

    This example would make a window pop up with a list of all updates available for the RemoteHost computer.
.EXAMPLE
    PS C:\> Get-SCCMUpdates -ComputerName RemoteHost -InstallAll

    In this case, all updates will be silently installed on the RemoteHost computer.
.EXAMPLE
    PS C:\> $Hosts = @('RemoteHost1','RemoteHost2','RemoteHost3')
    PS C:\> Get-SCCMUpdates -ComputerName $Hosts -InstallAll

    First, an array of hostnames is created (this can also be pulled from a CSV or text file). The array is then passed as an argument to Get-SCCMUpdates with the -InstallAll switch, which silently installs all updates against each computer in the array.
.INPUTS
    System.Object.String[]

    You can input a string representing a remote hostname if desired.

    Switch

    You can add a switch argument to install all updates available for each computer.
.OUTPUTS
    PSObject[]

    An array of System.Version objects is returned.
.NOTES
    This cmdlet relies on the buggy Software Center WMI instance to return objects. SCCM often requires cache deletion, uninstallation and reinstallation or other severe fixes to return reliable information. In turn, this module may not always provide the most up-to-date information.
#>


function Get-SCCMUpdates{
    Param
    (
        [Parameter(Mandatory=$True, Position=1)] 
        [string[]]$ComputerName,
        
        [Parameter(Position=2)]
        [switch]$InstallAll = $false
    )
Begin{
    # AppEvalState vars were based on the "EvaluationState" property of the CCM_Softwareupdate client class, which will exclude updates if
    # set too low. May introduce in a later version?
    # $AppEvalState0 = "0"
    # $AppEvalState1 = "1"
}
 
Process{
    If ($InstallAll){
        Foreach ($Computer in $ComputerName){
            try {
                $Application = (Get-CimInstance -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer -Property * -ErrorAction Stop)
                Invoke-CimMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Application) -Namespace "root\ccm\clientsdk" -ComputerName $Computer        
            }
            catch {
                Write-Warning ("Unable to connect to " + $Computer + ". Continuing...")
            }
        }
    }
    Else{
        # Form an array of updates ($Application array for each computer in the list is passed back to the master $update_list)
        $update_list = @(Foreach ($Computer in $ComputerName){
            try {
                $Application = (Get-CimInstance -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer -Property * -ErrorAction Stop)
                if($null -ne $Application){
                    foreach ($app in $Application){
                        $evaluation_state = Get-EvaluationState($app.EvaluationState)
                        $app | Add-Member -MemberType NoteProperty -Name "UpdateStatus" -Value $evaluation_state
                    }
                    $Application = $Application | Select-Object Name, URL, UpdateStatus, PSComputerName
                }
                $Application
            }
            catch {
                Write-Warning ("Unable to connect to " + $Computer + ". Continuing...")
            }
        })
        if($null -ne $update_list){
            # Display the updates available for all computers
            $update_list | Out-GridView -Title "List of Updates Available to SCCM"
        }
        else {
            Write-Output "There are no updates available for any of the computers provided."
        }
        
    }
}
End {}
}

function Get-EvaluationState {
    param (
        # A single integer representing the EvaluationState is passed. Currently set to accept an array, just in case.
        # More info from  https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/sdk/ccm_softwareupdate-client-wmi-class
        [Parameter(Mandatory=$true)]
        [int[]]$EvaluationState
    )
    $state_array = @(
        foreach ($state in $EvaluationState){
            switch ($state) {
                0   {$state = "None"; break}
                1	{$state = "Available"; break}
                2	{$state = "Submitted"; break}
                3	{$state = "ciJobStateDetecting"; break}
                4	{$state = "PreDownload"; break}
                5	{$state = "Downloading"; break}
                6	{$state = "WaitInstall"; break}
                7	{$state = "Installing"; break}
                8	{$state = "PendingSoftReboot"; break}
                9	{$state = "PendingHardReboot"; break}
                10	{$state = "WaitReboot"; break}
                11	{$state = "Verifying"; break}
                12	{$state = "InstallComplete"; break}
                13	{$state = "Error"; break}
                14	{$state = "WaitServiceWindow"; break}
                15	{$state = "WaitUserLogon"; break}
                16	{$state = "WaitUserLogoff"; break}
                17	{$state = "WaitJobUserLogon"; break}
                18	{$state = "WaitUserReconnect"; break}
                19	{$state = "PendingUserLogoff"; break}
                20	{$state = "PendingUpdate"; break}
                21	{$state = "WaitingRetry"; break}
                22	{$state = "WaitPresModeOff"; break}
                23	{$state = "WaitForOrchestration"; break}
                default {$state = "StateNotProvided"; break}
            }
        $state
        }
    )
    return $state_array
}
