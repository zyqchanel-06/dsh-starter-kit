# Superpowers on DeepSeek Harness (DSH) — tool mapping

Superpowers skills speak in actions ("dispatch a subagent", "create a todo",
"read a file"). On DeepSeek Harness those actions resolve to the tools below.

| Action | DSH tool |
|---|---|
| Invoke a skill | `skill` (exact name; `superpowers:<name>` -> `<name>`) |
| Read a file / image | `read` / `read_image` |
| Create / overwrite a file | `write` |
| Targeted edit of a file | `edit` |
| Run a shell command | `pwsh` (PowerShell on Windows; supports `run_in_background: true` and `workdir`) |
| Search file contents | `grep` |
| Find files by name / glob | `glob` |
| Web search | `web_search` |
| Dispatch a fresh subagent | `subagent` (isolated context; background by default) |
| Dispatch a subagent that inherits this conversation | `subagent_fork` |
| Send a follow-up to a live subagent | `send_message` |
| List / recall background subagents | `list_agents` |
| Create / update todos | `todo_write` (send the FULL list every call; it replaces the previous list) |

## Skill references

Skills reference each other with a `superpowers:` prefix (e.g.
`superpowers:brainstorming`, `superpowers:systematic-debugging`). On DSH, invoke
them with the `skill` tool using the bare name (drop the prefix). Each skill is
installed as a bundle at `~/.dsh/skills/<name>/SKILL.md`.

Relative file references inside a skill (e.g. `./implementer-prompt.md`,
`./code-reviewer.md`, `references/…`) resolve against the skill's own directory
under `~/.dsh/skills/<name>/` — read them with `read` when the skill tells you to.

## Subagent notes

- DSH subagents do not inherit this session's context. Pass a complete,
  self-contained prompt; the skills' prompt templates (`./implementer-prompt.md`,
  `./code-reviewer.md`, `./task-reviewer-prompt.md`, `./re-review-prompt.md`) are
  built for exactly this.
- The `subagent` tool has no per-dispatch model selector in this session; do not
  invent a model parameter. The harness chooses the model.
- "Never poll a wait interface" maps to DSH background-job notices: dispatch
  subagents in the background and wait for the runtime completion notice instead
  of busy-polling.