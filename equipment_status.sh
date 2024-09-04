#!/bin/bash
OUTPUT_FILE="$(date +"%m.%d.%Y")_status.txt"
RAINIERPASSWORD="20-WST-3n?1n33R"

# Path to your SSH private key
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Ensure SSH_AUTH_SOCK is set
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"
fi

echo "###########################################"
echo "              Daily Status                 "
echo "###########################################"
echo "Date: $(date)" >  $OUTPUT_FILE

echo "###################"
echo "       SeaDAS      "
echo "###################"  
echo "SeaDAS" >> $OUTPUT_FILE

echo "Requires a connection to..." 
echo "a. UW Network Without UW VPN, Tunnelblick is OK" 
echo "b. External Network with UW VPN, Tunnelblick is OK"
echo "c. Lab Ethernet Connection"
echo " "
read -p "Are you connected to the proper network? (y/n): " vpn_status
if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
    echo "Proceed to SSH."
    sleep 1.0
else
    read -p "Are you connected to another network with UW VPN turned on? (y/n): " vpn_status
    if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
        echo "You are connected to the UW VPN. Proceed to SSH."
        echo "Proceeding..."
        sleep 1.0
    else
        echo "Please connect to the UW Network before SSH."
        exit 1
    fi
fi
##
echo "###################" 
echo "Connecting to Operator on OptoDAS..."
ssh -T -i "$SSH_KEY_PATH" operator@10.158.15.97 << 'EOF'
if [ $? -ne 0 ]; then
    echo "SSH connection failed."
    exit 1
fi

echo "Connected to Operator" 
sleep 1.0
echo "Device API Status:"
sleep 0.5
curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.State'

curl -s http://10.158.15.97:10532/optodas/api/v2/status

echo " "
echo "Proceed to Filesystem Checks."
sleep 1.0
echo " "
echo "###################" 
echo "Mount Points:"
cd /mnt/

ls
echo "###################" 
for dir in $(ls); do
    if [ -d "$dir" ]; then
        echo " " 
        echo "$dir snapshot:"
        df -H "$dir"
        echo " "
        echo "Listing last 10 items in directory:"
        if [ -z "$(ls -A "$dir")" ]; then
            echo "NO_ITEMS"
        else
            ls "$dir" | tail
        fi
    fi
done
echo " "
echo "Logout SeaDAS"
echo " "
logout
EOF
sleep 1.0

echo "###################"
echo "       Rainier     "
echo "###################"
echo "Rainier" >> $OUTPUT_FILE

echo "Requires a connection to..." 
echo "a. Tunnelblick VPN, Gator Configuration" 
echo " "
read -p "Are you connected to the proper network? (y/n): " vpn_status
if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
    echo "Proceed to SSH."
    sleep 1.0
else
    echo "Connect to the Tunnelblick VPN."
    exit 1
fi
##


##
echo " "
echo "###################" 
echo " "
echo "Connecting to Sintela Onyx..."
PASSWORD="5intela_440"
sshpass -p "$PASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 10022 sintela@166.144.144.149 << 'EOF'

echo "Connected to Sintela"
sleep 1.0
echo " "
echo "Proceed to Filesystem Checks."
sleep 1.0
echo " "
echo "###################" 
echo "Mount Points:"
cd /mnt/
ls
echo "###################" 
for dir in $(ls); do
    # Check if it is a directory and if its name matches SSD1, SSD2, SSD3, or intSSD
    if [ -d "$dir" ] && [[ "$dir" =~ ^(extSSD1|extSSD2|extSSD3|intSSD)$ ]]; then
        echo " " 
        echo "$dir snapshot:"
        df -H "$dir"
        echo " "
        echo "Listing last 10 items in directory:"
        if [ -z "$(ls -A "$dir")" ]; then
            echo "NO_ITEMS"
        else
            ls "$dir" | tail
        fi
        echo ""
    fi
        
        # Check for directories and list their last 10 items 
        for subdir in "$dir"/rainier*; do
            if [ -d "$subdir" ]; then
                echo "Listing last 10 items in subdirectory: $subdir"
                if [ -z "$(ls -A "$subdir")" ]; then
                    echo "NO_ITEMS"
                else
                    ls "$subdir" | tail
                fi
                echo ""
            fi
        fi
    fi
done
echo "Logging out..."
logout
EOF

