#!/usr/bin/env bash
# Use from the base directory of nokogumbo

set -e

REMOTE_PATH=${REMOTE_PATH-lib}
LOCAL_PATH=${LOCAL_PATH-gumbo-parser/src}
PATCHES=${PATCHES-patches}


if [ $# -ne 1 ]; then
	echo "Usage: $0 COMMIT" >&2
	exit 1
fi

test ! -d "$PATCHES" && mkdir "$PATCHES"

n=0
for rev in $(git rev-list --topo-order --reverse "$1"..lua-gumbo/master -- "$REMOTE_PATH"); do
	patch_file="$(git format-patch -1 -o "$PATCHES" "$rev")"
	n=$(( n + 1 ))
	name="$(basename "$patch_file")"
	path="$PATCHES/$(printf "%04d" "$n")${name#0001}"
	if [ "$n" -gt 1 ]; then
		mv "$patch_file" "$path"
	fi
	sed -E -i '' -f <(cat <<EOF
: start
/^diff /{
	s, ([ab])/$REMOTE_PATH/([^ ]*), \1/$LOCAL_PATH/\2,g
	t ok
	# Comment out the diff for files outside /lib
	: delete
	s/^/### /
	n
	/^diff |^-- $/ b start
	b delete
}
: ok
s,^(--- a|\+\+\+ b)/$REMOTE_PATH/(.*)$,\1/$LOCAL_PATH/\2,
EOF
	) "$path"
	echo "$path"
done
