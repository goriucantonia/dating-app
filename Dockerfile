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
# broken resolve fails loudly at build time — S1-B9).
COPY pyproject.toml ./
RUN pip install .

# The dev workflow bind-mounts ./server over /app; this COPY makes the image
# self-sufficient when run without the mount.
COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
