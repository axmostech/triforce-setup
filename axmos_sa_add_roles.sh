export SA_NAME=organization-scanner@axmos-triforce-assessment.iam.gserviceaccount.com;
export PROJECT_ID=$1;

if [ -z "$PROJECT_ID" ]; then
  echo "Error: Please provide a project ID as a command-line argument."
  echo "Ex: ./axmos_sa_add_roles.sh prj-one-prd"
  exit 1
fi


ORG_ID="$(gcloud projects get-ancestors $PROJECT_ID --format=json | jq -r '.[]|select(.type | startswith("org"))|.id')"

echo "==========================================================================================="
echo ""
echo "IMPORTANT: Please copy this Organization ID and send it to AXIOS throw the Enrollment Form"
echo ""
echo "Org Id: "$ORG_ID;
echo ""
echo "==========================================================================================="

AXMOS_SA_ROLES=(
'roles/appengine.appViewer' \
'roles/artifactregistry.reader' \
'roles/bigquery.metadataViewer' \
'roles/bigtable.viewer' \
'roles/billing.viewer' \
'roles/cloudfunctions.viewer' \
'roles/cloudsql.viewer' \
'roles/composer.user' \
'roles/compute.networkViewer' \
'roles/compute.viewer' \
'roles/container.viewer' \
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
'roles/recommender.viewer' \
'roles/securitycenter.adminEditor' \
'roles/serviceusage.serviceUsageConsumer' \
'roles/iam.serviceAccountUser' \
'roles/artifactregistry.writer' \
'roles/monitoring.viewer' \
'roles/bigquery.metadataViewer' \
'roles/serviceusage.serviceUsageAdmin' \
'roles/containerregistry.ServiceAgent' \
'roles/cloudasset.owner' 
)

echo "Assigning roles to the service account at the organization..."
for role in "${AXMOS_SA_ROLES[@]}"
do
  echo "Assigning $role... to $SA_NAME at the organization";
  gcloud organizations add-iam-policy-binding ${ORG_ID} \
    --member=serviceAccount:"$SA_NAME" \
    --role="$role" \
    --no-user-output-enabled --quiet;
done

ON_PROJECT_PERMISSIONS=(
  'roles/run.admin' \
  'roles/cloudbuild.builds.editor' \
  'roles/storage.admin' \
  'roles/bigquery.jobUser' \
  'roles/bigquery.dataOwner' \
  'roles/bigquery.user'
)

echo "Assigning roles to the service account in the project..."
for role in "${ON_PROJECT_PERMISSIONS[@]}"
do
  echo "Assigning $role to $SA_NAME in the project"

  gcloud iam service-accounts add-iam-policy-binding $SA_NAME \
    --member=serviceAccount:$SA_NAME \
    --role="$role" \
    --no-user-output-enabled --quiet
done


echo "Script completed successfully."
