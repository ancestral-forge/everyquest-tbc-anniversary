## 1. Establish the contract

- [x] 1.1 Inspect the existing GitLab workflow and release-delivery spec, verifying the admitted pipeline sources and current dependency graph
- [x] 1.2 Define tag and backup scenarios that require explicit activation for every exposed GitLab job

## 2. Make GitLab jobs manual

- [x] 2.1 Add rule-local blocking manual settings to `lua`, `openspec`, and `publish-release`, preserving their tag conditions and verifying release dependencies remain unchanged
- [x] 2.2 Add rule-local blocking manual settings to both `sync-github` conditions and verify the schedule/web pipeline boundary remains unchanged

## 3. Validate and preserve evidence boundaries

- [x] 3.1 Parse `.gitlab-ci.yml`, validate OpenSpec, run `tools/verify-addon.sh`, and check the final diff
- [x] 3.2 Record live GitLab pipeline behavior as pending because no push or pipeline execution is authorized
