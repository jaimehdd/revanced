import os
import re
import shutil
import subprocess
import sys

# Configuration
UPSTREAM_REPO = "https://github.com/FiorenMas/Revanced-And-Revanced-Extended-Non-Root"
TEMP_DIR = "./tmp/revanced-check-script"
LOCAL_APPS_DIR = "src/build/apps"
UPSTREAM_BUILD_DIR = os.path.join(TEMP_DIR, "src/build")

# Commands to check for sync (these are the functions defined in utils.sh or the monolithic scripts)
CRITICAL_COMMANDS = {"get_apk", "patch", "split_editor", "get_patches_key", "dl_gh"}


def clone_upstream():
    if os.path.exists(TEMP_DIR):
        shutil.rmtree(TEMP_DIR)
    print(f"Cloning upstream repository: {UPSTREAM_REPO}")
    subprocess.check_call(["git", "clone", "--depth", "1", UPSTREAM_REPO, TEMP_DIR])


def parse_commands(file_path):
    """
    Parses a shell script and returns a set of normalized command strings.
    We normalize by stripping whitespace and comments.
    """
    commands = set()
    with open(file_path, "r") as f:
        for line in f:
            line = line.strip()
            # Ignore comments and empty lines
            if not line or line.startswith("#"):
                continue

            # Check if line starts with a critical command
            # We look for the command followed by a space or end of line
            parts = line.split()
            if not parts:
                continue

            cmd_name = parts[0]

            # Special handling for environment variable exports which user asked to ignore
            if "GITHUB_ENV" in line or line.startswith("export "):
                continue

            if cmd_name in CRITICAL_COMMANDS:
                commands.add(line)
    return commands


def main():
    try:
        clone_upstream()
    except Exception as e:
        print(f"Failed to clone upstream: {e}")
        sys.exit(1)

    # 1. Build Knowledge Base from Upstream
    upstream_commands = set()
    if not os.path.exists(UPSTREAM_BUILD_DIR):
        print(f"Error: Upstream build directory not found at {UPSTREAM_BUILD_DIR}")
        sys.exit(1)

    print(f"Parsing upstream scripts in {UPSTREAM_BUILD_DIR}...")
    for filename in os.listdir(UPSTREAM_BUILD_DIR):
        if filename.endswith(".sh"):
            path = os.path.join(UPSTREAM_BUILD_DIR, filename)
            cmds = parse_commands(path)
            upstream_commands.update(cmds)
            print(f"  Loaded {len(cmds)} commands from {filename}")

    print(f"Total unique upstream commands found: {len(upstream_commands)}")

    # 2. Verify Local Scripts
    if not os.path.exists(LOCAL_APPS_DIR):
        print(f"Error: Local apps directory not found at {LOCAL_APPS_DIR}")
        sys.exit(1)

    print(f"\nChecking local scripts in {LOCAL_APPS_DIR}...")
    all_passed = True

    for filename in os.listdir(LOCAL_APPS_DIR):
        if not filename.endswith(".sh"):
            continue

        path = os.path.join(LOCAL_APPS_DIR, filename)
        local_cmds = parse_commands(path)

        script_passed = True
        for cmd in local_cmds:
            if cmd not in upstream_commands:
                # Double check with loose matching (ignoring extra spaces might be needed, but exact match is safer for now)
                print(f"  [MISSING] {filename}: {cmd}")
                script_passed = False

        if script_passed:
            print(f"  [OK] {filename}")
        else:
            all_passed = False

    if all_passed:
        print("\nSUCCESS: All local scripts are synced with upstream.")
        sys.exit(0)
    else:
        print("\nFAILURE: Some local scripts contain commands not found in upstream.")
        sys.exit(1)


if __name__ == "__main__":
    main()
