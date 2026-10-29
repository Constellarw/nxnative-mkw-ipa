# nxnative-mkw-ipa (private)

Builds Mario Kart World IPA from the **already-decrypted** dump (ExeFS+RomFS), using private fork `Constellarw/nxnative-sw2`.

## Secrets
- `GDRIVE_FOLDER_ID` — Drive folder id of the zip parts (`mkw-1.8.0-parts`)
- `PROD_KEYS_B64` — optional (`base64 -w0 prod.keys`)

## Run
Actions → **Build MKW IPA (extracted)** → Run workflow.
