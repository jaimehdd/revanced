#!/bin/bash
# Instagram
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

echo "REPO_NAME=instagram-revanced" >> $GITHUB_ENV

# official ReVanced
revanced_dl
# Patch Instagram:
get_patches_key "instagram"
get_apkpure "com.instagram.android" "instagram-arm64-v8a" "instagram-android/com.instagram.android" "Bundle"
patch "instagram-arm64-v8a" "revanced"