echo "Connecting to Rainier NAS..."
sleep 1.0
sshpass -p "$RAINIERPASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 20022 sintela@166.144.144.149  << 'EOF'
echo "Connected to NAS"
cd ./volume1/Public 
df -H
logout
EOF

echo " "
##
echo "###################"
echo "       Alaska     "
echo "###################"
echo "Alaska" >> $OUTPUT_FILE
echo "Temporarily Down"
echo 
echo "Check completed."

echo " "
echo " "
echo " "
echo "Output written to $OUTPUT_FILE"
echo " "
echo " "
echo " "




#echo "Connect to Tunnelblick VPN"
#read -p "Are you connected to the Gator Configuration? (y/n):" vpn_status
#if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
#    echo "You are connected to the Tunnelblick VPN, Gator Configuration."
#    # Add any commands or tasks that require VPN/WiFi connection here
#else
#    echo "You must be connected to the Tunnelblick VPN."
#    exit 1
#fi
##
#echo "UW WiFi Shortcut"
#read -p "Are you connected to the UW VPN? (y/n):" port_number
#if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
#    echo "SSH port shortcut will be used."
#    port_number=37531
#else
#    echo "Ok."
#    port_number=27531
#fi
##

#echo "Connecting to RAD (Gateway Server)..."
#ssh -p 27531 kschoedl@rad.ess.washington.edu
##Prompted to enter password
#echo "Logged in user @ RAD Gateway Server."
#echo "Proceeding to checks."
##Check structure and space
#df -h
####Filesystem      Size  Used Avail Use% Mounted on
####devtmpfs        4.0M     0  4.0M   0% /dev
####tmpfs           3.7G     0  3.7G   0% /dev/shm
####tmpfs           1.5G  138M  1.4G  10% /run
####/dev/sda3        25G  3.0G   22G  13% /
####/dev/sda1       966M  212M  689M  24% /boot
####tmpfs           758M  4.0K  758M   1% /run/user/39205
####tmpfs           758M  4.0K  758M   1% /run/user/39062
##
#echo "alaska_das_IP=192.168.10.3"
#echo "alaska_nas_IP= "
#echo "alaska
##Connect to Alaska DAS Server with Device IP Address
#ping -c 10 $alaska_das_IP.ess.washington.edu > /dev/null &
#wait $!
#if [ $? -eq 0 ]; then
#    echo "Server $alaska_das_IP is reachable."
#else
#    echo "Server $alaska_das_IP is not reachable."
#fi
#Connect to alaska server (alaska_das) with password
#sshpass -p "$pass" ssh -p $port $user@$alaska_das_IP
#df -h
#Connect to NAS / QNAP Data
#temp_user=sintela
#temp_pass=5intela_440
#http://rad.ess.washington.edu:38080/cgi-bin/
##Connect to Interrogator
#sshpass -p "$temp_pass" ssh $temp_user@$alaska_das_IP

#NAS
#ONYX
###########################################
#Check if you can ping the storage servers
#ping pnwstore.ess.washington.edu
#ping cascadia.ess.washington.edu
#ping marine1.ess.washington.edu
#ping petasaur.ess.washington.edu
#ping siletzia.ess.washington.edu
#ping dasway.ess.washington.edu


########### Stuff
#!/bin/sh
####!!keep private!!
#ak_ip=''
#-------------------------#
#       Field Sites       #
#-------------------------#

##Alaska-------------------------------------------------------
#1. Connect to Cascadia
#Access Sintela Onyx
## To ssh into the GPU server, use "ssh -p 27531 user@192.168.10.6" when you are already ssh'd into the alaska_das server
## If you're sshing from cascadia into rad in order to transfer data to/from the alaska_das server,
## the default configuration of ssh on cascadia may require you to add a -4 to force it to use IPV4 for the port forwarding. E.g.: ssh -p 27531 -4 -L 8888:192.168.128.2:27531 efwillia@rad.ess.washington.edu



#MtRainier (Onyx)------------------------------------------------------
#1. Connect through Tunnelblick VPN

#if [ -z "$OPENVPN_PROCESS" ]; then
#    echo "/n OpenVPN is not running. Please connect to Tunnelblick via OpenVPN and try again."
#    exit 1
#else
#    echo "$OPENVPN_PROCESS"
#    echo "Connected to OpenVPN."
#fi

