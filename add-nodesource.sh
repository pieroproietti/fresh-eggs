#!/usr/bin/env bash

need_nodesource() {
  NODE_MAJOR_VERSION="18"
  local available_versions
  available_versions=$(apt-cache policy nodejs 2>/dev/null | grep 'Candidate:' | awk '{print $2}' | cut -d'.' -f1)

  for version in $available_versions; do
    if [[ "$version" =~ ^[0-9]+$ ]] && [ "$version" -ge "$NODE_MAJOR_VERSION" ]; then
      echo "Available $version. No need to add nodesource repo."
      return 0 # nodejs 18 available
    fi
  done
  echo "We need to add nodesource repos"
  return 1
}

add_nodesource() {
  if curl -fsSL "https://deb.nodesource.com/setup_$NODE_MAJOR_VERSION.x" | bash -; then
    apt-get update
  else
    echo "Error addind repository https://deb.nodesource.com"
    exit 1
  fi
}

# main
need_nodesource

