- **File Allocation Table** _FAT_ is the acronym for the file table used to keep track of where files are within the filesystem. It's also the name given to this type of filesystem, introduced in 1981. The filesystems for many OSs have been built on the design of FAT but without its limitations. A FAT filesystem uses the _8.3 naming convention_ (eight letters for the name, a period, and then a three-letter file identifier). This later became known as _FAT16_ (to differentiate it from FAT32) because it used a 16-bit binary number to hold cluster-numbering information. Because of that number, the largest FAT disk partition that could be created was approximately 2 GB.
    
- **Virtual FAT** _Virtual Fat (VFAT)_ is an extension of the FAT filesystem that was introduced with Windows 95. It augmented the 8.3 file-naming convention and allowed filenames with up to 255 characters. It created two names for each file: a long name and an 8.3-compatible name so that older programs could still access files. When VFAT was incorporated into Windows 95, it used 32-bit code for improved disk access while keeping the 16-bit naming system for backward compatibility with FAT. It also had the 2 GB disk partition limitation.
    
- **FAT32** The _FAT32_ filesystem was introduced along with Windows 95 OEM Service Release 2. As disk sizes grew, so did the need to be able to format a partition larger than 2 GB. FAT32 was based more on VFAT than on FAT16. It allowed for 32-bit cluster addressing, which, in turn, provided for a maximum partition size of 2 terabytes (2,048 GB). It also included smaller cluster sizes to avoid wasted space. FAT32 support is included in current Windows versions.
    
- **New Technology Filesystem** Introduced along with Windows NT, _New Technology Filesystem (NTFS)_ is available with all current versions of Windows. NTFS is a much more advanced filesystem in almost every way than all versions of the FAT filesystem. It includes such features as individual file security encryption and compression, disk quotas, and RAID support, as well as support for extremely large file and partition sizes and disk transaction monitoring. It is the filesystem of choice for higher-performance computing.
    
- **Compact Disc File System** Although not a filesystem that can be used on a hard drive, _Compact Disc File System (CDFS)_ is the filesystem of choice for CD media. It has been used with 32-bit Windows versions since Windows 95. A CD mounted with the CDFS driver appears as a collection.
    
- **Extended File Allocation Table** Created by Microsoft, _Extended File Allocation Table (exFAT)_ is a proprietary filesystem of choice for flash drives where NTFS cannot be used (because of overhead) and FAT32 is not acceptable (due to filesystem limitations). Although exFAT is a proprietary filesystem, it is being adopted by third-party device vendors to overcome the filesystem limitations of FAT32. It is ideal for SD cards that hold a lot of information, and it is supported in all current versions of Windows. exFAT is the default filesystem on USB flash drives over 32 GB in size.
    
- **Network File System** Network File System (NFS) was created by Sun Microsystems a number of decades ago and is widely used in UNIX and _Linux_ environments. Starting with Windows 7, Microsoft includes support for NFS with Windows (but it is not always installed). Windows versions prior to Windows 7 (Vista) can install Windows Services for UNIX (SFU) to gain this support.
    
- **Extended File System** Not natively supported with Windows, ext3 (Third Extended File System) became the default filesystem for many distributions of Linux due to its journaling capabilities. Enhancements were added to it to create _ext4_ (Fourth Extended File System), which is used with Android and other operating systems. It is possible to use ext4 with Windows, but doing so requires making some sacrifices in features for the sake of compatibility.
    
- **Hierarchical File System** _Hierarchical File System (HFS)_ is a proprietary filesystem that was developed by Apple for the Mac OS back in 1985. The filesystem was originally created so that the filesystem could scale for larger disks. HFS+ eventually replaced the original HFS filesystem and it was the primary filesystem on which macOS operated prior to macOS Sierra 10.12.4, iOS 10.3, and tvOS 10.2. Windows operating systems cannot read drives formatted in HFS.
    
- **Apple File System** _Apple File System (APFS)_ is a proprietary filesystem that was developed by Apple to replace HFS and HFS+. The filesystem was mainly developed to introduce new features with _solid-state storage drives (SSD)_, such as compression, encryption, and snapshots, just to name a few. APFS also fixed some core issues with the HFS+ filesystem, such as the number of files and data integrity. The filesystem is the default filesystem for macOS Sierra 10.12.4, iOS 10.3, and tvOS 10.2 and later. Windows operating systems cannot read drives formatted in APFS.
    
