# Triforce - Google Cloud Service Account Generator

This is a bash script used for assigning specific roles at organization level to a service account in Google Cloud Platform.

## Dependencies

This script requires the following dependencies:

- Google Cloud SDK (includes `gcloud`)
- `jq`

Ensure these are installed and properly configured on your system. This script has been tested on Debian-based systems, but should work on any system with the above dependencies installed.

## Permissions

The executing user must have the following IAM permissions to run this script:


- `roles/resourcemanager.organizationAdmin`:  Predefined role to manage organization IAM roles.

- `roles/resourcemanager.organizations.setIamPolicy`: Specific permission to manage organization IAM roles.

Please ensure that the executing user has these permissions in the Google Cloud Platform IAM settings.

## Set Vars

Replace the following placeholders with your own details in the axmos_sa_add_roles.sh file:

* [SA_NAME]: Replace with the name you want to give to your service account. This name must be unique within the project. Service account names must be between 6 and 30 characters (inclusive), must begin with a lowercase letter, and consist of lowercase letters, numbers, and hyphens.

* [PROJECT_ID]: Replace with your project's ID.


```bash
export $SA_NAME=
export $PROJECT_ID=
```


## Usage

To use this script, run it in your terminal with the email of the service account and the project ID as arguments:

```bash
./axmos_sa_add_roles.sh
```
