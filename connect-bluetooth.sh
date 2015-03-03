
is_bluez_tools_installed=$(dpkg -s bluez-tools | grep "install ok installed")

if [ "$is_bluez_tools_installed" == "" ]
then
  echo "bluez-tools is not yet installed."
  echo "Prepare to install bluez-tools..."
  sudo apt-get --yes --force install bluez-tools > /dev/null
fi

device_list_output=$(bt-device -l | tail -n +2)
#printf %s "$device_list_output" | while IFS='\n\r' read -r device_list
device_list=()
IFS='
' 
# reference: https://coderwall.com/p/lhilrq
for dev in `echo "$device_list_output"`
do 
  echo "$dev"
  device_list+=("$dev")
done

device_name_list=()
device_mac_list=()
for device in "${device_list[@]}"
do
  device_name=$(echo $device | cut -d'(' -f 1 | sed 's/ $//g' )
  device_mac=$(echo $device | cut -d'(' -f 2 | cut -d')' -f 1)
  device_name_list+=("$device_name")
  device_mac_list+=("$device_mac")
done

echo "Candidates are:"
for ((i=0;i<"${#device_list[@]}";i++)) 
do
  echo "$i) ${device_name_list[$i]} (${device_mac_list[$i]})"
done

while true; do
  read -p "Connect to:" choice
  if [ "$choice" -ge 0 ] && [ "$choice" -lt ${#device_list[@]} ]
  then
    status=`bt-audio -c ${device_mac_list[$choice]}`
    if [[ "$status" == *connected* ]]; then
      echo "[Bluetooth] Successfully connected"
    else
      echo "[Bluetooth] Failed to establish connection"
    fi
    break
  else
    echo "Please choose from available options"
  fi
done
    

