#!/bin/sh
# Confluence uploader (POSIX-ish): Markdown -> Confluence Storage, i18n (en/de),
# parent by ID/title/fzf, robust curl, minimal dependencies.
# Requires: curl, pandoc, python3. Optional: fzf (for --pick-parent).
# Config/secrets: ~/.confluence-upload.env

set -eu

# --------------------------- i18n (en/de) ---------------------------------
# Language detection: CONF_LANG > LANG
detect_lang() {
  if [ -n "${CONF_LANG:-}" ]; then
    case "$CONF_LANG" in
      de|de_DE*) echo "de" ;;
      *) echo "en" ;;
    esac
  else
    case "${LANG:-}" in
      de|de_DE*) echo "de" ;;
      *) echo "en" ;;
    esac
  fi
}

LANG_CODE="$(detect_lang)"

msg() {
  key="$1"
  case "$LANG_CODE:$key" in
    # English
    en:USAGE_HEADER) echo "Usage:" ;;
    en:USAGE_BODY) cat <<'EOF'
  confluence-upload-posix.sh -f <file.md> -t "<Page Title>" [-a <parentPageId> | -p "<parentTitle>" | --pick-parent] [-s <spaceKey>] [--upload-images]

Options:
  -f  Path to Markdown file
  -t  Confluence page title
  -a  Parent page ID (ancestor). Omit = space root
  -p  Parent page title (resolved within space)
  --pick-parent    Pick parent interactively (fzf)
  -s  Space key (default from ENV)
  --upload-images  Upload local images referenced in Markdown as attachments (best-effort)

Notes:
  Requires 'pandoc' and 'python3'. Install: brew install pandoc python
  Interactive picker requires 'fzf'. Install: brew install fzf
EOF
    ;;
    en:DONE_WITH_ID) echo "Done. ID=" ;;
    en:DONE_WITH_URL) echo "Done. Page:" ;;
    en:ERR_CONF_BASE) echo "CONF_BASE_URL is missing" ;;
    en:ERR_CONF_EMAIL) echo "CONF_EMAIL is missing" ;;
    en:ERR_CONF_SPACE) echo "CONF_SPACE_KEY is missing" ;;
    en:ERR_CONF_TOKEN) echo "CONF_API_TOKEN is missing" ;;
    en:ERR_CONVERT) echo "Wiki->Storage conversion failed" ;;
    en:ERR_CREATE) echo "Failed to create page" ;;
    en:ERR_EMPTY_STORAGE) echo "Empty storage body after conversion" ;;
    en:ERR_ENV_MISSING) echo "Env file not found" ;;
    en:ERR_FILE_MISSING) echo "Markdown file not found" ;;
    en:ERR_FZF_MISS) echo "fzf not found. Install with: brew install fzf" ;;
    en:ERR_NO_MATCHES) echo "No matching pages found for the given title" ;;
    en:ERR_NO_VERSION) echo "Could not retrieve current page version" ;;
    en:ERR_PANDOC_MISS) echo "pandoc not found. Install with: brew install pandoc" ;;
    en:ERR_PY3_MISS) echo "python3 not found. Install with: brew install python" ;;
    en:ERR_TITLE_MISSING) echo "Title is required (-t)" ;;
    en:ERR_UNKNOWN_OPT) echo "Unknown option" ;;
    en:ERR_UPDATE) echo "Failed to update page" ;;
    en:INFO_CONV_STORAGE) echo "Converting Wiki -> Storage (Confluence)..." ;;
    en:INFO_CONV_WIKI) echo "Converting Markdown -> Confluence Wiki (pandoc)..." ;;
    en:INFO_CREATE) echo "Page does not exist — creating." ;;
    en:INFO_IMG_FOUND) echo "Found %d image(s) — uploading..." ;;
    en:INFO_IMG_NONE) echo "No local images found." ;;
    en:INFO_IMG_SEARCH) echo "Scanning local image references for attachment upload..." ;;
    en:INFO_PAGE_EXISTS) echo "Page exists, try update" ;;
    en:INFO_PICK_PARENT) echo "Fetching pages for interactive selection (this may take a moment)..." ;;
    en:INFO_RESOLVE_TITLE) echo "Resolving parent by title within space..." ;;
    en:INFO_UPDATE) echo "Page exists — updating (ID=%s) as version %s." ;;
    en:INFO_UPLOAD_DESCR) echo "Upload '%s' as '%s' (#%s) as subpage of '%s' (#%s)...";;
    en:PROMPT_PICK) echo "Select parent page (ESC for space root):" ;;
    en:WARN_UPLOAD_FAIL) echo "Attachment upload failed:" ;;

    # German
    de:USAGE_HEADER) echo "Verwendung:" ;;
    de:USAGE_BODY) cat <<'EOF'
  confluence-upload-posix.sh -f <datei.md> -t "<Seitentitel>" [-a <parentPageId> | -p "<parentTitle>" | --pick-parent] [-s <spaceKey>] [--upload-images]