- **Swap Partition** Swap partitions, which are found only within Linux and UNIX installations, are the equivalent of the page file (pagefile.sys) in Windows, except that they are their own partition type. They are used for _virtual memory_ when the physical memory is exhausted.

# Windows Partitions 
- **Basic Disks** _Master Boot Record (MBR)_ is the standard BIOS partition table used and predates GPT. MBR disk storage can have a maximum of four primary partitions or three primary partitions and one extended partition containing multiple logical partitions, for a maximum of 26 logical partitions. The partition from which the operating system boots must be designated as active and must be a primary partition. Only one partition on a disk can be marked active.
    
- **GPT Disks** _GUID Partition Tables (GPT)_ is the current partition table specification used with _Unified Extensible Firmware Interface (UEFI)_ BIOS. GPT partition tables allocate 64-bit logical block addressing for larger partitions. If you need to create partitions 2 TB or larger, it is required. A GPT disk can contain up to 128 primary partitions. The large number of primary partitions supported eliminates the need to create extended/logical partitions.
    
- **Dynamic Disks** _Dynamic disks_ are proprietary to Windows operating systems. Dynamic disks can contain up to 2,000 volumes. All the dynamic disks installed in the operating system contain an identical 1 MB database (partition table) that describes all the other disks installed. The true benefit of this 1 MB database is moving fault-tolerant disks to another Windows operating system. The operating system will automatically recognize that the disks work together, and the _Logical Disk Management (LDM)_ will configure itself according to the layout in the 1 MB database.

# Authentication Factors
- **Something You Know**   This is commonly a username and password or _personal identification number (PIN)_. You can make passwords more complex by requiring uppercase, lowercase, numeric, and symbol combinations.
    
- **Something You Have**   This is based on something you physically have. This chapter covers several different types of devices, including key fobs, keys, and smartcards, just to name a few.
    
- **Something You Are**   This authentication factor is based on something that makes you physically unique. Biometrics such as fingerprints, your voice, and retina scans should be the first things that come to mind.
    
- **Somewhere You Are**   A relatively new factor of authentication is based on somewhere you are. With the proliferation of Global Positioning System (GPS) chips, your current location can authenticate you for a system. This is performed by authentication rules based on the user's location.
    
- **Something You Do**   Another relatively new factor of authentication for network systems is based on something you do. Although it has been used for hundreds of years for documents and contracts, a signature is something that you do and don't even think about how you do it. It is unique to you and only you, because there is a specific way you sign your name. Typing your name into the computer is something you do and don't think about, but there is a slight hesitation that you make without knowing it.

# Malware, viruses, etc.
### Malware

_Malware_ is a broad term describing any software with malicious intent. Although we use the terms _malware_ and _virus_ interchangeably, distinct differences exist between them. The lines have blurred because the delivery mechanisms of malware and viruses are sometimes indistinguishable.

A virus is a specific type of malware, the purpose of which is to multiply, infect, and do harm. A virus distinguishes itself from other malware because it is self-replicating code that often injects its payload into documents and executables. This is done in an attempt to infect more users and systems. Viruses are so efficient in replicating that their code is often programmed to deactivate after a period of time, or they are programmed to only be active in a certain region of the world.

Malware can be found in a variety of other forms, such as covert cryptomining, web search redirection, adware, spyware, and even ransomware, and these are just a few. Today the largest threat of malware is ransomware because it's lucrative for criminals.

#### Ransomware

