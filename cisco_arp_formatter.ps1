<#

Cisco-to-Windows MAC Address Conversion Script

Takes a Cisco-formatted MAC address and IP list, such as:

Internet 192.168.1.100     0     001a.d410.c734 ARPA Vlan10
Internet 192.168.1.101     6     0007.9a5d.6474 ARPA Vlan10
Internet 192.168.1.102     23     000b.9408.0abd ARPA Vlan10
Internet 192.168.1.50        1     001c.78f5.ee0c ARPA Vlan10
Internet 192.168.1.38     69     2c60.e57b.2562 ARPA Vlan10

And converts this to a two-column "csv" (without headers) for use in Windows-based applications.

Use: Open a Powershell window, then run <path_to_script>\cisco_arp_formatter.ps1 -InputFile "<cisco_input_file>"

#>
param(
    [parameter(Mandatory=$true,
    HelpMessage = "Enter the name of the arp file input, with extension if possible.")]
    [string]$inputfile
)
$array = (get-content -path $inputfile)
$array = foreach($item in $array){$item -replace '\s+',' '}
foreach ($row in $array)
{
    $ip_address = ($row -split "\s")[1]
    $mac_address = (((($row -split "\s")[3]).Trim()).replace('.','')) -replace '(..(?!$))','$1-'
    ($ip_address + "," + $mac_address) | out-file ".\mac_address_win_formatted.csv" -append
}