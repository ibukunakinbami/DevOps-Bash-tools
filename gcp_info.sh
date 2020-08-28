#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  shellcheck disable=SC1090
#
#  Author: Hari Sekhon
#  Date: 2020-08-13 19:38:39 +0100 (Thu, 13 Aug 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Gather common GCP environment info for quickly surveying new client environments
#
# Requires:
#
# - GCloud CLI to be available and configured 'gcloud init'
#   (or just use Cloud Shell, will prompt you to set the project if it's not already)
# - API services to be enabled (or to select Y to enable them when prompted)
# - Billing to be enabled in order to enable API services
#
# Tested with Google Cloud SDK installed locally

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists GCP deployed resources in the current or specified GCP Project

Make sure that you run this from an authorized network so things like kubectl don't hang

Lists in this order (categories broadly reflect the GCP Console grouping of services):

    - GCloud SDK version
    - Auth, Organizations & Config:
      - Organizations
      - Auth Configurations
      - Current Configuration & Properties
    - Projects:
      - Project Names & IDs
      - Current Project
      - checks project is set to continue with the following
    - Services & APIs:
      - Enabled Services & API
      - collectors all available services to only show enabled services from this point onwards
    - Accounts & Secrets:
      - IAM Service Accounts
      - Secrets Manager secrets
    - Compute:
      - GCE Virtual Machines
      - App Engine instances
      - Cloud Functions
      - GKE Clusters
      - Kubernetes, for every GKE cluster:
        - cluster-info
        - master component statuses
        - nodes
        - namespaces
        - deployments, replicasets, replication controllers, statefulsets, daemonsets, horizontal pod autoscalers
        - storage classes, persistent volumes, persistent volume claims
        - service accounts, resource quotas, network policies, pod security policies
        - pods  # might be too much detail if you have high replica counts, so done last, comment if you're sure nobody has deployed pods outside deployments
    - Storage:
      - Cloud SQL instances
      - Cloud Storage Buckets
      - Cloud Filestore
      - Cloud Memorystore Redis
      - BigTable clusters and instances
      - Datastore Indexes
    - Networks:
      - VPC Networks
      - Addresses
      - Proxies
      - Subnets
      - Routers
      - Routes
      - VPN Gateways
      - VPN Tunnels
      - Reservations
      - Firewall Rules & Forwarding Rules
      - DNS managed zones & verified domains
    - Big Data:
      - Dataproc clusters       (all regions)
      - Dataflow jobs           (all regions)
      - PubSub topics
      - Cloud IOT Registries    (all regions)
    - Tools:
      - Cloud Source Repositories
      - Cloud Builds
      - Container Registry Images
      - Deployment Manager

Can optionally specify a project id to switch to and list info for (will switch back to original project on any exit except kill -9)
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<project_id>]"

help_usage "$@"

check_bin gcloud


# GCloud SDK tools versions
cat <<EOF
# ============================================================================ #
#                              G C l o u d   S D K
# ============================================================================ #

EOF

gcloud version
#echo
#gsutil version -l
#echo
#bq version
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_auth_config.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_projects.sh"
echo
echo

# ============================================================================ #
echo "LISTING INFO FOR PROJECT:  $(gcloud info --format="get(config.project)")"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_services.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_accounts_secrets.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_compute.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_storage.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_networking.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_bigdata.sh"
echo
echo

# ============================================================================ #
. "$srcdir/gcp_info_tools.sh"
echo
echo

# Finished
cat <<EOF
# ============================================================================ #
# Finished listing resources for GCP Project $(gcloud config list --format="value(core.project)")
# ============================================================================ #
EOF
