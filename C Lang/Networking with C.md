The TCP client takes an address (i.e. http://example.com) and uses the **getaddrinfo()** function to resolve it into a struct addrinfo structure. 
The client then creates a socket using a call to **socket()** 
- The Sockets API represents the connection using a ***file descriptor (fd)***.
The client then establishes the new TCP connection by calling ***connect()***. At this point, the client can freely exchange data using ***send()*** and ***recv()***.

![[Screenshot from 2025-03-15 16-00-02.png]]

![[Screenshot from 2025-03-15 16-34-15.png]]

