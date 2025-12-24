#!/bin/bash
# Youtube
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
# Patch YouTube:
echo "REPO_NAME=yt-rv" >> $GITHUB_ENV
get_patches_key "youtube-revanced"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
split_editor "youtube" "youtube"
patch "youtube" "revanced"
# Patch Youtube Arm64-v8a
get_patches_key "youtube-revanced"
split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
patch "youtube-arm64-v8a" "revanced"
