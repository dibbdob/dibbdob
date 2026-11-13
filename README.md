# Building with Claude, in five repositories

I build software with Claude Code, and build software that runs on Claude. These five repositories show
both, around one small fictional support desk, so each one can be read on its own and all five fit
together.

Each was built in stages. Every stage is a branch merged with a message written like a pull request
(in plain terms, what changed, tests, review findings), and each stage exists because the one before it
left something unguarded. The history is meant to be read: it shows the decisions, the mistakes the
checks caught, and the fixes.

## About this portfolio

**Why it exists.** At the time of writing, Claude's certifications are taken through Claude Partner
Network firms. These repositories are how I show, before joining one, that I am ready for the Claude
Certified Architect – Foundations exam, and for the work its partners' clients pay for.

**Where it comes from.** It is built on two things:

- **Real-world experience.** I built and ran a production .NET system with Claude Code. The first
  repository recreates, from scratch and without that system's code, the workflow I used on it:
  specifications with testable acceptance criteria, a coordinator command, read-only subagents held by
  hooks, and an independent review. It then takes that workflow further than I did: to a team, and onto
  OpenSpec, an open-source framework for the specifications.
- **The rest of the exam's ground.** The other four take that discipline into the domains a Claude Code
  workflow does not touch: the Claude API and structured output, MCP servers, the Agent SDK, and running
  a Claude-powered service in production.

**How it was made.** I built these in November 2026, with Claude Code. Each history is arranged as the
stages of lessons learned, not as a record of months of work: the commit dates show it was all written in
a day. Every commit is co-authored by Claude, because directing Claude well is the skill on show. Each
README says what has been verified and what has not. In each, the last stage is the first real run
against a live model, and what it found. The repositories were recreated on GitHub once their histories
were final, so none holds pull requests from before; the first repository's README says which of its
GitHub runs were on its first copy.

## The repositories

| Repository | What it is | Built with | Stages | Tests | ADRs |
|---|---|---|---|---|---|
| `claude-code-governed-workflow` | A Claude Code setup that delivers an OpenSpec change end to end: a coordinator command, a read-only spec reader, a reviewer that is never told the author's reasons, hooks and checks that enforce what prompts only ask, packaged as a plugin, and built for a team: a brief in an issue, refinement as a reviewed pull request with its risk stated, a folder per delivery, pull requests checked on GitHub | Claude Code, OpenSpec, Node, Python, GitHub Actions | 15 | 52, and the hook's own | 9 |
| `claude-structured-extraction` | Turns a support email into the fields a desk acts on, with the Claude API: structured outputs, validation with one corrective retry, a cached prompt, an eval with confidence intervals, batch backfill, model routing held to a measurement | C#, .NET 10, `Anthropic` SDK | 8 | 48 | 6 |
| `mcp-server-dotnet` | An MCP server over the desk's tickets: tools a model can choose between, errors it can act on, annotations a host can trust, customer text labelled as untrusted, Streamable HTTP behind an origin check and a token | C#, `ModelContextProtocol` SDK | 8 | 37, all through the protocol | 4 |
| `agent-sdk-orchestrator` | Triages the open tickets with a hub of isolated worker agents: a checked structured handoff, synthesis from findings only, partial completion, a tool guard and audit hook, budgets, resume, an escalation queue | TypeScript, Claude Agent SDK | 8 | 29 | 5 |
| `ticket-intake-service` | The capstone: a running service that takes an email in, extracts it, prioritises it and never loses it, with OpenTelemetry, a Grafana dashboard as code, containers, a runbook, and a Kubernetes deployment verified on a local cluster | ASP.NET Core, Docker, OpenTelemetry, Kubernetes | 6 | 24 | 2 |

Every build runs without calling a model or spending anything. To check all five at once:

```bash
./verify-all.sh
```

## Against the Claude Certified Architect – Foundations domains

The domains and weights below are as published in third-party study guides for the exam; Anthropic's
own exam guide is the authority on them.

