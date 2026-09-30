#!/usr/bin/env bash


function wait_for_apt {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "Waiting for another process APT/DPKG to unlock..."
    sleep 5
  done
}

function ensure_node() {
  NODE_MAJOR_VERSION="22"
  ARCH=$(uname -m)

  # Check if node is already installed and version is >= NODE_MAJOR_VERSION
  if command -v node >/dev/null 2>&1; then
      CURRENT_NODE_VERSION=$(node -v | cut -d'.' -f1 | tr -d 'v')
      if [ "$CURRENT_NODE_VERSION" -ge "$NODE_MAJOR_VERSION" ]; then
          echo "Node.js $CURRENT_NODE_VERSION is already installed."
          return 0
      fi
  fi

  if [ "$ARCH" == "riscv64" ]; then
      echo "Detected riscv64 architecture."
      
      # Check if available via apt (unlikely for 22 on some distros, but check anyway)
      wait_for_apt
      if ! apt update -qq; then
         echo "apt update failed, continuing..."
      fi
      
      local available_versions
      available_versions=$(LANG=C apt-cache policy nodejs | awk '/Candidate:/ {print $2}' | cut -d'.' -f1)
      for version in $available_versions; do
        if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -ge "$NODE_MAJOR_VERSION" ]; then
          echo "Package nodejs $version is available via apt..."
          apt install -y nodejs
          return 0
        fi
      done

      # detailed fallback for riscv64
      echo "Node.js $NODE_MAJOR_VERSION not found via apt. Downloading unofficial build..."
      
      local NODE_URL="https://github.com/gounthar/unofficial-builds/releases/download/v22.22.0/nodejs-unofficial_22.22.0-1_riscv64.deb"
      local NODE_DEB="nodejs-unofficial_22.22.0-1_riscv64.deb"

      if curl -L -o "$NODE_DEB" "$NODE_URL"; then
          echo "Download successful."
      else 
          echo "Failed to download Node.js from $NODE_URL"
          exit 1
      fi

      echo "Installing Node.js via dpkg..."
      wait_for_apt
      dpkg -i "$NODE_DEB"
      rm "$NODE_DEB"
      echo "Node.js installed manually."
      return 0
  fi

  # Standard logic for other architectures (amd64, etc.)
  local available_versions
  available_versions=$(LANG=C apt-cache policy nodejs | awk '/Candidate:/ {print $2}' | cut -d'.' -f1)
  
  # refresh packages
  wait_for_apt
  if ! apt update -qq; then
    exit 1
  fi

  title
  for version in $available_versions; do
    if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -ge "$NODE_MAJOR_VERSION" ]; then
      echo "Package nodejs $version is available..."
      sleep 2
      # Ensure it is installed if available? The original script just returned 0 if available in policy?
      # The original script assumed if available in policy it might be enough or handled elsewhere? 
      # Actually the original script was 'ensure', usually implies installing. 
      # Looking at original: it returns 0 if available. It seemed to rely on a later install step or it being there.
      # To be safe and consistent with 'ensure', we should probably just continue to the repo add if NOT available.
      # If it IS available in apt policy efficiently, we assume `apt install nodejs` will happen or is happened.
      # BUT, let's keep the original logic's spirit: "if available, good". 
      # WAIT, the original script returned 0 if available in `apt-cache policy`. It didn't explicitly install it there?
      # Ah, line 23 check. If available, return 0.
      return 0
    fi
  done

  # add nodesource repository
  echo "We need to add nodejs>${NODE_MAJOR_VERSION} via nodesource repo"
  sleep 2
  wait_for_apt
  curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x" | bash -
  
  # Install after adding repo? The original script didn't explicitly install in the `ensure_node` function shown.
  # It setup the repo. Presumably the caller does `apt install nodejs`. 
  # However, for the riscv64 part I added explicit manual install because there is no repo to add.
  # For consistency, I will leave the nodesource part as just adding the repo (as per original).
  
  # free the LOCK before to end
  wait_for_apt
}
