#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
repo_dir=$PWD
ipa=${1:-"$repo_dir/YouTube.ipa"}
[[ "$ipa" = /* ]] || ipa="$repo_dir/$ipa"

export THEOS="$repo_dir/.build-tools/theos"
export PATH="$(brew --prefix make)/libexec/gnubin:$PATH"
logos_ref=31d2271046810dacedcbcd92b7780ec5da600e96

if [[ ! -d "$THEOS/sdks/iPhoneOS16.5.sdk" ]]; then
    echo "Missing iPhoneOS16.5.sdk in $THEOS/sdks" >&2
    exit 1
fi
if [[ ! -f "$ipa" ]]; then
    echo "IPA not found: $ipa" >&2
    exit 1
fi
if [[ "$(git -C "$THEOS/vendor/logos" rev-parse HEAD)" != "$logos_ref" ]]; then
    echo "Expected Logos $logos_ref in $THEOS/vendor/logos" >&2
    exit 1
fi

youtube_version=$(python3 - "$ipa" <<'PY'
import plistlib
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as archive:
    info = plistlib.loads(archive.read("Payload/YouTube.app/Info.plist"))
print(info["CFBundleVersion"])
PY
)

mkdir -p "$THEOS/lib/iphone/rootless"
make package THEOS_PACKAGE_SCHEME=rootless "IPA=$ipa" FINALPACKAGE=1 \
    "YOUTUBE_VERSION=$youtube_version" "UYOU_VERSION=${UYOU_VERSION:-3.0.4}" \
    "ADDITIONAL_XCODEOPTS=-derivedDataPath $repo_dir/.build-tools/DerivedData"

echo "Built IPA in $repo_dir/packages"
