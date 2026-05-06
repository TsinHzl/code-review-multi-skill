---
name: code-review-multi
description: Batch multi-repository Code Review expert. Automatically scans all subdirectories containing .git in the current directory, batch extracts Diff and branch information from each repository, and generates a single consolidated Code Review report file covering critical issues, improvement suggestions, and elegant refactoring solutions.
trigger: Triggered when the user requests batch Code Review across multiple repositories/subdirectories. Keywords: batch review, multi-repo, batch audit, all repositories, batch code inspection.
---

# Skill: code-review-multi (Batch Multi-Repository Code Review Expert)

## Trigger Conditions

- User input contains: batch review, multi-repo, batch audit, all repositories, batch code inspection
- User requests Code Review across multiple sub-repositories in the current directory

## Input Parameters

No parameters required. Automatically scans all subdirectories containing .git in the current directory.

## Role: Senior Software Engineer, executing batch Code Review

## Workflow

Follow the two steps below strictly in order. Step 1 must be executed in a single code/terminal execution tool call:

### Step 1: Batch Scan and Diff Extraction (execute in one shot)

⚠️ **MANDATORY**: You MUST execute the following command in a **SINGLE** Bash tool call. Do NOT split, simulate, or skip it.

```bash
bash "$(dirname "$0")/scripts/code-review-multi-env.sh"
```

### Step 2: Deep Review and Batch Report Generation

After receiving the aggregated log output from Step 1 (containing Diff, branch info, SKIP reasons, scan totals), begin the Code Review. If the log contains only `SKIP` entries with no valid `REPOSITORY` changes, reply to the user with "All repositories have no effective changes" and end the task.

**Review Requirements**: Skip auto-generated files (e.g., package-lock.json). **Before reviewing, extract the list of all changed files from each repository's diff, review file by file in alphabetical order. Within each file, independently process every `+` line change — do not merge or skip any change point. For each `+` line change, strictly scan the following 6 items in order. Each item must have an explicit conclusion (found/not found) — none may be skipped**:
1. Security vulnerabilities (injection, privilege escalation, sensitive data leakage, OWASP Top 10)
2. **Crashes and exceptions (zero tolerance)**: null pointer dereference, array/collection out-of-bounds access, forced type cast failure, division by zero, uncaught exceptions, unreleased resources (file handles/database connections/memory leaks), thread safety issues (race conditions/deadlocks), stack overflow, infinite recursion, any code that could cause program crash or throw unhandled exceptions
3. Logic errors and boundary omissions (including conditionals, loops, concurrency)
4. Performance issues (time complexity, redundant computation, memory leaks)
5. Code standards and readability (naming, redundant logic, magic numbers)
6. Refactoring opportunities (abstractable logic, duplicated code)

**Classification Rules (strictly enforced, no subjective judgment)**:
- 🚫 Critical Issues: Meets ANY of the following → (a) Can cause program crash/abnormal exit (including null pointer, out-of-bounds, uncaught exceptions, deadlocks, stack overflow, and all runtime crash risks) (b) Security vulnerability exists (c) Data loss or corruption (d) Build/compilation failure. Scan results from items 1 and 2 **ALWAYS** fall into this category and must NOT be downgraded to improvement suggestions.
- ⚠️ Improvement Suggestions: Does not meet critical issue conditions, but is a problem found in scan items 3, 4, or 5.
- 💡 Elegant Refactoring: Scan results from item 6, or structural optimizations to existing implementations.

**Ordering Rules**: Within the same category, sort by filename alphabetically; within the same file, sort by line number ascending. Each independent code location corresponds to one opinion — do not merge or split.
**Only report issues explicitly present in the diff. Do not speculate or supplement content beyond the diff.**
**Output Requirements (strictly enforced)**:
Call the file write tool to generate the Code Review report in the root directory where the initial command was executed. The following rules must be strictly followed:

1. **Single global file output**: All reviewed repositories MUST be consolidated into the same Markdown file. Splitting into multiple files is strictly prohibited.
2. **File naming convention**: The filename must strictly follow `[current_root_directory_name]_code_review.md` (read the `ROOT_DIRECTORY_NAME` from the script output).
3. **No-change filtering**: For repositories marked as `SKIP` by the script, skip the review phase entirely. Empty reports or placeholder messages in the body are strictly prohibited (only reflected in the final summary).

