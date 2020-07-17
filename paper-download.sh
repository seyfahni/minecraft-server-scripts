#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -eq 0 ]]; then
	version="$(wget -q -O - https://papermc.io/api/v1/paper | jq -r '.versions[]' | sort -Vr | head -n1)"
else
	version="$1"
fi
if [[ $# -eq 1 ]]; then
	build="$(wget -q -O - https://papermc.io/api/v1/paper/"$version" | jq -r '.builds.latest')"
else
	build="$2"
fi
if [[ $# -gt 2 ]]; then
	exit 1
fi

echo "loading server binary for minecraft version $version build $build"

wget -q -O "paper-$version-$build.jar" "https://papermc.io/api/v1/paper/$version/$build/download"
