# Commit-to-production flow (target: under two hours)

## AI Attribution Block

AI-assisted target workflow. It is a gate-budget design, not a measured delivery-time claim or evidence that protections are configured.

1. A reviewed pull request runs source control, build, SAST, dependency/container scan, integration/contract test, controlled ZAP scan, and policy gates.
2. `main` builds once and publishes one digest, an SBOM, and a keyless Cosign signature. The release metadata binds the digest to its source revision.
3. A promotion operator runs the promotion workflow with that exact image and digest. The workflow verifies the signature, edits only an environment overlay, and opens a GitOps pull request.
4. Dev can merge under its configured controls. Staging and production require GitHub Environment approval by a person other than the source author.
5. ArgoCD reconciles the approved overlay. Argo Rollouts verifies preview/canary health and aborts to the stable revision on analysis failure. A rollback is a reviewed Git revert to a previously verified digest.

The intended two-hour budget depends on short, enforced CI jobs; a pre-authorized controlled DAST target; and timely approvers. No manual direct-cluster workaround is part of this flow.
