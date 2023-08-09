# App engine with Oauth authentication
NodeJS app deployed on App Engine, with authentication against Cloud Identity. There is no frontend included, just the token exchange on the backend


## Overall architecture



## Project structure
```
.
|-- README.md
|-- app
|   |-- app.yaml
|   |-- package.json
|   `-- server.js
|-- appengine.tf
|-- config.tf
|-- install.sh
|-- terraform.tfvars.json
`-- vars.tf

```

## Setup

1. Follow the following procedure to create a Web Application Oauth Credentials in your GCP project [https://developers.google.com/workspace/guides/create-credentials#oauth-client-id](https://developers.google.com/workspace/guides/create-credentials#oauth-client-id). Use `https://YOUR_PROJECT_ID.ew.r.appspot.com/oauth2callback` as an Authorized redirect URI.


2. Find out your GCP project's id and number from the dashboard in the cloud console, and update the following variables in the `terraform.tfvars.json` file. Replace `YOUR_PROJECT_NMR`, `YOUR_PROJECT_ID`,  `YOUR_PROJECT_REGION`, `YOUR_OAUTH_CLIENT_ID`, and `YOUR_OAUTH_CLIENT_SECRET` with the correct values. 

```shell
{
    "project_id": "YOUR_PROJECT_ID",
    "project_nmr": YOUR_PROJECT_NMR,
    "project_default_region": "YOUR_PROJECT_REGION",
    "web_application_client_id": "YOUR_OAUTH_CLIENT_ID",
    "web_application_client_secret": "YOUR_OAUTH_CLIENT_SECRET"
}
```

## Install

1. Run the following command at the root of the folder:
```shell 
$ sudo ./install.sh
$ terraform init
$ terraform plan
$ terraform apply
```

> Note: You may have to run `terraform plan` and `terraform apply` twice if you get errors for serviceaccounts not found

2. Build and deploy the docker image in CloudRun service, by issuing the following command at the root of the project:

```shell
$ ./deploy.sh
```
