# Usage

The Splunk components included here are designed so the events pushed to the Windows Event Collector are properly forwarded to and parsed by the Splunk instance:
* `Inputs_WEF`: `inputs.conf` file to be deployed with the Splunk Universal Forwarder. The following points *must* be reviewed before pushing the configuration file to the Forwarder:
  * Sources follow the custom Windows logs configuration detailed in the `event-channels` folder of this repository,
  * Index is set to `FIXME_WEF` and should be changed to fit your environment,
  * Sources are disabled by default and need to be enabled according to your requirements.
* `TA_WEF`: `props.conf` and `transforms.conf` files to be deployed on the Splunk instance (Search Head and Indexer) to set the `host` property.


The deployment also relies on the following third-party components to be fully functional:
* Windows TA: https://splunkbase.splunk.com/app/742/
* Sysmon TA: https://splunkbase.splunk.com/app/1914/

# Example queries

The following queries are just a few examples of how the logs forwarded to the Splunk instance can be browsed.

##### Authentication
`index="WEF" sourcetype="WinEventLog:ForwardedEvents:Security" EventCode=4624 | table _time, Computer, EventCode, Logon_Type, TargetDomainName, Target_User_Name, Source_Workstation, WorkstationName | sort -_time`

##### Account manipulation
`index="WEF" sourcetype="WinEventLog:ForwardedEvents:Security" EventCode IN (4720, 4740, 4728, 4732, 4756) | table _time, Computer, EventCode, name, SubjectDomainName, SubjectUserName, TargetDomainName, Target_User_Name | sort -_time`

##### Program execution
`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1 | table _time, Computer, user, LogonId, cmdline, Image, CurrentDirectory, SHA256, parent_process | sort -_time`

##### Network connection
`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=3 | table _time, Computer, SourceIp, User, DestinationIp, DestinationHostname, DestinationPort, Image | sort -_time`

##### File creation
`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=11 | table _time, Computer, Image, TargetFilename | sort -_time`

##### Registry manipulation
`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode IN (12, 13, 14) | table _time, Computer, EventCode, EventType, UserID, Image, TargetObject, object, Details | sort -_time`

##### PsExec usage
`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1 Image="*psexe*"`

`index="WEF" sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=12 TargetObject="*\\Software\\SysInternals\\PsExec*"`
