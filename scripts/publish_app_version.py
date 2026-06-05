#!/usr/bin/env python3
"""Publish latest TestFlight version metadata to Supabase."""

from __future__ import annotations

import argparse
import json
import os
import urllib.request
from pathlib import Path


def env_required(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise RuntimeError(f"Missing required environment variable: {name}")
    return value


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True)
    parser.add_argument("--build", required=True, type=int)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--release-notes", required=True)
    parser.add_argument("--platform", default="ios")
    args = parser.parse_args()

    supabase_url = env_required("SUPABASE_URL").rstrip("/")
    service_role_key = env_required("SUPABASE_SERVICE_ROLE_KEY")
    testflight_url = os.environ.get("TESTFLIGHT_APP_URL", "").strip()
    release_notes = Path(args.release_notes).read_text()

    payload = {
        "platform": args.platform,
        "version": args.version,
        "build_number": args.build,
        "release_tag": args.tag,
        "release_notes": release_notes,
        "testflight_url": testflight_url,
        "is_active": True,
    }
    body = json.dumps(payload).encode("utf-8")
    url = (
        f"{supabase_url}/rest/v1/app_versions"
        "?on_conflict=platform,version,build_number"
    )
    request = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "apikey": service_role_key,
            "Authorization": f"Bearer {service_role_key}",
            "Content-Type": "application/json",
            "Prefer": "resolution=merge-duplicates,return=minimal",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        if response.status >= 300:
            raise RuntimeError(f"Supabase returned HTTP {response.status}")

    print(f"Published {args.platform} {args.version}+{args.build}")


if __name__ == "__main__":
    main()
