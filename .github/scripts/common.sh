#!/bin/bash

function die() {
  echo "$*"
  exit 1
}

function upper_to_lower() {
  text=$1
  echo "$text" | tr '[:upper:]' '[:lower:]'
}

function lower_to_upper() {
    text=$1
    echo "$text" | tr '[:lower:]' '[:upper:]'
}

function docker_login() {
  DOCKERHUB_USERNAME=$1
  DOCKERHUB_PASSWORD=$2

  set +o history
  echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin
  set -o history
}

function bump_docker_image_version() {
  docker_repo_name=$1
  docker_image_name=$2
  major_minor_patch=$3

  # Get latest docker image version
  TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKERHUB_USERNAME}'", "password": "'${DOCKERHUB_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)
  current_version=$(curl -s -H "Authorization: JWT ${TOKEN}" "https://hub.docker.com/v2/repositories/${docker_repo_name}/${docker_image_name}/tags/?page_size=500" | jq -r '.results | sort_by(.last_updated) | .[-2] | .name')

  echo "Current version - ${current_version}"

  major_version=$(echo "${current_version}" | cut -d'.' -f 1)
  minor_version=$(echo "${current_version}" | cut -d'.' -f 2)
  patch_version=$(echo "${current_version}" | cut -d'.' -f 3)


  if [[ "${major_minor_patch}" == "major" ]]; then
    major_version=$((major_version+1))
    minor_version=0
    patch_version=0
  elif [[ "${major_minor_patch}" == "minor" ]]; then
    minor_version=$((minor_version+1))
    patch_version=0
  elif [[ "${major_minor_patch}" == "patch" ]]; then
    patch_version=$((patch_version+1))

  else
    die "Bad parameter - ${major_minor_patch}"
  fi

  echo "New version - "${major_version}.${minor_version}.${patch_version}""

  new_version="${major_version}.${minor_version}.${patch_version}"

  echo "${new_version}"
}
