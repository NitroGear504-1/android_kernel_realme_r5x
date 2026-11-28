#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(realpath -m "${1:-$ROOT/out-r5x-clang20}")"

cd "$ROOT"

git diff --quiet
git diff --cached --quiet

COMMIT="$(git rev-parse HEAD)"
SHORT_COMMIT="$(git rev-parse --short=12 HEAD)"

test -s "$OUT/r5x-build-commit.txt"
test -s "$OUT/r5x-build-checksum.txt"

if [[ "$(cat "$OUT/r5x-build-commit.txt")" != "$COMMIT" ]]; then
    echo "Build does not match the current source commit."
    exit 1
fi

IMAGE="$OUT/arch/arm64/boot/Image.gz-dtb"

test -s "$IMAGE"

(
    cd "$OUT"
    sha256sum -c r5x-build-checksum.txt
)

ZIP_NAME="r5x-Stormbreaker-${SHORT_COMMIT}-$(date -u +%Y%m%d-%H%M%S).zip"
ZIP="$OUT/$ZIP_NAME"

test ! -e "$ZIP"

TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

STAGE="$TEMP/AnyKernel"
mkdir -p "$STAGE"

echo "=== PREPARING ANYKERNEL3 ==="

git archive "$COMMIT:AnyKernel" |
    tar -xf - -C "$STAGE"

cp "$IMAGE" "$STAGE/Image.gz-dtb"

test -s "$STAGE/tools/magiskboot"
test -s "$STAGE/tools/busybox"
test -f "$STAGE/anykernel.sh"

echo "=== CREATING ZIP ==="

(
    cd "$STAGE"

    zip -rq9 "$TEMP/$ZIP_NAME" . \
        -x "README.md" ".git" "*placeholder"
)

echo "=== VERIFYING ZIP ==="

unzip -tq "$TEMP/$ZIP_NAME"

cmp "$IMAGE" <(
    unzip -p "$TEMP/$ZIP_NAME" Image.gz-dtb
)

mv "$TEMP/$ZIP_NAME" "$ZIP"

(
    cd "$OUT"
    sha256sum "$ZIP_NAME" > "$ZIP_NAME.sha256"
    sha256sum -c "$ZIP_NAME.sha256"
)

ls -lh "$ZIP"

echo "Packaging completed successfully."
