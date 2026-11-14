# AGENTS.md

Guidance for AI coding agents and contributors. `CLAUDE.md` imports this file, and `.github/copilot-instructions.md` adds the review checklist.

## Language

- All deliverables are written in **English**: commit messages, PR/Issue titles and bodies, review comments, code comments and docstrings, and documentation (`README.md`, `AGENTS.md`, etc.).
- `README-ja.md` is an intentionally kept Japanese translation of `README.md`. Update both together.
- Exceptions (keep as is): quotations, technical identifiers, generated files, and external source text.
- Runtime messages (logs, errors) are English.
- Do not rewrite Git history to change the language of past commits.

## Overview

`audio-transcriber-docker` transcribes the speech in a video or audio file. A Docker container plays the audio (via `paplay`) into a PulseAudio virtual microphone, and Chrome's Web Speech API (`webkitSpeechRecognition`, language `ja`), driven by Puppeteer, recognizes it. Final results are appended to `output/{DateTime}.txt`.

## Commands

There is no package manifest, test, lint or build script. Run it through the helper scripts, which need `ffmpeg` and Docker on the host:

```bash
./start.sh           # converts the input to audio.wav, builds the image, runs the container (mounts output/)
./start-mount.sh     # same, but also mounts user-dir/ (Chrome profile, for the first-time microphone setup)
shellcheck *.sh      # what CI runs on the shell scripts
```

`start.bat` / `start-mount.bat` are the Windows equivalents. CI (`.github/workflows/shellcheck-ci.yml`, a reusable workflow from `book000/templates`) only runs ShellCheck.

## Structure

- `main.js`: Puppeteer script. Launches `google-chrome` (non-headless, on the host's `DISPLAY`), opens the external page `https://book000.github.com/audio-transcriber`, plays the file with `paplay --device=MicOutput`, and starts `webkitSpeechRecognition` in the page. Recognized text is passed back through `page.exposeFunction("handleRecognized")` and appended to the output file. The browser closes when `paplay` exits.
- `entrypoint.sh`: container entrypoint. Starts PulseAudio, creates the `MicOutput` null sink and `VirtualMic` source, then runs `main.js` on `/opt/media/audio.wav`.
- `Dockerfile`: a Node.js slim base image plus PulseAudio, Japanese fonts, Puppeteer and Google Chrome. `audio.wav` (written by the scripts with `ffmpeg`) and `user-dir/` must exist in the build context. The start scripts create `user-dir/` before `docker build`, but a manual `docker build` on a fresh clone requires creating `user-dir/` first.
- `start.sh`, `start-mount.sh`, `start.bat`, `start-mount.bat`: host-side launchers.
- `README.md` / `README-ja.md`: user documentation.

## Conventions

- Plain CommonJS JavaScript with 4-space indentation and double quotes; match the existing style. Naming mixes `snake_case` (`start_recognition`) and `camelCase` (`toHHMMSS`); follow the surrounding code.
- The code passed to `page.evaluate()` runs in the browser, so `webkitSpeechRecognition` and `recognition` are not Node.js globals. `--no-sandbox` is intentional (Chrome runs inside a Docker container).
- Behavior depends on the Chrome Web Speech API, the PulseAudio virtual devices (`MicOutput`) and the external page above. Keep these in mind when changing `main.js` or `entrypoint.sh`.
- Update `README.md` and `README-ja.md` when user-visible behavior changes.
- Commits follow [Conventional Commits](https://www.conventionalcommits.org/); branches follow [Conventional Branch](https://conventional-branch.github.io) short form (`feat/...`, `fix/...`).
- Do not commit to Renovate PRs. Never commit secrets or log personal information.
