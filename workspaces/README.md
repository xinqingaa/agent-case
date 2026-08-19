# Decomposition Workspaces

每个获准开始的项目在这里拥有一个独立工作区：

```text
workspaces/<project-id>/
├── project.yaml      # 后台：范围和权限
├── EVIDENCE.md       # 后台：证据台账
├── ACCEPTANCE.md     # 后台：阶段和阻断项
├── GLOSSARY.md       # 学习面：术语
├── detailed/         # 学习面：项目事实
└── working/          # 后台：临时记录，不是最终证据
```

读者主看 `detailed/` 和 `GLOSSARY.md`。阶段码和证据 ID 留在后台文件里。

`empty-drill` 是 0.2 空项目演练工作区：不对应真实源码，全部能力为 false。
