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
version=$(curl -I -s -L -A "Mozilla/5.0 (Android 14; Mobile; rv:134.0) Gecko/134.0 Firefox/134.0" "$url" -o /dev/null -w '%{url_effective}' | grep -oE 'messenger-[0-9]+(-[0-9]+)+' | sed 's/messenger-//;s/-/./g')
echo "APP_VERSION=$version" >> $GITHUB_ENV
req "$url" "messenger-arm64-v8a.apk"
patch "messenger-arm64-v8a" "revanced"
