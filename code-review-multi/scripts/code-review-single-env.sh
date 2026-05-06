#!/bin/bash
# code-review-single environment parsing and Diff extraction script
# Usage: bash code-review-single-env.sh [PARAM] [COMMIT_COUNT_RAW] [COMMIT_HASH_RAW]
#   $1 - PARAM: user input parameter (component path, etc.), leave empty if none
#   $2 - COMMIT_COUNT_RAW: commit count extracted from natural language, leave empty if none
#   $3 - COMMIT_HASH_RAW: commit hash (7-40 hex digits), leave empty if none

PARAM="${1:-}"
COMMIT_COUNT_RAW="${2:-}"
COMMIT_HASH_RAW="${3:-}"

# 1. Path resolution: strip leading @ and trailing /, then try to enter the directory
if [ -n "$PARAM" ]; then
    CLEAN_PATH=$(echo "$PARAM" | sed -e 's/^@//' -e 's/\/$//')
    [ -d "$CLEAN_PATH" ] && cd "$CLEAN_PATH" || echo "Directory $CLEAN_PATH not found, staying in current directory"
else
    CLEAN_PATH=$(basename "$(pwd)")
fi

# Safety check: verify current directory is a valid Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "BLOCK: Current directory is not a valid Git repository, exiting."
    exit 0
fi

REPO_NAME=$(basename "$(pwd)")

# 2. Get current branch and source branch
C_BR=$(git branch --show-current)

# Try to get source branch via reflog
O_BR=$(git reflog show "$C_BR" 2>/dev/null | awk '/Created from/ {print $NF; exit}')
O_BR_COMPARE="${O_BR#remotes/}"
O_BR_COMPARE="${O_BR_COMPARE#origin/}"

# Handle missing reflog or self-referencing remote scenario (e.g. fresh clone)
if [ -z "$O_BR" ] || [ "$C_BR" == "$O_BR_COMPARE" ]; then
    DEFAULT_BR=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

    if [ -z "$DEFAULT_BR" ]; then
        for br in main master develop; do
            if git rev-parse --verify "origin/$br" >/dev/null 2>&1; then
                DEFAULT_BR="$br"
                break
            fi
        done
    fi

    if [ -n "$DEFAULT_BR" ]; then
        O_BR="origin/$DEFAULT_BR"
        O_BR_COMPARE="$DEFAULT_BR"
    fi
fi

# 3. Blocking logic
if [ -z "$O_BR" ] || [ -z "$O_BR_COMPARE" ]; then
    echo "BLOCK: Source branch not found and cannot match default main branch, exiting."
    exit 0
fi

if [ "$C_BR" == "$O_BR_COMPARE" ]; then
    echo "BLOCK: Current branch ($C_BR) is the source branch ($O_BR_COMPARE), no review needed, exiting."
    exit 0
fi

# 4. Get Diff and assemble context
DIFF_TMP="/tmp/git_diff_raw_$(date +%s).txt"
FINAL_TMP="/tmp/git_diff_final_$(date +%s).txt"

git diff "$O_BR" HEAD > "$DIFF_TMP"

if [ ! -s "$DIFF_TMP" ]; then
    echo "BLOCK: Current branch ($C_BR) differs from source branch ($O_BR), but no effective code changes, exiting."
    rm -f "$DIFF_TMP"
    exit 0
fi

echo "REPOSITORY_NAME: $REPO_NAME" > "$FINAL_TMP"
echo "TARGET_COMPONENT: $CLEAN_PATH" >> "$FINAL_TMP"
echo "BRANCHES: $O_BR -> $C_BR" >> "$FINAL_TMP"
echo "=========================================" >> "$FINAL_TMP"
cat "$DIFF_TMP" >> "$FINAL_TMP"

cat "$FINAL_TMP"
rm -f "$DIFF_TMP" "$FINAL_TMP"
