export SA_NAME=axmos-assessment-sa;
export PROJECT_ID=axmos-internal-tools;

gcloud iam service-accounts create $SA_NAME --description="Axmos Triforce - Service Account" --display-name="Axmos Triforce - Service Account" --project=$PROJECT_ID

ORG_ID="$(gcloud projects get-ancestors $PROJECT_ID --format=json | jq -r '.[]|select(.type | startswith("org"))|.id')"
echo "Org Id: "$ORG_ID;




AXMOS_SA_ROLES=(
'roles/appengine.appViewer' \
'roles/artifactregistry.reader' \
'roles/bigquery.dataEditor' \
'roles/bigquery.metadataViewer' \
'roles/bigtable.viewer' \
'roles/billing.viewer' \
'roles/cloudasset.owner' \
'roles/cloudfunctions.viewer' \
'roles/cloudsql.viewer' \
'roles/composer.user' \
'roles/compute.networkViewer' \
'roles/compute.viewer' \
'roles/container.viewer' \
'roles/containerregistry.ServiceAgent' \
'roles/dataflow.viewer' \
'roles/dataproc.viewer' \
'roles/datastore.viewer' \
'roles/dns.reader' \
'roles/firebase.viewer' \
'roles/iam.securityReviewer' \
'roles/iam.serviceAccountViewer' \
'roles/logging.viewer' \
'roles/memcache.viewer' \
'roles/monitoring.alertPolicyViewer' \
'roles/monitoring.dashboardViewer' \
'roles/pubsub.viewer' \
'roles/redis.viewer' \
'roles/resourcemanager.folderViewer' \
'roles/resourcemanager.organizationViewer' \
'roles/run.viewer' \
'roles/secretmanager.viewer' \
'roles/serviceusage.serviceUsageAdmin' \
'roles/storage.admin' \
'roles/recommender.viewer' \
'roles/securitycenter.adminEditor' \
'roles/cloudbuild.builds.editor' \
'roles/serviceusage.serviceUsageConsumer' \
'roles/run.admin' \
'roles/iam.serviceAccountUser' \
'roles/artifactregistry.writer' \
'roles/monitoring.viewer'
)

for role in "${AXMOS_SA_ROLES[@]}"
do
  echo "Assigning $role... to $SA_NAME";
  gcloud organizations add-iam-policy-binding ${ORG_ID} \
    --member=serviceAccount:"$SA_NAME@axmos-internal-tools.iam.gserviceaccount.com" \
    --role="$role" \
    --no-user-output-enabled --quiet;
done