Optionen:
  -f  Pfad zur Markdown-Datei
  -t  Seitentitel in Confluence
  -a  Parent-Page-ID (Ancestor). Weglassen = Space-Wurzel
  -p  Parent-Seitentitel (innerhalb des Space auflösen)
  --pick-parent    Parent interaktiv auswählen (fzf)
  -s  Space-Key (Default aus ENV)
  --upload-images  Lokale Bilddateien aus Markdown als Attachments hochladen (Best-Effort)

Hinweise:
  Benötigt 'pandoc' und 'python3'. Installation: brew install pandoc python
  Interaktive Auswahl benötigt 'fzf'. Installation: brew install fzf
EOF
    ;;
    de:DONE_WITH_ID) echo "Fertig. ID=" ;;
    de:DONE_WITH_URL) echo "Fertig. Seite:" ;;
    de:ERR_CONF_BASE) echo "CONF_BASE_URL fehlt" ;;
    de:ERR_CONF_EMAIL) echo "CONF_EMAIL fehlt" ;;
    de:ERR_CONF_SPACE) echo "CONF_SPACE_KEY fehlt" ;;
    de:ERR_CONF_TOKEN) echo "CONF_API_TOKEN fehlt" ;;
    de:ERR_CONVERT) echo "Fehler bei Wiki->Storage-Konvertierung" ;;
    de:ERR_CREATE) echo "Fehler beim Erstellen der Seite" ;;
    de:ERR_EMPTY_STORAGE) echo "Leerer Storage-Body nach Konvertierung" ;;
    de:ERR_ENV_MISSING) echo "Env-Datei nicht gefunden" ;;
    de:ERR_FILE_MISSING) echo "Markdown-Datei nicht gefunden" ;;
    de:ERR_FZF_MISS) echo "fzf nicht gefunden. Installation: brew install fzf" ;;
    de:ERR_NO_MATCHES) echo "Keine passenden Seiten für den angegebenen Titel gefunden" ;;
    de:ERR_NO_VERSION) echo "Konnte aktuelle Seitenversion nicht ermitteln" ;;
    de:ERR_PANDOC_MISS) echo "pandoc nicht gefunden. Installation: brew install pandoc" ;;
    de:ERR_PY3_MISS) echo "python3 nicht gefunden. Installation: brew install python" ;;
    de:ERR_TITLE_MISSING) echo "Titel fehlt (-t)" ;;
    de:ERR_UNKNOWN_OPT) echo "Unbekannte Option" ;;
    de:ERR_UPDATE) echo "Fehler beim Aktualisieren der Seite" ;;
    de:INFO_CONV_STORAGE) echo "Konvertiere Wiki -> Storage (Confluence)..." ;;
    de:INFO_CONV_WIKI) echo "Konvertiere Markdown -> Confluence Wiki (pandoc)..." ;;
    de:INFO_CREATE) echo "Seite existiert nicht — wird erstellt." ;;
    de:INFO_IMG_FOUND) echo "Gefundene Bilder: %d — lade hoch..." ;;
    de:INFO_IMG_NONE) echo "Keine lokalen Bilder gefunden." ;;
    de:INFO_IMG_SEARCH) echo "Suche lokale Bild-Referenzen für Attachment-Upload..." ;;
    de:INFO_PAGE_EXISTS) echo "Seite existiert bereits, versuche zu aktualisieren" ;;
    de:INFO_PICK_PARENT) echo "Lade Seiten für interaktive Auswahl (das kann einen Moment dauern)..." ;;
    de:INFO_RESOLVE_TITLE) echo "Löse Parent über Titel im Space auf..." ;;
    de:INFO_UPDATE) echo "Seite existiert — wird aktualisiert (ID=%s) als Version %s." ;;
    de:INFO_UPLOAD_DESCR) echo "Lade '%s' als '%s' (#%s) unterhalb von '%s' (#%s) hoch...";;
    de:PROMPT_PICK) echo "Parent-Seite wählen (ESC = Space-Wurzel):" ;;
    de:WARN_UPLOAD_FAIL) echo "Upload fehlgeschlagen:" ;;


    *) echo "$key" ;;
  esac
}

