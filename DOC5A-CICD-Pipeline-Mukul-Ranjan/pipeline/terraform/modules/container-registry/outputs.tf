output "repository_key" {
  description = "JFrog Artifactory Docker repository key for NovaPay container images."
  value       = artifactory_local_docker_v2_repository.novapay.key
}

output "repository_id" {
  description = "JFrog Artifactory repository ID."
  value       = artifactory_local_docker_v2_repository.novapay.id
}

output "repository_name" {
  description = "JFrog Artifactory repository name."
  value       = artifactory_local_docker_v2_repository.novapay.key
}

output "docker_image_repository" {
  description = "Repository path to use when tagging NovaPay container images. The Artifactory host/registry prefix is supplied by the CI/CD environment."
  value       = artifactory_local_docker_v2_repository.novapay.key
}
