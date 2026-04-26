function Invoke-HermesSkill {
    param(
        [Parameter(Mandatory)]
        [string]$Skill,
        [Parameter(Mandatory)]
        [hashtable]$Input
    )

    $json = $Input | ConvertTo-Json -Depth 10
    $cmd = "hermes run --skill $Skill --input '$json'"
    Write-Verbose "Executing: $cmd"
    $result = Invoke-Expression $cmd
    return $result
}

function Invoke-WindowsUpdateRepair {
    param(
        [string]$SystemState,
        [string]$Logs,
        [string[]]$ErrorCodes
    )

    $input = @{
        system_state = $SystemState
        logs         = $Logs
        error_codes  = $ErrorCodes
    }

    return Invoke-HermesSkill -Skill "windows-update-repair" -Input $input
}

Export-ModuleMember -Function * -Alias *
