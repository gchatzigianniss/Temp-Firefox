#!/usr/bin/env bash
#
# Temp-Firefox Setup Script
# -------------------------
# 1. Checks for required tools (docker, wget).
# 2. Checks for X display (required on Linux for GUI).
# 3. Asks if the user wants to install the uBlock Origin extension.
# 4. Creates a Dockerfile (with or without the extension).
# 5. (If chosen) Creates an `extensions` folder and downloads the uBlock Origin XPI.
# 6. Builds and runs the container, then removes the image.
# 7. (If chosen) Deletes the `extensions/` folder.

########################################
# 1) Check if Docker is installed
########################################
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    echo "See: https://docs.docker.com/get-docker/"
    exit 1
else
    echo "Docker is installed."
fi

########################################
# 2) Check if wget is installed
########################################
if ! command -v wget &> /dev/null; then
    echo "wget is not installed. Please install wget (or modify script to use curl)."
    exit 1
else
    echo "wget is installed."
fi

########################################
# 3) Check for X display
########################################
if [[ -z "$DISPLAY" ]]; then
    echo "No DISPLAY variable found."
    echo
    read -p "Do you want to continue anyway? (y/N): " answer
    if [[ ! "$answer" =~ ^[Yy] ]]; then
        echo "Aborting..."
        exit 1
    fi
else
    echo "DISPLAY is set to $DISPLAY"
fi

########################################
# 4) Ask if user wants to install extension
########################################
echo
read -p "Do you want to install uBlock Origin extension? (y/N): " INSTALL_UBLOCK
INSTALL_UBLOCK="${INSTALL_UBLOCK:-N}"  # Default to "N" if empty

########################################
# 5) Create Dockerfile with or without extension
########################################

if [[ "$INSTALL_UBLOCK" =~ ^[Yy] ]]; then
    cat << 'EOF' > Dockerfile
FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
      firefox-esr \
      dbus \
      ttf-dejavu

RUN mkdir -p /usr/lib/firefox-esr/browser/extensions
COPY extensions/uBlock0@raymondhill.net.xpi \
     /usr/lib/firefox-esr/browser/extensions/uBlock0@raymondhill.net.xpi

CMD ["firefox-esr"]
EOF

    echo "Dockerfile created with uBlock Origin copy steps."
else
    cat << 'EOF' > Dockerfile
FROM alpine:latest

RUN apk update && \
    apk add --no-cache \
      firefox-esr \
      dbus \
      ttf-dejavu

CMD ["firefox-esr"]
EOF

    echo "Dockerfile created (no extensions)."
fi

########################################
# 6) If user wants extension create folder and download
########################################
EXTENSIONS_DOWNLOADED="false"

if [[ "$INSTALL_UBLOCK" =~ ^[Yy] ]]; then
    mkdir -p extensions
    cd extensions || exit 1

    # Download uBlock Origin XPI from GitHub
    wget -O "uBlock0@raymondhill.net.xpi" \
        https://github.com/gorhill/uBlock/releases/download/1.62.0/uBlock0_1.62.0.firefox.xpi

    if [[ $? -ne 0 ]]; then
        echo "Failed to download uBlock Origin. Check your network or the URL."
        exit 1
    fi

    cd ..
    EXTENSIONS_DOWNLOADED="true"
    echo "Downloaded uBlock Origin to extensions/uBlock0@raymondhill.net.xpi"
fi

########################################
# 7) Build the Docker image
########################################
echo
echo "Building the Docker image: 'temp-firefox'..."
docker build -t temp-firefox .
if [[ $? -ne 0 ]]; then
    echo "Docker build failed. Aborting."
    # Clean up the extensions folder if it exists
    if [[ "$EXTENSIONS_DOWNLOADED" == "true" ]]; then
        rm -rf extensions
    fi
    exit 1
fi
echo "Docker image 'temp-firefox' built successfully."

########################################
# 8) Run the container
########################################
echo
echo "Running the container. Close Firefox to exit..."
docker run -it --rm \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    temp-firefox

echo "Container exited."

########################################
# 9) Remove the Docker image
########################################
echo "Removing the 'temp-firefox' image..."
docker rmi temp-firefox
echo "Removed the 'temp-firefox' image."

########################################
# 10) If extension was installed remove folder
########################################
if [[ "$EXTENSIONS_DOWNLOADED" == "true" ]]; then
    rm -rf extensions
    echo "Removed the 'extensions' folder."
fi

########################################
# 11) Remove the Dockerfile
########################################
rm -f Dockerfile
echo "Removed the 'Dockerfile'."

echo
echo "End of script."
