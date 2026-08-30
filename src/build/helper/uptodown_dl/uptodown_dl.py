#!/usr/bin/env python3
"""
Uptodown APK / XAPK Downloader
Adapted from: https://github.com/RookieEnough/Morphe-AutoBuilds
"""

import argparse
import json
import logging
import os
import re
import sys
import time
from urllib.parse import urlparse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger("uptodown_dl")


def get_session():
    """Return a requests session, preferring curl_cffi for Cloudflare TLS impersonation if available."""
    try:
        from curl_cffi import requests as cffi_requests
        logger.debug("Using curl_cffi with Chrome impersonation")
        return cffi_requests.Session(impersonate="chrome120")
    except ImportError:
        import requests
        s = requests.Session()
        s.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Sec-Ch-Ua": '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
            "Sec-Ch-Ua-Mobile": "?0",
            "Sec-Ch-Ua-Platform": '"Windows"',
            "Upgrade-Insecure-Requests": "1"
        })
        return s


def generate_possible_uptodown_names(app_name="", package=""):
    """Generate all possible Uptodown URL subdomain slugs from package/app name (from Morphe-AutoBuilds)."""
    possible_names = set()
    
    if app_name:
        possible_names.add(app_name)
        possible_names.add(app_name.replace("-", ""))
        possible_names.add(app_name.replace("-plus", "plus"))
        possible_names.add(app_name.replace("-", "_"))

    if package:
        package_dash = package.replace(".", "-")
        possible_names.add(package_dash)

        if package.startswith("com."):
            possible_names.add(package_dash.replace("com-", ""))
            parts = package.split(".")
            if len(parts) >= 2:
                possible_names.add("com-" + parts[1])
                possible_names.add("com-" + parts[1] + "-" + parts[-1])
                possible_names.add(parts[1])
                possible_names.add(parts[-1])
                if len(parts) >= 3:
                    possible_names.add("com-" + parts[1] + parts[2])
                    possible_names.add("com-" + parts[1] + parts[2] + "-mea")
                    possible_names.add("com-" + "-".join(parts[1:]))

        suffixes = ["", "-android", "-mobile", "-mea", "-plus", "-pro", "-lite", "-hd", "-apk"]
        for suffix in suffixes:
            if app_name:
                possible_names.add(app_name + suffix)
            possible_names.add(package_dash + suffix)

    clean_names = []
    for n in possible_names:
        if n and len(n) > 1:
            clean_names.append(n.lower())

    return list(dict.fromkeys(clean_names))


def find_app_version_and_download(session, base_url, target_version=None):
    """Query versions page and API, find matching version, apply -x bypass, and extract download URL."""
    clean_base = base_url.rstrip("/")
    versions_page_url = f"{clean_base}/versions"

    logger.info(f"Checking versions on: {versions_page_url}")
    resp = session.get(versions_page_url, timeout=20)
    if resp.status_code != 200:
        logger.debug(f"Versions page returned HTTP {resp.status_code}")
        return None

    html = resp.text
    # Extract data-code (numeric app identifier)
    m = re.search(r'id=[\"\x27]detail-app-name[\"\x27][^>]*data-code=[\"\x27](\d+)[\"\x27]', html) or \
        re.search(r'data-code=[\"\x27](\d+)[\"\x27][^>]*id=[\"\x27]detail-app-name[\"\x27]', html)

    if not m:
        logger.warning(f"Could not find data-code on {versions_page_url}")
        return None

    data_code = m.group(1)
    logger.debug(f"Found app data-code: {data_code}")

    matched_entry = None
    page = 1
    max_pages = 8

    while page <= max_pages:
        api_url = f"{clean_base}/apps/{data_code}/versions/{page}"
        logger.debug(f"Fetching version API page {page}: {api_url}")
        api_resp = session.get(api_url, timeout=20)
        if api_resp.status_code != 200:
            break

        try:
            entries = api_resp.json().get("data", [])
        except Exception:
            break

        if not entries:
            break

        for entry in entries:
            ver = entry.get("version")
            if target_version:
                if ver == target_version or (target_version and ver and target_version in ver):
                    matched_entry = entry
                    break
            else:
                # Select first latest stable entry
                matched_entry = entry
                break

        if matched_entry:
            break

        page += 1

    if not matched_entry:
        logger.warning(f"Version {target_version or 'latest'} not found for {base_url}")
        return None

    resolved_version = matched_entry.get("version")
    kind_file = matched_entry.get("kindFile", "apk")
    parts = matched_entry.get("versionURL", {})
    u, eu, vid = parts.get("url"), parts.get("extraURL"), str(parts.get("versionID"))
    version_url = f"{u}/{eu}/{vid}"

    logger.info(f"Found version: {resolved_version} (kind={kind_file}) -> {version_url}")

    # Fetch version download page
    v_resp = session.get(version_url, timeout=20)
    if v_resp.status_code != 200:
        logger.warning(f"Failed to fetch version page: {version_url} (HTTP {v_resp.status_code})")
        return None

    vhtml = v_resp.text
    btn = re.search(r'<button[^>]+id=[\"\x27]detail-download-button[^\"]*[\"\x27][^>]*>', vhtml)
    btn_str = btn.group(0) if btn else ""

    # BYPASS LOGIC:
    # If the app is an XAPK or deeplink is enabled, loading version_url downloads the Uptodown App Store installer.
    # Appending "-x" forces data-only-xapk="1" and serves the actual APK/XAPK file.
    is_xapk = kind_file == "xapk" or "download-link-deeplink" in btn_str or "xapk" in btn_str.lower()
    if is_xapk:
        version_url += "-x"
        logger.info(f"Applying -x bypass for direct file delivery: {version_url}")
        v_resp = session.get(version_url, timeout=20)
        if v_resp.status_code == 200:
            vhtml = v_resp.text
            btn = re.search(r'<button[^>]+id=[\"\x27]detail-download-button[^\"]*[\"\x27][^>]*>', vhtml)
            btn_str = btn.group(0) if btn else ""

    # Extract direct download link
    download_url = None
    if btn:
        m_du = re.search(r'data-url=[\"\x27]([^\"]+)[\"\x27]', btn_str)
        if m_du:
            download_url = f"https://dw.uptodown.com/dwn/{m_du.group(1)}"

    if not download_url:
        m_dw = re.search(r'https://dw\.uptodown\.com/dwn/[^\"\'\s<>]+', vhtml)
        if m_dw:
            download_url = m_dw.group(0)

    if not download_url:
        # Fallback: check download-link or post-download
        m_dl = re.search(r'<a[^>]+id=[\"\x27]download-link[\"\x27][^>]+href=[\"\x27]([^\"]+)[\"\x27]', vhtml)
        if m_dl:
            download_url = m_dl.group(1)
            if download_url.startswith("/"):
                download_url = f"https://dw.uptodown.com{download_url}"

    if not download_url:
        logger.warning(f"Could not extract direct download URL from {version_url}")
        return None

    return {
        "version": resolved_version,
        "isSplit": is_xapk,
        "downloadUrl": download_url,
        "referer": version_url,
        "kindFile": kind_file
    }


