#!/usr/bin/env python3
"""
Uptodown APK / XAPK Downloader with Playwright Turnstile Bypass
Adapted from: https://github.com/RookieEnough/Morphe-AutoBuilds
"""

import argparse
import json
import logging
import os
import re
import sys
import time

# Configure logging to sys.stderr so stdout remains pure JSON
logging.basicConfig(
    stream=sys.stderr,
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger("uptodown_dl")


def get_session():
    """Return a requests session, preferring curl_cffi for TLS impersonation if available."""
    try:
        from curl_cffi import requests as cffi_requests
        logger.debug("Using curl_cffi with Chrome impersonation")
        return cffi_requests.Session(impersonate="chrome120")
    except ImportError:
        import requests
        s = requests.Session()
        s.headers.update({
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
            "Sec-Ch-Ua": '"Chromium";v="122", "Google Chrome";v="122"',
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


def resolve_with_playwright(version_url, output_path):
    """Launch headless Chromium via Playwright to solve Turnstile, click download, and get the APK file."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        logger.warning("[Playwright] playwright is not installed. Ensure playwright and chromium are installed in CI.")
        return None

    logger.info(f"[Playwright] Launching Chromium for Turnstile resolution on: {version_url}")
    resolved_download_url = None
    captured_version = None
    saved_file = False

    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-blink-features=AutomationControlled",
                "--disable-infobars",
                "--window-size=1280,800"
            ]
        )
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            viewport={"width": 1280, "height": 800},
            accept_downloads=True
        )
        page = context.new_page()

        # Stealth: mask navigator.webdriver
        page.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });
        """)

        # Intercept AJAX /download-url response
        def handle_response(response):
            nonlocal resolved_download_url
            if "download-url" in response.url:
                try:
                    data = response.json()
                    dl = data.get("data", {}).get("downloadURL") or data.get("downloadURL")
                    if dl:
                        logger.info(f"[Playwright] Intercepted direct download URL from AJAX response: {dl}")
                        resolved_download_url = dl
                except Exception as e:
                    logger.debug(f"[Playwright] Error parsing response JSON: {e}")

        page.on("response", handle_response)

        # Intercept browser download events
        download_event = None
        def handle_download(dl):
            nonlocal download_event, resolved_download_url
            logger.info(f"[Playwright] Download event triggered: {dl.url}")
            resolved_download_url = dl.url
            download_event = dl

        page.on("download", handle_download)

        try:
            page.goto(version_url, wait_until="domcontentloaded", timeout=45000)
            page.wait_for_timeout(2000)

            # Dismiss cookie consent dialog if present
            try:
                for selector in ["#didomi-notice-agree-button", "button:has-text('Accept')", "button:has-text('Agree')", ".qc-cmp2-summary-buttons button"]:
                    cookie_btn = page.query_selector(selector)
                    if cookie_btn and cookie_btn.is_visible():
                        logger.info(f"[Playwright] Dismissing cookie banner ({selector})...")
                        cookie_btn.click()
                        page.wait_for_timeout(1000)
                        break
            except Exception:
                pass

            # Capture version text from UI
            try:
                v_elem = page.query_selector(".version")
                if v_elem:
                    captured_version = v_elem.inner_text().strip()
            except Exception:
                pass

            # Trigger download button click via evaluate to bypass any overlay blocking
            logger.info("[Playwright] Triggering #detail-download-button click...")
            page.evaluate("""
                const btn = document.getElementById('detail-download-button');
                if (btn) {
                    btn.scrollIntoView();
                    btn.click();
                }
            """)

            # Wait for Turnstile solving and download URL extraction (up to 30 seconds)
            for i in range(30):
                if resolved_download_url or download_event:
                    logger.info(f"[Playwright] Successfully obtained download trigger after {i+1}s")
                    break
                page.wait_for_timeout(1000)

            if download_event:
                logger.info(f"[Playwright] Saving browser download stream to: {output_path}")
                os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
                download_event.save_as(output_path)
                saved_file = True

        except Exception as e:
            logger.warning(f"[Playwright] Page interaction exception: {e}")
        finally:
            browser.close()

    if saved_file and os.path.isfile(output_path):
        return {
            "success": True,
            "downloadUrl": resolved_download_url or "browser_stream",
            "version": captured_version,
            "savedViaBrowser": True
        }

    if resolved_download_url:
        return {
            "success": True,
            "downloadUrl": resolved_download_url,
            "version": captured_version,
            "savedViaBrowser": False
        }

    return None


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

    # Check for direct download link in static HTML if available
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
        m_dl = re.search(r'<a[^>]+id=[\"\x27]download-link[\"\x27][^>]+href=[\"\x27]([^\"]+)[\"\x27]', vhtml)
        if m_dl:
            download_url = m_dl.group(1)
            if download_url.startswith("/"):
                download_url = f"https://dw.uptodown.com{download_url}"

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
    resp = session.get(download_url, headers=headers, stream=True, timeout=120)
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
    parser.add_argument("target", help="Android package name (e.g. com.strava) or app slug (e.g. strava)")
    parser.add_argument("output_path", help="Output destination path")
    parser.add_argument("--version", "-v", help="Target version to download (optional)")
    parser.add_argument("--url", "-u", help="Direct Uptodown app base URL (e.g. https://strava.en.uptodown.com/android)")
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
        err = f"Could not find version info for '{args.target}' on Uptodown"
        logger.error(err)
        print(json.dumps({"success": False, "error": err}))
        sys.exit(1)

    output_path = args.output_path
    version_name = result_info.get("version")
    is_split = result_info.get("isSplit", False)
    kind_file = result_info.get("kindFile", "apk")
    download_url = result_info.get("downloadUrl")
    referer = result_info.get("referer")

    # 1. If direct download URL is available in static HTML, download directly
    if download_url:
        try:
            size = download_file(session, download_url, referer, output_path)
            output_json = {
                "success": True,
                "version": version_name,
                "versionName": version_name,
                "isSplit": is_split,
                "size": size,
                "kindFile": kind_file,
                "outputPath": output_path
            }
            print(json.dumps(output_json))
            sys.exit(0)
        except Exception as e:
            logger.warning(f"Static download failed: {e}. Attempting Playwright Turnstile resolution...")

    # 2. Turnstile bypass via Playwright headless browser
    pw_result = resolve_with_playwright(referer, output_path)
    if pw_result and pw_result.get("success"):
        if pw_result.get("savedViaBrowser") and os.path.isfile(output_path):
            size = os.path.getsize(output_path)
        elif pw_result.get("downloadUrl") and pw_result.get("downloadUrl") != "browser_stream":
            size = download_file(session, pw_result["downloadUrl"], referer, output_path)
        else:
            size = os.path.getsize(output_path) if os.path.isfile(output_path) else 0

        output_json = {
            "success": True,
            "version": version_name or pw_result.get("version"),
            "versionName": version_name or pw_result.get("version"),
            "isSplit": is_split,
            "size": size,
            "kindFile": kind_file,
            "outputPath": output_path
        }
        print(json.dumps(output_json))
        sys.exit(0)

    err = f"Could not resolve Turnstile download link for '{args.target}' on Uptodown"
    logger.error(err)
    print(json.dumps({"success": False, "error": err}))
    sys.exit(1)


if __name__ == "__main__":
    main()
