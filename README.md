# CyberPolice (CyberPatriotScripts)
### Intro
This script is for mainly for windows. It runs a bunch of hardening processes.<br />
This script is supposed to be used for automation of system hardening.<br />
This script was made for Cyber Patriot competition but can be used for other uses like system forensics and hardening.

### Useage
Run `CyberPolice.bat` as Administrator

#### Functions
```checkfiles``` (searches for specified extentions and words, outputs all to a log)<br />
```usermgmtff``` ([how this works](#user))<br />
```userprop``` (sets properties for users that is secure, like expiring passwords and change on login)<br />
```services``` (logs services on machine, disabled specific services set in `FirewallRulesOFF.txt`)<br />
```firewall``` (turns on firewall, disables set firewall rules in `Auto.txt`, `Disabled.txt`, `Manual.txt`)<br />
```features``` (turns off specified Windows features in `BadWinFeatures.txt`)<br />
```passwordPol``` (sets secure password policy)<br />
```audit``` (sets secure audit policy)<br />
```lockout``` (sets secure lockout policy)<br />
```rdp``` (turns rdp on/off and sets policies to allow for rdp on/off)<br />
```power``` (sets power settings)<br />
```sessions``` (checks for remote sessions and logs it)<br />
```shares``` (logs current shares, prompts user to edit shares)<br />
```checkdns``` (logs dns and hosts file, clears them afterwards)<br />
```uac``` (turns on UAC)<br />
```backuplsp``` (backs up current local security policy)<br />
```lsp``` (sets local security policy based one ones in/put in `ConfigFiles\lgpoTemplates`)<br />
```regharden``` (sets settings in the registy that are specified `RegistyHardenData.txt`)<br />
```verifysys``` (runs `sfc /verifyonly`)<br />
```auto``` (runs all functions in logical order)

### Tested OS'
| Windows Version   | Tested | 
| ------------- |---------------| 
| Windows Server 2019 | No | 
| Windows Server 2016 | Yes |
| Windows Server 2012 | No |
| Windows Server 2008 | No |
| Windows 10     | Yes |
| Windows 8.1 | No | 
| Windows 8 | No |
| Windows 7 | No |
| Windows Vista | No |
| Windows XP | No |

### Config Files

Some config files allow for commenting with `#` as the first line<br />
Files that allow for commenting:<br />
```RegistryHardenData.txt```<br />
```FirewallRulesOFF.txt```

Most config files you just put the name of the object you want to change in the text file that applies to that object

`RegistyHardenData.txt` useage<br />
To enter a registry change do the following (with ":" included)<br />
```Path:Key:Variable:Value```<br />
Example:<br />
```HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon:AutoAdminLogon:REG_DWORD:0```

### <a name="user"></a> User Config
The `PasteUsersHere.txt` is to be copy and pasted from the Cyber Patriot competition README (or made yourself)<br />
Example:
```Authorized Administrators:
bwayne (you)
	password: !@mBatM@n!
jgordon
	password: BaRbr@
apennyworth
	password: WayN3$
tdrake
	password: T1tANsGo!
bgordon
	password: password
Authorized Users:
hbullock
lfox
harold
hstrange
jtodd
twayne
dwayne
skyle