#Open terminal window and enter password for sintela@ONYX-0204
#osascript <<EOF
#tell application "Terminal"
##    try
#        do script "ssh -p 10022 sintela@166.144.144.149"
#        delay 15
#        do script "5intela_440"
#        delay 10

        ## check on which disk you are recording

#        do script "cd /mnt/extSSD1/rainier/"
#        delay 1
#       do script "if grep -q 'isRecording.text' ls | tail; then echo 'Recording on extSSD1'; fi"
#        delay 2
#        do script "cd ../../mnt/extSSD2/rainier"
#        delay 1
#        do script "if grep -q 'isRecording.text' ls|tail; then echo 'Recording on extSSD2'; fi"

        ##check how much space is remaining
        ## store in temp file and echo text

#        do script "df -H /mnt/extSSD1 /mnt/extSSD2 /mnt/extSSD3 > /tmp/rainier_output.txt; cat /tmp/rainier_output.txt"



        ## do script new tab
        ## do script "rsync -Rrva ./rainier /mnt/synology"
        ## delay 1
        ## press control +a, d

        ## do script "screen -d"  ##detatch from terminal and continue running in the background
        ## delay 1
        ## do script "logout"
        ## delay 2
        ## do script "ssh -p 20022 sintela@166.144.144.149"
        ## delay 2
        ## do script "20-WST-3n?1n33R"
        ## delay 2
 #       do script "ls -1 /volume1/Public/rainier | wc -l"
        ## ls -1 /volume1/Public/rainier | wc -l  to check the number of files on NAS

#    end try
#end tell
#EOF   #!/bin/sh


#-------------------------#
#         Servers         #
#-------------------------#

#PNWStore-------------------------------------------------------
#"$user@pnwstore1.ess.washington.edu"


#Cascadia
#ssh kschoedl@cascadia.ess.washington.edu

##Sermeq-------------------------------------------------------
#SermeqPass="xxx"
#ssh "$user@sermeq.ess.washington.edu"
## personal password
#df -h
#logout
#EOF

##Petasaur-------------------------------------------------------

##Marine1-------------------------------------------------------

##DASWay

#-------------------------#
#        Machines         #
#-------------------------#

##Silixa XT DTS SN-XT21032-------------------------------------------------------

##Sintela Onyx SN-0186-------------------------------------------------------
#SintelaUser="Sintela"
#SintelaPass="20-WST-3n?1n33R"
#sh -p 10022 sintela®166.144.144.149
#SintelaIP="192.168.10.186"
#SintellaSSHPWD="5intela_440"
#$SintelaPass
#http://166.144.144.149:18081/login/
#yes | logout

##OptoDAS LTT_SN042-------------------------------------------------------

#-------------------------#
#         Servers         #
#-------------------------#

#PNWStore-------------------------------------------------------
#"$user@pnwstore1.ess.washington.edu"

#Cascadia
#ssh kschoedl@cascadia.ess.washington.edu

##Sermeq-------------------------------------------------------
#SermeqPass="xxx"
#ssh "$user@sermeq.ess.washington.edu"
### personal password
#cd /data
#df -h
#logout
#EOF

##Petasaur-------------------------------------------------------

##Marine1-------------------------------------------------------

##DASWay



#!/bin/bash
# Add your script logic here
#date
#name = $date
#touch ./($name)_status.txt
# Run a command
#kschoedl@Katelyns-MacBook-Pro ~ % 
#kschoedl@Katelyns-MacBook-Pro ~ % ssh -p 27531 -L 8081:192.168.128.2:8081 rad.ess.washington.edu
#kschoedl@rad.ess.washington.edu's password: 
#Last login: Mon Aug 26 17:09:52 2024 from 10.102.11.67
#ssh -p 27531 -L 8081:192.168.128.2:8081 rad.ess.washington.edu
#Onyx Dashboard: http://127.0.0.1:8081/recording/
#[kschoedl@rad ~]$ 
#[kschoedl@rad ~]$ channel 3: open failed: connect failed: Connection timed out
#channel 4: open failed: connect failed: Connection timed out
#channel 5: open failed: connect failed: Connection timed out
#^C
#[kschoedl@rad ~]$ 
# Execute a script
#/path/to/your/script.sh
# Add any other commands or scripts you want to run as part of the cron job

#EOF