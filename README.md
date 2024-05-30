# Bootstrap

This repository bootstraps a google cloud environment using an infrastructure as configuration approach with terraform. The primary purpose of the bootstrap process is to set up workload federated identity integration with github so that all future terraform applies are executed using github actions and no privileged access is required to the google cloud environment. This repository also sets up the folder, project and service accounts for the environment and handles all the IAM bindings using authoritative bindings at the role level to custom roles. 
