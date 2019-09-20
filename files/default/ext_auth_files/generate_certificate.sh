#!/usr/bin/env bash
#
# Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.


# Generate a 5 year self-signed certificate and a new RSA private key and copy in the given path.
# The command must be executed as root.

# Usage:  ./generate_certificate.sh "/etc/parallelcluster/ext-auth-certificate.pem" dcvextauth dcv

_check_set() {
  file="$1"
  message="$2"
  if [[ -z "${file}" ]]; then
      >&2 echo "${message}"
      exit 1
  fi
}

main() {
  path="$1"
  user="$2"
  group="$3"
  _check_set "${path}" "Path required"
  _check_set "${user}" "User required"
  _check_set "${group}" "Group required"

  # Generate a new certificate and a new RSA private key
  openssl req -new -x509 -days 1825 -subj "/CN=localhost" -nodes -out "${path}" -keyout "${path}"
  chmod 440 "${path}"
  chown "${user}":"${group}" "${path}"
}

main "$@"
