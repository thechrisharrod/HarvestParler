#HarvestParler
#@thechrisharrod

$MaxThreads = 100
$RunspacePool = [RunspaceFactory ]::CreateRunspacePool(1, $MaxThreads)
$RunspacePool.Open()
$RunspaceCollection = New-Object system.collections.arraylist

$ScriptBlock = {
    do {
        $Number = Get-Random -Minimum 1 -Maximum 25000000
        Invoke-WebRequest -Uri "http://par.pw/v1/photo?id=$Number" -OutFile "D:\Parler\$Number.jpg"
    }
    while ($True)
    [System.GC]::Collect()
}

$Powershell = [PowerShell]::Create().AddScript($ScriptBlock).AddArgument($Computer).AddArgument($ResultsPath).AddArgument($Creds)
$Powershell.RunspacePool = $RunspacePool
$RunSpace = New-Object -TypeName PSObject -Property @{
    Runspace = $PowerShell.BeginInvoke()
    PowerShell = $PowerShell
}
$RunspaceCollection.Add($RunSpace) | Out-Null

While($RunspaceCollection){
    Foreach($Runspace in $RunspaceCollection.ToArray()){
        If($Runspace.Runspace.IsCompleted){
            $Runspace.PowerShell.EndInvoke($Runspace.Runspace)
            $Runspace.PowerShell.Dispose()
            $RunspaceCollection.Remove($Runspace)
        }
    }
}