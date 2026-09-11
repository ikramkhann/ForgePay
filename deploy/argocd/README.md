# ArgoCD integration structure

## AI Attribution Block

AI-assisted template only. No ArgoCD instance, repository credential, destination cluster, or Application registration is asserted.

Render `application.yaml.tmpl` separately for dev, staging, and production once the GitOps repository URL and registered cluster server are authorized. ArgoCD renders each overlay with `--enable-helm`; it is the only deployer. Automated prune and self-heal remain disabled by default so progressive-rollout failure handling and reviewed rollback Git revisions remain explicit.
