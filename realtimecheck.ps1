# Set the path for the log file
$logFile = "C:\Users\mranv\Desktop\Hello-World\process_creation_log.txt"

# Create the log file if it doesn't exist
if (!(Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

# Function to write to both console and log file
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# Set up the event query
$query = '*[System[(EventID=1)]]'
$events = New-Object System.Diagnostics.Eventing.Reader.EventLogQuery("Microsoft-Windows-Sysmon/Operational", [System.Diagnostics.Eventing.Reader.PathType]::LogName, $query)
$listener = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher($events)

# Register the event
Register-ObjectEvent -InputObject $listener -EventName EventRecordWritten -Action {
    $event = $Event.SourceEventArgs.EventRecord
    $eventXML = [xml]$event.ToXml()
    
    $processName = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'Image'} | Select-Object -ExpandProperty '#text'
    $pid = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'ProcessId'} | Select-Object -ExpandProperty '#text'
    $commandLine = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'CommandLine'} | Select-Object -ExpandProperty '#text'
    $parentProcessName = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'ParentImage'} | Select-Object -ExpandProperty '#text'
    $parentPid = $eventXML.Event.EventData.Data | Where-Object {$_.Name -eq 'ParentProcessId'} | Select-Object -ExpandProperty '#text'
    
    if ($processName -like "C:\Users\mranv\Desktop\Hello-World\*") {
        Write-Log "New Process Created:"
        Write-Log "Process Name: $processName"
        Write-Log "PID: $pid"
        Write-Log "Command Line: $commandLine"
        Write-Log "Parent Process: $parentProcessName"
        Write-Log "Parent PID: $parentPid"
        Write-Log "------------------------"
    }
}

Write-Log "Monitoring for new process creation events in C:\Users\mranv\Desktop\Hello-World\... Press Ctrl+C to stop."
while ($true) { Start-Sleep -Seconds 1 }