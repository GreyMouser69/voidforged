#!/usr/bin/env bash
# Upload a build_manifest.py publish folder to the patch host's PATCH_DIR over ssh.
#
#   ./publish_box.sh <publish dir> <user@host> <remote patch dir>      (SSH_KEY=<key file> to pick a key)
#
# Only objects the host doesn't have yet are sent. manifest.txt goes last, swapped in with a rename, so
# players never get a list naming files that aren't there yet.
set -euo pipefail

if [ $# -ne 3 ]; then
	echo "usage: $0 <publish dir> <user@host> <remote patch dir>" >&2
	exit 2
fi

pub=$1
host=$2
dir=$3
ssh_cmd=(ssh)
if [ -n "${SSH_KEY:-}" ]; then
	ssh_cmd+=(-i "$SSH_KEY")
fi

[ -f "$pub/manifest.txt" ] || { echo "no manifest.txt in $pub" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

"${ssh_cmd[@]}" "$host" "mkdir -p '$dir/objects' && cd '$dir/objects' && find . -type f ! -name '*.tmp' | sed 's|^\./||'" | sort > "$tmp/remote"
(cd "$pub/objects" && find . -type f ! -name '*.tmp' | sed 's|^\./||') | sort > "$tmp/local"
comm -23 "$tmp/local" "$tmp/remote" > "$tmp/missing"

count=$(wc -l < "$tmp/missing")
if [ "$count" -gt 0 ]; then
	bytes=$(cd "$pub/objects" && tr '\n' '\0' < "$tmp/missing" | xargs -0 du -cb | tail -1 | cut -f1)
	echo "uploading $count object(s), $((bytes / 1048576)) MB"
	tar -C "$pub/objects" -cf - -T "$tmp/missing" | "${ssh_cmd[@]}" "$host" "tar -C '$dir/objects' -xf -"
else
	echo "host already has every object"
fi

"${ssh_cmd[@]}" "$host" "cat > '$dir/manifest.txt.tmp' && chmod -R a+rX '$dir' && mv '$dir/manifest.txt.tmp' '$dir/manifest.txt'" < "$pub/manifest.txt"
echo "manifest $(grep -m1 '^version' "$pub/manifest.txt" | cut -f2) published"
