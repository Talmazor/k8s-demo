#!/bin/bash

set -x

major_minor_patch="${MAJOR_MINOR_PATCH}"
tag_latest="${TAG_LATEST}"
docker_repo_name="${DOCKER_REPO_NAME}"
docker_image_name="${DOCKER_IMAGE_NAME}"

source common.sh

bump_docker_image_version "${docker_repo_name}" "${docker_image_name}" "${major_minor_patch}"

echo "${new_version}"

echo "docker_image_name=${docker_image_name}" >> $GITHUB_ENV
echo "PREVIOUS_VERSION=${current_version}" >> $GITHUB_ENV
echo "CURRENT_VERSION=${new_version}" >> $GITHUB_ENV

# Build docker image
cd ..

docker build --no-cache -t "${docker_repo_name}/${docker_image_name}:${new_version}" \
  --build-arg PORT=${DOCKER_PORT} \
  --build-arg ENVIRONMENT="${ENVIRONMENT}" .

docker_login "${DOCKERHUB_USERNAME}" "${DOCKERHUB_PASSWORD}" || die 'unable to login to docker hub' >/dev/null 2>&1

docker push docker.io/"${docker_repo_name}/${docker_image_name}:${new_version}"

tag_latest=$(upper_to_lower "${tag_latest}")

if [[ "${tag_latest}" =~ (true|"true") ]]; then
  docker tag "${docker_repo_name}/${docker_image_name}:${new_version}" "${docker_repo_name}/${docker_image_name}:latest"
  docker push "${docker_repo_name}/${docker_image_name}:latest"
fi

docker logout