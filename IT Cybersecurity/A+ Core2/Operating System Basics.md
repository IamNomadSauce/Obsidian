- **Alpha** An operating system in alpha is a first draft of an operating system. Operating systems that are available in alpha are considered previews. It is common to find these in open source communities, such as Linux operating systems, but it is uncommon to find a corporate-based operating system in alpha.
    
- **Beta** An operating system in beta is a second draft of an operating system. This stage of an operating system means most of the bugs have been discovered and are avidly being patched. This stage is typically used to discover missing features and new bugs. Some operating system developers require an opt-in to run a beta operating system, and some require invites to a beta program that mandates participation.
    
- **Release Candidate** An operating system that is deemed a release candidate is in the final stage before it is released to market. During the release candidate stage, administrators are urged to install and use the operating system as though it were the final release. The benefit is that the administrator can get a previewed look at the operating system while helping to polish the final product, also called the _release to market (RTM)_. An operating system in this stage is generally stable and has relatively few bugs.
    
- **Current** A current operating system, as the term states, is the current release of an operating system. Many operating system developers are on a one- to two-year release cycle for the future version of the current operating system.
    
- **Service Pack** Although the term _service pack_ is generally associated with updates, it is also used to describe a milestone in the life cycle of an operating system. When a service pack is released for an operating system, it adds major features as well as patches for both security and functionality. Microsoft has replaced this term with the introduction of Windows 8; it is now just called an update. However, many other operating systems still use "service pack."
    
- **Mainstream Support** During the _mainstream support_ of an operating system, all _hotfixes_, _security updates_, _feature updates_, and general support for the operating system is supported. An operating system developer will usually have a predetermined mainstream support date when the operating system is released. When the mainstream support ends for an operating system, it is either no longer supported or enters into an extended support period.
    
- **Extended Support** The _extended support_ period, sometimes called the _long-term support (LTS)_ period, for an operating system is the final state of an OS's life cycle. For example, during this time, hotfixes and features will no longer be supported, but critical security updates will be supported with Microsoft operating systems. Additional contract purchases may be required if hotfixes are required during this period. An administrator should have all systems upgraded to the current operating system by the end of the extended support date.

**CPU Architecture:** 
- 32 bit
	- X86
	- Limit of 4GB of RAM
- 64 bit
	- X64 / AMD64
# Windows Versions
![[Pasted image 20230820113831.png]]
![[Pasted image 20230817162957.png]]
![[Pasted image 20230821122410.png]]

- **Windows 10 Home** 
	- Lacks support for Remote Desktop (client only), BitLocker, Windows To Go, Hyper-V, joining to a domain, and participating in Group Policy. This edition is strictly for consumer use.
	- 128GB of RAM max
	- 2 CPUs
    
- **Windows 10 Pro (Professional)** 
	- Can join a Windows server domain; includes Remote Desktop Server, BitLocker, Windows To Go, Hyper-V, and participating in Group Policy.
	- 2TB of RAM
	- 2 CPUs
    
- **Windows 10 Pro for Workstations** 
	- This edition is used primarily for high-end computer workstations that require more than two CPUs and that need to address more than 2 TB of memory. Windows 10 Pro for Workstations supports up to four CPUs and 6 TB of memory. In addition, it supports Remote Direct Memory Access and Non-Volatile Dual Inline Memory Modules (NVDIMM).
	- 6TB of RAM
	- 4 CPUs
    
- **Windows 10 Enterprise** 
	- Includes BitLocker, support for domain joining and Group Policy, DirectAccess, AppLocker, and BranchCache. This edition is available only through a volume license subscription.
	- 6TB or RAM
	- 2 CPUs
	- Requires a volume license subscription
*Limited to 255 character filenames*

## Bitlocker
- Drive encryption, including those required for startup and login.
- Available in all versions of Windows 10/11 except for Home Edition
- Requires a TPM (Trusted Platform Module)
- Found in Control Panel
### Bitlocker to Go
- Bitlocker for removable drives

## EFS
- Encrypting File System
- Allows for encryption of files stored in NTFS
- Uses certificates stored in user profile
	- If computer is on Active Directory, the AD Certificate Authority will handle it
- Right-Click > Properties > Advanced
- All users can use EFS but only Administrators can turn on Bitlocker

**System Config (MSCONFIG)**
	- General, Boot, Services, Startup, and Tools configuration.


**Control Panel** 
![[Pasted image 20230821083700.png]]

**HomeGroup**
- Allows for sharing of files and printers with a single password.
- Windows 10 (1709) and older

