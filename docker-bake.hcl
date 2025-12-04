fullname = ( environment == "testing") ? "${registry}/postgis-testing" : "${registry}/postgis"
fullname_vectorchord = ( environment == "testing") ? "${registry}/postgis-vectorchord-containers-testing" : "${registry}/postgis-vectorchord-containers"
url = "https://github.com/pablo-tx/postgis-vectorchord-containers"

// MANUALLY EDIT THE CONTENT - to add new PostGIS major version
variable "postgisMajorVersions" {
  default = [
    "3"
  ]
}

// MANUALLY EDIT THE CONTENT - to add new VectorChord versions
variable "vectorchordVersions" {
  default = [
    "1.0.0"
  ]
}

// PostGIS matrix of distro x versions
postgisMatrix = {
  bookworm = {
    // renovate: suite=bookworm-pgdg depName=postgis
    "3" = "3.6.1+dfsg-1.pgdg12+1"
  }
  trixie = {
    // renovate: suite=trixie-pgdg depName=postgis
    "3" = "3.6.1+dfsg-1.pgdg13+1"
  }
}

// VectorChord version mapping
vectorchordMatrix = {
  bookworm = {
    "1.0.0" = "1.0.0"
  }
  trixie = {
    "1.0.0" = "1.0.0"
  }
}

variable "distributions" {
  default = [
    "bookworm",
    "trixie"
  ]
}

variable "imageTypes" {
  default = [
    "standard",
    "system"
  ]
}

target "postgis" {
  matrix = {
    tgt = imageTypes
    distro = distributions
    postgisMajor = postgisMajorVersions
    pgVersion = getPgVersions(postgreSQLVersions, postgreSQLPreviewVersions)
  }

  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "cwd://Dockerfile"
  context = "."
  name = "postgis-${postgisMajor}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${postgisMajor}-${tgt}-${distro}",
    "${fullname}:${index(split(".",cleanVersion(pgVersion)),0)}-${getShortPostgisVersion(distro, postgisMajor)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${tgt}-${distro}",
    "${fullname}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${getPostgisPackage(distro, postgisMajor)}"
    POSTGIS_MAJOR = postgisMajor
    BASE = "${getBaseImage(pgVersion, tgt, distro)}"
  }
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=${url}",
    "index,manifest:org.opencontainers.image.source=${url}",
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${getPostgisVersion(distro, postgisMajor)}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} container image",
    "index,manifest:org.opencontainers.image.documentation=${url}",
    "index,manifest:org.opencontainers.image.authors=${authors}",
    "index,manifest:org.opencontainers.image.licenses=Apache-2.0",
    "index,manifest:org.opencontainers.image.base.name=${getBaseImage(pgVersion, tgt, distro)}",
  ]
  labels = {
    "org.opencontainers.image.created" = "${now}",
    "org.opencontainers.image.url" = "${url}",
    "org.opencontainers.image.source" = "${url}",
    "org.opencontainers.image.version" = "${pgVersion}",
    "org.opencontainers.image.revision" = "${revision}",
    "org.opencontainers.image.vendor" = "${authors}",
    "org.opencontainers.image.title" = "CloudNativePG PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS ${pgVersion}-${getPostgisVersion(distro, postgisMajor)} container image",
    "org.opencontainers.image.documentation" = "${url}",
    "org.opencontainers.image.authors" = "${authors}",
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.base.name" = "${getBaseImage(pgVersion, tgt, distro)}"
  }
}

