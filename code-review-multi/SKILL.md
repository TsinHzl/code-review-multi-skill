---
name: code-review-multi
description: Batch multi-repository Code Review expert. Automatically scans all subdirectories containing .git in the current directory, batch extracts Diff and branch information from each repository, and generates a single consolidated Code Review report file covering critical issues, improvement suggestions, and elegant refactoring solutions.
trigger: Triggered when users request batch Code Review execution across multiple repositories/subdirectories. Keywords: batch review, multi-repo, batch audit, all repositories, batch code inspection.

---

# Skill: code-review-multi (Batch Multi-Repository Code Review Expert)

## Trigger Conditions

- User input contains: batch review, multi-repo, batch audit, all repositories, batch code inspection
- User requests simultaneous Code Review execution across multiple subdirectories in the current directory

## Input Parameters

No parameters required, automatically scans all subdirectories containing .git in the current directory

## Role: Senior Development Engineer, executing batch Code Review

## Workflow

Strictly follow these two steps in order. Step 1 must be executed completely in one run via code/terminal execution tool:

### Step 1: Batch Scanning and Diff Extraction (Execute completely in one run)

Use the terminal tool to directly run the following complete Bash script. This script will automatically scan real Git repositories in subdirectories, extract root directory name, branch information, skip logs, and all valid changes, outputting everything in one run.

```bash
#!/bin/bash
ROOT_DIR=$(pwd)
ROOT_DIR_NAME=$(basename "$ROOT_DIR")
ALL_DIFFS_TMP="/tmp/batch_git_diff_$(date +%s).txt"
# [NEW] Prepare independent temp file for single repo Diff to prevent variable memory overflow
REPO_DIFF_TMP="/tmp/single_repo_diff_$(date +%s).txt"

# Record root directory name for later naming use
echo "ROOT_DIRECTORY_NAME: $ROOT_DIR_NAME" > "$ALL_DIFFS_TMP"
echo "=========================================" >> "$ALL_DIFFS_TMP"

TOTAL_SCANNED=0

# Traverse all subdirectories in current directory
for d in */; do
    # [Logic Enhancement 1] Prevent error when no subdirectories exist and */ is treated as literal
    [ -d "$d" ] || continue
    
    cd "$d" || continue

    # [Logic Enhancement 2] Perfect compatibility with regular repos, Submodules, and Worktrees
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        cd "$ROOT_DIR"
        continue
    fi

    TOTAL_SCANNED=$((TOTAL_SCANNED + 1))
    REPO_NAME=$(basename "$d")
    
    C_BR=$(git branch --show-current)
    
    # [Logic Enhancement 3] Intercept Detached HEAD state to prevent subsequent command errors
    if [ -z "$C_BR" ]; then
        echo "========== SKIP: $REPO_NAME (Reason: Currently in Detached HEAD state, no explicit branch) ==========" >> "$ALL_DIFFS_TMP"
        cd "$ROOT_DIR"
        continue
    fi

    O_BR=$(git reflog show "$C_BR" | awk '/Created from/ {print $NF; exit}')

    O_BR_COMPARE="${O_BR#remotes/}"   
    O_BR_COMPARE="${O_BR_COMPARE#origin/}" 

    # Blocking logic and SKIP log recording
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

    # [Logic Enhancement 4] Prevent memory explosion: Write Diff directly to independent temp file and verify with -s
    git diff "$O_BR" HEAD > "$REPO_DIFF_TMP"

    # Read file to verify if there are substantial changes
    if [ -s "$REPO_DIFF_TMP" ]; then
        echo "========== REPOSITORY: $REPO_NAME | BRANCHES: $O_BR -> $C_BR ==========" >> "$ALL_DIFFS_TMP"
        cat "$REPO_DIFF_TMP" >> "$ALL_DIFFS_TMP"
        echo -e "\n\n" >> "$ALL_DIFFS_TMP"
    else
        echo "========== SKIP: $REPO_NAME (Reason: Branches differ but no effective code changes) ==========" >> "$ALL_DIFFS_TMP"
    fi

    # Clean up current repo's Diff temp file, prepare for next loop
    rm -f "$REPO_DIFF_TMP"
    cd "$ROOT_DIR"
done

# Output total scanned count
echo "TOTAL_SCANNED_REPOS: $TOTAL_SCANNED" >> "$ALL_DIFFS_TMP"

# Read and clean up total temp file
cat "$ALL_DIFFS_TMP"
rm -f "$ALL_DIFFS_TMP"
```

*(Note: To prevent escape conflicts, the code block closing markers above have an extra space. Remove the space between backticks when actually using)*

### Step 2: Deep Review and Batch Report Generation

