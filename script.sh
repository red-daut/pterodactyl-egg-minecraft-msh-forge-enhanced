#!/bin/bash
# Forge Installation Script
#
# Server Files: /mnt/server
apt update -y # TODO
apt upgrade -y # TODO
apt install -y curl jq # TODO

if [[ ! -d /mnt/server ]]; then
  mkdir /mnt/server
fi

cd /mnt/server || exit 1

# Remove spaces from the version number to avoid issues with curl
# MSH_D_URL="https://msh.gekware.net/builds/egg/"
# FORGE_VERSION="1.12.2-14.23.5.2860" # TODO Remove this after testing
# MC_VERSION="1.12.2" # TODO Remove this after testing
FORGE_VERSION="$(echo "$FORGE_VERSION" | tr -d ' ')"
MC_VERSION="$(echo "$MC_VERSION" | tr -d ' ')"

if [ -z "${SERVER_JARFILE}" ]; then 
  SERVER_JARFILE=server.jar
fi

DL_URL=https://maven.minecraftforge.net/net/minecraftforge/forge/"${FORGE_VERSION}"/forge-"${FORGE_VERSION}"-installer.jar
curl -sSL -o installer.jar "${DL_URL}"

echo -e "Preparing to download forge version: ${FORGE_VERSION}\n"
echo -e "Download link is ${DL_URL}"

#Checking if downloaded jars exist
if [[ ! -f ./installer.jar ]]; then
  echo "!!! Error downloading forge version ${FORGE_VERSION} !!!"
  exit
else
  echo -e "installer.jar (forge version: ${FORGE_VERSION}) downloaded successfully"
fi

#Installing server
echo -e "Installing forge server. Please be patient. This can take some time...\n"
java -jar installer.jar --installServer > /dev/null || { echo -e "install failed using Forge version ${FORGE_VERSION} and Minecraft version ${MC_VERSION}"; exit 4; }

echo -e "Deleting installer.jar file\n"
rm -rf installer.jar

echo -e "Renaming forge-*.jar to server.jar\n"
mv forge-1.12.2-14.23.5.2860.jar server.jar

echo -e "Forge install completed successfully!\n" 

echo -e "Now installing MSH...\n"
arch=$(uname -m)

if [[ $arch == x86_64* ]]; then
    echo "MSH: X64 Architecture"
    echo -e "Running curl -o msh_server.bin ${MSH_D_URL}msh-linux-amd64.bin"
    curl -o msh_server.bin "${MSH_D_URL}"msh-linux-amd64.bin
  elif  [[ $arch == aarch64* ]]; then
    echo "MSH: aarch64 Architecture"
    echo -e "Running curl -o msh_server.bin ${MSH_D_URL}msh-linux-arm64.bin"
    curl -o msh_server.bin "${MSH_D_URL}"msh-linux-arm64.bin
  elif  [[ $arch == arm* ]]; then
    echo "MSH: ARM not V8 is not supported..."
  elif  [[ $arch == unknown* ]]; then
    echo "MSH: Architecture dedection failed..."
    return 1
fi

chmod u+x ./msh_server.bin

if [ ! -f server.properties ]; then
    echo -e "No MC server.properties file found, will now download barebones version for MSH to function"
    echo -e "Downloading MC server.properties"
    curl -o server.properties https://raw.githubusercontent.com/parkervcp/eggs/master/minecraft/java/server.properties
fi

if [ ! -f msh-config.json ]; then
    echo -e "No msh-config.json was found, will now download a new one..."
    echo -e "Downloading MSH msh-config.json"
    curl -o msh-config.json https://gist.githubusercontent.com/BolverBlitz/fa895e8062fcab7dd7a54d768843a261/raw/7224a0694a985ba1bff0b4fe9b44f2c79e9b495e/msh-config.json
fi

if [[ ! -f server.jar ]]; then
  echo -e "Dummy server.jar was created as no other server.jar file was found."
  echo "DUMMY" >> ./server.jar
fi