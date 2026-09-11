# Segregation of duties, break-glass and reviews

## AI Attribution Block

AI-assisted control design. Role assignments, approvals, access reviews and emergency events require real identity-system configuration and evidence.

## Required separation

| Activity | Initiator | Required independent control | Prohibited combination |
| --- | --- | --- | --- |
| Source merge | Developer | Protected-branch review and CI checks | Author approving/merging own protected change |
| Build, scan, sign, publish | CI workload identity | Exact GitHub OIDC trust; immutable provenance/signature verification | Developer AWS keys or CI cluster-admin role |
| Staging promotion | Release operator/CI | Environment protection and reviewed GitOps PR | Direct `kubectl` or ArgoCD sync bypass |
| Production promotion | Release operator | Production environment reviewer and GitOps PR reviewer independent of source/GitOps author | Source author self-approval; CI merging its own promotion PR |
| Database D1 execution | Database migration executor | Approved plan and database owner; compatibility gates in `docs/04-database-migration/` | Deployer silently executing an unapproved migration |
| Contract/recovery | Database/incident owner | Separate approved recovery decision | Automated destructive rollback |
| IAM/KMS policy change | Security/platform owner | Peer review and auditable change | Application developer self-granting privileged role |

Use distinct human groups for developers, release approvers, database owners, IAM/KMS administrators, ArgoCD/platform operators, security auditors, and incident commanders. Membership in production approver, IAM administrator, database production executor and break-glass groups is time-bounded and reviewed; no one role should routinely hold conflicting permissions.

## Break-glass

Break-glass is an emergency, named, MFA-protected role with no standing assignment. Its trust path must require strong authentication and an incident/change ticket reference where the identity provider supports session tags. Activation requires two authorized people (incident commander plus security/platform approver when feasible), records identity, justification, target, start/end time and commands/API events, and expires automatically. After use, revoke the session, rotate any exposed credentials, review the activity, and open a corrective action. It does not authorize bypassing cryptographic verification, destructive database rollback, or deletion of evidence.

## Audit and access reviews

Collect and retain according to approved regulatory retention policy: GitHub audit/ruleset/environment events; AWS CloudTrail management and relevant data events; STS AssumeRole and OIDC federation events; EKS control-plane audit logs; Kubernetes/ArgoCD audit events; KMS key-use/administration events; registry image/signature actions; and database migration approval/execution records. Logs must identify a human or workload principal, action, target, time, source/change reference and result, with secrets and sensitive payment data redacted.

Review privileged and production access at least quarterly, and immediately after role change, transfer, termination, incident or break-glass use. Review service-role policies, GitHub Environment reviewers, ArgoCD project roles, EKS workload associations, KMS key administrators/users, dormant accounts, OIDC subject conditions and Cosign trust identities. Record reviewer, population, decisions, removals and exceptions; this repository cannot manufacture that evidence.
