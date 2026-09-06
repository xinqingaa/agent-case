# Templates

`project-decomposition/` 是 0.3 版项目工作区模板。项目交付文件必须复制到 `workspaces/<project-id>/` 根部，使用 `foundation-*`、`source-study-*`、`replication-*` 和 `extension-*` 前缀，不使用二级目录。模板结构与 [`docs/specifications/document-contract.md`](../docs/specifications/document-contract.md) 一致，并由 [`scripts/init-project.sh`](../scripts/init-project.sh) 复制。

学习文档面向有工程背景、但不是该仓库作者的人。`learning_profile` 决定各路线是否生成和验收；排除路线不需要创建。`{{PLACEHOLDER}}` 必须在最终验收前全部解决。
