# AI Attribution Block: AI-assisted OPA policy enforcing immutable digest references in GitOps overlays.
package forgepay.gitops

deny[msg] {
  input.kind == "Kustomization"
  image := input.images[_]
  not startswith(image.digest, "sha256:")
  msg := sprintf("image %q must use a sha256 digest", [image.name])
}

deny[msg] {
  input.kind == "Kustomization"
  image := input.images[_]
  contains(image.digest, "REPLACE_WITH")
  msg := sprintf("image %q has not been promoted", [image.name])
}
