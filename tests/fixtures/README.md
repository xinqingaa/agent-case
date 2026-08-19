# Test fixtures

- `valid-project.yaml`：符合 0.2 Schema 的最小 L0 项目。
- `invalid-permission.yaml`：使用非布尔权限值，应被拒绝。

工作区结构、缺失核心链路、重复初始化和模板占位符场景由 `test-scripts.sh` 在临时目录中动态生成，避免维护一整套重复模板。
