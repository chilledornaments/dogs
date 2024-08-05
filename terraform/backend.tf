terraform {
  cloud {
    organization = "chilledornaments"

    workspaces {
      name = "dog-api"
    }
  }
}