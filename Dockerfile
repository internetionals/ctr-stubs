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
	case "$ID" in \
		alpine) \
			addgroup -g "${GID}" "${GROUP}" || true; \
			GROUP="$(getent group "${GID}" | cut -f1 -d:)"; \
			adduser -h "${HOME}" -G "${GROUP}" -u "${UID}" -g "${GECOS}" -D "${USER}"; \
			;; \
		debian|ubuntu) \
			addgroup --gid "${GID}" "${GROUP}" || true; \
			GROUP="$(getent group "${GID}" | cut -f1 -d:)"; \
			adduser -q --home "${HOME}" --gid "${GID}" --uid "${UID}" --gecos "${GECOS}" --disabled-password "${USER}"; \
			;; \
		fedora|rhel|centos) \
			addgroup --gid "${GID}" "${GROUP}" || true; \
			GROUP="$(getent group "${GID}" | cut -f1 -d:)"; \
			adduser --non-unique --no-create-home --home-dir "${HOME}" --gid "${GID}" --uid "${UID}" --comment "${GECOS}" --password '!' "${USER}"; \
			;; \
		*) \
			echo "No adduser support"; \
			exit 1; \
			;; \
	esac;

ENTRYPOINT []
USER "${USER}"
WORKDIR "${HOME}"
