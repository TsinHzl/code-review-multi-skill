#!/bin/bash
# code-review-multi batch scan and Diff extraction script
# Usage: bash code-review-multi-env.sh
# Auto-scans all subdirectories containing .git under the current directory and outputs an aggregated Diff log

ROOT_DIR=$(pwd)
ROOT_DIR_NAME=$(basename "$ROOT_DIR")
ALL_DIFFS_TMP="/tmp/batch_git_diff_$(date +%s).txt"
REPO_DIFF_TMP="/tmp/single_repo_diff_$(date +%s).txt"

echo "ROOT_DIRECTORY_NAME: $ROOT_DIR_NAME" > "$ALL_DIFFS_TMP"
echo "=========================================" >> "$ALL_DIFFS_TMP"

TOTAL_SCANNED=0

for d in */; do
    [ -d "$d" ] || continue

    cd "$d" || continue

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        cd "$ROOT_DIR"
        continue
    fi

    TOTAL_SCANNED=$((TOTAL_SCANNED + 1))
    REPO_NAME=$(basename "$d")

    C_BR=$(git branch --show-current)

    if [ -z "$C_BR" ]; then
        echo "========== SKIP: $REPO_NAME (Reason: Currently in Detached HEAD state, no active branch) ==========" >> "$ALL_DIFFS_TMP"
        cd "$ROOT_DIR"
        continue
    fi

    O_BR=$(git reflog show "$C_BR" | awk '/Created from/ {print $NF; exit}')
    O_BR_COMPARE="${O_BR#remotes/}"
    O_BR_COMPARE="${O_BR_COMPARE#origin/}"

    if [ -z "$O_BR" ]; then
        echo "========== SKIP: $REPO_NAME (Reason: Source branch not found) ==========" >> "$ALL_DIFFS_TMP"
        cd "$ROOT_DIR"
        continue
    fi
    if [ "$C_BR" == "$O_BR" ] || [ "$C_BR" == "$O_BR_COMPARE" ]; then
        echo "========== SKIP: $REPO_NAME (Reason: Current branch matches source branch, no new commits) ==========" >> "$ALL_DIFFS_TMP"
        cd "$ROOT_DIR"
        continue
    fi

    git diff "$O_BR" HEAD > "$REPO_DIFF_TMP"

    if [ -s "$REPO_DIFF_TMP" ]; then
        echo "========== REPOSITORY: $REPO_NAME | BRANCHES: $O_BR -> $C_BR ==========" >> "$ALL_DIFFS_TMP"
        cat "$REPO_DIFF_TMP" >> "$ALL_DIFFS_TMP"
        echo -e "\n\n" >> "$ALL_DIFFS_TMP"
    else
        echo "========== SKIP: $REPO_NAME (Reason: Branches differ but no effective code changes) ==========" >> "$ALL_DIFFS_TMP"
    fi

    rm -f "$REPO_DIFF_TMP"
    cd "$ROOT_DIR"
done

echo "TOTAL_SCANNED_REPOS: $TOTAL_SCANNED" >> "$ALL_DIFFS_TMP"

cat "$ALL_DIFFS_TMP"
rm -f "$ALL_DIFFS_TMP"
