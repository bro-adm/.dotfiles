SHELL := /bin/bash

# --- Configuration Variables Read from Environment ---
# QUAY_SERVER defines the registry server URL.
ifeq ($(QUAY_SERVER), )
    QUAY_SERVER = quay.io
endif

# QUAY_USERNAME defines the registry username (Must be set via environment or command line).
# Example: export QUAY_USERNAME=...
ifeq ($(QUAY_USERNAME), )
    QUAY_USERNAME = required-username
endif

# QUAY_PASSWORD defines the registry password (Must be set via environment or command line).
# Example: export QUAY_PASSWORD=...
ifeq ($(QUAY_PASSWORD), )
    QUAY_PASSWORD = required-password
endif

# --- Internal Variables ---
GLOBAL_SECRET_NAME := pull-secret
GLOBAL_SECRET_NS := openshift-config
TEMP_CONFIG := /tmp/quay_config.json

# Service Account Configuration (for create-sa target)
SA_NAME ?= my-quay-sa
SECRET_NAME ?= quayme
AUTH_JSON_PATH ?= $(HOME)/.config/containers/auth.json

.PHONY: quay-add-private-repo-cluster-wide quay-link-namespaced-sa quay-podman-login-from-cluster quay-check_envs quay-help

# Primary execution target - Add private repo to cluster-wide pull secret
quay-add-private-repo-cluster-wide: quay-check_envs
	@echo "--- 🔑 Configuring Global Pull Secret ---"
	@echo ">>> 1. Downloading existing $(GLOBAL_SECRET_NAME)..."
	oc get secret $(GLOBAL_SECRET_NAME) -n $(GLOBAL_SECRET_NS) \
		--template='{{index .data ".dockerconfigjson" | base64decode}}' > $(TEMP_CONFIG)

	@echo ">>> 2. Adding credentials for $(QUAY_SERVER) to local config file..."
	oc registry login \
		--registry='$(QUAY_SERVER)' \
		--auth-basic='$(QUAY_USERNAME):$(QUAY_PASSWORD)' \
		--to=$(TEMP_CONFIG)

	@echo ">>> 3. Updating the cluster-wide $(GLOBAL_SECRET_NAME) in $(GLOBAL_SECRET_NS)..."
	oc set data secret/$(GLOBAL_SECRET_NAME) -n $(GLOBAL_SECRET_NS) \
		--from-file=.dockerconfigjson=$(TEMP_CONFIG)

	@echo ">>> 4. Cleaning up temporary file..."
		rm $(TEMP_CONFIG)

	@echo "✅ Cluster-wide config complete. Nodes can now pull from $(QUAY_SERVER)."

# Create a custom service account with private registry access
quay-link-namespaced-sa:
	@echo "--- 🔐 Creating Service Account with Private Registry Access ---"
	@echo ">>> 1. Creating secret $(SECRET_NAME) from $(AUTH_JSON_PATH)..."
	oc create secret generic $(SECRET_NAME) \
		--from-file=.dockerconfigjson=$(AUTH_JSON_PATH) \
		--type=kubernetes.io/dockerconfigjson

	@echo ">>> 2. Creating service account $(SA_NAME)..."
	oc create sa $(SA_NAME)

	@echo ">>> 3. Linking secret to service account for image pulls..."
	oc secrets link $(SA_NAME) $(SECRET_NAME) --for=pull

	@echo "✅ Service account $(SA_NAME) created and linked to $(SECRET_NAME)."

# Login to podman using credentials from cluster's global pull secret
quay-podman-login-from-cluster:
	@echo "--- 🐳 Logging into Podman using Cluster Credentials ---"
	@echo ">>> 1. Extracting auth string from cluster secret..."
	$(eval AUTH_STRING := $(shell oc get secret $(GLOBAL_SECRET_NAME) -n $(GLOBAL_SECRET_NS) -o jsonpath='{.data.\.dockerconfigjson}' | base64 --decode | jq -r '.auths."$(QUAY_SERVER)".auth'))
	@echo ">>> 2. Decoding credentials..."
	$(eval USER_TOKEN := $(shell echo '$(AUTH_STRING)' | base64 --decode))
	$(eval EXTRACTED_USERNAME := $(shell echo '$(USER_TOKEN)' | cut -d ':' -f 1))
	$(eval EXTRACTED_TOKEN := $(shell echo '$(USER_TOKEN)' | cut -d ':' -f 2-))
	@echo "Extracted Username: $(EXTRACTED_USERNAME)"
	@echo "Extracted Token (first 5 chars): $$(echo '$(EXTRACTED_TOKEN)' | cut -c1-5)..."
	@echo ">>> 3. Logging into podman..."
	@podman login $(QUAY_SERVER) -u '$(EXTRACTED_USERNAME)' -p '$(EXTRACTED_TOKEN)'
	@echo "✅ Podman login successful. You can now pull images from $(QUAY_SERVER)."

# --- Environment Variable Check ---
quay-check_envs:
ifeq ($(QUAY_USERNAME), required-username)
	$(error QUAY_USERNAME must be set. Example: export QUAY_USERNAME=your_user)
endif
ifeq ($(QUAY_PASSWORD), required-password)
	$(error QUAY_PASSWORD must be set. Example: export QUAY_PASSWORD=your_pass)
endif

# --- Help Target ---
quay-help:
	@echo "OpenShift Quay Registry Configuration Tool"
	@echo "=========================================="
	@echo ""
	@echo "## Available Targets:"
	@echo ""
	@echo "1. cluster-add-private-repo"
	@echo "   Add private registry credentials to cluster-wide pull secret."
	@echo "   Required: QUAY_USERNAME, QUAY_PASSWORD"
	@echo "   Example: make cluster-add-private-repo QUAY_USERNAME=user QUAY_PASSWORD=pass"
	@echo ""
	@echo "2. create-sa"
	@echo "   Create a service account with private registry access (when global config is insufficient)."
	@echo "   Variables: SA_NAME (default: $(SA_NAME)), SECRET_NAME (default: $(SECRET_NAME))"
	@echo "   Example: make create-sa SA_NAME=my-sa SECRET_NAME=my-secret"
	@echo ""
	@echo "3. podman-login-from-cluster"
	@echo "   Login to podman locally using cluster's global pull secret credentials."
	@echo "   Example: make podman-login-from-cluster"
	@echo ""
	@echo "## Variables (Override via ENV or CLI):"
	@echo "   QUAY_SERVER      : Registry URL. Default: $(QUAY_SERVER)"
	@echo "   QUAY_USERNAME    : Your Quay username (for cluster-add-private-repo)"
	@echo "   QUAY_PASSWORD    : Your Quay password (for cluster-add-private-repo)"
	@echo "   SA_NAME          : Service account name. Default: $(SA_NAME)"
	@echo "   SECRET_NAME      : Secret name. Default: $(SECRET_NAME)"
	@echo "   AUTH_JSON_PATH   : Path to auth.json. Default: $(AUTH_JSON_PATH)"