**Workgroup**
- Loosely associated computers, each of which is its own security authority, that share a common _workgroup_ name. Often used for 10 or fewer computers/workstations that do not require a server computer.
- Peer-to-Peer
- Used in SOHO environments (20 Connections max)
	- Click the Start menu.
	- Click the Settings gear.
	- Click System.
	- Click About.
	- Click the Advanced System Settings, related setting.
	- Click Change Settings under the heading of Computer Name, Domain, and Workgroup Settings.
	- Click Change Next to Rename This Computer or Change Its Domain Or Workgroup.
	- Change the Workgroup option to the desired workgroup.
	- Click OK.
	- Click OK.
	- Reboot the computer.
![[Pasted image 20230821162408.png]]

**Domain** 
- A group of computers that are tightly connected or associated and that share a common domain name. Has a single authority (called a _domain controller_) that manages security for all the computers. Often used for 10 or more computers/workstations that connect to one or more server computers.
- Creates a trust between client and authentication server.
	- Click Start ➢ Settings ➢ Accounts ➢ Access Work or School ➢ Connect ➢ Join This Device To A Local Active Directory Domain. You will be prompted to enter a domain name
	- Enter your credentials on the domain when prompted
	- Reboot the operating system for the changes to take effect.
- Alternative option
	- Right-click Start.
	- Click System.
	- Under Related choose Advanced System Settings.
	- Under Computer Name, Domain, And Workgroup Settings, select Change Settings.
	- Click Change.
	- Select the Domain radio button under Member Of.
	- Enter the domain name and click OK,
![[Pasted image 20230821162342.png]]

## User Authentication #TODO DAC MAC Access Control
- When using a workgroup model, authentication is local to the operating system.
	- Security Account Manager (SAM)
		- A local database of users and groups
- When using a Domain model, users authenticate against an Active Directory domain controller.
**Single Sign-On** #TODO Complete/finish
![[Pasted image 20230821162738.png]]


## Windows Settings
- Introduced in Windows 8
- Time and Language
- Update and Security
- Personalization
- Apps
- Privacy
	- Windows 10/11
- System
	- Display
	- Sound
	- Notifications and Actions
	- Devices
		- Will eventually replace Devices and Printers Control Panel applet
		- Bluetooth and other devices
		- Printers and Scanners
		- Mouse
		- Typing
		- Pen and Windows Ink
		- Autoplay
		- USB
	- Network and Internet
		- Status
		- Ethernet
		- Dial-up
		- VPN
		- Proxy
	- Gaming
	- Accounts
		- Your Info
		- Email and Accounts
		- Sign-in Options
		- Access Work or School
		- Family and Other Users
		- Sync settings
## Windows Registry #TODO where is the registry file
- Configuration files that can only be opened with **regedit** & **regedt32** 
- Hives:
	- HKEY_CLASSES_ROOT
			- Includes information about which filename extensions map to particular applications
	- HKEY_CURRENT_USER
		- Holds all configuration information specific to a particular user, such as their desktop settings and history information.
	- HKEY_LOCAL_MACHINE
		- Includes nearly all configuration information about the actual computer hardware and software.
	- HKEY_USERS
		- Includes information about all users who have logged into the system. The HKEY_CURRENT_USER hive is actually a subkey of this hive.
	- HKEY_CURRENT_CONFIG 
		- Provides quick access to a number of commonly needed keys that are otherwise buried deep in the HKEY_LOCAL_MACHINE structure.

## Disc Management
- Discs must be partitioned and formatted first before it can hold files.
- File Allocation Table **(FAT)**
	- Used to keep track of where files are on the system
	- 2GB max partition size
	- 8.3 naming system (8 letters for name, 3 letter file identifier)
- Virtual FAT (VFAT)
	- Introduced in Windows 95
	- 32bit code with 16bit naming system for backwards compatibility
	- Uses 8.3 naming convention
	- Allows up to 255 characters for file names
- FAT32 
	- Introduced in Windows 95 OEM Service Release
	- Allows up to 2TB (2048GB) files
	- Uses 32bit cluster addressing
	- Available on current Windows systems
- New Technology File System (NTFS)
	- Includes individual file encryption and compression, disk quotas, and RAID support
- Compact Disc File System (CDFS)
	- File system for CD media. Used since Windows 95 on 32 bit systems and appears as a *collection*
- Extended File Allocation Table (exFAT)
	- Microsoft proprietary file system used for flash drives.
	- Default file system for flash drives over 32-GB
- Network File System (NFS)
	- Created by Sun Microsystems.
	- Used in Unix and Linux systems. (Can be use with Windows too, but may need to be installed)