say() { printf "%s %s\n" "ℹ️ " "$(msg "$1")"; }
say_formated() { # printf with format
  key="$1"; shift
  # shellcheck disable=SC2059
  printf "%s %s\n" "ℹ️ " "$(printf "$(msg "$key")" "$@")"
}
die() { echo "❌ $1${2:+ $2}" >&2; exit 1; }
warn() { echo "⚠️ $1${2:+ $2}" >&2; }

usage() { msg USAGE_HEADER >&2; msg USAGE_BODY >&2; exit 2; }

# --------------------------- Load ENV --------------------------------------
PANEL_LUA="${HOME}/.local/share/confluence-update/panel.lua"
[ -f "$PANEL_LUA" ] || die "$(msg ERR_ENV_MISSING):" "$PANEL_LUA"

BR_LUA="${HOME}/.local/share/confluence-update/br2jira.lua"
[ -f "$BR_LUA" ] || die "$(msg ERR_ENV_MISSING):" "$BR_LUA"

CODE_LUA="${HOME}/.local/share/confluence-update/code_language.lua"
[ -f "$CODE_LUA" ] || die "$(msg ERR_ENV_MISSING):" "$CODE_LUA"

ENV_FILE="${HOME}/.confluence-upload.env"
[ -f "$ENV_FILE" ] || die "$(msg ERR_ENV_MISSING):" "$ENV_FILE"
# shellcheck disable=SC1090
. "$ENV_FILE"

: "${CONF_BASE_URL:?$(msg ERR_CONF_BASE)}"
: "${CONF_EMAIL:?$(msg ERR_CONF_EMAIL)}"
: "${CONF_API_TOKEN:?$(msg ERR_CONF_TOKEN)}"
: "${CONF_SPACE_KEY:?$(msg ERR_CONF_SPACE)}"

RETRY="${CONF_RETRY:-3}"
TIMEOUT="${CONF_TIMEOUT:-30}"
PARENT_ID="${CONF_PARENT_PAGE_ID:-}"

# ------------------------------- CLI parse ---------------------------------
TITLE=""
FILEPATH=""
UPLOAD_IMAGES="false"
PARENT_TITLE=""
PICK_PARENT="false"

while [ $# -gt 0 ]; do
  case "$1" in
    -f) shift; FILEPATH="${1:-}";;
    -t) shift; TITLE="${1:-}";;
    -a) shift; PARENT_ID="${1:-}";;
    -p) shift; PARENT_TITLE="${1:-}";;
    --pick-parent) PICK_PARENT="true";;
    -s) shift; CONF_SPACE_KEY="${1:-}";;
    --upload-images) UPLOAD_IMAGES="true";;
    -h|--help) usage ;;
    *) die "$(msg ERR_UNKNOWN_OPT):" "$1" ;;
  esac
  shift || true
done

API="${CONF_BASE_URL%/}/rest/api"
AUTH_USER="${CONF_EMAIL}:${CONF_API_TOKEN}"

