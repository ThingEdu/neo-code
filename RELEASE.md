# Releasing NEO Code

Every release is one `.deb` attached to a GitHub release. `scripts/install_on_neo.sh`
downloads it by tag and installs it with apt, which resolves PyQt6 and the Qt6 QML
runtime per-architecture. **There is no in-app updater** — updates go through the
install script, so a release that is not on GitHub does not exist as far as devices
are concerned.

## Steps

1. **Bump the version.** `pyproject.toml`'s `version` is the single source of truth.

2. **Add a `debian/changelog` stanza** for the new version — this is the technical
   record, written for whoever maintains the package. Keep the newest at the top:

   ```
   neo-code (X.Y.Z) unstable; urgency=medium

     * What changed, in whole sentences.

    -- ThingEdu <everwellmax@gmail.com>  Thu, 23 Jul 2026 15:20:00 +0700
   ```

   The date must be RFC 2822 (`date -R`), or `dpkg-buildpackage` rejects it.

3. **Build**: `make deb` → `dist/neo-code_X.Y.Z_all.deb`

4. **Verify on the target**, not on your host — bookworm ships Qt 6.4.2 and a
   newer host Qt proves nothing:

   ```bash
   docker run --rm -v "$PWD/dist:/d:ro" -e QT_QPA_PLATFORM=offscreen debian:bookworm bash -c '
     apt-get update -qq
     apt-get install -y -qq --no-install-recommends /d/neo-code_X.Y.Z_all.deb
     timeout 20 neo-code & sleep 12; kill %1'
   ```

   It must install, launch, and print no QML errors. For UI changes, screenshot the
   affected modes as well — see `AGENTS.md` § Verifying UI changes.

5. **Tag and release:**

   ```bash
   git tag -a vX.Y.Z -m "vX.Y.Z" && git push origin main vX.Y.Z
   gh release create vX.Y.Z dist/neo-code_X.Y.Z_all.deb \
       --title "NEO Code vX.Y.Z" --notes "$(cat notes.md)"
   ```

6. **Check the install command in the notes names the version you just released.**
   It is copy-pasted from the previous release every time, and has shipped wrong
   before.

## Release notes template

Notes are read by teachers and parents, not packagers — they answer "what is new
for the kids?". Keep them short: one topic heading, a few bullets, the install
command. The changelog stanza is where technical detail belongs.

Mode names appear as kids see them on screen: **Chơi**, **Học**, **Sáng tạo**.

```markdown
## <Topic — the one thing this release is about>

<One or two sentences a non-engineer can follow.>

- <What a user can now do, not how it was implemented.>
- <Bold the thing worth noticing: **falls back to a simulated arm**.>
- <Vietnamese UI strings and Python API names in `code`.>

## Install (NEO One)

```bash
curl -sSL https://raw.githubusercontent.com/ThingEdu/neo-code/main/scripts/install_on_neo.sh | bash -s -- --version=X.Y.Z
```
```

Drop `-s -- --version=X.Y.Z` to have the installer take the latest release instead
of a pinned one.

For a release with more than one theme, use `## New` with a bolded lead-in per item
rather than several `##` headings — see v0.6.1.

## Conventions

- Title is always `NEO Code vX.Y.Z`. Nothing descriptive.
- One asset: `neo-code_X.Y.Z_all.deb`. Everything a device needs is either inside
  it or comes from apt.
- No "Breaking changes", "Contributors", or licence sections. If something needs
  that much explanation, it belongs in `docs/specs/`.
- Don't claim tests pass — there is no test suite. Say what you actually verified.
