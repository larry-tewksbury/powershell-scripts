function create-m3u{
    Param
    (
        [Parameter(Mandatory=$True, Position=1)] 
        [string[]]$Directory
    )

    $files = Get-ChildItem -Path $Directory
    $multi_disc_files = $files | Where-Object {$_.Name -match "\(Disc"}
    $multi_disc_grouped = $multi_disc_files | Group-Object {$_.Name -replace " \(Disc \d\)"}

    foreach ($group in $multi_disc_grouped){
        $name = $(($group.Name -replace "\....") + ".m3u")
        $group.group.Name | Out-File -FilePath .\$name -Append
    }
}