# Windows EC2 instance hibernator
Some scripts to hibernate windows EC2 instances

To configure:
1. Create a SSH key pair.
2. Install a windows SSH a server (I used [http://www.freesshd.com/]:)
3. In your SSH server, configure a user that corresponds to an administrator (or with sufficent priviledges to put windows into hibernate), configure this user to used key based authentication.
4. In a Command Prompt "Run as Administrator": > powercfg.exe /hibernate
5. Test hibernate: > shutdown /h
6. Schedule your hibernate.sh and start.sh respectively
7. Save $$$