call_curl() {
  tmp_body="$(mktemp)"

  if [ "$1" = "--capture-curl-output" ]; then
    CAPTURE_CURL_OUTPUT="$2"
    shift; shift
  fi

  http_code="$(
    curl -sS \
      --retry "$RETRY" --retry-all-errors --connect-timeout "$TIMEOUT" --max-time $((TIMEOUT*2)) \
      -u "$AUTH_USER" \
      -w "%{http_code}" -o "$tmp_body" "$@"
  )" || true

  case "$http_code" in
    2??)
      cat "$tmp_body"
      if [ -n "${CAPTURE_CURL_OUTPUT:-}" ]; then
        cp "$tmp_body" "$CAPTURE_CURL_OUTPUT"
      fi
      rm -f "$tmp_body"
      return 0
      ;;
    *)
      echo "HTTP $http_code" >&2
      echo "---- response body ----" >&2
      cat "$tmp_body" >&2
      echo >&2
      rm -f "$tmp_body"
      return 1
      ;;
  esac
}

# Align space key to parent's space if a parent is provided
if [ -n "${PARENT_ID:-}" ]; then
  CURL_OUT="$(mktemp)"
  NORM_PARENT_SPACE="$(mktemp)"

  # shellcheck disable=SC2259
  parent_space="$(call_curl --capture-curl-output "$CURL_OUT" -G "${API}/content/${PARENT_ID}" --data-urlencode "expand=space")"
  python3 - "$NORM_PARENT_SPACE" "$CURL_OUT" <<'PY' || parent_space=""
import sys,json
from pathlib import Path
with open(sys.argv[2], 'r') as f:
  d=json.load(f)
open(sys.argv[1],'w').write((d.get('space') or {}).get('key') or "")
PY
  if [ -s "$NORM_PARENT_SPACE" ]; then
    parent_space="$(cat "$NORM_PARENT_SPACE")"
  fi

  if [ -n "$parent_space" ] && [ "$parent_space" != "$CONF_SPACE_KEY" ]; then
    echo "ℹ️  Aligning spaceKey to parent's space: $CONF_SPACE_KEY -> $parent_space"
    CONF_SPACE_KEY="$parent_space"
  fi

  rm -f "$CURL_OUT" "$NORM_PARENT_SPACE"
fi

if [ -z "$FILEPATH" ] || [ ! -f "$FILEPATH" ]
then
  die "$(msg ERR_FILE_MISSING):" "$FILEPATH"
fi
[ -n "$TITLE" ] || die "$(msg ERR_TITLE_MISSING)"
command -v pandoc >/dev/null 2>&1 || die "$(msg ERR_PANDOC_MISS)"
command -v python3 >/dev/null 2>&1 || die "$(msg ERR_PY3_MISS)"

# shellcheck disable=SC2120
json_escape_stdin() {
  python3 - "$@" <<'PY'
import sys,json
from pathlib import Path

if len(sys.argv) < 2:
  sys.exit("Usage: json_escape_stdin <inputfile> [args...]")

inputfile = sys.argv[1]

if not Path(inputfile).exists():
  sys.exit(f"json_escape_stdin: The file {inputfile} doesn't exists")

print(json.dumps(Path(inputfile).read_text()))
PY
}

# find page by exact title in space -> print id
find_page_by_title_exact() {
  title="$1"
  # shellcheck disable=SC2259
  call_curl -G "${API}/content" \
    --data-urlencode "title=${title}" \
    --data-urlencode "spaceKey=${CONF_SPACE_KEY}" \
  | python3 - "$title" <<'PY' 2>/dev/null || true
import sys,json
title=sys.argv[1]
data=json.load(sys.stdin)
for r in data.get('results',[]):
  if r.get('type')=='page' and r.get('title')==title:
    print(r.get('id')); sys.exit(0)
sys.exit(1)
PY
}

# get page version number
get_page_version() {
  CURL_OUT="$(mktemp)"
  pid="$1"
  # shellcheck disable=SC2259
  call_curl --capture-curl-output "$CURL_OUT" -G "${API}/content/${pid}" --data-urlencode "expand=version" >/dev/null

  python3 - "$CURL_OUT" <<'PY' 2>/dev/null
import sys,json
with open(sys.argv[1], 'r') as f:
  d=json.load(f)
print(d.get('version',{}).get('number') or "")
PY

  rm -f "$CURL_OUT"
}

