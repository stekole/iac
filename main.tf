terraform {
  #   backend "gcs" {
  #     bucket = "terraform-state-bucket"
  #     prefix = "environment/"
  #   }

}

locals {
  
  project_id = local.project_id_mapping[terraform.workspace]
  #example of getting the workspace-specific project ID, and if that fails, it defaults to the "stg" value.
  # project_id = try(local.project_id_mapping[terraform.workspace], local.project_id_mapping["stg"])

  project_id_mapping = {
    prd  = "test-project-prd"
    stg  = "test-project-stg"
    test = "test-project-test"
    //default = "test-project-sre"
  }
  env = terraform.workspace
  regions = {
    prd = [
      "eu-west2",
      "northamerica-northeast1",
      "us-central1",
      "us-west1",
    ]
    stg = [
      "northamerica-northeast1",
      "us-west1",
    ]
  }
}





