## 1. Establish current state

- [x] 1.1 Record the clean linked worktree state, fetch `origin/main`, inspect incoming files, and merge it without rewriting history
- [x] 1.2 Read the current agent contract, skill, contributor guide, OpenSpec config, and development-workflow spec before editing

## 2. Clarify contributor policy

- [x] 2.1 Scope strict worktree and plan-first rules to AI agents in `AGENTS.md` and verify the human path is not described as mandatory there
- [x] 2.2 Narrow the skill's OpenSpec decision gate to high-risk or durable contracts and verify ordinary focused changes can use issue or PR planning
- [x] 2.3 Add the lightweight human workflow to `CONTRIBUTING.md` and verify it does not require AI tools, OpenSpec, or a separate worktree
- [x] 2.4 Align `openspec/config.yaml`, the delta spec, and the main development-workflow spec with the approved audience and risk tiers, then validate the main specs

## 3. Keep regression checks automatic

- [x] 3.1 Replace the explicit Lua regression-test list with sorted `tools/test-*.lua` discovery and verify all checked-in test files execute

## 4. Validate the result

- [x] 4.1 Validate the EveryQuest skill with `quick_validate.py`
- [x] 4.2 Run `shellcheck tools/verify-addon.sh` and `tools/verify-addon.sh`
- [x] 4.3 Run `openspec validate --all` and inspect the complete diff with `git diff --check`
