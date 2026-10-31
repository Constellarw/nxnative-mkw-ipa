# nxnative-mkw-ipa (private)

Builds Mario Kart World IPA from the **already-decrypted** dump (ExeFS+RomFS), using private fork `Constellarw/nxnative-sw2`.

## Secrets
- `GDRIVE_FOLDER_ID` — Drive folder id of the zip parts (`mkw-1.8.0-parts`)
- `PROD_KEYS_B64` — optional (`base64 -w0 prod.keys`)

## Run
Actions → **Build MKW IPA (extracted)** → Run workflow.

## Pokemon Pokopia (`build-pokopia.yml`)
`0400A3A01EE4C000` v327680 (display 5.0.0), loose ExeFS+RomFS, macos-26 / Xcode 26.6, nxnative-sw2 ref `cursor/pokopia-mac-ci`.
- Dump: private release `Constellarw/nxnative-mkw-dump@pokopia-dump-v1` (tar parts + `manifest.tsv`), Drive folder fallback (gdown).
- Shaders (97,469) are resumable across runs: every `*.manifest.tsv` chunk in `nxnative-mkw-dump@pokopia-shader-seed-v1` is merged into the build tree first
  (`linux*` = keys finished on the Linux box, `ci<run>-<attempt>` = keys finished by earlier runs), only the missing keys are built (time budget `budget_min`),
  and the new keys are uploaded as another chunk. Re-run until the summary says "all shaders built"; that run stamps the library and uploads the IPA
  to a private release `pokopia-ipa-<run id>` (never a public artifact).
- Secrets: `NXNATIVE_PAT` (read nxnative-sw2, read+write releases on nxnative-mkw-dump).
