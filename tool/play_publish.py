#!/usr/bin/env python3
"""Uploads an app to Google Play with the official Google Play Developer API.

What it can do for one app (any combination):
  --listing   titles, descriptions, icon, feature graphic and screenshots for
              every locale in store/<id>/metadata/android/
  --aab FILE  upload the bundle and put it on a track (internal by default)
  --product   create or update the one-time product (premiumProductId) with
              the suggested USD price; Play converts it to other currencies

Credentials: a Google Cloud service account JSON key, given as the
PLAY_SERVICE_ACCOUNT_JSON environment variable (the JSON text) or --key FILE.
See docs/09-AUTO-PUBLISH.md for the one-time setup.

What the API cannot do (Google requires the Play Console for these, once per
app): create the app, upload its very first bundle, and the "App content"
declarations (privacy policy, ads, content rating, target audience, data
safety).

    python3 tool/play_publish.py --app nailvi --listing --dry-run
    python3 tool/play_publish.py --app nailvi --aab app-nailvi-release.aab --track internal
    python3 tool/play_publish.py --app dominodots --listing --product --aab x.aab --status completed
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
IMAGE_TYPES = {
    "icon.png": "icon",
    "featureGraphic.png": "featureGraphic",
}
DRAFT_APP_ERROR = "draft app"


def find_app(app_id: str) -> tuple[dict, Path]:
    """Returns (config, project root) for apps/<id>.json or games/apps/<id>.json."""
    for root in (REPO, REPO / "games"):
        cfg = root / "apps" / f"{app_id}.json"
        if cfg.exists():
            return json.loads(cfg.read_text()), root
    sys.exit(f"No apps/{app_id}.json or games/apps/{app_id}.json")


def read_listings(store: Path) -> list[dict]:
    """One entry per locale folder: texts plus image paths."""
    out = []
    for loc_dir in sorted(p for p in store.iterdir() if p.is_dir()):
        def text(name: str) -> str:
            f = loc_dir / name
            return f.read_text().strip() if f.exists() else ""

        images = loc_dir / "images"
        shots = sorted(
            (images / "phoneScreenshots").glob("*.png"),
            key=lambda p: int(p.stem) if p.stem.isdigit() else 0,
        )
        out.append({
            "language": loc_dir.name,
            "title": text("title.txt"),
            "shortDescription": text("short_description.txt"),
            "fullDescription": text("full_description.txt"),
            "images": {kind: images / name for name, kind in IMAGE_TYPES.items() if (images / name).exists()},
            "phoneScreenshots": shots,
        })
    return out


def service_from_env(key_file: str | None):
    from google.oauth2 import service_account
    from googleapiclient.discovery import build

    if key_file:
        info = json.loads(Path(key_file).read_text())
    else:
        raw = os.environ.get("PLAY_SERVICE_ACCOUNT_JSON", "")
        if not raw.strip():
            sys.exit("Set PLAY_SERVICE_ACCOUNT_JSON (service account key JSON) or pass --key FILE.")
        info = json.loads(raw)
    creds = service_account.Credentials.from_service_account_info(
        info, scopes=["https://www.googleapis.com/auth/androidpublisher"]
    )
    return build("androidpublisher", "v3", credentials=creds, cache_discovery=False)


def upload_listings(api, pkg: str, edit: str, listings: list[dict]) -> None:
    from googleapiclient.http import MediaFileUpload

    edits = api.edits()
    for l in listings:
        lang = l["language"]
        edits.listings().update(
            packageName=pkg, editId=edit, language=lang,
            body={k: l[k] for k in ("language", "title", "shortDescription", "fullDescription")},
        ).execute()
        for kind, path in l["images"].items():
            edits.images().deleteall(packageName=pkg, editId=edit, language=lang, imageType=kind).execute()
            edits.images().upload(
                packageName=pkg, editId=edit, language=lang, imageType=kind,
                media_body=MediaFileUpload(str(path), mimetype="image/png"),
            ).execute()
        if l["phoneScreenshots"]:
            edits.images().deleteall(
                packageName=pkg, editId=edit, language=lang, imageType="phoneScreenshots"
            ).execute()
            for shot in l["phoneScreenshots"]:
                edits.images().upload(
                    packageName=pkg, editId=edit, language=lang, imageType="phoneScreenshots",
                    media_body=MediaFileUpload(str(shot), mimetype="image/png"),
                ).execute()
        print(f"  listing {lang}: texts + {len(l['images'])} images + {len(l['phoneScreenshots'])} screenshots")


def upload_bundle(api, pkg: str, edit: str, aab: Path) -> int:
    from googleapiclient.http import MediaFileUpload

    res = api.edits().bundles().upload(
        packageName=pkg, editId=edit,
        media_body=MediaFileUpload(str(aab), mimetype="application/octet-stream", resumable=True),
    ).execute()
    print(f"  bundle uploaded: versionCode {res['versionCode']}")
    return int(res["versionCode"])


def set_track(api, pkg: str, edit: str, track: str, version: int, status: str, notes: str) -> None:
    release = {"versionCodes": [str(version)], "status": status}
    if notes:
        release["releaseNotes"] = [{"language": "en-US", "text": notes}]
    api.edits().tracks().update(
        packageName=pkg, editId=edit, track=track, body={"track": track, "releases": [release]}
    ).execute()
    print(f"  track {track}: versionCode {version} ({status})")


def upsert_product(api, pkg: str, cfg: dict) -> None:
    """Create or update the one-time product with a USD default price."""
    from googleapiclient.errors import HttpError

    sku = cfg["premiumProductId"]
    usd = float(cfg.get("suggestedPriceUsd", 4.99))
    title = cfg["title"].get("en") or next(iter(cfg["title"].values()))
    body = {
        "packageName": pkg,
        "sku": sku,
        "status": "active",
        "purchaseType": "managedUser",
        "defaultLanguage": "en-US",
        "defaultPrice": {"priceMicros": str(int(round(usd * 1_000_000))), "currency": "USD"},
        "listings": {"en-US": {
            "title": "Unlock everything"[:55],
            "description": f"One-time purchase for {title}. No subscription."[:200],
        }},
    }
    products = api.inappproducts()
    try:
        products.get(packageName=pkg, sku=sku).execute()
        products.patch(packageName=pkg, sku=sku, body=body, autoConvertMissingPrices=True).execute()
        print(f"  product {sku}: updated (US${usd})")
    except HttpError as e:
        if e.resp.status != 404:
            raise
        products.insert(packageName=pkg, body=body, autoConvertMissingPrices=True).execute()
        print(f"  product {sku}: created (US${usd})")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--app", required=True, help="app id, e.g. nailvi or dominodots")
    ap.add_argument("--aab", help="bundle to upload")
    ap.add_argument("--track", default="internal", help="internal | alpha (closed) | beta (open) | production")
    ap.add_argument("--status", default="draft", choices=["draft", "completed"],
                    help="draft = you press 'Roll out' in Play Console; completed = live on the track now")
    ap.add_argument("--notes", default="", help="release notes (en-US)")
    ap.add_argument("--listing", action="store_true", help="upload store texts, icon, graphics, screenshots")
    ap.add_argument("--product", action="store_true", help="create/update the one-time product")
    ap.add_argument("--key", help="service account JSON key file (else PLAY_SERVICE_ACCOUNT_JSON)")
    ap.add_argument("--dry-run", action="store_true", help="check files and print the plan; no API calls")
    a = ap.parse_args()

    cfg, root = find_app(a.app)
    pkg = cfg["applicationId"]
    store = root / "store" / a.app / "metadata/android"
    listings = read_listings(store) if a.listing else []
    aab = Path(a.aab) if a.aab else None
    if aab and not aab.exists():
        sys.exit(f"Bundle not found: {aab}")
    if not (a.listing or aab or a.product):
        sys.exit("Nothing to do: pass --listing, --aab and/or --product")

    print(f"{a.app} ({pkg})")
    if a.dry_run:
        for l in listings:
            assert l["title"] and len(l["title"]) <= 30, (l["language"], "title")
            assert l["shortDescription"] and len(l["shortDescription"]) <= 80, (l["language"], "short")
            assert l["fullDescription"] and len(l["fullDescription"]) <= 4000, (l["language"], "full")
            print(f"  would upload listing {l['language']}: {l['title']!r}, "
                  f"{len(l['images'])} images, {len(l['phoneScreenshots'])} screenshots")
        if aab:
            print(f"  would upload {aab.name} to track {a.track} ({a.status})")
        if a.product:
            print(f"  would create/update product {cfg['premiumProductId']} at US${cfg.get('suggestedPriceUsd')}")
        return

    from googleapiclient.errors import HttpError

    api = service_from_env(a.key)
    edit = api.edits().insert(packageName=pkg, body={}).execute()["id"]
    try:
        if listings:
            upload_listings(api, pkg, edit, listings)
        version = upload_bundle(api, pkg, edit, aab) if aab else None
        if version is not None:
            set_track(api, pkg, edit, a.track, version, a.status, a.notes)
        try:
            api.edits().commit(packageName=pkg, editId=edit).execute()
        except HttpError as e:
            # Apps that were never published only accept draft releases.
            if version is None or a.status == "draft" or DRAFT_APP_ERROR not in str(e).lower():
                raise
            print("  app is still a draft in Play Console: saving the release as draft instead")
            set_track(api, pkg, edit, a.track, version, "draft", a.notes)
            api.edits().commit(packageName=pkg, editId=edit).execute()
        print("  edit committed")
    except HttpError as e:
        try:
            api.edits().delete(packageName=pkg, editId=edit).execute()
        except HttpError:
            pass
        msg = str(e)
        if "not found" in msg.lower() and "package" in msg.lower():
            msg += ("\n→ The app does not exist in Play Console yet, or its first bundle was never "
                    "uploaded by hand. Do that once (docs/09-AUTO-PUBLISH.md, step 3).")
        if "permission" in msg.lower():
            msg += "\n→ Give the service account access to this app in Play Console → Users and permissions."
        sys.exit(msg)

    if a.product:
        upsert_product(api, pkg, cfg)


if __name__ == "__main__":
    main()
