# Agentic AI session TA

Template repository for the BME 6120 Project 4 agentic AI session.

**Homework assignment (due Dec 8, 2026):** [docs/homework-before-session-2.md](docs/homework-before-session-2.md)

Opening a GitHub Codespace from this repo builds the dev container defined in
[`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json), so every student gets the
same environment:

- Python 3.12, with numpy, pandas, scipy, matplotlib, seaborn, statsmodels, scikit-learn and
  ipykernel (versions pinned in [`requirements.txt`](requirements.txt))
- Node.js
- Claude Code (`claude`)
- GitHub Copilot CLI (`copilot`)
- OpenAI Codex CLI (`codex`)
- Google Antigravity CLI (`agy`)

## Open a codespace

Click **Use this template → Create a new repository** to make your own copy. Then, in your copy,
click **Code → Codespaces → Create codespace on main**. Do not open a codespace on this repository
itself: you cannot push to it.

## Status

Draft. The dev container was test-built on Nov 16, 2026, and all four agent CLIs installed.
`requirements.txt` was added on Nov 18 and test-installed on Python 3.12. Still to add: R.
