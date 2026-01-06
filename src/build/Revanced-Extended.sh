#!/bin/bash
# Revanced Extended build
source src/build/utils.sh

# Download requirements
use_beta="${use_beta:-true}"

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

morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "latest"
	dl_gh "morphe-cli" "MorpheApp" "latest"
}

1() {
	revanced_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	get_patches_key "youtube-revanced-extended"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube" "Bundle_extract"
	# Patch Youtube Arm64-v8a
	split_editor "youtube" "youtube-arm64-v8a" "exclude" "split_config.armeabi_v7a split_config.x86 split_config.x86_64"
	patch "youtube-arm64-v8a" "revanced-extended" "inotia"
}
4() {
	revanced_dl
	# Patch YouTube:
	echo "APP_NAME=youtube" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	get_patches_key "youtube-revanced-extended"
	get_apk "com.google.android.youtube" "youtube" "youtube" "google-inc/youtube/youtube"
	patch "youtube" "revanced-extended" "inotia"
	# Split architecture Youtube:
	get_patches_key "youtube-revanced-extended"
	for i in {0..0}; do
		split_arch "youtube" "revanced-extended" "$(gen_rip_libs ${libs[i]})"
	done
}
2() {
	revanced_dl
	# Patch YouTube Music Extended:
	echo "APP_NAME=youtube-music" >> $GITHUB_ENV
	echo "VARIANT=rve" >> $GITHUB_ENV
	# Arm64-v8a
	get_patches_key "youtube-music-revanced-extended"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-arm64-v8a" "youtube-music" "google-inc/youtube-music/youtube-music" "arm64-v8a"
	patch "youtube-music-arm64-v8a" "revanced-extended" "inotia"
}
case "$1" in
    1)
        1
        ;;
    4)
        4
        ;;
    2)
        2
        ;;
esac