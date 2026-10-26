#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
archive="$script_dir/boost_1_83_0.tar.gz"
checksum_file="$archive.sha256"
temporary_archive="$archive.tmp.$$"

cleanup() {
  rm -f "$temporary_archive"
}

trap cleanup 0 1 2 15

if [ ! -f "$checksum_file" ]; then
  echo "Missing checksum file: $checksum_file" >&2
  exit 1
fi

expected_checksum=$(awk 'NR == 1 { print $1 }' "$checksum_file")
if [ -z "$expected_checksum" ]; then
  echo "Checksum file is empty or invalid: $checksum_file" >&2
  exit 1
fi

file_checksum() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{ print $1 }'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{ print $1 }'
  else
    echo "Neither shasum nor sha256sum is available." >&2
    exit 1
  fi
}

if [ -f "$archive" ]; then
  actual_checksum=$(file_checksum "$archive")
  if [ "$actual_checksum" = "$expected_checksum" ]; then
    echo "Boost archive is ready: $archive"
    exit 0
  fi
  echo "Existing Boost archive has an invalid checksum; rebuilding it." >&2
fi

set -- "$archive".part-*
if [ "$1" = "$archive.part-*" ]; then
  echo "Missing Boost archive chunks: $archive.part-*" >&2
  exit 1
fi

cat "$@" > "$temporary_archive"
actual_checksum=$(file_checksum "$temporary_archive")

if [ "$actual_checksum" != "$expected_checksum" ]; then
  echo "Restored Boost archive failed checksum validation." >&2
  echo "Expected: $expected_checksum" >&2
  echo "Actual:   $actual_checksum" >&2
  exit 1
fi

mv "$temporary_archive" "$archive"
echo "Boost archive restored and verified: $archive"
