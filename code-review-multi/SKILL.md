---
name: code-review-multi
description: Batch multi-repository Code Review expert. Auto-scans all subdirectories containing .git under the current directory, batch extracts Diff and branch info from each repo, and generates a single consolidated Code Review report covering critical issues, improvement suggestions, and elegant refactoring solutions.
trigger: Triggered when the user requests batch Code Review across multiple repositories/subdirectories. Keywords: batch review, multi-repo, batch audit, all repositories, batch code inspection.
---

# Skill: code-review-multi (Batch Multi-Repository Code Review Expert)

## Trigger Conditions

- User input contains: batch review, multi-repo, batch audit, all repositories, batch code inspection
- User requests simultaneous Code Review on multiple sub-repositories in the current directory

## Input Parameters

No parameters required — automatically scans all subdirectories containing .git under the current directory

## Role: Senior Software Engineer, executing batch Code Review

## Workflow

Execute strictly in the following two steps. Step 1 must complete in a single terminal tool call:

### Step 1: Batch Scan & Diff Extraction (Complete in a Single Call)

⚠️ **MANDATORY**: You MUST execute the following command in a **SINGLE** Bash tool call. Do NOT split, simulate, or skip it.

```bash
bash "${HOME}/.claude/commands/scripts/code-review-multi-env.sh"
```

### Step 2: Deep Review & Batch Report Generation

After receiving the aggregated log from Step 1 (containing Diff, branch info, SKIP reasons, total scan count), begin Code Review. If the output contains only `SKIP` entries with no valid `REPOSITORY` changes, reply to the user: "No effective changes found in any repository." and end the task.

**Review requirements**: Skip auto-generated files (e.g., `package-lock.json`). **Before reviewing, extract the full list of changed files from each repo's diff, then review each file in alphabetical order. Within each file, process every `+` line change independently — no merging, no skipping. For each `+` line change, strictly scan the following 6 items in order. Each item must yield an explicit conclusion (found / not found) — none may be skipped**:
1. Security vulnerabilities (injection, privilege escalation, sensitive data exposure, OWASP Top 10)
2. **Crashes & exceptions (zero tolerance)**: null pointer dereferences, array/collection out-of-bounds, failed type casts, division by zero, uncaught exceptions, resource leaks (file handles/DB connections/memory leaks), thread-safety issues (race conditions/deadlocks), stack overflows, infinite recursion, any code that could cause a crash or unhandled exception
3. Logic errors & boundary gaps (conditions, loops, concurrency)
4. Performance issues (time complexity, redundant computation, memory leaks)
5. Code standards & readability (naming, redundant logic, magic numbers)
6. Refactoring opportunities (abstractable logic, duplicate code)

**Classification rules (enforce strictly, no subjective judgment)**:
- 🚫 Critical Issue: meets any of the following → (a) can cause crash/abnormal exit (null pointer, out-of-bounds, uncaught exception, deadlock, stack overflow, or any runtime crash risk) (b) security vulnerability (c) data loss or corruption (d) build/compile failure. Results from items 1 and 2 **must** go here — never downgrade to suggestions.
- ⚠️ Improvement Suggestion: does not meet Critical criteria, but issues found in items 3, 4, or 5.
- 💡 Elegant Refactoring: results from item 6, or structural optimizations to existing implementations.

**Ordering**: within the same category, sort by filename (alphabetical); within the same file, sort by line number ascending. One comment per distinct code location — no merging, no splitting.
**Only report issues explicitly present in the diff — no speculation, no content beyond the diff.**

**Output requirements (strict)**:
Use the file-write tool to generate the Code Review report in the root directory where the command was initially executed. The following rules must be strictly observed:

1. **Single global output file**: All reports for all changed repositories must be consolidated into a single Markdown file — splitting is never allowed.
2. **File naming convention**: The filename must be strictly named `[current_root_dir_name]_code_review.md` (read `ROOT_DIRECTORY_NAME` from script output).
3. **Filter unchanged repos**: For repositories marked `SKIP` by the script, skip the review stage entirely — do not output empty reports or placeholder text in the body (only include them in the final summary).

