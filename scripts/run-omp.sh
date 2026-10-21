#!/usr/bin/env bash
# Run one headless omp (oh-my-pi) job in its own work dir.
# Usage: run-omp.sh [--model M] <workdir> <prompt-file | "prompt">
# Output: <dir>/run.jsonl (event stream), final.txt, run.err, meta.json
set -euo pipefail
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"
MODEL="${OMP_MODEL:-viber/deepseek-v4.1-flash-1017}"
[ "${1:-}" = "--model" ] && { MODEL="$2"; shift 2; }
[ $# -lt 2 ] && { sed -n '2,4p' "$0"; exit 2; }
WORKDIR="$1"; shift; P="$*"
command -v omp >/dev/null || { echo "omp missing: bun i -g @oh-my-pi/pi-coding-agent" >&2; exit 2; }
mkdir -p "$WORKDIR"; WORKDIR="$(cd "$WORKDIR" && pwd)"
if [ -f "$P" ]; then cp "$P" "$WORKDIR/prompt.txt" 2>/dev/null || true; else printf '%s\n' "$P" > "$WORKDIR/prompt.txt"; fi
cd "$WORKDIR"; S=$(date +%s); set +e
omp -p --mode json --model "$MODEL" --no-lsp --cwd "$WORKDIR" --session-dir "$WORKDIR/.omp-session" \
  "$(cat prompt.txt)" > run.jsonl 2> run.err < /dev/null
RC=$?; set -e; E=$(date +%s)
node -e '
const fs=require("fs");let t="";
for (const l of fs.readFileSync("run.jsonl","utf8").split("\n")){if(!l.trim())continue;
 try{const e=JSON.parse(l);const m=e.message||e;
  if((e.type==="message_end"||e.type==="agent_end"||e.type==="turn_end")&&m.role==="assistant"&&Array.isArray(m.content)){
   const x=m.content.filter(c=>c.type==="text").map(c=>c.text).join("");if(x)t=x;}
  if(e.type==="agent_end"&&Array.isArray(e.messages)){for(const mm of e.messages)if(mm.role==="assistant"){const x=(mm.content||[]).filter(c=>c.type==="text").map(c=>c.text).join("");if(x)t=x;}}
 }catch{}}
fs.writeFileSync("final.txt",t);' || true
printf '{"exit":%d,"seconds":%d,"model":"%s","dir":"%s"}\n' $RC $((E-S)) "$MODEL" "$WORKDIR" > meta.json
echo "omp done: exit=$RC, $((E-S))s, dir: $WORKDIR" >&2
[ -s final.txt ] && cat final.txt
exit $RC
