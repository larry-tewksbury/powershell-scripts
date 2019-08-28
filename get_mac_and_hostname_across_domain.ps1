<#
This script grabs the hostname and MAC address for all PCs inside a specific OU of a domain and puts them into a CSV.

Can easily be changed into a one-liner by hardcoding variable values.

#>

# SearchBase is typically something like "OU=PCs,DC=mydomain,DC=com"
$search_base = "OU=PCs,DC=mydomain,DC=com"
# File to store results in pseudo-CSV format
$target = ($env:USERPROFILE + '\Desktop\hostnames_and_macs.csv')

#Requires -Module ActiveDirectory

foreach ($pc in (Get-ADComputer -Filter * -SearchBase $search_base).DNSHostname){
    $pc.TrimEnd('.scu-corp.com')+','+(getmac /s $pc)[3].subString(0,17) | Out-File $target -Append}