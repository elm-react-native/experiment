#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$APP_ROOT/.." && pwd)"

SCHEME="${SCHEME:-Plex}"
CONFIGURATION="${CONFIGURATION:-Release}"
WORKSPACE="${WORKSPACE:-ios/Plex.xcworkspace}"
DERIVED_DATA="${DERIVED_DATA:-ios/build/release-derived-data}"
JS_BUILD_DIR="${JS_BUILD_DIR:-ios/build/release-js}"
ENTRY_FILE="${ENTRY_FILE:-index.js}"
NODE_BINARY="${NODE_BINARY:-$(command -v node || true)}"

DEPLOY=1
LAUNCH=1
CLEAN=0
VERBOSE=0

REQUESTED_DEVICES=()
DEVICE_SELECTORS=()
TARGET_IDS=()
TARGET_LABELS=()

usage() {
  cat <<EOF
Usage: scripts/release-ios.sh [options]

Builds Plex for iOS Release and deploys it to paired iPhone/iPad devices.

Options:
  -d, --device <id|name>  Deploy to a specific devicectl device id, UDID, or name.
                          May be passed more than once.
      --phone            Deploy to usable paired iPhone devices.
      --ipad             Deploy to usable paired iPad devices.
      --all              Deploy to usable paired iPhone and iPad devices. Default.
      --no-deploy        Build only.
      --no-launch        Install but do not launch after install.
      --clean            Clean the Xcode build before building.
      --configuration X  Xcode configuration. Default: Release.
      --derived-data P   Xcode DerivedData path. Default: ios/build/release-derived-data.
      --js-build-dir P   Production JS bundle output dir. Default: ios/build/release-js.
      --verbose          Print extra command detail.
  -h, --help             Show this help.

Examples:
  scripts/release-ios.sh
  scripts/release-ios.sh --phone
  scripts/release-ios.sh --ipad --no-launch
  scripts/release-ios.sh --device 00008150-0012713126F3401C
EOF
}

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

run() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  fi
  "$@"
}

add_target() {
  local id="$1"
  local label="$2"
  local existing

  if [[ "${#TARGET_IDS[@]}" -gt 0 ]]; then
    for existing in "${TARGET_IDS[@]}"; do
      [[ "$existing" == "$id" ]] && return 0
    done
  fi

  TARGET_IDS+=("$id")
  TARGET_LABELS+=("$label")
}