- Extended File System (ext3/ext4)
	- Used with Linux systems.
	- Journaling. 
	- EXT4 is used with android
- Hierarchical File System (HFS)
	- Developed by Apple in 1985
	- Used up till OSX 10.12.4, and iOS 10.3
- Apple File System (APFS)
	- Proprietary to Apple.
	- Developed new features for SSDs
		- Encryption, compression, and snapshots.
- Swap Partition
	- Only found on Linux and Unix systems. 
	- Equivalent to *page file* for Windows.
	- Used for virtual memory when physical memory is exhausted.

**Windows Partition Types**
Partition and volume mean the same thing
-  logical subdivisions of a physical disk. 

-  Basic Disk
	- MBR (Master Boot Record) used with BIOS (Replaced with GPT)
	- MBR types can have 4 primary partitions, or 3 primary partitions and one extended partition containing multiple logical partitions. (Max of 26 partitions.)
	- Booting partition must be designated as **Active** and must be primary partition. 
		- Only one disk can be designated as Active. 
- GPT Disk
	- GUID Partition Tables
	- Used with UEFI (User Extensible Firmware Interface)
		- Current used
	- Allocates 64-bit logical block addressing for larger partitions. 
		- If you want to create partition greater than 2TB, this is required
	- 128 primary partitions max
- Dynamic Disk
	- Proprietary to Windows systems. 
	- Can contain up to 2000 volumes. 
	- Contains a 1MB partition table.

## Upgrading Windows
Windows 10 can used BIOS or UEFI, but Windows 11 must use UEFI
UEFI uses Secure Boot
- Checks the signatures of hardware, UEFI drivers, EFI Applications, and the Operating System
- Windows 11 requires the hardware to be Secure-Boot capable and have a TPM 2.0 module installed.
- Holds a 500MB file called Windows Recovery Environment.
- EFI System Partition (ESP) is a partition used to hold Boot Configuration Data (BCD) for booting of the boot partition containing the Windows Kernel. 
Windows XP was last version of Windows to allow installation from CD ROM
Can be booted from network using PXE (Pre-Boot Execution Environment)

## Command Line Tools (CLI)
- **Navigation**
	- dir
		- Used to display files and folders in a directory
		- dir *.txt will display all text files
	![[Pasted image 20230821142550.png]]
	- cd
		- Change Directory
	- md
		- Move Directory
	- rmdir
		- Remove Directory
![[Pasted image 20230821142720.png]]
- **Network Tools**
	- ipconfig
		- Displays IP Address, subnet mask, default gateway, and DNS suffix.
	- ipconfig /all
		- Lists all adapters and their:
			- IP Address
			- subnet mask
			- default gateway
			- DNS suffix
			- DHCP Server(s)
			- MAC address
		- Can renew/release ip address
			- Renew
				- Renews the lease of the ip address
			- Release
				- Releases the ip address
	- ping
		- Verify a network via ICMP.
	- tracert
		- Verifies the path a network packet travels to its destination. 
	- pathping
		- Combines ping and tracert
		- Used to diagnose packet loss to a destination address
	- netstat
		- Allows you to view listening and established networking connections for the operating system.
			- -b switch displays the application name and its current established connections
			- -a switch displays all the listening connections in addition to the established connections.
	- nslookup
		- nslookup [domain name] will show ip address and FQDN of the website you are looking up.
	- hostname
		- Returns the hostname of the pc you are using
	- gpupdate
		- Updates group policy settings.  It refreshes or changes both local and Active Directory based policies.
		- /force switch
			- Force the refresh cycle immediately
	- gpresult
		- Used to show the Resultant Set of Policy (RSoP) report/values for a remote user and computer. 
	- net
- **Disk Commands**
	- format
		- Wipes data from disk and prepares it for new use.
		- Must be partitioned first with **diskpart**
		- format *volume* *switches*
			- **format D: /fs:ntfs /v:HDD2**
![[Pasted image 20230821152349.png]]
- copy
	- Copies a file to another location
	- copy *filename* *destination*
	- Can use a wildcard '*' to copy everything
		- copy *.exe to copy .exe files, or copy * to copy everything
- xcopy
	- Used to copy folders/directories
	- xcopy *source destination switches*
![[Pasted image 20230821153102.png]]
- robocopy
	- Copies files and their NTFS attributes
- diskpart
	- Shows partitions and lets you manage them on the computers hard drives
- chkdsk
	- Check and display status reports for the hard disk
	- Can also correct file system problems
	- You can also right click the drive and select *properties* in the GUI and then select the Tools tab
- shutdown
	- Can schedule a shutdown or restart remotely or locally. 
