ARG BASE_IMAGE
FROM ${BASE_IMAGE}

USER 0

ARG USER
ARG UID
ARG GROUP
ARG GID
ARG HOME
ARG GECOS
RUN set -eux; \
	. /etc/os-release; \
	if [ "$ID" = alpine ]; then \
		addgroup -g "${GID}" "${GROUP}" || true; \
		GROUP="$(getent group "${GID}" | cut -f1 -d:)"; \
		adduser -h "${HOME}" -G "${GROUP}" -u "${UID}" -g "${GECOS}" -D "${USER}"; \
	elif [ "$ID" = debian ]; then \
		addgroup --gid "${GID}" "${GROUP}" || true; \
		GROUP="$(getent group "${GID}" | cut -f1 -d:)"; \
		adduser -q --home "${HOME}" --gid "${GID}" --uid "${UID}" --gecos "${GECOS}" --disabled-password "${USER}"; \
	else \
		echo "No adduser support"; \
		exit 1; \
	fi;

ENTRYPOINT []
USER "${USER}"
WORKDIR "${HOME}"
