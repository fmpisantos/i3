#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo: sudo $0"
  exit 1
fi

# echo "WARNING: This script will temporarily disable and re-enable your USB host controllers."
# echo "This may cause connected USB devices (including keyboard/mouse) to become unresponsive briefly."
# echo "Ensure you understand the implications before proceeding."
# read -p "Do you wish to continue? (y/N): " confirm
# if [[ ! "$confirm" =~ ^[yY]$ ]]; then
#   echo "Operation cancelled."
#   exit 0
# fi

echo "Identifying USB host controllers..."

# Use awk to parse lspci output and extract PCI address and driver.
# The awk script ensures the PCI address is in the full 0000:XX:YY.Z format
# and extracts the driver name.
usb_controllers=$(lspci -nnk | awk '
  /USB controller/ {
    pci_addr = $1
    # Prepend "0000:" if the domain is missing (common for lspci output)
    if (pci_addr !~ /^....:/) {
        pci_addr = "0000:" pci_addr
    }
  }
  /Kernel driver in use:/ {
    driver = $NF
    if (pci_addr != "" && driver != "") {
      print pci_addr "," driver
      pci_addr = "" # Reset for next block
      driver = ""
    }
  }
')

if [ -z "$usb_controllers" ]; then
  echo "No USB host controllers found or parsing failed."
  exit 1
fi

echo "Found the following USB host controllers to restart:"
echo "$usb_controllers" | sed 's/,/ (Driver: /; s/$/)/'
echo ""

# Loop through each identified controller and restart it
while IFS=',' read -r pci_address driver; do
  echo "--- Restarting controller: $pci_address (Driver: $driver) ---"

  # Check if the driver directory exists
  if [ ! -d "/sys/bus/pci/drivers/$driver" ]; then
    echo "Error: Driver directory /sys/bus/pci/drivers/$driver not found. Skipping."
    continue
  fi

  # Unbind the device
  echo "Unbinding $pci_address..."
  if echo "$pci_address" | tee "/sys/bus/pci/drivers/$driver/unbind" > /dev/null; then
    echo "Unbind successful."
  else
    echo "Error unbinding $pci_address. It might already be unbound or there's a permission issue."
  fi

  sleep 2 # Give devices a moment to detach

  # Bind the device
  echo "Binding $pci_address..."
  if echo "$pci_address" | tee "/sys/bus/pci/drivers/$driver/bind" > /dev/null; then
    echo "Bind successful."
  else
    echo "Error binding $pci_address. Check system logs for details."
  fi

  echo "---------------------------------------------------"
  sleep 3 # Give devices a moment to re-initialize before the next controller
done <<< "$usb_controllers"

echo "All identified USB host controllers have been processed."
echo "Please check your USB devices to ensure they are functioning correctly."
