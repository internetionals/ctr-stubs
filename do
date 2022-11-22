#!/bin/sh

set -eu
[ "${DEBUG_DO:-0}" -eq 0 ] || set -x 

BASEDIR="$(cd "$(dirname -- "$0")"; pwd -L)"

[ -n "${USER:-}" ] || USER="$(id -u -n)"
[ -n "${UID:-}" ] || UID="$(id -u)"
[ -n "${GROUP:-}" ] || GROUP="$(id -g -n)"
[ -n "${GID:-}" ] || GID="$(id -g)"
[ -n "${GECOS:-}" ] || GECOS="$(id -F)"
[ -n "${HOME:-}" ] || HOME="$(dscacheutil -q user -a name "$USER" | grep '^dir: ' | sed -e 's/^dir: //')"

quiet () {
	EV=0
	OUT="$("$@" 2>&1)" || EV=$?
	if [ "$EV" -ne 0 ] || [ "${DEBUG_DO:-0}" -ne 0 ]; then
		echo "Command '$*' exited with status $EV" >&2
		if [ -n "$OUT" ]; then
			echo "$OUT" | sed -e 's/^/  /' >&2
		fi
	fi
	return $EV
}

silent () {
	OUT="$("$@" 2>&1)" || return
}

image_exists () {
	silent docker image inspect "$1"
}

image_build () {
	quiet docker build \
		${BUILD_ARGS:-} \
		--build-arg BASE_IMAGE="${BASE_IMAGE:-alpine}" \
		--build-arg USER="$USER" \
		--build-arg UID="$UID" \
		--build-arg GROUP="$GROUP" \
		--build-arg GID="$GID" \
		--build-arg GECOS="$GECOS" \
		--build-arg HOME="$HOME" \
		-t "$1" \
		"$2"
}

IMG="$1"
shift
if [ "${FORCE_REBUILD:-0}" -ne 0 ] || ! image_exists "$USER-do-$IMG"; then
	if [ "${FORCE_REBUILD:-0}" -ne 0 ] || ! image_exists "do-$IMG"; then
		BUILD_ARGS="--pull" image_build "do-$IMG:latest" "$BASEDIR/$IMG"
	fi
	BUILD_ARGS="" BASE_IMAGE="do-$IMG:latest" image_build "$USER-do-$IMG" "$BASEDIR"
fi

VOLS="${VOLS:-${EXTRA_VOLS:-} $PWD}"
VOLS="$(echo "$VOLS" | sort -ur)"
DOCKER_ARGS="${DOCKER_ARGS:-}"
for VOL in $VOLS; do
	if [ -e "$VOL" ]; then
		DOCKER_ARGS="$DOCKER_ARGS --volume=$VOL:$VOL"
	fi
done

docker run -ti --rm $DOCKER_ARGS -u "$UID:$GID" -w "$PWD" "$USER-do-$IMG" "$@"
