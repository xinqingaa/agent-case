# 开始一个拆解项目

## 1. 初始化

```shell
./scripts/init-project.sh <project-id> <project-name> <source-path>
```

初始化只复制模板，不读取 `source-path`。

## 2. 完成 G0

编辑 `workspaces/<project-id>/project.yaml`：记录源码 revision、目标读者、交付目标、排除项、禁止操作和能力矩阵。未明确授权的能力保持 `false`。

## 3. 检查结构

```shell
./scripts/validate-project.sh workspaces/<project-id> --structure-only
```

## 4. 请求下一阶段授权

说明下一阶段需要读取什么、要产生哪些证据、明确不做什么。只有授权卡更新后才开始源码侦察。

## 5. 持续记录证据

调查过程中同步维护 `EVIDENCE.md` 和未知项，不要在文档写完后补造引用。
