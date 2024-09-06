#!/bin/bash
# Export OUTPUT_FILE to make it available to the SSH sessions
OUTPUT_FILE="$(date +"%m.%d.%Y")_status.txt"
export OUTPUT_FILE
RAINIERPASSWORD="20-WST-3n?1n33R"
SINTELAPASSWORD="5intela_440"

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
echo "OptoDAS" >> $OUTPUT_FILE

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
echo "###################" 
echo "Connecting to Operator on OptoDAS..."
ssh -T -i "$SSH_KEY_PATH" operator@10.158.15.97 << 'EOF'
if [ $? -ne 0 ]; then
    echo "SSH connection failed."
    exit 1
fi

echo "Connected to Operator" 
echo " "
sleep 1.0

echo "Device API Status:"
curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.State'
sleep 0.5
echo " "
echo "Storage Used: "
curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.StorageUtilisation * 100 | tostring + "%"' 
echo "...at location: "
curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.Location' 
sleep 0.5
echo " "

curl -s http://10.158.15.97:10532/optodas/api/v2/status
daily_status=$(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.State')
storage_status=$(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.StorageUtilisation * 100 | tostring + "%"')
location_status=$(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.Location' )

echo " "
echo "Proceed to Filesystem Checks."
sleep 1.0
echo " "
echo "###################" 
echo "   Mount Points:   "
echo "###################" 
cd /mnt/
ls

for dir in $(ls); do
    if [ -d "$dir" ]; then
        echo " "
        echo "###" 
        echo "$dir snapshot:"
        df -H "$dir"
        echo " "

        echo "  Listing last 10 items in $dir:"
        if [ -z "$(ls -A "$dir")" ]; then
            echo "  NO_ITEMS"
        else
            ls "$dir" | tail | sed 's/^/    /'
        fi
        echo ""
    fi
done

echo "" 
echo "###" 
echo "Logging out from OptoDAS..."
echo "###" 
echo " "
logout
EOF

# Parse the captured output to extract the variables
daily_status=$(echo "$ssh_output" | grep "DAILY_STATUS" | cut -d '=' -f 2)
storage_status=$(echo "$ssh_output" | grep "STORAGE_STATUS" | cut -d '=' -f 2)
location_status=$(echo "$ssh_output" | grep "LOCATION_STATUS" | cut -d '=' -f 2)

# Append the captured variables to the output file
echo "Daily Status: $daily_status" >> $OUTPUT_FILE
echo "Storage Status: $storage_status" >> $OUTPUT_FILE
echo "Location Status: $location_status" >> $OUTPUT_FILE


echo "###################"
echo "      Rainier     "
echo "###################"
echo "Rainier" >> $OUTPUT_FILE
echo "Onyx" >> $OUTPUT_FILE

echo "Requires a connection to..." 
echo "a. Tunnelblick VPN, Gator Config" 
echo " "
read -p "Are you connected to the proper network? (y/n): " vpn_status
if [[ "$vpn_status" == "y" || "$vpn_status" == "Y" ]]; then
    echo "Proceed to SSH."
    sleep 1.0
else
        echo "Please connect to the UW Network before SSH."
        exit 1
fi

echo "###################" 
echo "   "
echo "Connecting to Sintela at Rainier..."
sleep 1.0
sshpass -p "$SINTELAPASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 10022 -o SendEnv=OUTPUT_FILE sintela@166.144.144.149 << 'EOF'

echo "Proceed to Filesystem Checks."
sleep 1.0
echo " "
echo "###################" 
echo "   Mount Points:   "
echo "###################" 
df -H /mnt/extSSD1 /mnt/extSSD2 /mnt/extSSD3

cd /mnt/
for dir in */; do
    if [ -d "$dir" ]; then
        echo " "
        echo "###" 
        echo "$dir snapshot:"
        

        echo "  Listing last 10 items in $dir:"
        if [ -z "$(ls -A "$dir")" ]; then
            echo "  NO_ITEMS"
        else
            echo ls "$dir" | tail | sed 's/^/    /'
            if ls "$subdir" | tail | grep -q "isRecording.txt"; then
                echo "    Recording to $subdir in $dir"
            fi
        fi
        echo ""

        # Loop through subdirectories
        for subdir in "$dir"rainier*; do
            if [ -d "$subdir" ]; then
                echo "  Listing last 10 items in subdirectory $subdir:"
                if [ -z "$(ls -A "$subdir")" ]; then
                    echo "    NO_ITEMS"
                else
                    ls "$subdir" | tail | sed 's/^/    /'
                fi
                echo ""
            fi
        done
    fi
done



logout
EOF

echo " "
echo "####################"
echo "Connecting to Rainier NAS..."
sleep 1.0
sshpass -p "$RAINIERPASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 20022 -o SendEnv=OUTPUT_FILE -o LogLevel=ERROR -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null sintela@166.144.144.149 << 'EOF'
if [ $? -ne 0 ]; then
    echo "SSH connection failed."
    exit 1
fi
echo " "
echo "Connected to NAS"
echo ""
df -H
echo " "
echo "Most recent files:"
ls -1 /volume1/Public/rainier | tail
echo " "

echo "Logging out..."
logout
EOF
echo " "
##
echo "###################"
echo "       Alaska     "
echo "###################"
echo "Alaska" >> $OUTPUT_FILE
echo "Temporarily Down"
echo " "
echo " "
echo "Checks completed."
echo " "
echo "Output written to $OUTPUT_FILE"


##################
## Template Alaska
## To ssh into the GPU server, use "ssh -p 27531 user@192.168.10.6" when you are already ssh'd into the alaska_das server
## If you're sshing from cascadia into rad in order to transfer data to/from the alaska_das server,
## the default configuration of ssh on cascadia may require you to add a -4 to force it to use IPV4 for the port forwarding. E.g.: ssh -p 27531 -4 -L 8888:192.168.128.2:27531 efwillia@rad.ess.washington.edu
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
