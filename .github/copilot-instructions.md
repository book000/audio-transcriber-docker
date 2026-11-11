# GitHub Copilot Instructions

Review according to [`AGENTS.md`](../AGENTS.md), which is the source of truth for project guidance.

## Language

- Commit messages, PR/Issue text, review comments, code comments and documentation are in English; runtime messages (logs, errors) are English.
- `README-ja.md` is a Japanese translation of `README.md` and must be kept in sync with it.

## Review checklist

- Commit and PR titles follow Conventional Commits.
- No secrets or personal information in code or logs.
- User-visible behavior changes update `README.md` and `README-ja.md`.
- Shell scripts pass ShellCheck.

## Do not flag

- Code inside `page.evaluate()` in `main.js` runs in the browser; undeclared globals such as `webkitSpeechRecognition` and `recognition` are intentional.
- `--no-sandbox` is intentional (Chrome runs inside a Docker container).
- Mixed `snake_case` / `camelCase` and style-only differences follow the existing code.
