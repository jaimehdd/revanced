#!/bin/bash
# Facebook
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
# Patch Facebook:
echo "REPO_NAME=fb-rv" >> $GITHUB_ENV
# Arm64-v8a
export version="478.0.0.41.86"
get_patches_key "facebook"
get_apk "com.facebook.katana" "facebook-arm64-v8a" "facebook" "facebook-2/facebook/facebook" "arm64-v8a"
patch "facebook-arm64-v8a" "revanced"