![[Pasted image 20230821153932.png]]
- sfc
	- System File Check
	- Checks and verifies the versions of system files.
		- If corrupted, sfc replaces the corrupted files with correct versions
	- sfc *switch*
![[Pasted image 20230821154203.png]]
- winver / ver
	- Displays version of windows
- help and /?
	- Gives you a manual of possible commants. 
	- *command* /?

--
- The Generalize pass is where the operating system detects hardware and installs the appropriate drivers. 
- The Out-Of-Box Experience (OOBE) is the pass that is responsible for configuring and creating the user environment during the setup process. 
- The Specialization pass is where the operating system is configured during setup. 
- The WinPE pass starts the procedure of installing the operating system.
--
- The Windows Deployment Service (WDS) is a server role that is used to create a Windows image for mass deployment. 
- The Microsoft Assessment and Planning (MAP) toolkit is used to create reports on system hardware for image deployment. 
- The User State Migration Toolkit (USMT) is used in corporate environments to migrate user data. 
- The sysprep utility is used to prepare an operating system for imaging.
--
- The General Availability branch installs updates as they are released to the general public. 
- The Semi-Annual Channel is no longer a channel supported by Windows 10/11. 
- The Long-Term Servicing Channel never installs new features during the life of the version of Windows. 
- The Insider Program allows for the installation of brand-new features before they are publicly released.
--
- The msinfo32.exe tool allows for the remote reporting of a computer’s hardware. 
- regedit.exe is used to edit the Registry. 
- msconfig.exe is used to change the startup of services and change the boot process. 
- dxdiag.exe is used to diagnose DirectX problems.
--
- The chkdsk command is used to check a volume for corruption, as well as attempt to repair the corruption. 
- The diskpart command allows you to create, modify, and view volumes on a disk. 
- The format command allows you to format a filesystem on a volume. 
- The sfc command is used to fix corrupted files but not volume corruption.
--
- The Boot Configuration Data is stored in the EFI System Partition on an EFI installation of Windows. 
- The WinRE partition is used for the Windows Recovery Environment. 
- Secure Boot is a feature of an EFI installation and does not contain its own partition. 
- The C:\WINDOWS folder is where the installation of Windows exists.
--
#TODO Chapter 15
- The Wireless Wide Area Network (WWAN) connection is a cellular connection and is configured on the Cellular screen in the Settings app. 
- A wired connection is configured on the Ethernet screen in the Settings app. 
- A wireless connection is configured on the Wi-Fi screen in the Settings app. 
- A virtual private network (VPN) connection is configured on the VPN screen in the Settings app.
#TODO Windows Upgrade Path

#TODO lusr, mmc
---------------------------
# Chapter 16
## MacOS
- App Store
- APP File
	- A container that holds the app, the launcher, files and folders
- DMG File 
	- Disc Image File
	- Similar to ISO or ZIP file
	- Can be mounted as a disk
- PKG File
	- Automated package installer.
## Linux
![[Pasted image 20230821173526.png]]
su -
- Becomes root
ps
- ps ax
	- List of processes for the entire operating system
kill *process*
- Kills process
cd
- Change directory
- cd ..
	- Go back one directory
- cd ~
	- Go to root directory
ls
- list files in directory
- ls -a
	- Lists all files including hidden files
- ls -l
	- Lists files and their permissions
- ls -al
	- List files and permissions including hidden files
mkdir
- Creates a directory/folder
- mkdir -p
	- Create directory hierarchy
**Permissions**
![[Pasted image 20230821183258.png]]
chmod
- Change permissions of file/folder
- chmod a+x filename gives execute permissions to all
chown
- Change permissions for a user
- chown *user_id file/folder*
cp
- Copies a file 
- cp -ar *source_directory* *desination_directory*
	- Copies all files in a directory recursively
mv
- Moves files to a directory
- mv *file* *destination_directory*
rm
- Removes a file
- rm -r
	- Removes all files and directories (even if not empty)
rmdir
- Remove directory (only if empty)
cat
- View contents of a file
ifconfig
- Get ip address (similar to ipconfig on Windows)
fsck
- Checks and repairs disks.

# Chapter 18
- Accounts and groups
	- Microsoft
		- 
	- Local
	- Administrator
		- Has all the power including the ability to remove the operating system
		- Should be used only when necessary
	- Power User
		- Read and write privileges
			- Can install software and is good for devs and programmers
		- Did not work out well, and is no longer used but kept around for backwards compatibility reasons
	- Standard User
		- Belongs to local Users group by default
		- Has read / write privileges to their own profile, but cannot modify system-wide Registry settings
			- Cannot do something like sfc.exe unless in Administrators group and have administrator password
	- Guest
		- Created by default and should be disabled
		- Has same abilities as Standard User but cannot access log files.
