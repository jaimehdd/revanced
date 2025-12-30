import json
import os
import sys

METADATA_FILE = "release_metadata.jsonl"
OUTPUT_FILE = "releases.json"

def main():
    if not os.path.exists(METADATA_FILE):
        print(f"No metadata file found at {METADATA_FILE}. Exiting.")
        return

    releases = []
    # Read existing releases if they exist (optional, but good for history)
    if os.path.exists(OUTPUT_FILE):
        try:
            with open(OUTPUT_FILE, 'r') as f:
                content = f.read()
                if content.strip():
                     releases = json.loads(content)
        except Exception as e:
            print(f"Error reading existing releases.json: {e}")

    # Read new entries from jsonl
    new_entries = []
    with open(METADATA_FILE, 'r') as f:
        for line in f:
            if line.strip():
                try:
                    new_entries.append(json.loads(line))
                except json.JSONDecodeError as e:
                    print(f"Skipping invalid json line: {line.strip()} - {e}")

    # Merge strategy: Update existing entries if name matches, append if new.
    # Note: This strategy assumes one entry per "name" (app variant).

    for entry in new_entries:
        found = False
        for i, r in enumerate(releases):
            if r.get("name") == entry.get("name"):
                 releases[i] = entry
                 found = True
                 break
        if not found:
            releases.append(entry)

    with open(OUTPUT_FILE, 'w') as f:
        json.dump(releases, f, indent=2)

    print(f"Successfully generated {OUTPUT_FILE} with {len(releases)} entries.")

if __name__ == "__main__":
    main()
