#!/bin/bash
# Youtube Extended Split
source src/build/utils.sh

# Download requirements
use_beta="${use_beta:-false}"

revanced_dl_beta(){
	dl_gh "revanced-patches revanced-cli" "inotia00" "prerelease"
}

revanced_dl(){
	if [ "$use_beta" = true ]; then
		revanced_dl_beta
	else
		dl_gh "revanced-patches revanced-cli" "inotia00" "latest"
	fi
}

revanced_dl
# Patch YouTube:
echo "REPO_NAME=yt-rve" >> $GITHUB_ENV
get_patches_key "youtube-revanced-extended"
get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
patch "youtube" "revanced-extended" "inotia"
# Split architecture Youtube:
get_patches_key "youtube-revanced-extended"
for i in {0..0}; do
	split_arch "youtube" "revanced-extended" "$(gen_rip_libs ${libs[i]})"
done
