#!/bin/bash

m32="255.255.255.255"
m31="255.255.255.254"
m30="255.255.255.252"
m29="255.255.255.248"
m28="255.255.255.240"
m27="255.255.255.224"
m26="255.255.255.192"
m25="255.255.255.128"
m24="255.255.255.0"
m23="255.255.254.0"
m22="255.255.252.0"
m21="255.255.248.0"
m20="255.255.224.0"

# Check if the correct number of arguments is provided
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <filename> <ip_file>"
  exit 1
fi

filename="$1"
ip_file="$2"

# Check if the IP file exists
if [[ ! -f "$ip_file" ]]; then
  echo "IP file not found: $ip_file"
  exit 1
fi

# Declare arrays to store IP addresses and masks
declare -a ip_addresses
declare -a masks

# Read the IP file line by line
while IFS= read -r line; do
  # Extract the IP address and mask
  ip_address=$(echo "$line" | cut -d'/' -f1)
  mask=$(echo "$line" | cut -d'/' -f2)

  # Store the IP address and mask in the arrays
  ip_addresses+=("$ip_address")
  masks+=("$mask")

done <"$ip_file"

# Replace NETMASK values with corresponding variables mN
for ((i=0; i<${#masks[@]}; i++)); do
  mask="${masks[$i]}"
  case $mask in
    32) masks[$i]="${m32}";;
    31) masks[$i]="${m31}";;
    30) masks[$i]="${m30}";;
    29) masks[$i]="${m29}";;
    28) masks[$i]="${m28}";;
    27) masks[$i]="${m27}";;
    26) masks[$i]="${m26}";;
    25) masks[$i]="${m25}";;
    24) masks[$i]="${m24}";;
    23) masks[$i]="${m23}";;
    22) masks[$i]="${m22}";;
    21) masks[$i]="${m21}";;
    20) masks[$i]="${m20}";;
    *) echo "Invalid mask=$mask"; exit 1;;
  esac
done

# Print the IP addresses
for ((i=0; i<${#ip_addresses[@]}; i++)); do
  echo "IPADDR$((i+1))=${ip_addresses[$i]}"
done

# Print the masks
for ((i=0; i<${#masks[@]}; i++)); do
  echo "NETMASK$((i+1))=${masks[$i]}"
done

# Redirect the output to the specified file
{
  for ((i=0; i<${#ip_addresses[@]}; i++)); do
    echo "IPADDR$((i+1))=${ip_addresses[$i]}"
  done

  for ((i=0; i<${#masks[@]}; i++)); do
    echo "NETMASK$((i+1))=${masks[$i]}"
  done
} >> "$filename"

echo "Output added to $filename"

cat $filename  | cut -d '/' -f1 | while read ip; do ping -c1 $ip >/dev/null 2>&1 && echo $ip IS UP || echo $ip IS DOWN; done

systemctl restart network

while IFS='=' read -r key value; do
  if [[ $key == "IPADDR"* && $value =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    ip_address="${value}"
    ping -c 1 "$ip_address" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "IP ${ip_address} up"
    else
      echo "IP ${ip_address} down"
    fi
  fi
done < "$filename"
