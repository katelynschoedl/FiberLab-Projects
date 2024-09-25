#!/bin/bash
echo "###########################################"
echo "              Daily Status                 "
echo "###########################################"
# Export OUTPUT_FILE to make it available to the SSH sessions
OUTPUT_FILE="$(date +"%m.%d.%Y")_status.txt"
#OUTPUT_FILE="temp.txt"
export OUTPUT_FILE
echo "Date: $(date)" >  $OUTPUT_FILE

# Create an archive directory if it doesn't exist
ARCHIVE_DIR="archive-daily-status"
mkdir -p "$ARCHIVE_DIR"

# Move old reports to the archive directory
find . -maxdepth 1 -name "*_status.txt" ! -name "$(date +"%m.%d.%Y")_status.txt" -exec mv {} "$ARCHIVE_DIR" \;

# Defining Environment Variables
# Path to your SSH private key
SSH_KEY_PATH="$HOME/.ssh/id_rsa"
# Ensure SSH_AUTH_SOCK is set
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"
fi

# Define the passwords for the SSH sessions
RAINIERPASSWORD="20-WST-3n?1n33R"
SINTELAPASSWORD="5intela_440"

# Define the passwords for the machines
# Define the IP addresses for the machines
# Define the URLs for the Dashboards

echo "Starting..."
echo " "
echo "Your Device Status:"
wifi=n
tunnelblick_vpn=n
husky_vpn=n

###########################################"
###########################################"
# Check WIFI network
current_ssid=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
if [[ "$current_ssid" == "University of Washington" ]]; then
    echo "# Connected to the University of Washington WiFi network."
    wifi=y
else
    echo "# Not connected to the University of Washington WiFi network."
fi
###########################################"
###########################################"
# Check if VPN processes are running
openvpn_processes=$(ps aux | grep tunnelblick | grep -v grep)
if [ -n "$openvpn_processes" ]; then
    echo "# OpenVPN process is running:"
    echo "  # Connected to Tunnelblick VPN."
    tunnelblick_vpn="y"
else
    echo "# OpenVPN process is not running."
    tunnelblick_vpn="n"
fi
openvpn_processes=$(ps aux | grep BIG-IP | grep -v grep)
if [ -n "$openvpn_processes" ]; then
    echo "# Husky VPN process is running:"
    echo "  # Connected to UW VPN."
    husky_vpn="y"
else
    echo "# Husky VPN process is not running."
    husky_vpn="n"
fi
echo " "
###########################################"
###########################################"
echo " "
echo "###################"
echo "      Onyx 0204    "
echo "###################"
echo " " >> $OUTPUT_FILE
echo "Onyx 0204" >> $OUTPUT_FILE
echo "  {" >> $OUTPUT_FILE

echo "Requires a connection to..." 
echo "a. Tunnelblick VPN, Gator Config" 
echo " "
echo "Checking network connection..."
if [ $tunnelblick_vpn == y ]; then
    echo "Proceeding to SSH."
    sleep 1.0
else
    echo "Are you connected to the Tunnelblick VPN?" 
    echo "Please connect to the Gator Config before running again."
    echo "See PNSN Wiki for support."
    exit 1
fi
echo "###################" 
echo "   "
echo "Connecting to Sintela at Rainier..."
###########################################"
###########################################"
sshpass -p "$SINTELAPASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 10022 sintela@166.144.144.149 << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
echo "Device Status: "
sleep 1.0
echo "Cable Location: rainier"
#df -H /mnt/extSSD1 /mnt/extSSD2 /mnt/extSSD3

cd /mnt/
echo " "
echo "Devices and Space Remaining:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed 's/^/    /' | while read -r line; do
    name=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    type=$(echo $line | awk '{print $3}')
    mountpoint=$(echo $line | awk '{print $4}')
    if [[ "$mountpoint" != "MOUNTPOINT" && "$mountpoint" == *"/"* ]]; then
        df_output1=$(df -h "$mountpoint" | awk 'NR==2 {print $2}')     
        df_output2=$(df -h "$mountpoint" | awk 'NR==2 {print $3}') 
        df_output3=$(df -h "$mountpoint" | awk 'NR==2 {print $4}') 
        # Function to convert sizes to gigabytes
        convert_to_gb() {
            size=$1
            unit=${size: -1}
            value=${size::-1}
            case $unit in
                T) echo $(awk "BEGIN {print $value * 1024}") ;;
                G) echo $value ;;
                M) echo $(awk "BEGIN {print $value / 1024}") ;;
                K) echo $(awk "BEGIN {print $value / (1024 * 1024)}") ;;
                *) echo $value ;;
            esac
        }
        df_output1_gb=$(convert_to_gb $df_output1)
        df_output2_gb=$(convert_to_gb $df_output2)
        df_output3_gb=$(convert_to_gb $df_output3)
        used_percentage=$(awk "BEGIN {print ($df_output2_gb / $df_output1_gb) * 100}")
        echo "$line -> Used: $df_output2, Remaining: $df_output3, $used_percentage% FULL"
    else
        echo "$line"
    fi
done
logout
EOF
echo "  }" >> $OUTPUT_FILE

##################################################
sshpass -p "$RAINIERPASSWORD" ssh -T -i "$SSH_KEY_PATH" -p 20022 sintela@166.144.144.149 << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
sleep 1.0