target "postgis-vectorchord" {
  matrix = {
    tgt = imageTypes
    distro = distributions
    postgisMajor = postgisMajorVersions
    vectorchordVersion = vectorchordVersions
    pgVersion = getPgVersions(postgreSQLVersions, postgreSQLPreviewVersions)
  }

  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  dockerfile = "cwd://Dockerfile"
  context = "."
  name = "postgis-vectorchord-${postgisMajor}-${index(split(".",cleanVersion(pgVersion)),0)}-${tgt}-${distro}"
  tags = [
    "${fullname_vectorchord}:${index(split(".",cleanVersion(pgVersion)),0)}-${postgisMajor}-${vectorchordVersion}-${tgt}-${distro}",
    "${fullname_vectorchord}:${index(split(".",cleanVersion(pgVersion)),0)}-${getShortPostgisVersion(distro, postgisMajor)}-${vectorchordVersion}-${tgt}-${distro}",
    "${fullname_vectorchord}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion}-${tgt}-${distro}",
    "${fullname_vectorchord}:${cleanVersion(pgVersion)}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion}-${formatdate("YYYYMMDDhhmm", now)}-${tgt}-${distro}",
  ]
  args = {
    PG_MAJOR = "${getMajor(pgVersion)}"
    POSTGIS_VERSION = "${getPostgisPackage(distro, postgisMajor)}"
    POSTGIS_MAJOR = postgisMajor
    VECTORCHORD_TAG = "${vectorchordVersion}"
    BASE = "${getBaseImage(pgVersion, tgt, distro)}"
  }
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=${url}",
    "index,manifest:org.opencontainers.image.source=${url}",
    "index,manifest:org.opencontainers.image.version=${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion}",
    "index,manifest:org.opencontainers.image.revision=${revision}",
    "index,manifest:org.opencontainers.image.vendor=${authors}",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostGIS+VectorChord ${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion} ${tgt}",
    "index,manifest:org.opencontainers.image.description=A ${tgt} PostGIS+VectorChord ${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion} container image",
    "index,manifest:org.opencontainers.image.documentation=${url}",
    "index,manifest:org.opencontainers.image.authors=${authors}",
    "index,manifest:org.opencontainers.image.licenses=Apache-2.0",
    "index,manifest:org.opencontainers.image.base.name=${getBaseImage(pgVersion, tgt, distro)}",
  ]
  labels = {
    "org.opencontainers.image.created" = "${now}",
    "org.opencontainers.image.url" = "${url}",
    "org.opencontainers.image.source" = "${url}",
    "org.opencontainers.image.version" = "${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion}",
    "org.opencontainers.image.revision" = "${revision}",
    "org.opencontainers.image.vendor" = "${authors}",
    "org.opencontainers.image.title" = "CloudNativePG PostGIS+VectorChord ${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion} ${tgt}",
    "org.opencontainers.image.description" = "A ${tgt} PostGIS+VectorChord ${pgVersion}-${getPostgisVersion(distro, postgisMajor)}-${vectorchordVersion} container image",
    "org.opencontainers.image.documentation" = "${url}",
    "org.opencontainers.image.authors" = "${authors}",
    "org.opencontainers.image.licenses" = "Apache-2.0"
    "org.opencontainers.image.base.name" = "${getBaseImage(pgVersion, tgt, distro)}"
  }
}

function getBaseImage {
  params = [ pgVersion, imageType, distro ]
  result = format("ghcr.io/cloudnative-pg/postgresql:%s-%s-%s", cleanVersion(pgVersion), imageType, distro)
}

function getPostgisPackage {
  params = [distro, postgisMajor]
  result = postgisMatrix[distro][postgisMajor]
}

// Gets the MM.mm.pp postgis version, e.g. "3.6.0"
function getPostgisVersion {
  params = [ distro, postgisMajor ]
  result = join(".", slice(split(".", split("+", getPostgisPackage(distro, postgisMajor))[0]), 0, 3))
}

// Gets the MM.mm postgis version, e.g. "3.6"
function getShortPostgisVersion {
  params = [ distro, postgisMajor ]
  result = join(".", slice(split(".", split("+", getPostgisPackage(distro, postgisMajor))[0]), 0, 2))
}

function getVectorchordPackage {
  params = [distro, vectorchordVersion]
  result = vectorchordMatrix[distro][vectorchordVersion]
}
