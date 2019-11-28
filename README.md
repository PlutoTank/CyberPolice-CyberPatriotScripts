# CyberPolice-CyberPatriotScripts
### Intro
This script is for mainly for windows. Runs a bunch of hardening processes.\
This script is supposed to be used for automation of system hardening.\
This script was made for Cyber Patriot competition but can be used for other uses like system forensics and hardening.\

### Useage
Run `CyberPolice.bat` as Administrator

#### Functions
```checkfiles``` Gamer\
```usermgmtff```\
```userprop```\
```services```\
```firewall```\
```features```\
```passwordPol```\
```audit```\
```lockout```\
```rdp```\
```power```\
```sessions```\
```shares```\
```checkdns```\
```uac```\
```backuplsp```\
```lsp```\
```regharden```\
```verifysys```\
```auto```

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

Most config files you just put the name of the object you want to change in the text file that applies to that object
