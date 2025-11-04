#!/bin/bash
# Los Animales RP asset installation script.
# Downloads and extracts ped assets defined in peds/manifest.json.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CODEX_DIR="${SCRIPT_DIR}/.."
MANIFEST_FILE="${CODEX_DIR}/peds/manifest.json"

if ! command -v jq > /dev/null; then
  echo "Error: 'jq' is required to parse ${MANIFEST_FILE}. Please install jq and run again."
  exit 1
fi

ASSETS_DIR="${CODEX_DIR}/peds/assets"
mkdir -p "${ASSETS_DIR}"

mapfile -t rows < <(jq -c '.assets[]' "${MANIFEST_FILE}")
for row in "${rows[@]}"; do
  name=$(echo "${row}" | jq -r '.name')
  url=$(echo "${row}" | jq -r '.url')
  echo "Downloading ${name} from ${url} ..."
  tmpfile=$(mktemp)
  curl -L "${url}" -o "${tmpfile}"
  mkdir -p "${ASSETS_DIR}/${name}"
  unzip -o "${tmpfile}" -d "${ASSETS_DIR}/${name}" >/dev/null
  rm -f "${tmpfile}"
  echo "${name} installed."
done

echo "All assets installed to ${ASSETS_DIR}"