- ### Authentication
	- Active Directory
		- Uses Kerberos v5
			- A server that runs Active Directory retains information about all access rights for all users and groups in the network
			- Issued a *Kerberos Token* that is a GUID  (Globally Unique Identifier)
	- Single Sign-On
	- Windows Hello
		- Stores credentials in a secure container called the Credential Manager
		- Credential manager is locked and unlocked
			- Pin
			- Biometrics
			- Security Key
			- Picture Password
		- Start > Settings App > Accounts > Sign-in Options
	- #### RADIUS (Remote Authentication Dial-in User Service)
		- Commonly used for authentication of:
			- VPNs
			- wireless systems
			- any network that requires a common authentication system
		- Client-Server protocol
		- Controls Authentication, Authorization, and Accounting (AAA)
		- UDP 1812 for Authentication
		- UDP 1813 for Accounting
	- #### TACACS+ (Terminal Access Controller Access Control System Plus)
		- Developed by CISCO
		- Authentication of users on routers and switches to allow management access
		- Authenticates users connecting to WAPs via a centralized database
		- Largely replaced by RADIUS
	- #### Kerberos
		- Open standard developed by MIT.
		- Main authentication protocol used by Active Directory
		- Can be used as main authentication method for Microsoft's implementation of a RADIUS server NPS  (Network Policy Server)
		- Can also be used with 802.1X for direct authentication with EAP (Extensible Authentication Protocol)
Moving vs. Copying
- Copying a file creates a new entity
- Moving a file retains the permissions


## Securing a SOHO Network (Wireless)
- Change the default SSID
- Disable SSID broadcasts
- Disable DHCP or use reservations
- Use MAC filtering
- Use IP filtering
- Use the strongest security available on the wireless access point
- Change the static security keys every 2-4 weeks
- When new wireless protection schemes become available, consider migrating them
- Limit the user accounts that can use wireless connectivity
- Use a preauthentication system, (RADIUS)
- Use remote access filters against:
	- client type 
	- protocols 
	- used
	- time 
	- date 
	- user 
	- account 
	- content
	- etc
- Use IPsec tunnels
- Turn down the signal strength to the minimum needed to support connectivity
- Consider removing wireless access from your LAN

## Securing A SOHO Network (Wired)
- Changing default credentials
- Upgrading firmware
- Filtering
	- IP filtering
- Disabling ports
- MAC Address Filtering
- Content Filter
- Screened Subnet (DMZ)
- Port Forwarding/Mapping
- DHCP
	- Reservations
	- Static
- Physical security




## Chapter 20
- Scripting
	- PowerShell - .ps1
		- Allows for the automation and management of the Windows OS, and cloud services: Azure & Microsoft 365
		- Based on .NET
		- Introduced cmdlets
			- Get-Item (Gets an item such as directory, environmental variable, registry)
		- Uses Integrated Scripting Environment (ISE)
	- Visual Basic Scripts -.vbs
		- Being replaced by PowerShell
		- Based on COM (Component Object Model) to allow interaction with the OS
		- Based on .NET
		- Can be executed through cscript.exe
		- Uses a program called wscript.exe
		- Windows Scripting Host (WSH) is the environment
	- Shell - .sh
		- Bash (Bourne Again Shell)
		- Linux and Unix
		- Do not require .sh extension to run but needs to have execute permissions
		- #!/bin/bash
	- Python - .py
		- Runs in the IDE (Integrated Development Environment)
	- Javascript - .js
		- Web browsers
- ### Remote Access
	- RDP (Remote Desktop Protocol) TCP 3389
	- Operate remote computer as if you were sitting in front of it.
	- Uses TLS encryption by default
		- 128-bit encryption
	- RDC (Remote Desktop Client)
		- mstsc.exe
	- VPN (Virtual Private Network)
		- Secure tunneling over unsecure network.
		- Site-to-Site
		- Client-to-Site
			- Strategy for mobile access.
	- VNC (Virtual Network Computing) TCP 5900
		- Allows one console per OS.
		- Not encrypted by default.
		- Client-server model. 
		- Open source protocol.
	- Telnet TCP 23
		- unsecure and deprecated
		- Replaced by SSH
	- SSH TCP 22
		- Remote access via text console for Linux and Unix systems
		- Private key pair.
	- MSRA 
		- Microsoft Remote Assistance.
		- msra.exe
	- Quick Assist
		- Developed to deal with deficiencies with MSRA
		- GoToMeeting, JoinMe.
		- Does not support file transfers