_Ransomware_ is a type of malware that is becoming popular because of anonymous currency, such as Bitcoin. Ransomware is software that is often delivered through an unsuspecting random download. It takes control of a system and demands that a third party be paid. The "control" can be accomplished by encrypting the hard drive, by changing user password information, or via any of a number of other creative ways. Users are usually assured that by paying the extortion amount (the ransom), they will be given the code needed to revert their systems back to normal operations. CryptoLocker was a popular ransomware that made headlines across the world (see [Figure 17.18](https://viewer.books24x7.com/assetviewer.aspx?bookid=159471&chunkid=605348946&resumebookmarkid=52bc6f2e-0432-ee11-80cd-0050569533bd#)). You can protect yourself from ransomware by having antivirus/antimalware software with up-to-date definitions and by keeping current on patches.

#### Trojans

_Trojan horses_ are programs that enter a system or network under the guise of another program. A Trojan horse may be included as an attachment or as part of an installation program. The Trojan horse can create a backdoor or replace a valid program during installation. It then accomplishes its mission under the guise of another program. Trojan horses can be used to compromise the security of your system, and they can exist on a system for years before they're detected.

The best preventive measure for Trojan horses is to not allow them entry into your system. Immediately before and after you install a new software program or operating system, back it up! If you suspect a Trojan horse, you can reinstall the original program(s), which should delete the Trojan horse. A port scan may also reveal a Trojan horse on your system. If an application opens a TCP or UDP port that isn't supported in your network, you can track it down and determine which port is being used.

#### Keyloggers

A _keylogger_ is normally a piece of software that records an unsuspecting victim's keystrokes. Keyloggers can stay loaded in memory and wait until you log into a website or other authentication system. They will then capture and relay the information to an awaiting host on the Internet.

Keyloggers don't always have to be in the form of software. Some keyloggers are hardware dongles that sit between the keyboard and computer. These must be retrieved and the data must be downloaded manually, so they are not very common.

#### Rootkits

_Rootkits_ are software programs that have the ability to hide certain things from the operating system. They do so by obtaining (and retaining) administrative-level access. With a rootkit, there may be a number of processes running on a system that don't show up in Task Manager, or connections that don't appear in a Netstat display of active network connections that may be established or available. The rootkit masks the presence of these items by manipulating function calls to the operating system and filtering out information that would normally appear.

Unfortunately, many rootkits are written to get around antivirus and antispyware programs that aren't kept up-to-date. The best defense you have is to monitor what your system is doing and catch the rootkit in the process of installation.

#### Spyware

Spyware differs from other malware in that it works—often actively—on behalf of a third party. Rather than self-replicating, like viruses and worms, spyware is spread to machines by users who inadvertently ask for it. The users often don't know they have asked for it but have done so by downloading other programs, visiting infected sites, and so on.

The spyware program monitors the user's activity and responds by offering unsolicited pop-up advertisements (sometimes known as _adware_), gathers information about the user to pass on to marketers, or intercepts personal data, such as credit card numbers.

#### Cryptominers

With the rise of bitcoin, so came the rise of cryptominers. A cryptominer is typically a purpose-built device that grinds out cryptographic computations. When the computation is balanced a cryptocoin is created and equates to real money, such as Bitcoin, Ethereum, and Dogecoin, just to name a few. A cryptominer does not always have to be a dedicated purpose-built device, it can also be a distributed group of computers called a cryptopool.

Malware in the form of cryptominers became very popular, because it is a very lucrative way for threat agents to make money. The problem is that the threat agents uses your computer to grind out the computations. The most common way a threat agent will run a cryptominer remotely is with JavaScript embedded on a malicious web page. Threat agents have also been known to create viruses in which the payload (cryptominer) uses your video card to grind out the computations. However, the JavaScript variant is more common to find in the wild.

#### Viruses

Viruses can be classified as polymorphic, stealth, retrovirus, multipartite, armored, companion, phage, and macro viruses. Each type of virus has a different attack strategy and different consequences.

##### Note 

Estimates for losses due to viruses are in the billions of dollars. These losses include financial loss as well as lost productivity.

The following sections introduce the symptoms of a virus infection, explain how a virus works, and describe the types of viruses you can expect to encounter and how they generally behave. We'll also discuss how a virus is transmitted through a network and look at a few hoaxes.

#### Botnets

A _botnet_ is a group of zombies, which sounds like a ridiculous beginning to a horror movie. When malware infects a computer, its purpose is often to lie dormant and await a command from a command-and-control server. When this happens, the computer is considered a zombie. When enough infected computers (zombies) check in, the _threat agent_ will send a command to the command-and-control server, and the botnet of zombies will work on the task. Often the task is to launch a malicious DDoS attack or to send spam. DDoS will be covered later in this chapter.

#### Worms

A _worm_ is different from a virus in that it can reproduce itself, it's self-contained, and it doesn't need a host application to be transported. Many of the so-called viruses that make the news are actually worms. However, it's possible for a worm to contain or deliver a virus to a target system.

By their nature and origin, worms are supposed to propagate, and they use whatever services they're capable of using to do that. Early worms filled up memory and bred inside the RAM of the target computer. Worms can use TCP/IP, email, Internet services, or any number of possibilities to reach their target.

