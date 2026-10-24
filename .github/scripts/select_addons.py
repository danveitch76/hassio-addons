"""Select add-on builds without executing changed filenames as shell code."""

import json
import os
from pathlib import Path
import subprocess


def select_addons(addons, changed_paths, include_shared=True):
    shared = {".github/workflows/builder.yml", ".github/scripts/select_addons.py",
              ".github/scripts/test_select_addons.py", "build.sh"}
    if include_shared and any(path in shared for path in changed_paths):
        return sorted(addons)
    return sorted(addon for addon in addons if any(
        path.startswith(addon + "/") and not path.lower().endswith(".md")
        for path in changed_paths
    ))


def main():
    addons = [p.name for p in Path(".").iterdir() if p.is_dir() and any(
        (p / name).is_file() for name in ("config.yaml", "config.yml", "config.json")
    )]
    base = os.environ.get("BASE_SHA", "")
    if not base or set(base) == {"0"}:
        selected = sorted(addons)
        publish_addons = []
    else:
        raw = subprocess.check_output(["git", "diff", "--name-only", "-z", base, "HEAD"])
        paths = raw.decode("utf-8", errors="surrogateescape").rstrip("\0").split("\0")
        selected = select_addons(addons, paths)
        publish_addons = select_addons(addons, paths, include_shared=False)
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as stream:
        stream.write("addons=" + json.dumps(selected) + "\n")
        stream.write("publish_addons=" + json.dumps(publish_addons) + "\n")
        stream.write("changed=" + str(bool(selected)).lower() + "\n")
    print("Selected add-ons: " + json.dumps(selected))


if __name__ == "__main__":
    main()
