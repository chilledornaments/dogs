# dog-api
Random pictures of my dogs!

## Terraform

### Workspace env vars

For OIDC role assumption to work, these env vars must be set in the workspace:

- `TFC_AWS_PROVIDER_AUTH = true`
- `TFC_AWS_RUN_ROLE_ARN = <role ARN>`