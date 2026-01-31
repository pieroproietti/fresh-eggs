#!/usr/bin/env bash

function wait_for_apt {
  while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "Waiting for another process APT/DPKG to unlock..."
    sleep 5
  done
}

function ensure_node20() {
  NODE_MAJOR_VERSION="20"
  local available_versions
  available_versions=$(LANG=C apt-cache policy nodejs | awk '/Candidate:/ {print $2}' | cut -d'.' -f1)
  
  # refresh dei pacchetti
  wait_for_apt
  if ! apt update -qq; then
    exit 1
  fi

  title
  for version in $available_versions; do
    if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -ge "$NODE_MAJOR_VERSION" ]; then
      echo "Package nodejs $version is available..."
      sleep 2
      return 0
    fi
  done

  # add nodesource repository
  echo "We need to add nodejs>${NODE_MAJOR_VERSION} via nodesource repo"
  sleep 2
  wait_for_apt
  curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x" | bash -

  # free the LOCK before to end
  wait_for_apt
}
