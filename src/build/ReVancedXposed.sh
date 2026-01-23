#!/bin/bash
# ReVancedXposed build
source ./src/build/utils.sh
#################################################
# Download requirements
j="i"
dl_gh "ReVancedXposed_Spot"$j"fy" "chsbuffer" "latest"
dl_gh "LSPatch" "JingMatrix" "latest"
#################################################

# Extract ReVancedXposed version from the downloaded APK filename
xposed_apk=$(ls ReVancedXposed*.apk 2>/dev/null | head -n1)
if [[ -n "$xposed_apk" ]]; then
    xposed_version=$(echo "$xposed_apk" | sed -E 's/ReVancedXposed[^0-9]*([0-9.]+)\.apk/\1/')
else
    xposed_version="unknown"
fi

echo "APP_NAME=spotify" >> $GITHUB_ENV
echo "VARIANT=rv" >> $GITHUB_ENV
echo "patch_version=$xposed_version" >> $GITHUB_ENV

# Patch Spotjfy:
get_apkpure "com.spot"$j"fy.music" "spotjfy" "spot"$j"fy-music-and-podcasts-for-android/com.spot"$j"fy.music"
green_log "[+] Patching apk file..."
java -jar lspatch.jar ./download/spotjfy.apk -k ./src/fiorenmas.ks fiorenmas fiorenmas fiorenmas -m ReVancedXposed*.apk -o ./release/
mv ./release/spotjfy-*-lspatched.apk ./release/spotjfy-ReVancedXposed.apk