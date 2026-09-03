# Shared agent skills

This directory is the canonical source for personal skills shared by Codex and
Factory.

- The `agents` package is stowed into `~/.agents`, the canonical cross-agent
  source.
- `install_factory_hooks.py` links each skill into both `~/.codex/skills` and
  `~/.factory/skills`, covering Codex and Factory versions that do not discover
  `~/.agents/skills` directly.
- `stow.sh` and `stow_utils.sh` pass `--adopt-existing`, which safely adopts
  an identical installed copy and keeps a backup before replacing it with a
  link. Non-identical skills are left untouched.

Add a skill as `agents/.agents/skills/<skill-name>/SKILL.md`, including any
references or scripts it needs. Keep generated caches such as `__pycache__`
out of the repository.
