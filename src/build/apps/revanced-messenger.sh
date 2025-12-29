#!/bin/bash
# Messenger
source src/build/utils.sh

# Download requirements
use_beta="${use_beta:-false}"

revanced_dl_beta(){
	dl_gh "revanced-cli" "revanced" "latest"
	dl_gh "revanced-patches" "revanced" "prerelease"
}

revanced_dl(){
	if [ "$use_beta" = true ]; then
		revanced_dl_beta
	else
		dl_gh "revanced-patches revanced-cli" "revanced" "latest"
	fi
}

revanced_dl
# Patch Messenger:
echo "REPO_NAME=messenger-revanced" >> $GITHUB_ENV
# Arm64-v8a
get_patches_key "messenger"
url="https://facebook-messenger.en.uptodown.com/android/download"
url="https://dw.uptodown.com/dwn/$(req "$url" - | $pup -p --charset utf-8 'button#detail-download-button attr{data-url}')"
req "$url" "messenger-arm64-v8a.apk"
patch "messenger-arm64-v8a" "revanced"
