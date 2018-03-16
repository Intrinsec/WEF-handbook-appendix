# Using custom event channels

You need both the .man file and a .dll to enable custom event log channels.

The `EventChannelsFWD.dll` file included here was compiled with the following environment:
* Windows 7 x64 English
* Windows 7 SDK
* .Net Framework 4.0

It provides the four following event channels:
* FWD-AppLocker
* FWD-PowerShell
* FWD-Security
* FWD-Sysmon

Copy both files to `C:\Windows\System32` then run the following command in a privileged command prompt to enable the new event channels:
`wevtutil im C:\Windows\System32\EventChannelsFWD.man`

We encountered no issues when using this DLL with later versions of both desktop and server flavors of Windows running different language packs.

You are welcome to recompile the DLL to suit your needs; please refer to the guide for details.

# Credits

Original manifest file by Russel Tomkins, available [here](https://blogs.technet.microsoft.com/russellt/2016/05/18/creating-custom-windows-event-forwarding-logs/).
