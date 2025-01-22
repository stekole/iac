# Infrastructure as Code Framework

This repo is an example of how to create self-service infrastructure using yaml files and terraform. This is a way to create infrastructure in a way that is easy to understand and maintain. Any form of infrastructure as code can significantly boost developer velocity and reduce toil.

I use Google Cloud Platform but you can bring this framework concept into any provider. 

The main idea is to have a yaml file that defines the infrastructure to manage. This repo can be used in two ways:
1. **A mono repo ->** single repo for easy of use
2. **Per service/purpose repo ->** per service model, (or per purpose?) such as "only managing iam roles". Purpose is up to your specific case.

**NOTE: Any function which requires separation of concerns I recommend splitting the code to a different repo and using *CODEOWNERS*. You will get better control over who can make changes.**

# How to use

Install some tools to get you started:

```bash
brew install cosign tenv
tenv tofu install
tofu init
```

Use a `tofu workspace list` command to see the workspaces available. If you are just getting started you will need to create them.

## 1. Deploy as a mono repo

This is the easy one. Just simply fork the repo and change any configuration in the directory structure below. 

| Directory | Description |
| --- | --- |
| .github/workflows | Github actions to run the terraform |
| ./infrastructure | Yaml code to create infrastructure. This is split by workspace/environment/ directories |
| ./modules | The terraform sub-modules to use |
| ./users | Yaml file to define users and roles |

Update your cloud secrets and yaml files with any infrastructure you want to create, and apply.

## 2. Deploy per service/purpose

This is a bit more tricky and requires some extra steps. 

Each service or repo you want to use this for needs a directory with a main.tf file. They will also need to add some tooling added to the CICD pipeline to plan and apply the configuration. Notem this also requires extra eyes, as you dont want to accidentally commit secrets or other sensitive information. You should add a CODEOWNERS file to your repo to ensure only certain people can approve or merge changes to the `main.tf`.

A CICD step or shared tool would run tofu and pull in the repo as a module. The yaml file locations can then be managed locally per service.

Call the module example in a `main.tf` file:
```hcl
## add a state file and possibly a few other configurations

module "example" {
  source = "https://github.com/stekole/iac/releases/download/v35/module.zip"

  iam_enabled = false
  # users_file = "./users.yaml" # uncomment and use with `iam_enabled = true`
  infrastructure_file = "./infrastructure.yaml"
}
```

You will need to auth with your provider
in this case we are using GCP
```gcloud auth application-default login```


## Sample tofu/terrform commands

```bash
# List workspaces
tofu workspace list

# Create new workspace
tofu workspace new stg
tofu workspace new prd

# Switch workspace
tofu workspace select stg

# Show current workspace
tofu workspace show

# run 
tofu workspace select stg && tofu plan
```

## Updating the yamls. 

See the invidual .yaml files for more details.

## CICD

I have setup some example github actions which does some basic checks. 
If you make any changes to yamls make sure you update the schema.json to refect any changes.

## Troubleshooting data objects with the console

Below are some example commands to help you debug the data objects.

```bash
tofu console

# Start console
tofu console

# Inspect the raw users list
local.users

# View the users map
local.users_map

# Examine the final role mappings
local.role_mappings

# Look at a specific mapping (replace key with actual username-role)
local.role_mappings["username-roles/viewer"]

# See all planned IAM bindings
google_project_iam_member.user_roles

# Create a list from values in a map
[ for email in local.users.*.email : email ]
[
  "email1@test.com",
  "email2@test.com",
  "email3@test.com",
]
 local.users.*.email
[
  "email1@test.com",
  "email2@test.com",
  "email3@test.com",
]

# Create a map of usernames to IDs for easy lookup
#${local.user_name_to_id[user.name]}
user_name_to_id = { for user in local.users : lower(username) => user.id }

[for key, value in local.instances: format("Each.key is %s. Each.value is %v", key, value)]

```