After receiving the aggregated log from Step 1 (including Diff, branch info, SKIP reasons, total scanned count), begin Code Review execution. If only `SKIP` logs exist with no valid `REPOSITORY` changes, directly reply to user "All repositories have no effective changes" and end task.

**Review Requirements**: Skip auto-generated files (like package-lock.json, etc.). Focus on logic bugs, boundary omissions, readability/naming, performance optimization, and security vulnerabilities.

**Output Requirements (Strict Constraints)**:
Call the file write tool to generate the Code Review report in the root directory where the initial command was executed. Must strictly follow these rules during execution:

1. **Single Global File Output**: Must consolidate all changed repository reports into the same Markdown file, absolutely no file splitting allowed.
2. **File Naming Convention**: File name must be strictly named as `[current_root_directory_name]_code_review.md` (read `ROOT_DIRECTORY_NAME` from script output).
3. **No-Change Filtering**: For repositories marked as `SKIP` by the script, directly skip the review phase, strictly prohibit outputting empty reports or placeholder prompts in the main text (only reflect in final summary).

For the generated Markdown file, **strictly apply the following structure** for formatting, do not modify hierarchy or add unnecessary pleasantries:

# 📦 Repository Name: [Read REPOSITORY name from log]

**Branch Comparison**: `[Source Branch O_BR]` -> `[Current Branch C_BR]`

## 📝 Change Overview

[Concisely summarize the main code change points of this repository]

## 🚨 Deep Review Opinions

*(Note: Fill in the following three categories as needed, if a category has no findings, directly omit that category)*

### 🚫 Critical Issues

*Only list all issues that can cause crashes, security vulnerabilities, serious logic errors, or block builds.*

* **Issue Description**: [Precisely describe defect cause]

* **Potential Impact**: [Describe consequences, e.g.: memory overflow, data leak]

* **Location**: Lines L[start_line] - L[end_line]

* **Current Branch vs Original Branch Change Comparison**:

  ```javascript
  // Original branch code
  [Please fully extract original branch code block]
  
  // Current branch changed code
  [Please fully extract current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Fully extract original code block containing issue]
  
  // ✅ Fixed code
  [Provide refactored code conforming to Clean Code, high performance]
  ```

* **Fix Highlights**: [Briefly describe core advantages after fix, e.g.: reduce cyclomatic complexity]

### ⚠️ Improvement Suggestions (Standard)

*List all optimization points for code standards, readability, redundant logic, and best practices.*

* **Suggestion Point**: [Describe suggestion, e.g.: Recommend using Optional Chaining]

* **Rationale**: [Explain why this change is better]

* **Location**: Lines L[start_line] - L[end_line]

* **Current Branch vs Original Branch Change Comparison**:

  ```javascript
  // Original branch code
  [Please fully extract original branch code block]
  
  // Current branch changed code
  [Please fully extract current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Fully extract original code block containing issue]
  
  // ✅ Fixed code
  [Provide refactored code conforming to Clean Code, high performance]
  ```

* **Fix Highlights**: [Briefly describe core advantages after fix, e.g.: reduce cyclomatic complexity]

### 💡 Elegant Refactoring

*Must provide refactoring solutions based on context for specific code change points. Strictly follow the comparison format below:*

* **Location**: Lines L[start_line] - L[end_line]

* **Current Branch vs Original Branch Change Comparison**:

  ```javascript
  // Original branch code
  [Please fully extract original branch code block]
  
  // Current branch changed code
  [Please fully extract current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Fully extract original code block containing issue]
  
  // ✅ Fixed code
  [Provide refactored code conforming to Clean Code, high performance]
  ```

* **Fix Highlights**: [Briefly describe core advantages after fix, e.g.: reduce cyclomatic complexity]

## 🏁 Summary Review

* **Overall Rating**: [Score from 1-10, briefly describe robustness and cleanliness of this commit] 
* **Core Risk**: [One sentence summarizing the change point that needs most attention]

---

*(Note: When there are multiple changed repositories, use `---` to separate and loop repeat the above template block.)*

# 📊 Global Execution Summary

*(Note: Must be placed at the very end of document)*

* **Total Scanned**: [Read TOTAL_SCANNED_REPOS from log]
* **Total Reviewed**: [Number of repositories that actually produced Diff reports]
* **Total Skipped**: [Number of repositories that did not generate reports]
* **Skip Details**:
  * [Repository A name]: [Extract specific reason from `SKIP` log in parentheses]
  * [Repository B name]: [Extract specific reason from `SKIP` log in parentheses]

## Constraints (Mandatory)

- Mandatory output in Chinese.
- Extremely concise, reject nonsense and excessive pleasantries.
- Must consolidate all repository reports into the same Markdown file, cannot split into multiple files.
