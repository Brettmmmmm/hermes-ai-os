### Example Input
system_state: "WU service failing to start, error 0x80070424"
logs: "Service 'wuauserv' missing from registry"
error_codes: ["0x80070424"]

### Example Output (truncated)
## Goal
Restore Windows Update functionality by repairing missing service definitions.

## Diagnostics Summary
- wuauserv service missing
- BITS service present but disabled
- Update Orchestrator service failing dependency check

## Root Cause
Corrupted service registry keys caused by incomplete rollback.

## Remediation Plan
1. Recreate wuauserv service
2. Reset BITS configuration
3. Re-register update DLLs
4. Reset SoftwareDistribution
5. Restart update stack

## PowerShell Script
```powershell
sc.exe create wuauserv binPath= "C:\Windows\system32\svchost.exe -k netsvcs" start= auto
...
```

## Verification Steps
- Check service status
- Run wuauclt /detectnow
- Confirm no errors in WindowsUpdate.log

## Post-Checks
- Confirm update history loads
- Confirm cumulative update installs
