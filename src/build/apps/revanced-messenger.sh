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
get_apkpure "com.facebook.orca" "messenger-arm64-v8a" "facebook-messenger/com.facebook.orca"
patch "messenger-arm64-v8a" "revanced"
