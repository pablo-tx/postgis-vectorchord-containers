# Building PostGIS Container Images for CloudNativePG

This guide explains how to build PostGIS operand images for
[CloudNativePG](https://cloudnative-pg.io) using
[Docker Bake](https://docs.docker.com/build/bake/) together with a
[GitHub Actions workflow](.github/workflows/bake.yml).

## Prerequisites

This project depends on
[`postgres-containers`](https://github.com/cloudnative-pg/postgres-containers).
Before you begin, ensure that you have met the same prerequisites and
requirements described there:

- [Prerequisites](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#prerequisites)
- [Verifying requirements (from the `postgres-containers` project)](https://github.com/cloudnative-pg/postgres-containers/blob/main/BUILD.md#verifying-requirements)

To confirm that your environment is correctly set up for building PostGIS
images, run:

```bash
# The two docker-bake.hcl files are:
# - the one from the upstream postgres-containers repository (remote)
# - the one from this project (local), which extends/overrides the upstream file
docker buildx bake --check \
  -f docker-bake.hcl \
  -f cwd://docker-bake.hcl \
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \
  postgis
```

## How It Works

This repository extends the build system of
[`postgres-containers`](https://github.com/cloudnative-pg/postgres-containers)
by defining PostGIS as an additional build target.

It achieves this by:

- Including the upstream [`docker-bake.hcl`](https://github.com/cloudnative-pg/postgres-containers/blob/main/docker-bake.hcl)
  file as a source definition.
- Extending it locally with the [`docker-bake.hcl`](docker-bake.hcl) in this
  repository, which adds the `postgis` target.

This modular setup allows you to reuse the same configuration, overrides, and
build attributes from the upstream project, while keeping PostGIS-specific
settings separate and maintainable, including the supply chain.

## PostGIS Target

The `postgis` target in Bake is defined as a Cartesian product of the following
dimensions:

- **Base Image** (e.g. `18-standard-trixie`)

  - **PostgreSQL major version** (e.g. `18`)
  - **Image type** (e.g. `standard`)
  - **Operating system codename** (e.g. `trixie`)
- **Platforms**
- **PostGIS version**

# Building PostGIS Images

To build all available PostGIS images, run:

```bash
# The two docker-bake.hcl files are:
# - the one from the upstream postgres-containers repository (remote)
# - the one from this project (local), which extends/overrides the upstream file
docker buildx bake --push \
  -f docker-bake.hcl \
  -f cwd://docker-bake.hcl \
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \
  postgis
```

> **IMPORTANT:** Always specify the `postgis` target (or a more specific one).
> If you omit the target, Bake will attempt to build all upstream targets
> (including the default PostgreSQL-only images).

This approach, based on
[remote Bake file definitions](https://docs.docker.com/build/bake/remote-definition/),
lets you combine multiple Bake files so that:

- The full configuration from the upstream project is inherited.
- Local overrides and PostGIS-specific settings are applied cleanly.

### Limiting the Build

You can narrow down the build scope to a specific PostGIS/PostgreSQL
combination using target naming conventions.

PostGIS targets follow this pattern:

```
postgis-<postgisMajor>-<postgresMajor>-<variant>-<os>
```

Examples:

- Build all PostGIS 3 images for PostgreSQL 17:

  ```bash
  docker buildx bake \
    -f docker-bake.hcl \
    -f cwd://docker-bake.hcl \
    "https://github.com/cloudnative-pg/postgres-containers.git#main" \
    postgis-3-17*
  ```

- Build a specific image (PostGIS 3, PostgreSQL 17, `standard` variant,
  Debian Trixie):

  ```bash
  docker buildx bake \
    -f docker-bake.hcl \
    -f cwd://docker-bake.hcl \
    "https://github.com/cloudnative-pg/postgres-containers.git#main" \
    postgis-3-17-standard-trixie

## Building PostGIS + VectorChord Images

The project also supports building images that include both PostGIS and VectorChord extensions.

To build all available PostGIS + VectorChord images, run:

```bash
# The two docker-bake.hcl files are:
# - the one from the upstream postgres-containers repository (remote)
# - the one from this project (local), which extends/overrides the upstream file
docker buildx bake --push \
  -f docker-bake.hcl \
  -f cwd://docker-bake.hcl \
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \
  postgis-vectorchord
```

### Limiting the Build

You can narrow down the build scope to specific PostGIS/VectorChord/PostgreSQL combinations using target naming conventions.

PostGIS + VectorChord targets follow this pattern:

```
postgis-vectorchord-<postgisMajor>-<postgresMajor>-<variant>-<os>
```

Examples:

- Build all PostGIS 3 + VectorChord 1.0.0 images for PostgreSQL 17:

  ```bash
  docker buildx bake \
    -f docker-bake.hcl \
    -f cwd://docker-bake.hcl \
    "https://github.com/cloudnative-pg/postgres-containers.git#main" \
    postgis-vectorchord-3-17*
  ```

- Build a specific image (PostGIS 3, VectorChord 1.0.0, PostgreSQL 17, `standard` variant, Debian Trixie):

  ```bash
  docker buildx bake \
    -f docker-bake.hcl \
    -f cwd://docker-bake.hcl \
    "https://github.com/cloudnative-pg/postgres-containers.git#main" \
    postgis-vectorchord-3-17-standard-trixie
  ```

### Image Tags

PostGIS + VectorChord images are tagged with the following pattern:
`postgres-version-postgis-version-vectorchord-version-type-os`

Examples:
- `17.7-3.6.1-1.0.0-standard-bookworm`
- `18.1-3.6.1-1.0.0-system-trixie`

### Registry Configuration

By default, images are pushed to `ghcr.io/pablo-tx/postgis-vectorchord-containers`. To use a different registry, set the `registry` environment variable:

```bash
export registry=ghcr.io/your-username
docker buildx bake --push \
  -f docker-bake.hcl \
  -f cwd://docker-bake.hcl \
  "https://github.com/cloudnative-pg/postgres-containers.git#main" \
  postgis-vectorchord
```
  ```