# list all pages in space as "title<TAB>id"
list_space_pages_tab() {
  start=0
  limit=200
  while : ; do
    resp="$(call_curl -G "${API}/content" \
      --data-urlencode "spaceKey=${CONF_SPACE_KEY}" \
      --data-urlencode "type=page" \
      --data-urlencode "limit=${limit}" \
      --data-urlencode "start=${start}")" || break
    # shellcheck disable=SC2259
    echo "$resp" | python3 - <<'PY' 2>/dev/null
import sys,json
d=json.load(sys.stdin)
for r in d.get('results',[]):
  t=(r.get('title',"") or "").replace("\t"," ")
  print(f"{t}\t{r.get('id','')}")
print("NEXT=" + (d.get('_links',{}).get('next') or ""))
PY
    # shellcheck disable=SC2259
    next_link="$(echo "$resp" | python3 - <<'PY' 2>/dev/null
import sys,json
d=json.load(sys.stdin)
print(d.get('_links',{}).get('next') or "")
PY
)"
    [ -n "$next_link" ] || break
    start=$(( start + limit ))
    [ "$start" -gt 5000 ] && break
  done
}

# Resolve parent by title or picker if needed
resolve_parent() {
  if [ -n "${PARENT_ID:-}" ]; then
    return 0
  fi
  if [ -n "${PARENT_TITLE:-}" ]; then
    say INFO_RESOLVE_TITLE
    PARENT_ID="$(find_page_by_title_exact "$PARENT_TITLE" || true)"
    if [ -z "${PARENT_ID:-}" ]; then
      if [ "$PICK_PARENT" = "true" ] || command -v fzf >/dev/null 2>&1; then
        [ -x "$(command -v fzf || true)" ] || die "$(msg ERR_FZF_MISS)"
        say INFO_PICK_PARENT
        tmp="$(mktemp)"
        list_space_pages_tab > "$tmp"
        # shellcheck disable=SC2002
        choice="$(cat "$tmp" | fzf --prompt "$(msg PROMPT_PICK) " --with-nth=1 --delimiter='\t' --tac || true)"
        rm -f "$tmp"
        if [ -n "$choice" ]; then
          PARENT_ID="$(printf "%s\n" "$choice" | awk -F'\t' '{print $NF}')"
        else
          PARENT_ID=""
        fi
      else
        die "$(msg ERR_NO_MATCHES)"
      fi
    fi
  elif [ "$PICK_PARENT" = "true" ]; then
    [ -x "$(command -v fzf || true)" ] || die "$(msg ERR_FZF_MISS)"
    say INFO_PICK_PARENT
    tmp="$(mktemp)"
    list_space_pages_tab > "$tmp"
    # shellcheck disable=SC2002
    choice="$(cat "$tmp" | fzf --prompt "$(msg PROMPT_PICK) " --with-nth=1 --delimiter='\t' --tac || true)"
    rm -f "$tmp"
    if [ -n "$choice" ]; then
      PARENT_ID="$(printf "%s\n" "$choice" | awk -F'\t' '{print $NF}')"
    else
      PARENT_ID=""
    fi
  fi
}

# ----------------------- Convert Markdown -> Storage -----------------------
MD_DIR="$(cd "$(dirname "$FILEPATH")" && pwd)"
MD_BASE="$(basename "$FILEPATH")"
MD_ABS="${MD_DIR}/${MD_BASE}"

say INFO_CONV_WIKI
WIKI_TMP="$(mktemp)"
pandoc --from=markdown --to=jira --lua-filter="$PANEL_LUA" --lua-filter="$BR_LUA" --lua-filter="$CODE_LUA" --wrap=none "$MD_ABS" > "$WIKI_TMP"

say INFO_CONV_STORAGE
CONVERT_REQ="$(mktemp)"
CONVERT_RESP="$(mktemp)"
# Build JSON without non-POSIX brace groups
printf '{"value":%s,"representation":"wiki"}' "$(json_escape_stdin "$WIKI_TMP")" > "$CONVERT_REQ"

