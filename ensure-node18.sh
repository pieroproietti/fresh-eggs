#!/usr/bin/env bash

ensure_node18() {
  NODE_MAJOR_VERSION="18"
  local available_versions
  available_versions=$(apt-cache policy nodejs 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | cut -d'.' -f1)

  # refresh dei pacchetti
  apt-get update

  for version in $available_versions; do
    if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -ge "$NODE_MAJOR_VERSION" ]; then
      echo "Available $version. No need to add nodesource repo."
      return # nodejs 18 is available
    fi
  done

  # add nodesource repository
  echo "adding nodesource repo"
  curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x" | bash -
  apt-get update
}
