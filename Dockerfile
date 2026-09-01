# Builds the `api` image from the server submodule (build context is ./server,
# so paths below are relative to server/). Lives at the superproject root by
# owner decision, 2026-09-01 — see communication_protocol.md §2.

FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# postgresql-client provides psql for the Step 1 acceptance check
# (psql from inside `api` must reach `db`; the same attempt from the host must fail).
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Resolve the dependency set first so source edits don't re-resolve (and so a
# broken resolve fails loudly at build time — S1-B9). The package COPY itself
# is uninstalled again: a baked site-packages copy of `app` silently shadows
# the bind-mounted live code for scripts (DEFECTS.md D-004).
#
# `.[dev]` and not `.`: pytest and ruff are how this project checks its own
# definition of done, and until 2026-09-01 they were in the image only because
# someone had once installed them by hand. That is invisible, unreproducible,
# and it vanished the moment the image was rebuilt (see D-012 for the same
# shape of problem next door). Declared dependencies or they do not exist.
# Trade: a larger image. Accepted — this image is the dev target, bind-mounted
# and running --reload; nothing about it is minimal already.
COPY pyproject.toml ./
RUN pip install ".[dev]" && pip uninstall -y dating-app-server

# The dev workflow bind-mounts ./server over /app; this COPY makes the image
# self-sufficient when run without the mount. The editable install makes /app
# the ONE authoritative code location on sys.path, mounted or not.
COPY . .
RUN pip install --no-deps -e .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
