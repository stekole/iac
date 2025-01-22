resource "google_project_iam_member" "project" {
  project = var.project_id
  role    = var.role
  member  = "user:${var.member}" # add var.domain here to lock to a company
}