if [ $? -ne 0 ]; then
    echo "SSH connection failed."
    exit 1
fi
echo "Connected to NAS"
echo ""
df -H
echo ""
cd /volume1/Public/

echo "Most recent files:"
ls /volume1/Public/ 
echo " "
for dir in */; do
    if [ -d "$dir" ]; then
        echo "$dir:"
        cd "$dir"
        echo "  Last 10 items in $dir:"
        if [ -z "$(ls -A "$dir")" ]; then
            echo "  NO_ITEMS"
        else
            ls "$dir" | tail | sed 's/^/    /'
            if ls "$dir" | tail | grep -q "isRecording.txt"; then
                echo "    Recording to $dir"
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
##################################################
echo " " >> $OUTPUT_FILE
echo " "

###########################################"
###########################################"
echo " "
echo "###################"
echo "      Onyx 0186    "
echo "###################"
echo " " >> $OUTPUT_FILE
echo "Onyx 0186" >> $OUTPUT_FILE
echo "  {" >> $OUTPUT_FILE

###########################################"
###########################################"

echo "###################"
echo "       Onyx @AK    "
echo "###################"
echo " " >> $OUTPUT_FILE
echo "Onyx @AK" >> $OUTPUT_FILE
echo "  {" >> $OUTPUT_FILE
echo " "


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


echo "OpenSense Router Port forward..."
ssh -p 27531 -L 8443:192.168.128.2:443 kschoedl@rad.ess.washington.edu << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
echo df -hT 
EOF
open -a "Google Chrome" https://127.0.0.1:8443/?url=/dashboard/


echo "Connecting to RAD (Gateway Server)..."
ssh -p 27531 kschoedl@rad.ess.washington.edu << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
echo df -hT

echo "Connecting to Alaska DAS..."
ssh -p 27531 kschoedl@192.168.128.2 << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
echo df -hT 

echo "Connecting to Onyx 0203..."
ssh sintela@192.168.10.5 << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
echo df -hT 



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

###########################################"
###########################################"

echo "###################"
echo "       OptoDAS     "
echo "###################"  
echo " " >> $OUTPUT_FILE
echo "OptoDAS" >> $OUTPUT_FILE
echo "  {" >> $OUTPUT_FILE

echo "Requires a connection to..." 
echo "a. UW Network Without UW VPN, Tunnelblick is OK" 
#        wifi="y", husky_vpn="n"
echo "b. External Network with UW VPN, Tunnelblick is OK"
#        wifi="n", husky_vpn="y"
echo "c. Lab Ethernet Connection"
#        wifi="y"
echo " "
echo "Checking network connection..."
if [[ $wifi == y && $husky_vpn == n ]] || [[ $wifi == n && $husky_vpn == y ]]; then
    echo "Proceeding to SSH."
    sleep 1.0
else
    echo "Are you connected to the UW wifi, or to another network with UW VPN turned on?" 
    echo "Please connect to the UW Network before running again."
    exit 1
fi
echo "###################" 
echo "Connecting to Operator on OptoDAS..."
ssh -T -i "$SSH_KEY_PATH" operator@10.158.15.97 << 'EOF' | sed 's/^/    /' >> $OUTPUT_FILE
if [ $? -ne 0 ]; then
    echo "SSH connection failed."
    exit 1
fi
sleep 1.0
echo "Device Status: $(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.State')"
sleep 0.5
echo "Cable Location: $(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.Location' )"
sleep 0.5
echo "Storage Used on Active Mountpoint: $(curl -s http://10.158.15.97:10532/optodas/api/v2/status | jq -r '.StorageUtilisation * 100 | tostring + "%"')" 
echo " "
echo "Devices and Space Remaining:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | sed 's/^/    /' | while read -r line; do
    name=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    type=$(echo $line | awk '{print $3}')
    mountpoint=$(echo $line | awk '{print $4}')
    if [[ "$mountpoint" != "MOUNTPOINT" && "$mountpoint" == *"/"* ]]; then
        df_output1=$(df -h "$mountpoint" | awk 'NR==2 {print $2}')     
        df_output2=$(df -h "$mountpoint" | awk 'NR==2 {print $3}') 
        df_output3=$(df -h "$mountpoint" | awk 'NR==2 {print $4}') 
        # Function to convert sizes to gigabytes
        convert_to_gb() {
            size=$1
            unit=${size: -1}
            value=${size::-1}
            case $unit in
                T) echo $(awk "BEGIN {print $value * 1024}") ;;
                G) echo $value ;;
                M) echo $(awk "BEGIN {print $value / 1024}") ;;
                K) echo $(awk "BEGIN {print $value / (1024 * 1024)}") ;;
                *) echo $value ;;
            esac
        }
        df_output1_gb=$(convert_to_gb $df_output1)
        df_output2_gb=$(convert_to_gb $df_output2)
        df_output3_gb=$(convert_to_gb $df_output3)
        used_percentage=$(awk "BEGIN {print ($df_output2_gb / $df_output1_gb) * 100}")
        echo "$line -> Used: $df_output2, Remaining: $df_output3, $used_percentage% FULL"
    else
        echo "$line"
    fi
done
EOF
echo "  }" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Running checks on OptoDAS..."
echo "DONE"
echo " "
echo " "

##################################################

echo " "
echo "Checks completed."
echo " "
echo "Output written to $OUTPUT_FILE"