call_curl -H "Content-Type: application/json" -X POST \
  --data @"$CONVERT_REQ" \
  "${API}/contentbody/convert/storage" > "$CONVERT_RESP" || die "$(msg ERR_CONVERT)"

STORAGE_VALUE_FILE="$(mktemp)"
# shellcheck disable=SC2261
python3 - "$STORAGE_VALUE_FILE" "$CONVERT_RESP" <<'PY' 2>/dev/null
import sys,json
with open(sys.argv[2], 'r') as f:
  data=json.load(f)
open(sys.argv[1],'w').write(data.get('value',""))
PY
[ -s "$STORAGE_VALUE_FILE" ] || die "$(msg ERR_EMPTY_STORAGE)"

# --------------------------- Build payloads --------------------------------
ANCESTORS_JSON=""
if [ -n "${PARENT_ID:-}" ]; then
  ANCESTORS_JSON='"ancestors":[{"id": '"${PARENT_ID}"' }],'
fi

TMPDIR_MAIN="$(mktemp -d)"
cleanup() {
  rm -rf "$TMPDIR_MAIN" "$WIKI_TMP" "$CONVERT_REQ" "$CONVERT_RESP" "$STORAGE_VALUE_FILE" "$CURL_OUT" 2>/dev/null || true
}
trap cleanup EXIT

# ----------------------------- Create/Update -------------------------------
resolve_parent

find_self_id() {
  CURL_OUT="$(mktemp)"

  # Exact title match in the (already aligned) space, no CQL.
  # shellcheck disable=SC2259
  call_curl --capture-curl-output "$CURL_OUT" -G "${API}/content" \
    --data-urlencode "title=${TITLE}" \
    --data-urlencode "spaceKey=${CONF_SPACE_KEY}" \
    --data-urlencode "type=page" \
    --data-urlencode "limit=1" >/dev/null

  python3 - "$CURL_OUT" <<'PY' 2>/dev/null || true
import sys, os, json
with open(sys.argv[1], 'r') as f:
  d = json.load(f)
for r in d.get('results', []):
  if r.get('type') == 'page':
    print(r.get('id') or "")
    break
PY
  rm -f "$CURL_OUT"
}

PAGE_ID="$(find_self_id || true)"

say_formated INFO_UPLOAD_DESCR "$FILEPATH" "$TITLE" "$PAGE_ID" "$PARENT_TITLE" "$PARENT_ID"

if [ -z "${PAGE_ID:-}" ]; then
  say INFO_CREATE
  JSON_FILE="${TMPDIR_MAIN}/create.json"
  python3 - "$STORAGE_VALUE_FILE" "$CONF_SPACE_KEY" "$TITLE" "${PARENT_ID:-}" > "$JSON_FILE" <<'PY'
import sys, json
storage = open(sys.argv[1], 'r').read()
space   = sys.argv[2]
title   = sys.argv[3]
parent  = sys.argv[4]
payload = {
    "type": "page",
    "title": title,
    "space": {"key": space},
    "body": {"storage": {"representation": "storage", "value": storage}},
}
if parent:
    try: payload["ancestors"] = [{"id": int(parent)}]
    except ValueError: payload["ancestors"] = [{"id": parent}]
print(json.dumps(payload))
PY

  # Versuch: Create
  if RESP="$(call_curl -H "Content-Type: application/json" -X POST --data @"$JSON_FILE" "${API}/content")"; then
    # shellcheck disable=SC2259
    PAGE_ID="$(printf '%s' "$RESP" | python3 - <<'PY'
import sys, json
print(json.load(sys.stdin).get('id', ""))
PY
)"
  else
    # 4xx: Prüfen, ob "already exists" -> dann ID suchen und auf Update wechseln
    EXISTING_ID="$(find_self_id || true)"

    if [ -n "$EXISTING_ID" ]; then
      say INFO_PAGE_EXISTS
      PAGE_ID="$EXISTING_ID"
    else
      # keine ID gefunden -> echter Fehler
      die "$(msg ERR_CREATE)"
    fi
  fi