For the generated Markdown file, **strictly apply the following structure**. Do not alter heading hierarchy or add irrelevant filler text:

# 📦 Repository: [Read REPOSITORY name from log]

**Branch comparison**: `[source branch O_BR]` -> `[current branch C_BR]`

## 📝 Change Overview

[Concise summary of the main code changes in this repository]

## 🚨 Deep Review

*(All three categories must be output. If none found in a category, write: `No issues of this type found in this change.` — the category heading must not be omitted.)*

### 🚫 Critical Issues

*Only list issues that satisfy the Critical classification criteria (crash/unhandled exception/security vulnerability/data corruption/build failure). **Any code that could cause a runtime crash or unhandled exception must be listed here — no downgrading.** Issues that don't meet the criteria go into Improvement Suggestions.*

* **Issue description**: [Precise description of the defect]
* **Potential impact**: [Describe consequences, e.g., memory overflow, data leak]

* **Location**: Line L[start] - L[end]
* **Current vs origin branch diff**:

  ```javascript
  // Origin branch code
  [Extract full origin branch code block]
  
  // Current branch changed code
  [Extract full current branch changed code]
  ```

* **Fix comparison**:

  ```javascript
  // ❌ Original code
  [Extract full original problematic code block]
  
  // ✅ Fixed code
  [Provide Clean Code, high-performance refactored code]
  ```

* **Fix highlights**: [Briefly describe the core improvement, e.g., reduced cyclomatic complexity]

### ⚠️ Improvement Suggestions

*List all issues that don't meet Critical criteria but fall under logic errors/boundary gaps/performance issues/code standards. Sort by filename (alphabetical), then line number ascending.*

* **Suggestion**: [Describe the suggestion, e.g., use Optional Chaining]
* **Rationale**: [Explain why this change is better]

* **Location**: Line L[start] - L[end]
* **Current vs origin branch diff**:

  ```javascript
  // Origin branch code
  [Extract full origin branch code block]
  
  // Current branch changed code
  [Extract full current branch changed code]
  ```

* **Fix comparison**:

  ```javascript
  // ❌ Original code
  [Extract full original code block]
  
  // ✅ Fixed code
  [Provide Clean Code, high-performance refactored code]
  ```

* **Fix highlights**: [Briefly describe the core improvement]

### 💡 Elegant Refactoring

*Must provide refactoring solutions based on context for specific code changes. Strictly follow the comparison format below:*

* **Location**: Line L[start] - L[end]

* **Current vs origin branch diff**:

  ```javascript
  // Origin branch code
  [Extract full origin branch code block]
  
  // Current branch changed code
  [Extract full current branch changed code]
  ```

* **Fix comparison**:

  ```javascript
  // ❌ Original code
  [Extract full original code block]
  
  // ✅ Fixed code
  [Provide Clean Code, high-performance refactored code]
  ```

* **Fix highlights**: [Briefly describe the core improvement]

## 🏁 Summary

* **Overall rating**: [Calculate: 10 - (critical×3) - (suggestions×0.5) - (refactoring×0.2), minimum 1.0, one decimal place. Format: X.X pts (critical×N, suggestions×N, refactoring×N)]
* **Core risk**: [One-sentence summary of the most important change to watch]

---

*(Note: When there are multiple changed repositories, use `---` as separator and repeat the above template block.)*

# 📊 Global Execution Summary

*(Note: Must be placed at the very end of the document)*

* **Total scanned**: [Read TOTAL_SCANNED_REPOS from log]
* **Total reviewed**: [Number of repositories that produced a Diff report]
* **Total skipped**: [Number of repositories that did not produce a report]
* **Skip details**:
  * [Repo A name]: [Extract specific reason from `SKIP` log entry]
  * [Repo B name]: [Extract specific reason from `SKIP` log entry]

## Constraints

- Output language must match the user's input language (e.g., Chinese input → Chinese output; English input → English output).
- Extremely concise; reject verbosity and excessive pleasantries.
- Must consolidate all repository reports into a single Markdown file; splitting into multiple files is not allowed.
