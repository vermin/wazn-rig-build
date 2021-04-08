#!/bin/bash

VERS="v1.00"

# Clear screen
clear

# Error Trapping with Cleanup
errexit() {
  # Draw 5 lines of + and message
  for i in {1..5}; do echo "+"; done
  echo -e "\e[91mError raised! Cleaning Up and Exiting.\e[39m"

  # Remove _source directory if found.
  if [ -d "$SCRIPTPATH/_source" ]; then rm -r $SCRIPTPATH/_source; fi

  # Remove wazn-rig directory if found.
  if [ -d "$SCRIPTPATH/wazn-rig" ]; then rm -r $SCRIPTPATH/wazn-rig; fi

  # Dirty Exit
  exit 1
}

# Phase Header
phaseheader() {
  echo
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m- $1..."
  echo -e "\e[32m=======================================\e[39m"
}

# Phase Footer
phasefooter() {
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m $1 Completed"
  echo -e "\e[32m=======================================\e[39m"
  echo
}

# Intro/Outro Header
inoutheader() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo " WAZNRig Build Script $VERS"

  [ $BUILD -eq 7 ] && echo " for ARMv7"
  [ $BUILD -eq 8 ] && echo " for ARMv8"
  [ $BUILD -eq 0 ] && echo " for x86-64"

  echo " by vermin & DocDryden"
  echo

  if [[ "$DEBUG" = "1" ]]; then echo -e "\e[5m\e[96m++ DEBUG ENABLED - SKIPPING BUILD PROCESS ++\e[39m\e[0m"; echo; fi
}

# Intro/Outro Footer
inoutfooter() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo
}

# Error Trap
trap 'errexit' ERR

# Setup Variables
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BUILD=0
DEBUG=0

# Parse Commandline Arguments
[ "$1" = "7" ] && BUILD=7
[ "$1" = "8" ] && BUILD=8
[ "$1" = "d" ] && DEBUG=1
[ "$2" = "d" ] && DEBUG=1

# Opening Intro
inoutheader
inoutfooter

# Check for curl
if [[ $(which curl &>/dev/null; echo $?) != "0" ]] # Production
then
  echo "Warning: CURL not found."
  echo
  echo "This script uses CURL to check for updates."
  echo
  read -r -p "Do you want to continue without checking? (not recommended) [y/N] " response
  curlresponse=${response,,}
  if [[ $curlresponse =~ ^(no|n| ) ]] || [[ -z $curlresponse ]]
  then
    echo
    echo "Note: This script can attempt to install CURL and try again."
    echo
    read -r -p "Would you like to install CURL and try again? (recommended) [Y/n] " response
    installresponse=${response,,}
    if [[ $installresponse =~ ^(yes|y| ) ]] || [[ -z $installresponse ]]
    then
      echo
      echo "Attempting to install CURL..."
      echo
      apt install curl -y
      echo
      echo "Restarting script..."
      echo
      exec $0
    else
      echo
      echo "Script Aborted."
      exit 0
    fi
  else
    echo
    echo "Continuing..."
    sleep 3
  fi
else

### Start Phase 6
PHASE="Dependencies"
phaseheader $PHASE

