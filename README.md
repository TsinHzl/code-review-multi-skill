# code-review-multi-skill

Batch multi-repository Code Review expert skill for Claude Code CLI.

## Overview

Automatically scans all subdirectories containing `.git` in the current directory, batch extracts Diff and branch information from each repository, and generates a single consolidated Code Review report file covering critical issues, improvement suggestions, and elegant refactoring solutions.

## Features

- **Batch scanning** — Auto-discovers and processes all Git repositories (regular repos, Submodules, Worktrees)
- **Smart filtering** — Auto-skips repos with no changes, Detached HEAD state, or invalid branches
- **Unified report** — All repository reviews consolidated into a single Markdown file
- **Deep analysis** — Covers critical issues, improvement suggestions, and elegant refactoring
- **Memory optimized** — Uses temp files to prevent memory overflow from large diffs

## Installation

Place the `code-review-multi/` folder into your Claude Code skills directory:

```bash
# macOS/Linux
cp -r code-review-multi ~/.claude/skills/

# Windows
copy code-review-multi %USERPROFILE%\.claude\skills\
```

## Usage

### Trigger Keywords

Use the following keywords in Claude Code to trigger the skill:

- `batch review`
- `multi-repo`
- `batch audit`
- `all repositories`
- `batch code inspection`
- `批量审查`
- `多仓库`
- `批量审核`
- `所有仓库`
- `批量代码检查`

### Example

```bash
# In a directory containing multiple Git repositories
cd /path/to/parent-directory

# Start Claude Code and request batch review
claude
> batch review all repositories
> 请对所有仓库进行批量代码审查
```

### Workflow

1. **Auto-scan** — Scans all subdirectories in current directory, identifies Git repositories
2. **Extract changes** — Extracts branch info and Diff from each repository
3. **Deep review** — Analyzes code changes, identifies issues and optimization points
4. **Generate report** — Outputs unified Markdown report file

## Output Format

Generated report file is named `[current_directory_name]_code_review.md`. The report template is defined in `references/report-template.md` and contains:

### Per-Repository Review Content

- **📝 Change Overview** — Summary of main code changes
- **🚨 Deep Review Opinions**:
  - 🚫 **Critical Issues** — Crashes, security vulnerabilities, severe logic errors
  - ⚠️ **Improvement Suggestions** — Code standards, readability, redundant logic optimization
  - 💡 **Elegant Refactoring** — Context-based refactoring solutions
- **🏁 Summary Review** — Overall rating and core risk

### Global Execution Summary

- Total scanned
- Total reviewed
- Total skipped
- Skip details (with reasons)

## Skip Scenarios

Repositories are automatically skipped in the following cases:

- Detached HEAD state
- Source branch not found and cannot match default main branch
- Current branch matches source branch (no new commits)
- Branches differ but no effective code changes

## Technical Details

### Branch Detection Logic

- Uses `git reflog` to trace branch creation origin
- Auto-handles `remotes/` and `origin/` prefixes
- Fallback to default main branch (main/master/develop) when source branch cannot be determined
- Compatible with regular repos, Submodules, and Worktrees

### Memory Optimization

- Uses independent temp files to store single repository Diff
- Avoids variable memory overflow from large changesets
- Auto-cleans temp files

### Review Standards

- Skips auto-generated files (e.g., `package-lock.json`)
- Focuses on logic bugs, boundary gaps, readability, performance, security
- Provides complete code comparison and fix solutions
- Report structure follows the template defined in `references/report-template.md`

## Constraints

- Output language: **forced Chinese output**
- Extremely concise, rejects nonsense and excessive pleasantries
- Must consolidate all repository reports into the same Markdown file
- No empty reports or placeholder prompts for unchanged repositories
- Each independent code location corresponds to a single review comment, no merging or splitting

## Dependencies

- Git 2.0+
- Bash 4.0+
- Claude Code CLI

## License

MIT

## Contributing

Issues and Pull Requests are welcome.

---



