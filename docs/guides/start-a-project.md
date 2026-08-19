# 开始一个拆解项目

对用户：说要拆哪个项目，以及现在可否读源码、可否本地运行、可否联网。其余由 Agent 填写。

## 1. 初始化

```shell
./scripts/init-project.sh <project-id> <project-name> <source-path>
```

初始化只复制模板，不读取 `source-path`。

## 2. 范围确认

Agent 根据用户的白话许可填写 `workspaces/<project-id>/project.yaml`：源码 revision、读者画像、交付目标、排除项、禁止操作和能力矩阵。未明确授权的能力保持 `false`。不要让用户手填阶段码或 11 个权限开关。

## 3. 检查结构

```shell
./scripts/validate-project.sh workspaces/<project-id> --structure-only
```

## 4. 下一步许可

用白话说明接下来要读什么、要搞清什么、明确不做什么。只有授权卡更新后才开始源码侦察。

## 5. 持续记录

调查过程中由 Agent 维护 `EVIDENCE.md` 和未知项。学习文档写项目事实；不要在写完后再补造引用，也不要把证据字母表写进读者正文。