# Install required tools for building from source
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - apt update && apt upgrade -y\e[39m"
apt update && apt upgrade -y
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full curl -y\e[39m"
apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

### End Phase 6
phasefooter $PHASE

### Start Phase 5
PHASE="Backup"
phaseheader $PHASE
if [ -d "$SCRIPTPATH/wazn-rig" ]
then
  if [ -f "$SCRIPTPATH/wazn-rig/waznrig-build.7z.bak" ]
  then
    # Remove last backup archive
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm $SCRIPTPATH/wazn-rig/waznrig-build.7z.bak\e[39m"
    rm $SCRIPTPATH/wazn-rig/waznrig-build.7z.bak
    echo "waznrig-build.7z.bak removed"
  else
    echo "waznrig-build.7z.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/wazn-rig/waznrig.bak" ]
  then
    # Remove last backup binary
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm $SCRIPTPATH/wazn-rig/waznrig.bak\e[39m"
    rm $SCRIPTPATH/wazn-rig/waznrig.bak
    echo "waznrig.bak removed"
  else
    echo "waznrig.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/wazn-rig/waznrig-build.7z" ]
  then
    # Backup last archive
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mv $SCRIPTPATH/wazn-rig/waznrig-build.7z $SCRIPTPATH/wazn-rig/waznrig-build.7z.bak\e[39m"
    mv $SCRIPTPATH/wazn-rig/waznrig-build.7z $SCRIPTPATH/wazn-rig/waznrig-build.7z.bak
    echo "waznrig-build.7z renamed to waznrig-build.7z.bak"
  else
    echo "waznrig-build.7z doesn't exist - Skipping Backup..."
  fi
  if [ -f "$SCRIPTPATH/wazn-rig/waznrig" ]
  then
    # Backup last binary
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mv $SCRIPTPATH/wazn-rig/waznrig $SCRIPTPATH/wazn-rig/waznrig.bak\e[39m"
    mv $SCRIPTPATH/wazn-rig/waznrig $SCRIPTPATH/wazn-rig/waznrig.bak
    echo "waznrig renamed to waznrig.bak"
  else
    echo "waznrig doesn't exist - Skipping Backup..."
  fi
else
  # Make wazn-rig folder if it doesn't exist
  echo "Creating wazn-rig directory..."
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mkdir -p $SCRIPTPATH/wazn-rig\e[39m"
  mkdir -p $SCRIPTPATH/wazn-rig
fi

### End Phase 5
phasefooter $PHASE

### Start Phase 4
PHASE="Setup"
phaseheader $PHASE

# If a _source directory is found, remove it.
if [ -d "$SCRIPTPATH/_source" ]
then
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm -r $SCRIPTPATH/_source\e[39m"
  rm -r $SCRIPTPATH/_source
fi

# Make new source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mkdir $SCRIPTPATH/_source\e[39m"
mkdir $SCRIPTPATH/_source

# Change working dir to source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd $SCRIPTPATH/_source\e[39m"
cd $SCRIPTPATH/_source

# Clone WAZNRig from github into source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - git clone https://github.com/project-wazn/waznrig.git\e[39m"
git clone https://github.com/project-wazn/wazn-rig.git

# Change working dir to clone - Create build folder - Change working dir to build folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd wazn-rig && mkdir build && cd build\e[39m"
cd wazn-rig && mkdir build && cd build

### End Phase 4
phasefooter $PHASE

### Start Phase 3
PHASE="Compiling & Building"
phaseheader $PHASE

# Setup build enviroment
[ $DEBUG -eq 1 ] && [ $BUILD -eq 7 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
[ $BUILD -eq 7 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
[ $DEBUG -eq 1 ] && [ $BUILD -eq 8 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
[ $BUILD -eq 8 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
[ $DEBUG -eq 1 ] && [ $BUILD -eq 0 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release\e[39m"
[ $BUILD -eq 0 ] && cmake .. -DCMAKE_BUILD_TYPE=Release

# Bypass make process if debug is enabled.
if [[ "$DEBUG" = "1" ]]
then
  echo -e "\e[96m++ $PHASE - touch waznrig\e[39m"
  touch waznrig
else
  make
fi

# End Phase 3
phasefooter $PHASE

### Start Phase 2
PHASE="Compressing/Moving"
phaseheader $PHASE

# Compress built waznrig into archive
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - 7z a waznrig-build.7z $SCRIPTPATH/wazn-rig\e[39m"
7z a waznrig-build.7z $SCRIPTPATH/wazn-rig

# Copy archive to waznrig folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cp waznrig-build.7z $SCRIPTPATH/wazn-rig/waznrig-build.7z\e[39m"
cp waznrig-build.7z $SCRIPTPATH/wazn-rig/waznrig-build.7z

# Copy built waznrig to waznrig folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cp $SCRIPTPATH/_source/wazn-rig/build/waznrig $SCRIPTPATH/wazn-rig/waznrig\e[39m"
cp $SCRIPTPATH/_source/wazn-rig/build/waznrig $SCRIPTPATH/wazn-rig/waznrig

# End Phase 2
phasefooter $PHASE

# Start Phase 1
PHASE="Cleanup"
phaseheader $PHASE

# Change working dir back to root
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd $SCRIPTPATH\e[39m"
cd $SCRIPTPATH

# Remove source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm -r _source\e[39m"
rm -r _source
echo "Source directory removed."

# Create start-example.sh
if [ ! -f "$SCRIPTPATH/wazn-rig/start-example.sh" ]
then
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cat > $SCRIPTPATH/wazn-rig/start-example.sh <<EOF\e[39m"
cat > $SCRIPTPATH/wazn-rig/start-example.sh <<EOF
#! /bin/bash

screen -wipe
screen -dm $SCRIPTPATH/wazn-rig/waznrig -o <pool_IP>:<pool_port> -l /var/log/waznrig-cpu.log --donate-level 1 --rig-id <rig_name> -k --verbose
screen -r
EOF
  echo "start-example.sh created."

  # Make start-example.sh executable
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - chmod +x $SCRIPTPATH/wazn-rig/start-example.sh\e[39m"
  chmod +x $SCRIPTPATH/wazn-rig/start-example.sh
  echo "start-example.sh made executable."
fi

# End Phase 1
phasefooter $PHASE

# Close Out
inoutheader
echo " Folder Location: $SCRIPTPATH/wazn-rig/"
echo " Bin: $SCRIPTPATH/wazn-rig/waznrig"
echo " Example Start Script: $SCRIPTPATH/wazn-rig/start-example.sh"
echo
inoutfooter

# Clean exit of script
exit 0
