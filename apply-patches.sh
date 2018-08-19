#!/usr/bin/env bash
set -e

PATCHES=${PATCHES-patches}

for patch_file in patches/*; do
	echo "$patch_file"
	git am --reject "$patch_file"
done