| Domain | Weight | Where it is shown |
|---|---|---|
| **Agentic architecture and orchestration** | 27% | `agent-sdk-orchestrator`: hub and spoke in code, one isolated worker per ticket, failure as a value, partial completion, escalation (`src/coordinator.ts`, ADRs 0001, 0003, 0005). `claude-code-governed-workflow`: a coordinator command with parallel subagents (`.claude/commands/deliver.md`) |
| **Claude Code configuration and workflows** | 20% | `claude-code-governed-workflow`: CLAUDE.md at project and directory level with each rule a pointer at its check; subagents with tool limits and model routing; `PreToolUse` hooks that fail closed; spec-driven development with OpenSpec; project permissions; headless `claude -p`; a plugin and marketplace generated from the project, which moves the read-only hook to plugin level because plugin subagents ignore `hooks` |
| **Prompt engineering and structured output** | 20% | `claude-structured-extraction`: a schema built from one taxonomy and enforced by the API; stop reasons read before text; one corrective retry; a sectioned, cached prompt with few-shot examples that the build keeps out of the eval set; an eval with 95% intervals (ADRs 0001 to 0004) |
| **Tool design and MCP integration** | 18% | `mcp-server-dotnet`: names and descriptions a model can choose by, actionable `isError` results, annotations, bounded results, stdio and Streamable HTTP, project and user scope configuration (ADRs 0001 to 0004). `agent-sdk-orchestrator`: in-process MCP tools bound to one ticket |
| **Context management and reliability** | 15% | `agent-sdk-orchestrator`: one ticket per context, a synthesiser that never sees customer text, checkpoint and resume. `ticket-intake-service`: an email is never lost to the model; idempotency, concurrency limits, telemetry with no customer data (ADR 0001) |

The Developer – Foundations scope (the Claude API, tool use and agent development) is covered by
`claude-structured-extraction`, `mcp-server-dotnet` and `agent-sdk-orchestrator`. The questions a
Professional exam covers (integration architecture, governance, evaluation) run through all five: the
ADRs, the eval, the budgets and the guards.

## What ties them together

- **A check is shown failing before it is trusted.** Across the five, that found a UTC gate that could
  not fail, a hook whose character scan no test depended on, a read-only allowlist that let
  `git grep -O` through (and then its fix, which still let `-iO` and `--open` through), a build that passed with zero tests, a cost that counted only a failure's last reply, and a
  dashboard whose p95 was wrong by a factor of 500. Each is in the commit that fixed it.
- **Running it for real finds what a stand-in cannot.** The first live runs found an empty field the API
  refused, a summary that miscounted its own tickets, copied code that lagged its source's fix, a reviewer
  that kept finding smaller things for four rounds, and a command list that let an unlisted `rm` through.
  Each is fixed in its repository's last stage.
- **Instructions are enforced where they can be.** A rule that matters becomes a hook, a schema, a
  bound tool, a build gate or a type, and the prose points at it.
- **Untrusted text is marked as untrusted.** Each of the four repositories that handle customer text
  has an email that tries to instruct its reader, and shows what happens to it.
- **Nothing spends without saying so.** The command-line tools that call the Claude API (repos 2 and 4)
  print an estimate or a ceiling and stop unless told `--yes`, and costs are reported per item, retries
  and fallbacks included. Repo 1's unattended runs are capped by a turn limit, and its run on GitHub starts
  only when someone adds a label; repo 5 calls a model only once switched to live mode.
- **Each README says what has not been verified.** A live run is a decision about spending money, not
  something a build should make. The five that were made cost under $4 in all, most of it one unattended
  delivery.

## What has not been run yet

| Repository | Not yet run | How |
|---|---|---|
| `claude-code-governed-workflow` | `/deliver` in an attended session, OpenSpec's propose and explore skills, the packaged plugin installed, and the overnight `deliver` workflow (an unattended delivery has run for real, and the build, ruleset, `refined` and `claimed` on GitHub) | A session, then the README's bot setup |
| `claude-structured-extraction` | The batch backfill, and a refusal answered by server-side fallback (the three evals have run, and settled ADR 0006) | `backfill … --yes`, then a ticket that triggers a refusal |
| `mcp-server-dotnet` | An attended session approving the server, and a host other than Claude Code (a model has used the tools headless) | Approve the project server in Claude Code |
| `agent-sdk-orchestrator` | A partial run and its resume, and a worker stopped by its budget (a full triage has run) | `--yes --budget 0.05`, then `--yes --run <id>` |
| `ticket-intake-service` | A deployment to a cloud's managed Kubernetes (live mode has run on the local cluster) | The changes ADR 0002 lists |

## A note from the human

Somewhere along the way I stopped writing most of the code and started writing down what it had to do,
then checking it had been done. The tools are very good. The lessons were mine to learn: that "please
don't write any files" is a request, not a security model; that a check isn't a check until you've
watched it fail; and that the model is rarely the problem when the instructions are. These repositories
are partly those lessons, written down.
