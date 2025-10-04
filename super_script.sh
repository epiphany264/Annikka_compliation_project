#!/bin/bash
set -euo pipefail

LOG_DIR="/home/codebind/docker-fix/new_logs"        
JAVA11_HOME="/usr/lib/jvm/java-1.11.0-openjdk-arm64"
STEP1="/workspace/step_one.sh"
STEP2="/workspace/step_two.sh"
STEP3="/workspace/step_three.sh"
STEP4="/workspace/step_four.sh"
mkdir -p "$LOG_DIR"





die() { echo "error: $*" >&2; exit 1; }


#START


run_with_log() {
  local name="$1"; shift
  {
    echo "===== $name ====="
    "$@"
    rc=$?
    echo "exit code: $rc"
    echo "finished: $(date +"%Y-%m-%d %H:%M:%S")"
    return $rc
  } &> "$LOG_DIR/${CURRENT_SHA}__${name}.log"
  return $?
}


reset_clean_repo() {
  git -C "$REPO_ROOT" reset --hard HEAD >/dev/null 2>&1 || true
  git -C "$REPO_ROOT" clean -xfd       >/dev/null 2>&1 || true
}



run_combos_for_module() {
  REPO_ROOT="$1"
  local MODULE_PATH="$2"

  [ -d "$REPO_ROOT/$MODULE_PATH" ] || { echo "[skip] module not found"; return 1; }

  export JAVA_HOME="$JAVA11_HOME"
  export PATH="$JAVA_HOME/bin:$PATH"

  reset_clean_repo
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1" bash -lc "$STEP1 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1"; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_2" bash -lc "$STEP2 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1_+_2 "; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT" && $STEP3 &>/dev/null ) || true
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_3" bash -lc "$STEP1 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1_+_3"; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT" && $STEP4 &>/dev/null ) || true
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_4" bash -lc "$STEP1 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1_+_4"; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT" && $STEP3 &>/dev/null ) || true
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_2_+_3" bash -lc "$STEP2 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1_+_2_+_3 "; return 0; }
 
  reset_clean_repo
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_2_+_4" bash -lc "$STEP2 '$MODULE_PATH' && $STEP4 &>/dev/null ") && { echo "[SUCCESS] Step_1_+_2_+_4 "; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT" && $STEP3 &>/dev/null && $STEP4 &>/dev/null ) || true
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "Step_1_+_3_+_4" bash -lc "$STEP1 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_1_+_3_+_4 "; return 0; }

  reset_clean_repo
  ( cd "$REPO_ROOT" && $STEP3 &>/dev/null && $STEP4 &>/dev/null ) || true
  ( cd "$REPO_ROOT/$MODULE_PATH" && run_with_log "S3+S4+S2" bash -lc "$STEP2 '$MODULE_PATH'" ) && { echo "[SUCCESS] Step_3_+_4_+_2 "; return 0; }

  echo "[FAILED] All step combinations failed"
  return 1
} 


can_access_repo(){ GIT_TERMINAL_PROMPT=0 git ls-remote --heads "$1" >/dev/null 2>&1; }


process_single() {
  local REPO_URL="$1" SHA="$2" MODULE="$3"
  export GIT_TERMINAL_PROMPT=0
  
  can_access_repo "$REPO_URL" || { echo "[skip] $REPO_URL not accessible"; return 0; }

  local WORKDIR="/workspace/target-project"
  rm -rf "$WORKDIR"

  git clone "$REPO_URL" "$WORKDIR" &>/dev/null || { echo "[skip] clone failed"; return 0; }
  git -C "$WORKDIR" checkout "$SHA" &>/dev/null || { echo "[skip] checkout failed"; return 0; }

  CURRENT_SHA="$(git -C "$WORKDIR" rev-parse HEAD)"
  run_combos_for_module "$WORKDIR" "$MODULE" && echo "[MODULE SUCCESS]"  || echo "[MODULE FAILED]"
  return 0
}


process_row_modules() {
  local URL="$1" SHA="$2" MODS="$3"
  IFS=';|' read -ra ARR <<< "$MODS"
  for m in "${ARR[@]}"; do
    mod="$(echo "$m" | xargs)"
    [ -n "$mod" ] || continue
    echo "=============================="
    echo "Repo: $URL | SHA: $SHA | Mod: $mod"
    process_single "$URL" "$SHA" "$mod" || echo "failure for module: $mod (continuing)"
  done
}


#Reading the csv
run_csv() {
  [ -f "$1" ] || die "CSV not found: $1"

  local line=0
  while IFS=, read -r repo sha modules rest || [[ -n "$repo$sha$modules" ]]; do
    line=$((line+1))
    [[ -z "${repo// }" || "$repo" == "repo_url" ]] && continue
    process_row_modules "$repo" "$sha" "$modules" </dev/null
  done < <(tr -d '\r' < "$1")
 
  echo "[csv done] processed $line lines"

}

if [[ "${1:-}" == "--csv" ]]; then
  [[ $# -ge 2 ]] || exit 1
  run_csv "$2"
elif [[ $# -eq 3 ]]; then
  process_single "$1" "$2" "$3"
else
  exit 1
fi





