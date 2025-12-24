#!/bin/bash
# Tumblr
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
# Patch Tumblr:
get_patches_key "tumblr"
get_apk "com.tumblr" "tumblr" "tumblr" "tumblr-inc/tumblr/tumblr-social-media-art" "Bundle_extract"
split_editor "tumblr" "tumblr"
patch "tumblr" "revanced"
# Patch Tumblr Arm64-v8a:
get_patches_key "tumblr"
split_editor "tumblr" "tumblr-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
patch "tumblr-arm64-v8a" "revanced"
