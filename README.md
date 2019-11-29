# CyberPolice (CyberPatriotScripts)
### Intro
This script is for mainly for windows. It runs a bunch of hardening processes.\
This script is supposed to be used for automation of system hardening.\
This script was made for Cyber Patriot competition but can be used for other uses like system forensics and hardening.

### Useage
Run `CyberPolice.bat` as Administrator

#### Functions
```checkfiles``` (searches for specified extentions and words, outputs all to a log)\
```usermgmtff``` ([how this works](#user)):\
```userprop``` (sets properties for users that is secure, like expiring passwords and change on login)\
```services``` (logs services on machine, disabled specific services set in `FirewallRulesOFF.txt`)\
```firewall``` (turns on firewall, disables set firewall rules in `Auto.txt`, `Disabled.txt`, `Manual.txt`)\
```features``` (turns off specified Windows features in `BadWinFeatures.txt`)\
```passwordPol``` (sets secure password policy)\
```audit``` (sets secure audit policy)\
```lockout``` (sets secure lockout policy)\
```rdp``` (turns rdp on/off and sets policies to allow for rdp on/off)\
```power``` (sets power settings)\
```sessions``` (checks for remote sessions and logs it)\
```shares``` (logs current shares, prompts user to edit shares)\
```checkdns``` (logs dns and hosts file, clears them afterwards)\
```uac``` (turns on UAC)\
```backuplsp``` (backs up current local security policy)\
```lsp``` (sets local security policy based one ones in/put in `ConfigFiles\lgpoTemplates`)\
```regharden``` (sets settings in the registy that are specified `RegistyHardenData.txt`)\
```verifysys``` (runs `sfc /verifyonly`)\
```auto``` (runs all functions in logical order)

### Tested OS'
| Windows Version   | Tested        | 
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

Some config files allow for commenting with `#` as the first line\
Files that allow for commenting:\
```RegistryHardenData.txt```\
```FirewallRulesOFF.txt```

Most config files you just put the name of the object you want to change in the text file that applies to that object\

`RegistyHardenData.txt` useage\
To enter a registry change do the following (with ":" included)\
```Path:Key:Variable:Value```\
Example:\
```HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon:AutoAdminLogon:REG_DWORD:0```

### <a name="user"></a> User Config
The `PasteUsersHere.txt` is to be copy and pasted from the Cyber Patriot competition README (or made yourself)\
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
skyle```
