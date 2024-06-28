# Bootstrap

This repository bootstraps a google cloud environment using an infrastructure as configuration approach with terraform. The primary purpose of the bootstrap process is to set up workload federated identity integration with github so that all future terraform applies are executed using github actions and no privileged access is required to the google cloud environment. This repository also sets up the folder, project and service accounts for the environment and handles all the IAM bindings using authoritative bindings at the role level to custom roles. 

Whilst this repository was designed to be used with multiple projects, this lab environment only uses one project. There are dummy project references for the following projects that all map to the same project
* prj_devops.yaml (prj-devops) - the devops project that owns the terraform service accounts
* prj_dev_network.yaml (prj-dev-network) - the development environment network host project
* prj_dev_tenant_1.yaml (prj-dev-tenant-1) - the development environment network service project for tenant 1

These projects all map to the lab-gke-se project for this deployment

All organization, folders, projects, services, foundation service accounts and IAM resources should be controlled through this repo. It should be used to create all organization level resources, folders and projects as well as any service accounts that are not part of the tenants infrastructure. It also sets up custom roles for organizations and projects and manages the role bindings for foundational elements. 

# Changes

To make changes to this repo, create a branch called feature/abc where abc is the feature change you want to make. Make the changes in your branch and push the changes to the repo. This will trigger a terraform plan of your changes and if these changes are acceptable then raise a PR to merge the feature to master. The merge to master will trigger an apply

