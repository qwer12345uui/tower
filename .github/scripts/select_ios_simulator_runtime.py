#!/usr/bin/env python3
"""Print the highest available iOS Simulator runtime identifier.

GitHub-hosted macOS images can change their pre-created simulator devices
independently of the installed Xcode runtimes. Selecting the available runtime
at job time keeps the CI destination stable without pinning a fragile UUID.
"""

from __future__ import annotations

import json
import subprocess
import sys
from typing import Any


def version_key(runtime: dict[str, Any]) -> tuple[int, ...]:
    raw_version = str(runtime.get("version", ""))
    try:
        return tuple(int(part) for part in raw_version.split("."))
    except ValueError:
        return ()


def main() -> int:
    output = subprocess.check_output(
        ["xcrun", "simctl", "list", "runtimes", "--json"],
        text=True,
    )
    runtimes = json.loads(output).get("runtimes", [])
    available_ios_runtimes = [
        runtime
        for runtime in runtimes
        if runtime.get("isAvailable")
        and str(runtime.get("identifier", "")).startswith("com.apple.CoreSimulator.SimRuntime.iOS")
        and version_key(runtime)
    ]

    if not available_ios_runtimes:
        print("No available iOS Simulator runtime was found.", file=sys.stderr)
        return 1

    selected = max(available_ios_runtimes, key=version_key)
    print(selected["identifier"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
