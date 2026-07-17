# skill-package

将 `skills/` 目录下的 Skill 打包成 `.skill` 发布归档，基于 SHA-256 内容哈希进行变更检测。

## 核心功能

- **扫描** `skills/` 下的直接子目录（含 `SKILL.md` 的）
- **计算** 每个 skill 目录的内容哈希（SHA-256）
- **比对** `releases/` 下的 per-skill manifest，仅打包有变更的 skill
- **输出** `.skill` 文件（ZIP 格式）到 `releases/`

## 使用方式

对 Skill 说：

- "打包发布所有 skill"
- "package skills"
- "检查哪些 skill 需要重新打包"
- "强制重新打包所有 skill"
- "校验 releases 完整性"

## 文件结构

```
skill-package/
├── SKILL.md                          # 核心协议
├── README.md                         # 本文件
└── references/
    ├── manifest-format.md            # Manifest schema 与哈希计算规则
    └── packaging-conventions.md      # .skill 归档格式与命名约定
```

## 设计决策

| 决策 | 选择 | 理由 |
|---|---|---|
| 扫描范围 | 仅 `skills/` 直接子目录 | 避免误打包 Agent 运行时放在项目其他位置的 skill |
| 变更检测 | SHA-256 内容哈希 | 最可靠，不受文件时间戳跨设备差异影响 |
| Manifest 粒度 | 每个 skill 一个独立 manifest | 删除/更新单个 skill 不影响其他 skill 的记录 |
| Manifest 位置 | `releases/<skill-name>.manifest.json` | 与 `.skill` 文件同级，1:1 配对 |
| 归档结构 | 文件平铺在 ZIP 根级 | 与现有 `.skill` 包格式一致 |
