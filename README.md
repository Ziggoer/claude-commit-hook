# claude-commit-hook

用 [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) CLI 帮你写 git commit message 的 `prepare-commit-msg` hook。

一个 20 行的 bash 脚本，没有任何依赖，只调一次 `claude` 命令。

## 效果

```bash
$ git add .
$ git commit
# hook 自动把 staged diff 喂给 claude，生成 conventional commit 风格的 message
# 打开编辑器时已经预填好，你可以改也可以直接保存
```

## 安装

前置要求：本机已安装 `claude` CLI 并完成登录（`claude --version` 能跑通即可）。

一行命令：

```bash
curl -fsSL https://raw.githubusercontent.com/Ziggoer/claude-commit-hook/main/install.sh | bash
```

或者 clone 下来手动跑：

```bash
git clone https://github.com/Ziggoer/claude-commit-hook.git
cd claude-commit-hook
./install.sh
```

脚本会：

1. 检查 `claude` CLI 是否存在
2. 把 hook 复制到 `~/.config/git/hooks/prepare-commit-msg` 并加可执行权限
3. 设置 `git config --global core.hooksPath ~/.config/git/hooks`

### Windows 用户

需要在 **Git Bash**（Git for Windows 自带）或 **WSL** 里跑 `install.sh`，PowerShell/cmd 本身不能直接执行 bash 脚本。装完之后，无论你从哪里触发 `git commit`（命令行、GUI 客户端如 Fork/SourceTree/GitHub Desktop），hook 都会被 git 自动调用 —— GUI 客户端底层也是 Git for Windows，会用它自带的 bash 解释 shebang。

仓库里 `.gitattributes` 已强制 `prepare-commit-msg` 和 `*.sh` 使用 LF 换行，规避了 Windows 常见的 `bad interpreter: /bin/bash^M` 问题。

## 卸载

```bash
./uninstall.sh
```

会删除 hook 文件、清掉 `core.hooksPath` 设置（仅当它指向本工具安装目录时才清）。

## 工作原理

`prepare-commit-msg` 是 git 在打开 commit message 编辑器之前触发的 hook。脚本逻辑：

```
git commit 被触发
    │
    ├─ 有 -m / -F / --amend / merge / squash / -c 等显式 message 源？
    │     └─ 直接退出，什么都不做
    │
    ├─ 有非空 commit.template（-t 或全局 commit.template 配置）？
    │     └─ 直接退出，尊重用户模板
    │     （空模板如 SourceTree 默认的 ~/.stCommitMsg 会继续走 claude）
    │
    ├─ 没有 staged 改动？
    │     └─ 直接退出
    │
    └─ 把 `git diff --cached` 管道给 claude -p，取回 message 写进文件
            └─ 如果 claude 失败或返回空 → 保留 git 默认模板（fallback，并打印到 stderr）
```

即 **只在"你真的要让 git 给你开编辑器让你写 message"的场景下才介入**，不会抢走你的 `-m`、不会覆盖 merge commit 的默认文案、不会无视你认真写的模板。

## 自定义 prompt

直接编辑 `~/.config/git/hooks/prepare-commit-msg` 里那段传给 `claude` 的 prompt 即可。比如想让 message 包含 emoji、走中文、加上 scope 等等。

## 注意事项

### 1. `core.hooksPath` 是替换语义

全局设置 `core.hooksPath` 后，**所有仓库**的 `.git/hooks/` 目录都会被忽略。如果你某些仓库里有自己的 hooks，需要手动把它们也放进 `~/.config/git/hooks/`。

### 2. Husky / Lefthook 冲突

Node 项目如果用 Husky，它在 `npm install` 时会把对应仓库的 `core.hooksPath` 覆盖成 `.husky/`。这种仓库里本 hook 就失效了 —— 属于预期行为。

### 3. claude 不可用时会静默降级

如果 `claude` 命令缺失、超时或返回空，hook 不会报错也不会清空 message —— git 会继续用它的默认 template 打开编辑器，你手动写就是了。

### 4. 首次调用速度

`claude` 冷启动 + 模型响应大概需要几秒，有网络抖动时可能更慢。嫌慢就把 prompt 写短，或者在编辑器打开后 Ctrl-C 取消 commit。

## License

MIT
