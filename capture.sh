#!/bin/bash

set -ueo pipefail
shopt -s inherit_errexit

# Build ENVs
: "${BUILD_DIR:="/build"}"    # Root build directory
: "${PACKAGE_DIR:="package"}" # Package subdirectory

# Control file ENVs
: "${APP:?"APP ENV is missing."}"
: "${VERSION:?"VERSION ENV is missing."}"
: "${PRIORITY:?"PRIORITY ENV is missing."}"
: "${SECTION:?"SECTION ENV is missing."}"
: "${MAINTAINER:?"MAINTAINER ENV is missing."}"
: "${TARGETARCH:?"TARGETARCH ENV is missing."}"
: "${DEPENDS:?"DEPENDS ENV is missing."}"
: "${DESCRIPTION:?"DESCRIPTION ENV is missing."}"

# 0 - exclude doc files
# 1 - include doc files
: "${INCLUDE_DOCS:?"INCLUDE_DOCS ENV is missing."}"

_snapshot() {
	local ID=$1
	# Get all directories, files and links
	find / -xdev -type d | sort > "$BUILD_DIR/$ID"-d.txt
	find / -xdev -type f | sort > "$BUILD_DIR/$ID"-f.txt
	find / -xdev -type l | sort > "$BUILD_DIR/$ID"-l.txt
}

# Make before/after FS snapshots and execute the command, e.g. 'make install'
if ! (( $# )); then
	echo "Error: Command is missing."
	exit 1
fi >&2
mkdir -p "$BUILD_DIR"
_snapshot before
"$@"
_snapshot after

# Find differences
(
	set +e
	comm -13 "$BUILD_DIR/before-d.txt" "$BUILD_DIR/after-d.txt" | grep -v "^$BUILD_DIR" > "$BUILD_DIR/diff-d.txt"
	comm -13 "$BUILD_DIR/before-f.txt" "$BUILD_DIR/after-f.txt" | grep -v "^$BUILD_DIR" > "$BUILD_DIR/diff-f.txt"
	comm -13 "$BUILD_DIR/before-l.txt" "$BUILD_DIR/after-l.txt" | grep -v "^$BUILD_DIR" > "$BUILD_DIR/diff-l.txt"
	true
)

# Create package directory structure
mkdir -p "$BUILD_DIR/$PACKAGE_DIR/DEBIAN"
cd       "$BUILD_DIR/$PACKAGE_DIR"

# Create directories
while IFS= read -r DIR; do
	mkdir -p ./"$DIR"
done < "$BUILD_DIR/diff-d.txt"

# Move files and symlinks
while IFS= read -r FILE; do
	DIR=$(dirname "$FILE")
	mkdir -p ./"$DIR"
	mv "$FILE" ./"$DIR"/
done < <(cat "$BUILD_DIR/diff-f.txt" "$BUILD_DIR/diff-l.txt")

# Include docs?
if (( INCLUDE_DOCS == 1 )); then
	(
		cd -
		shopt -s nullglob
		for i in ABOUT ABOUT-NLS ANNOUNCE AUTHORS *BUGS* CHANGES CONFIGURATION *COPYING* *COPYRIGHT* CREDITS ChangeLog Changelog CHANGELOG CONTRIBUTORS *FAQ* FEATURES FILES HACKING History HISTORY INSTALL* LICENSE LSM MANIFEST NEWS *README* *Readme* SITES *RELEASE* RELNOTES THANKS TIPS TODO VERSION CONFIGURATION* GPL License Doc doc Docs* docs* Roadmap ROADMAP; do
			if [ -f "$i" ]; then
				mkdir -p "$BUILD_DIR/$PACKAGE_DIR/usr/share/doc/$APP"
				mv "$i"  "$BUILD_DIR/$PACKAGE_DIR/usr/share/doc/$APP/"
			fi
		done
	)
fi

# Get package size in KB
SIZE=$(du -sk . | awk '{print $1}')

# Create control file
# https://www.debian.org/doc/debian-policy/ch-controlfields.html#debian-binary-package-control-files-debian-control
cat > DEBIAN/control <<-EOF
	Package: $APP
	Version: $VERSION-1
	Priority: $PRIORITY
	Section: $SECTION
	Maintainer: $MAINTAINER
	Architecture: $TARGETARCH
	Installed-Size: $SIZE
	Depends: $DEPENDS
	Description: $DESCRIPTION
EOF
