#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

##############################################################
# This script is used to compile thrift-service
# Usage:
#    sh build.sh
#
##############################################################

# Bugzilla 37848: When no TTY is available, don't output to console
have_tty=0
# shellcheck disable=SC2006
if [[ "`tty`" != "not a tty" ]]; then
    have_tty=1
fi

 # Only use colors if connected to a terminal
if [[ ${have_tty} -eq 1 ]]; then
  PRIMARY=$(printf '\033[38;5;082m')
  RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  BLUE=$(printf '\033[34m')
  BOLD=$(printf '\033[1m')
  RESET=$(printf '\033[0m')
else
  PRIMARY=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  RESET=""
fi

echo_r () {
    # Color red: Error, Failed
    [[ $# -ne 1 ]] && return 1
    # shellcheck disable=SC2059
    printf "[%sDoris%s] %s$1%s\n"  $BLUE $RESET $RED $RESET
}

echo_g () {
    # Color green: Success
    [[ $# -ne 1 ]] && return 1
    # shellcheck disable=SC2059
    printf "[%sDoris%s] %s$1%s\n"  $BLUE $RESET $GREEN $RESET
}

echo_y () {
    # Color yellow: Warning
    [[ $# -ne 1 ]] && return 1
    # shellcheck disable=SC2059
    printf "[%sDoris%s] %s$1%s\n"  $BLUE $RESET $YELLOW $RESET
}

echo_w () {
    # Color yellow: White
    [[ $# -ne 1 ]] && return 1
    # shellcheck disable=SC2059
    printf "[%sDoris%s] %s$1%s\n"  $BLUE $RESET $WHITE $RESET
}

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
os400=false
# shellcheck disable=SC2006
case "`uname`" in
CYGWIN*) cygwin=true;;
OS400*) os400=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [[ -h "$PRG" ]]; do
  # shellcheck disable=SC2006
  ls=`ls -ld "$PRG"`
  # shellcheck disable=SC2006
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    # shellcheck disable=SC2006
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
# shellcheck disable=SC2006
ROOT=$(cd "$(dirname "$PRG")" &>/dev/null && pwd)
export DORIS_HOME=$(cd "$ROOT/../" &>/dev/null && pwd)

. "${DORIS_HOME}"/env.sh

# include custom environment variables
if [[ -f ${DORIS_HOME}/custom_env.sh ]]; then
    . "${DORIS_HOME}"/custom_env.sh
fi

echo_g " build starting..."
${MVN_BIN} clean package -Dthrift.binary=${THRIFT_BIN} "$@"


EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
  DIST_DIR=${DORIS_HOME}/dist
  [ ! -d "$DIST_DIR" ] && mkdir "$DIST_DIR"
  dist_jar=$(ls "${ROOT}"/target | grep "thrift-service")
  rm -rf "${DIST_DIR}"/"${dist_jar}"
  cp "${ROOT}"/target/"${dist_jar}" "$DIST_DIR"
  echo_g "*****************************************************************"
  echo_g "Successfully build Thrift-Service-SDK"
  echo_g "dist: $DIST_DIR/$dist_jar "
  echo_g "*****************************************************************"
  exit 0
else
  echo_w "Failed build Thrift-Service-SDK"
  exit $EXIT_CODE
fi