fi

if [ -n "$PAGE_ID" ]; then
  CUR_VER="$(get_page_version "$PAGE_ID")"
  [ -n "$CUR_VER" ] || die "$(msg ERR_NO_VERSION)"
  NEXT_VER=$(( CUR_VER + 1 ))

  say_formated INFO_UPDATE "$PAGE_ID" "$NEXT_VER"

  JSON_FILE="${TMPDIR_MAIN}/update.json"
  python3 - "$STORAGE_VALUE_FILE" "$TITLE" "$NEXT_VER" "${PARENT_ID:-}" > "$JSON_FILE" <<'PY'
import sys, json
storage = open(sys.argv[1], 'r').read()
title   = sys.argv[2]
nextver = int(sys.argv[3])
parent  = sys.argv[4]

payload = {
    "version": {"number": nextver},
    "type": "page",
    "title": title,
    "body": {"storage": {"representation": "storage", "value": storage}},
}
if parent:
    try:
        payload["ancestors"] = [{"id": int(parent)}]
    except ValueError:
        payload["ancestors"] = [{"id": parent}]

print(json.dumps(payload))
PY

  call_curl -H "Content-Type: application/json" -X PUT --data @"$JSON_FILE" "${API}/content/${PAGE_ID}" >/dev/null \
    || die "$(msg ERR_UPDATE)"
fi

# ---------------------------- Attachment upload ----------------------------
if [ "$UPLOAD_IMAGES" = "true" ]; then
  say INFO_IMG_SEARCH
  # Extract markdown image paths into a temp file (simple regex)
  IMG_CANDIDATES="$(mktemp)"
  # shellcheck disable=SC2129
  grep -Eo '!\[[^]]*\]\(([^)]+)\)' "$MD_ABS" 2>/dev/null | sed -E 's/!\[[^]]*\]\(([^)"]+)(\"[^"]*\")?\)/\1/g' > "$IMG_CANDIDATES" || true

  # Build list of existing local files
  IMG_LIST="$(mktemp)"
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in http*|data:*) continue ;; esac
    if [ -f "${MD_DIR}/${line}" ]; then
      printf "%s\n" "${MD_DIR}/${line}" >> "$IMG_LIST"
    elif [ -f "$line" ]; then
      printf "%s\n" "$line" >> "$IMG_LIST"
    fi
  done < "$IMG_CANDIDATES"
  rm -f "$IMG_CANDIDATES"

  if [ -s "$IMG_LIST" ]; then
    count="$(wc -l < "$IMG_LIST" | tr -d ' ')"
    # shellcheck disable=SC2059
    say_formated INFO_IMG_FOUND "$count"
    while IFS= read -r img; do
      mime="$(file --mime-type -b "$img" 2>/dev/null || echo application/octet-stream)"
      call_curl -X POST -H "X-Atlassian-Token: nocheck" \
        -F "file=@${img};type=${mime}" \
        "${API}/content/${PAGE_ID}/child/attachment" >/dev/null || warn "$(msg WARN_UPLOAD_FAIL)" " $(basename "$img")"
    done < "$IMG_LIST"
  else
    say INFO_IMG_NONE
  fi
  rm -f "$IMG_LIST"
fi

# ------------------------------- Final output ------------------------------
CURL_OUT="$(mktemp)"

call_curl --capture-curl-output "$CURL_OUT" -G "${API}/content/${PAGE_ID}" --data-urlencode "expand=_links" >/dev/null

PAGE_WEBUI_PATH="$(python3 - "$CURL_OUT" <<'PY' 2>/dev/null
import sys,json
with open(sys.argv[1], 'r') as f:
  print(json.load(f).get('_links',{}).get('webui',""))
PY
)"

if [ -n "$PAGE_WEBUI_PATH" ]; then
  echo "✅ $(msg DONE_WITH_URL) ${CONF_BASE_URL%/}${PAGE_WEBUI_PATH} (ID=${PAGE_ID})"
else
  echo "✅ $(msg DONE_WITH_ID) ${PAGE_ID}"
fi
