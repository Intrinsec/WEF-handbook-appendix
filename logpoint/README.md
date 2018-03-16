# Example queries

The following queries are just a few examples of how the logs forwarded to the LogPoint instance can be browsed.

##### Authentication
`repo_name = "wef" event_source = "Microsoft-Windows-Security-Auditing" channel = "Security" event_id = 4624 | fields log_ts, host, target_domain, target_user, source_address, workstation`

##### Account manipulation
`repo_name = "wef" event_source = "Microsoft-Windows-Security-Auditing" channel = "Security" (event_id = 4720 OR event_id = 4740 OR event_id = 4728 OR event_id = 4732 OR event_id = 4756) | fields log_ts, host, event_id, group_name, domain, user, target_domain, target_user`

##### Program execution
`repo_name = "wef"  event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" event_id = 1 | fields log_ts, host, user_id, logonid, commandline, image, currentdirectory, parentimage`

##### Network connection
`repo_name = "wef"  event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" event_id = 3 | fields log_ts, host, sourceip, domain, user, destinationip, destinationport, image`

##### File creation
`repo_name = "wef" event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" event_id = 11 | fields log_ts, host, domain, user, image, targetfilename`

##### Registry manipulation
`repo_name = "wef" event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" (event_id = 12 OR event_id = 13 OR event_id = 14) | fields log_ts, host, event_id, message,  domain, user, image, targetobject, details`

##### PsExec usage
`repo_name = "wef"  event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" event_id = 1 image = "*psexe*"`

`repo_name = "wef" event_source = "Microsoft-Windows-Sysmon" channel = "Microsoft-Windows-Sysmon/Operational" event_id = 12 targetobject = "*\Software\SysInternals\PsExec*"`