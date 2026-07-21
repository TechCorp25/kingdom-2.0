# Gate-change proposals — owner-promotion drop zone

`automate-dev-suite/gates/**` is owner-gated and hook-enforced
(`.claude/hooks/gates-guard.py`, ported from v1's global-approval pattern):
the assistant cannot edit gate definitions, the gate map, or the risk
envelope directly — the gate framework may not modify itself.

## The approved flow

1. The assistant writes the full proposed file here as
   `<ISO8601>-<target-name>.md` (complete replacement content, plus a short
   header note of what changed and why).
2. The owner reviews it.
3. **The owner promotes it by hand in their own terminal — this `git mv` IS
   the approval signal:**
   ```bash
   git mv automate-dev-suite/gates/_proposals/<ISO8601>-<target>.md \
          automate-dev-suite/gates/<target>.md
   ```
   (committed on the session branch → PR → owner merge, per policy).
4. Reject = delete the proposal.

Only files actually present in `gates/` are live. Anything in `_proposals/`
is a draft with no authority. The assistant never `git mv`s its own proposal
— the guard blocks it, and doing it another way is a contract breach, not a
shortcut.
