---
name: code-review-multi
description: 批量多仓库 Code Review 专家。自动扫描当前目录下所有含 .git 的子仓库，批量执行深度审查并输出统一报告。触发关键词：批量 review、多仓库、批量审查、所有仓库、批量代码检查。
---

# 批量多仓库 Code Review

## 输入参数

无需参数，自动扫描当前目录下所有含 .git 的子目录。

## Workflow

### Step 1: 批量扫描与 Diff 提取

**单次 Bash 调用**执行：

```bash
bash "${HOME}/.claude/skills/code-review-multi/scripts/code-review-multi-env.sh"
```

### Step 2: 深度审查与批量生成报告

若仅含 `SKIP` 日志无有效 `REPOSITORY` 改动 → 回复"所有仓库均无有效改动"，结束。

否则读取 [references/step2-review.md](references/step2-review.md) 并严格执行。

## Constraints

- 强制中文输出
- 所有仓库汇总至同一个 Markdown 文件
- 仅报告 diff 中明确存在的问题
- 略过自动生成文件
- SKIP 仓库不在正文出现，仅在末尾汇总体现
- 每个独立代码位置对应一条意见，不合并、不拆分
