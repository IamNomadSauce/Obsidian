The TCP client takes an address (i.e. http://example.com) and uses the **getaddrinfo()** function to resolve it into a struct addrinfo structure. 
- struct addrinfo {
               int              ai_flags;
               int              ai_family;
               int              ai_socktype;
               int              ai_protocol;
               socklen_t        ai_addrlen;
               struct sockaddr *ai_addr;
               char            *ai_canonname;
               struct addrinfo *ai_next;
           };

- TCP: ai_socktype = SOCK_STREAM
- UDP: ai_socktype = SOCK_DGRAM
- ai_flags = AI_PASSIVE
	- listen on any available network device
- IPv4: ai_family = AF_INET. AF_INET
- IPv6: ai_family = AF_INET6. AF_INET
	
The client then creates a socket using a call to **socket()** 
- The Sockets API represents the connection using a ***file descriptor (fd)***.
The client then establishes the new TCP connection by calling ***connect()***. At this point, the client can freely exchange data using ***send()*** and ***recv()***.

![[Screenshot from 2025-03-15 16-00-02.png]]

![[Screenshot from 2025-03-15 16-34-15.png]]

![[Screenshot from 2025-03-16 15-12-53.png]]![[Screenshot from 2025-03-17 20-33-06.png]]
#### select()
- multiplexing
- select() can check for all three conditions with one call:
- select(
		max_sockets+1, 
		&ready_to_read, 
		&ready_to_write,
		&excepted, 
		&timeout);
Before calling select(), first add our sockets into an fd_set. 
If we have three sockets: 
	socket_listen, 
	socket_a, 
	and socket_b, 
Add them to an fd_set, like this:
	FD_ZERO(&our_sockets);
	FD_SET(socket_listen, &our_sockets);
	FD_SET(socket_a, &our_sockets);
	FD_SET(socket_b, &our_sockets);
It is important to zero-out the fd_set using FD_ZERO() before use.