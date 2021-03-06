# Copyright (c) 2018 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# We want to use bash
SHELL:=/bin/bash

# Default target, no other targets should be before default
.PHONY: default
default: all

# Include Makefiles
include docker/base/Makefile.base
include docker/ha-scale-vpn/Makefile.ha-scale-vpn
include docker/jitike/Makefile.jitike
include docker/anycast/Makefile.anycast

# Setup proxies for docker build
ifeq ($(HTTP_PROXY),)
HTTPBUILD=
else
HTTPBUILD=--build-arg HTTP_PROXY=$(HTTP_PROXY)
endif
ifeq ($(HTTPS_PROXY),)
HTTPSBUILD=
else
HTTPSBUILD=--build-arg HTTPS_PROXY=$(HTTPS_PROXY)
endif

DOCKERBUILD=docker build ${HTTPBUILD} ${HTTPSBUILD}

.PHONY: all check docker-build
#
# The all target is what is used by the travis-ci system to build the Docker images
# which are used to run the code in each run.
#
all: check docker-build

check:
	@shellcheck `find . -name "*.sh"`

docker-build: docker-build-ha-scale-vpn docker-build-jitike docker-build-anycast

# Travis
.PHONY: travis
travis:
	@echo "=> TRAVIS: $$TRAVIS_BUILD_STAGE_NAME"
	@echo "Build: #$$TRAVIS_BUILD_NUMBER ($$TRAVIS_BUILD_ID)"
	@echo "Job: #$$TRAVIS_JOB_NUMBER ($$TRAVIS_JOB_ID)"
	@echo "AllowFailure: $$TRAVIS_ALLOW_FAILURE TestResult: $$TRAVIS_TEST_RESULT"
	@echo "Type: $$TRAVIS_EVENT_TYPE PullRequest: $$TRAVIS_PULL_REQUEST"
	@echo "Repo: $$TRAVIS_REPO_SLUG Branch: $$TRAVIS_BRANCH"
	@echo "Commit: $$TRAVIS_COMMIT"
	@echo "$$TRAVIS_COMMIT_MESSAGE"
	@echo "Range: $$TRAVIS_COMMIT_RANGE"
	@echo "Files:"
	@echo "$$(git diff --name-only $$TRAVIS_COMMIT_RANGE)"

# NOTE: We do not run ha-scale-vpn by default here because it has issues in travis-ci.
#       See #31 for more details.
.PHONY: run
run: run-ha-scale-vpn run-jitike run-anycast

# NOTE: We do not test ha-scale-vpn by default here because it has issues in travis-ci.
#       See #31 for more details.
.PHONY: test
test:
	@echo "Passed"