device_rows() {
  local json
  json="$(mktemp)"
  trap 'rm -f "$json"' RETURN

  xcrun devicectl list devices --json-output "$json" >/dev/null
  jq -r '
    .result.devices[]
    | select((.hardwareProperties.platform // "") == "iOS")
    | select((.hardwareProperties.reality // "") == "physical")
    | select((.connectionProperties.pairingState // "") == "paired")
    | select((.connectionProperties.tunnelState // "") != "unavailable")
    | [
        .identifier,
        (.deviceProperties.name // "Unknown"),
        (.hardwareProperties.marketingName // .hardwareProperties.productType // "iOS device"),
        (.hardwareProperties.deviceType // "unknown"),
        (.deviceProperties.osVersionNumber // "unknown"),
        (.connectionProperties.tunnelState // "unknown")
      ]
    | @tsv
  ' "$json"
}

resolve_auto_devices() {
  local selector="$1"
  local id name marketing type os tunnel label matched
  matched=0

  while IFS=$'\t' read -r id name marketing type os tunnel; do
    [[ -z "${id:-}" ]] && continue

    case "$selector" in
      all)
        [[ "$type" == "iPhone" || "$type" == "iPad" ]] || continue
        ;;
      phone)
        [[ "$type" == "iPhone" ]] || continue
        ;;
      ipad)
        [[ "$type" == "iPad" ]] || continue
        ;;
    esac

    label="$name ($marketing, iOS $os, $tunnel)"
    add_target "$id" "$label"
    matched=1
  done < <(device_rows)

  [[ "$matched" -eq 1 ]]
}

print_usable_devices() {
  local id name marketing type os tunnel

  printf 'Usable paired iPhone/iPad devices:\n'
  while IFS=$'\t' read -r id name marketing type os tunnel; do
    [[ -z "${id:-}" ]] && continue
    [[ "$type" == "iPhone" || "$type" == "iPad" ]] || continue
    printf '  %s\t%s\t%s\tiOS %s\t%s\n' "$id" "$name" "$marketing" "$os" "$tunnel"
  done < <(device_rows)
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--device)
      [[ $# -ge 2 ]] || die "$1 requires a device id, UDID, or name"
      REQUESTED_DEVICES+=("$2")
      shift 2
      ;;
    --phone)
      DEVICE_SELECTORS+=("phone")
      shift
      ;;
    --ipad)
      DEVICE_SELECTORS+=("ipad")
      shift
      ;;
    --all)
      DEVICE_SELECTORS+=("all")
      shift
      ;;
    --no-deploy)
      DEPLOY=0
      shift
      ;;
    --no-launch)
      LAUNCH=0
      shift
      ;;
    --clean)
      CLEAN=1
      shift
      ;;
    --configuration)
      [[ $# -ge 2 ]] || die "$1 requires a configuration"
      CONFIGURATION="$2"
      shift 2
      ;;
    --derived-data)
      [[ $# -ge 2 ]] || die "$1 requires a path"
      DERIVED_DATA="$2"
      shift 2
      ;;
    --js-build-dir)
      [[ $# -ge 2 ]] || die "$1 requires a path"
      JS_BUILD_DIR="$2"
      shift 2
      ;;
    --verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown option: $1"
      ;;
  esac
done

cd "$APP_ROOT"

require_cmd xcodebuild
require_cmd xcrun
require_cmd jq
[[ -n "$NODE_BINARY" ]] || die "Missing required command: node"
[[ -d node_modules ]] || die "Missing node_modules. Run yarn install or npm install in $APP_ROOT."
[[ -d ios/Pods ]] || die "Missing iOS Pods. Run bundle exec pod install in $APP_ROOT/ios."
[[ -f "$REPO_ROOT/build" ]] || die "Missing repo Elm build script at $REPO_ROOT/build."

log "Building Elm output"
(cd "$REPO_ROOT" && run ./build plex)

log "Bundling production React Native JS"
rm -rf "$JS_BUILD_DIR"
mkdir -p "$JS_BUILD_DIR"
run "$NODE_BINARY" node_modules/react-native/cli.js bundle \
  --platform ios \
  --dev false \
  --entry-file "$ENTRY_FILE" \
  --bundle-output "$JS_BUILD_DIR/main.jsbundle" \
  --assets-dest "$JS_BUILD_DIR"

log "Building $SCHEME $CONFIGURATION app"
if [[ "$CLEAN" -eq 1 ]]; then
  run env RCT_NO_LAUNCH_PACKAGER=1 NODE_BINARY="$NODE_BINARY" \
    xcodebuild \
      -workspace "$WORKSPACE" \
      -scheme "$SCHEME" \
      -configuration "$CONFIGURATION" \
      -sdk iphoneos \
      -destination "generic/platform=iOS" \
      -derivedDataPath "$DERIVED_DATA" \
      clean
fi

run env RCT_NO_LAUNCH_PACKAGER=1 NODE_BINARY="$NODE_BINARY" \
  xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    -derivedDataPath "$DERIVED_DATA" \
    -allowProvisioningUpdates \
    build

APP_PATH="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphoneos/${SCHEME}.app"
[[ -d "$APP_PATH" ]] || die "Built app not found at $APP_PATH"

log "Built app: $APP_PATH"

if [[ "$DEPLOY" -eq 0 ]]; then
  log "Skipping deploy"
  exit 0
fi

if [[ "${#REQUESTED_DEVICES[@]}" -gt 0 ]]; then
  for requested in "${REQUESTED_DEVICES[@]}"; do
    add_target "$requested" "$requested"
  done
fi

if [[ "${#DEVICE_SELECTORS[@]}" -eq 0 && "${#REQUESTED_DEVICES[@]}" -eq 0 ]]; then
  DEVICE_SELECTORS+=("all")
fi

if [[ "${#DEVICE_SELECTORS[@]}" -gt 0 ]]; then
  for selector in "${DEVICE_SELECTORS[@]}"; do
    if ! resolve_auto_devices "$selector"; then
      print_usable_devices >&2
      die "No usable paired devices matched --$selector"
    fi
  done
fi

[[ "${#TARGET_IDS[@]}" -gt 0 ]] || die "No deploy targets resolved"

BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Info.plist")"
[[ -n "$BUNDLE_ID" ]] || die "Unable to read built app bundle identifier"

for index in "${!TARGET_IDS[@]}"; do
  target_id="${TARGET_IDS[$index]}"
  target_label="${TARGET_LABELS[$index]}"

  log "Installing on $target_label"
  run xcrun devicectl device install app --device "$target_id" "$APP_PATH"

  if [[ "$LAUNCH" -eq 1 ]]; then
    log "Launching $BUNDLE_ID on $target_label"
    run xcrun devicectl device process launch --terminate-existing --device "$target_id" "$BUNDLE_ID"
  fi
done

log "Release deploy complete"