def download_file(session, download_url, referer, output_path):
    """Stream download file to output_path."""
    logger.info(f"Downloading: {download_url}")
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    headers = {"Referer": referer}
    resp = session.get(download_url, headers=headers, stream=True, timeout=60)
    resp.raise_for_status()

    total_size = int(resp.headers.get("content-length", 0))
    downloaded = 0

    with open(output_path, "wb") as f:
        for chunk in resp.iter_content(chunk_size=65536):
            if chunk:
                f.write(chunk)
                downloaded += len(chunk)

    logger.info(f"Saved {downloaded} bytes -> {output_path}")
    return downloaded


def main():
    parser = argparse.ArgumentParser(description="Download APK/XAPK from Uptodown")
    parser.add_argument("target", help="Android package name (e.g. com.google.android.youtube) or app slug (e.g. youtube)")
    parser.add_argument("output_path", help="Output destination path")
    parser.add_argument("--version", "-v", help="Target version to download (optional)")
    parser.add_argument("--url", "-u", help="Direct Uptodown app base URL (e.g. https://youtube.en.uptodown.com/android)")
    parser.add_argument("--pkg-type", default="apk", choices=["apk", "bundle", "bundle_extract"], help="Package type")
    args = parser.parse_args()

    session = get_session()

    candidates = []
    if args.url:
        candidates.append(args.url.rstrip("/"))
    else:
        app_name = args.target if "." not in args.target else ""
        package = args.target if "." in args.target else ""
        slugs = generate_possible_uptodown_names(app_name, package)
        for s in slugs:
            candidates.append(f"https://{s}.en.uptodown.com/android")

    logger.info(f"Searching Uptodown for '{args.target}' (target_version={args.version or 'latest'})...")

    result_info = None
    for base_url in candidates:
        try:
            info = find_app_version_and_download(session, base_url, target_version=args.version)
            if info:
                result_info = info
                break
        except Exception as e:
            logger.debug(f"Error checking {base_url}: {e}")
            continue

    if not result_info:
        err = f"Could not find or resolve download for '{args.target}' on Uptodown"
        logger.error(err)
        print(json.dumps({"success": False, "error": err}))
        sys.exit(1)

    try:
        size = download_file(session, result_info["downloadUrl"], result_info["referer"], args.output_path)
        output_json = {
            "success": True,
            "version": result_info["version"],
            "versionName": result_info["version"],
            "isSplit": result_info["isSplit"],
            "size": size,
            "kindFile": result_info["kindFile"],
            "outputPath": args.output_path
        }
        print(json.dumps(output_json))
    except Exception as e:
        logger.error(f"Download failed: {e}")
        print(json.dumps({"success": False, "error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    main()
