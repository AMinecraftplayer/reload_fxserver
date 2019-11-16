# reload_fxserver
Debian BASH script for for FiveM FXServer. Start, Stop, Status, Restart, Backup

Dependencies:
* FXServer      # FiveM modded GTAV Server
* Debian        # or similar UNIX system running BASH (most do, but I'm not going to test other OSs
* screen        # I prefer running screens and the script will requite modifcation to run without.
* tar           # I use tar with gzip compression for backups.
* crontab       # Optional, I use this to automate restart and backups at specific times. 
* MySQL/MariaDB # If you use this method of storing data on your FXserver

To install:

1) Download files from github.
2) Edit PATH in reload_fxserver.sh # Replace esx_server with your server user runing FXServer.
3) Edit messages to match your language...I shoud probably just upload current in english...
4) Edit ExcludeDatabases to match your DB's  
5) Make sure all the varibles match your folders and edit names how you like. Just don't use any other charachters then standard english alphapet A-Z and 0-9. Untested non the less.
6) 
