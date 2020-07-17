# Michael Berger Terraform Technical Challenge.

Thank you for this challenge and the time extension. I really appreciate it. After running into some problems that would not resolve, I restarted this challenge, basically, from scratch this morning. I was able to meet most of the requirements, however some where not completed. I used an iterative approach to this challenge, completing different parts then moving to the next. I would start completely over each time with project creation. I, unfortunatly, ran into quota issues with creating projects due to this approach. Towards the end of this time frame I received the following error... Error: Error waiting for creating folder: Error code 8, message: The project cannot be created because you have exceeded your allotted project quota.  UGH. I was working on putting the subnets into the shared VPC, as during my testing I was using auto_create_subnetworks = "true" to create subnets inside the shared VPC. I have left the code in main.tf, but I commented out the sub1-4 creation so the build will work once I can create projects again. 

## Instance Types and OS
I chose f1 micros for this exercise. The reasoning is pretty simple, there is no workload that will take place on these instances and I'm trying to stay within the $300 credit limit from Google. The RHEL 7 instance has a default disk size of 20 GB which is what the requirements stated, so there's no explicid call to disk size in the main.tf file.

## Service Account User
I created a service account within a project that was only used for this service account user. The user was given proper permissions for creating projects in other projects and well as the roles listed below.

## Creating Shared VPC.
I ran into some problems creating Shared VPCs as I had never done this in terraform. The initial problem I ran into with SharedVPC is that you are unable to create shared VPC unless your account has an org node. The account I initially started with was a general account based on a gmail account. I then had to "dust off" my old account I had with an org node. The billing account assocuiated with that account was in closed state due to the cc being expited and my credits being expired. I created a new user in that same account and was given the $300 credit and created a new billing account to be able to create infrastructire in this new account. In addition to this issue, perimssions to create and activate the SharedVPC proved to be something I needed to research.

Ensure that the application default credentials (and the ServiceAccount user designated for automation) have permission to create and manage projects and Shared VPCs (sometimes called 'XPN'). The example also requires you to specify a billing account, since it does start up a few VMs.

Regular Accounts:
    gcloud organizations add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/compute.xpnAdmin"

ServiceAccounts:
    gcloud organizations add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/compute.xpnAdmin"

Regular Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/compute.xpnAdmin"
Service Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/compute.xpnAdmin"

Regular Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='user:support@internetinnovation.com' --role="roles/resourcemanager.projectIamAdmin"
Service Accounts:
    gcloud beta resource-manager folders add-iam-policy-binding 325998602966 --member='serviceAccount:terraform@michaelberger-terraform-admin.iam.gserviceaccount.com' --role="roles/resourcemanager.projectIamAdmin"


I had a problem with metadata_startup_script, found some help here - https://serverfault.com/questions/1017276/use-metadata-startup-script-in-google-cloud-template-in-terraform


## Folders
I was also unable to test after I put the projects into folders, due to the quote issue. I removed the folder lines out of the code, so I knew the build would work. Below is what was removed. Replace the org id with your own. 

    resource "google_project" "host_project" {
        name            = "Host Project"
        project_id      = "tf-vpc-${random_id.host_project_name.hex}"
        org_id          = var.org_id
        billing_account = var.billing_account_id
        folder_id  = google_folder.management.name
    }

    resource "google_folder" "management" {
        display_name = "Management"
        parent       = "organizations/325998602966"
    }

    resource "google_project" "service_project_1" {
        name            = "Service Project 1"
        project_id      = "tf-vpc-${random_id.service_project_1_name.hex}"
        org_id          = var.org_id
        billing_account = var.billing_account_id
        folder_id  = google_folder.applications.name
    }

    resource "google_folder" "applications" {
        display_name = "Applications"
        parent       = "organizations/325998602966"
    }


## How to
Begin by cloning the repo at git@github.com:mberger/cf-gcp.git. You will need a service account user with the permissions mentioned above. Download your credentials from Google Cloud Console; the default path for the downloaded file is ~/.gcloud/Terraform.json. If you use another path, update the credentials_file_path variable. Ensure that these credentials have Organization-level permissions - this example will create and administer projects.

Run the following to build the infrastructure: 
    terraform init \
            -var="region=us-useast1" \
            -var="region_zone=us-east1-b" \
            -var="org_id=325998602966" \
            -var="billing_account_id=01B494-EFBA64-4E3B48"

    terraform plan \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"

    terraform apply \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"

To destroy the infrastructure: 
    terraform destroy \
        -var="region=us-useast1" \
        -var="region_zone=us-east1-b" \
        -var="org_id=325998602966" \
        -var="billing_account_id=01B494-EFBA64-4E3B48"


## Random Notes:
getting base image names:
    gcloud compute images list
service account user:
    terraform@michaelberger-terraform-admin.iam.gserviceaccount.com
This was my starting point for the most part today:https://github.com/terraform-providers/terraform-provider-google/tree/master/examples/shared-vpc

## Links 
https://www.terraform.io/docs/providers/google/r/google_folder.html
https://www.terraform.io/docs/providers/google/r/compute_instance_template.html
https://www.terraform.io/docs/providers/google/r/google_project.html
https://registry.terraform.io/modules/GoogleCloudPlatform/lb-http/google/1.0.9/examples/shared-vpc
LOL - https://support.google.com/cloud/answer/7283050?hl=en
https://stackoverflow.com/questions/57682483/terraform-gcp-startup-script-local-file-instead-of-inline
https://cloud.google.com/vpc/docs/shared-vpc
Also, a pdf that I downloaded called gcp-shared-vcp-deployment-guide.pdf from Palo Alto Networks. I don't find the link.