# code-review-multi-skill（中文说明）

批量多仓库 Code Review 专家技能包，用于 Claude Code CLI。

## 功能概述

自动扫描当前目录下所有包含 `.git` 的子目录，批量提取每个仓库的 Diff 和分支信息，生成单个统一的 Code Review 报告文件，涵盖关键问题、改进建议和优雅重构方案。

## 特性

- **批量扫描** — 自动发现并处理所有 Git 仓库（包括常规仓库、Submodules、Worktrees）
- **智能过滤** — 自动跳过无变更、Detached HEAD 状态或无效分支的仓库
- **统一报告** — 所有仓库的审查结果整合到单个 Markdown 文件
- **深度分析** — 涵盖关键问题、改进建议、优雅重构三个维度
- **内存优化** — 使用临时文件防止大型 Diff 导致的内存溢出

## 安装

将 `code-review-multi` 目录复制到 Claude Code 的技能目录：

```bash
# macOS/Linux
cp -r code-review-multi ~/.claude/skills/

# Windows
copy code-review-multi %USERPROFILE%\.claude\skills\
```

## 使用方法

### 触发关键词

在 Claude Code 中使用以下关键词触发技能：

- `批量审查`
- `多仓库`
- `批量审核`
- `所有仓库`
- `批量代码检查`
- `batch review`
- `multi-repo`
- `batch audit`
- `all repositories`
- `batch code inspection`

### 示例

```bash
# 在包含多个 Git 仓库的目录中
cd /path/to/parent-directory

# 启动 Claude Code 并请求批量审查
claude
> 请对所有仓库进行批量代码审查
> batch review all repositories
```

### 工作流程

1. **自动扫描** — 扫描当前目录下所有子目录，识别 Git 仓库
2. **提取变更** — 对每个仓库提取分支信息和 Diff
3. **深度审查** — 分析代码变更，识别问题和优化点
4. **生成报告** — 输出统一的 Markdown 报告文件

## 输出格式

生成的报告文件命名为 `[当前目录名]_code_review.md`，报告模板详见 `references/report-template.md`，包含：

### 每个仓库的审查内容

- **📝 变更概览** — 主要代码变更点总结
- **🚨 深度审查意见**:
  - 🚫 **关键问题** — 崩溃、安全漏洞、严重逻辑错误
  - ⚠️ **改进建议** — 代码规范、可读性、冗余逻辑优化
  - 💡 **优雅重构** — 基于上下文的重构方案
- **🏁 总结审查** — 整体评分和核心风险

### 全局执行摘要

- 总扫描数
- 总审查数
- 总跳过数
- 跳过详情（含原因）

## 跳过场景

以下情况仓库会被自动跳过：

- Detached HEAD 状态
- 未找到源分支且无法匹配默认主分支
- 当前分支与源分支一致（无新提交）
- 分支不同但无有效代码变更

## 技术细节

### 分支检测逻辑

- 使用 `git reflog` 追溯分支创建来源
- 自动处理 `remotes/` 和 `origin/` 前缀
- 无法确定源分支时 fallback 到默认主分支（main/master/develop）
- 兼容常规仓库、Submodules 和 Worktrees

### 内存优化

- 使用独立临时文件存储单个仓库 Diff
- 避免大型变更集导致的变量内存溢出
- 自动清理临时文件

### 审查标准

- 跳过自动生成文件（如 `package-lock.json`）
- 关注逻辑缺陷、边界遗漏、可读性、性能、安全性
- 提供完整的代码对比和修复方案
- 报告结构遵循 `references/report-template.md` 定义的模板

## 约束条件

- 输出语言：**强制中文输出**
- 极度精简，拒绝废话和过度客套
- 必须将所有仓库报告整合到同一个 Markdown 文件
- 无变更的仓库不输出空报告或占位提示
- 每个独立代码位置对应一条审查意见，不合并、不拆分

## 依赖

- Git 2.0+
- Bash 4.0+
- Claude Code CLI

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request。
