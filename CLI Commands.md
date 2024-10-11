# nmap:
- most effective six-probe combination host discovery
	-  `sudo nmap -sS -p- -PE -PP -PS80,443 -PA3389 -PU40125 -A -T4 -oA <filename>-%D <*target ip*>`
	- `nmap -sS -p- -PE -PP -PS80,443 -PA3389 -PU40125 -A -T4 -oA avatartcpscan-%D 192.168.0.1/24`
- Quick find help
`nmap -h | grep -e '-P'`

- scan shortcuts:
	- ( -A )
		- OS & version detection
	- 
	- Null scan (`-sN`)
		- Does not set any bits (TCP flag header is 0)
	- FIN scan (`-sF`)
		- Sets just the TCP FIN bit.
	- Xmas scan (`-sX`)
		- Sets the FIN, PSH, and URG flags, lighting the packet up like a Christmas tree.
	- ACK scan ( -sA )
		- One of the most interesting uses of ACK scanning is to differentiate between stateful and stateless firewalls.
	- TCP Maimon Scan ( -sM )
		- FIN/ACK
		- RFC 793: An RST packet should be generated in response to such a probe whether the port is open or closed
	- Idle Scan ( -sI )
		- TCP. 
			- `nmap -Pn -p- -sI kiosk.adobe.com www.riaa.com`
		1. Probe the zombie's IP ID and record it.
		2. Forge a SYN packet from the zombie and send it to the desired port on the target. Depending on the port state, the target's reaction may or may not cause the zombie's IP ID to be incremented.
		3. Probe the zombie's IP ID again. The target port state is then determined by comparing this new IP ID with the one recorded in step 1.
	- #### Scripting examples
		- nmap -sC example.com
			- A simple script scan using the default set of scripts.
		- nmap -sn -sC example.com
			- A script scan without a port scan; only host scripts are eligible to run.
		- nmap -Pn -sn -sC example.com
			- A script scan without host discovery or a port scan. All hosts are assumed up and only host scripts are eligible to run.
		- nmap --script smb-os-discovery --script-trace example.com
			- Execute a specific script with script tracing.
		- nmap --script snmp-sysdescr --script-args creds.snmp=admin example.com
			- Run an individual script that takes a script argument.
		- nmap --script *mycustomscripts*,safe example.com
			- Execute all scripts in the `mycustomscripts` directory as well as all scripts in the `safe` category.
# Regex 
- https://www.regexr.com
- [...]
	- Matches a single instance of a character within the brackets, such as: 
		- [a-z], [A-Z]
		- [0-9], [a-zA-Z0-9]
		- [\s] (white space)
		- [\d] (single digit)
- +
	- Matches one or more occurrences and is called a quantifier, such as \d+ matching one or more digits
- *
	- Matches zero or more occurrences, such as \d* matching zero or more digits
- ?
	- Matches one or none times, such as \d? matching zero or one digits
- { }
	- Matches the number of times within the curly braces, such as \d{3} matching three digits or \d{7-10} matching seven to ten digits
- ( … )
	- Defines a matching group with a regex sequence placed within the parentheses, and then each group can subsequently be referred to by \1 for the first group, \2 for the second, and so on
- |
	- The OR logical operator to match conditions as “this or that”
- ^
	- The regex will only match at the start of a line when searching
- $
	- The regex will only match at the end of a line when searching



# Cronjobs
- crontab -e
- minute hour day month weekday <*command-to-execute*>

# Grep
- grep -F 192.168.1.10 access.log
	- grep "192.168.1.10" *
	- grep -r 192\.168\.1\.[\d]{1,3} .
	- grep -r 192\.168\.1\.[0-255] .
- -i (ignore case sensitivity)
- -v (return non-matching strings)
- -w (treat search strings as words)
- -c (return a count of matching strings only)
- -l (return names of files with matching lines)
- -L (return names of files without matching lines)