For the generated Markdown file, **strictly apply the following structure** for formatting. Do not modify the hierarchy or add unnecessary pleasantries:

# 📦 Repository Name: [read REPOSITORY name from log]

**Branch Comparison**: `[source branch O_BR]` -> `[current branch C_BR]`

## 📝 Change Overview

[Concisely summarize the main code changes in this repository]

## 🚨 Deep Review Opinions

*(All three categories must be output. If none found for a category, write: `No issues of this type found in this change.` — do not omit the category heading.)*

### 🚫 Critical Issues (Critical)

*Only list issues meeting the critical issue classification criteria (crash/unhandled exception/security vulnerability/data corruption/build failure). **Any code that could cause runtime crash or throw unhandled exceptions MUST be listed here and must NOT be downgraded.** Anything not meeting these conditions goes into improvement suggestions.*

* **Issue Description**: [Precisely describe the defect cause]
* **Potential Impact**: [Describe consequences, e.g., memory overflow, data leakage]

* **Location**: Lines L[start_line] - L[end_line]
* **Current branch vs source branch change comparison**:

  ```javascript
  // Source branch code
  [Extract complete source branch code block]
  
  // Current branch changed code
  [Extract complete current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Extract complete original code block containing the issue]
  
  // ✅ Fixed code
  [Provide refactored code following Clean Code principles and high performance]
  ```

* **Fix Highlights**: [Briefly describe the core advantage after fix, e.g., reduced cyclomatic complexity]

### ⚠️ Improvement Suggestions (Standard)

*List all issues that do not meet critical issue conditions but belong to logic errors/boundary omissions/performance issues/code standards. Sort by filename alphabetically, then by line number ascending.*

* **Suggestion**: [Describe the suggestion, e.g., recommend using Optional Chaining]
* **Rationale**: [Explain why this change is better]

* **Location**: Lines L[start_line] - L[end_line]
* **Current branch vs source branch change comparison**:

  ```javascript
  // Source branch code
  [Extract complete source branch code block]
  
  // Current branch changed code
  [Extract complete current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Extract complete original code block containing the issue]
  
  // ✅ Fixed code
  [Provide refactored code following Clean Code principles and high performance]
  ```

* **Fix Highlights**: [Briefly describe the core advantage after fix, e.g., reduced cyclomatic complexity]

### 💡 Elegant Refactoring (Refactoring)

*Must provide refactoring solutions based on context targeting specific code change points. Strictly follow the comparison format below:*

* **Location**: Lines L[start_line] - L[end_line]

* **Current branch vs source branch change comparison**:

  ```javascript
  // Source branch code
  [Extract complete source branch code block]
  
  // Current branch changed code
  [Extract complete current branch changed code]
  ```

* **Fix Comparison**:

  ```javascript
  // ❌ Original code
  [Extract complete original code block containing the issue]
  
  // ✅ Fixed code
  [Provide refactored code following Clean Code principles and high performance]
  ```

* **Fix Highlights**: [Briefly describe the core advantage after fix, e.g., reduced cyclomatic complexity]

## 🏁 Summary Review

* **Overall Rating**: [Calculate by formula: 10 - (critical_count × 3) - (suggestion_count × 0.5) - (refactoring_count × 0.2), minimum 1 point, one decimal place. Format: X.X points (Critical × N, Suggestions × N, Refactoring × N)]
* **Core Risk**: [One sentence summarizing the most important change point to focus on]

---

*(Note: When multiple repositories have changes, use `---` as separator and repeat the template blocks above.)*

# 📊 Global Execution Summary

*(Note: Must be placed at the very end of the document)*

* **Total Scanned**: [read TOTAL_SCANNED_REPOS from log]
* **Total Reviewed**: [number of repositories that produced Diff reports]
* **Total Skipped**: [number of repositories without reports]
* **Skip Details**:
  * [RepoA name]: [extract specific reason from `SKIP` log parentheses]
  * [RepoB name]: [extract specific reason from `SKIP` log parentheses]

## Constraints (Mandatory)

- Output language must match the user's language (e.g., if the user writes in Chinese, output in Chinese; if in English, output in English).
- Extremely concise, reject filler and excessive pleasantries.
- Must consolidate all repository reports into the same Markdown file. Splitting into multiple files is prohibited.
