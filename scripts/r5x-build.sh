#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(realpath -m "${1:-$ROOT/out-r5x-clang20}")"
TOOLCHAIN="${CLANG_DIR:-$HOME/toolchain/clang20}"
JOBS="${JOBS:-$(nproc)}"

cd "$ROOT"

case "$OUT" in
    "$ROOT"/out-*) ;;
    *)
        echo "Invalid build directory: $OUT"
        exit 1
        ;;
esac

export PATH="$TOOLCHAIN/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export LLVM=1
export LLVM_IAS=1

test -x "$TOOLCHAIN/bin/clang"
test -x "$TOOLCHAIN/bin/ld.lld"

clang --version
ld.lld --version

# Do not build from modified tracked sources.
git diff --quiet
git diff --cached --quiet

COMMIT="$(git rev-parse HEAD)"

mkdir -p "$OUT"

# Invalidate previous successful-build records.
rm -f "$OUT/r5x-build-commit.txt"
rm -f "$OUT/r5x-build-checksum.txt"

ARGS=(
    O="$OUT"
    ARCH=arm64
    LLVM=1
    LLVM_IAS=1
    CC=clang
    LD=ld.lld
    AR=llvm-ar
    NM=llvm-nm
    OBJCOPY=llvm-objcopy
    OBJDUMP=llvm-objdump
    READELF=llvm-readelf
    STRIP=llvm-strip
)

echo "=== GENERATING CONFIGURATION ==="

make "${ARGS[@]}" vendor/trinket-perf_defconfig
make "${ARGS[@]}" vendor/r5x.config
make "${ARGS[@]}" olddefconfig

if [[ -n "${REFERENCE_CONFIG:-}" ]]; then
    test -s "$REFERENCE_CONFIG"

    DIFF="$(scripts/diffconfig \
        "$REFERENCE_CONFIG" "$OUT/.config")"

    if [[ -n "$DIFF" ]]; then
        echo "Unexpected configuration differences:"
        echo "$DIFF"
        exit 1
    fi

    echo "Reference configuration matched."
fi

echo "=== BUILDING KERNEL ==="

make -j"$JOBS" "${ARGS[@]}" Image.gz-dtb \
    2>&1 | tee "$OUT/build.log"

IMAGE="$OUT/arch/arm64/boot/Image.gz-dtb"

test -s "$IMAGE"
test -s "$OUT/vmlinux"

# Ensure sources did not change during compilation.
test "$(git rev-parse HEAD)" = "$COMMIT"
git diff --quiet
git diff --cached --quiet

echo "=== BUILD INFORMATION ==="

cat "$OUT/include/generated/compile.h"
cat "$OUT/include/generated/utsrelease.h"

ls -lh "$IMAGE"
llvm-size "$OUT/vmlinux"

echo "=== RECORDING CHECKSUM ==="

(
    cd "$OUT"
    sha256sum arch/arm64/boot/Image.gz-dtb \
        > r5x-build-checksum.txt

    sha256sum -c r5x-build-checksum.txt
)

printf '%s\n' "$COMMIT" > "$OUT/r5x-build-commit.txt"

echo "Kernel build completed successfully."
