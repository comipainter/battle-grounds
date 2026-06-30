# ossutil 使用指南

## 前置条件

确保已安装并配置好 ossutil，配置文件位于 `~/.ossutilconfig`。

OSS Bucket 信息：
- Bucket 名称：`battle-grounds-assets`
- 资源根路径：`oss://battle-grounds-assets/assets/`
- 本地项目路径：项目根目录下的 `assets/` 文件夹

---

## 1. 全量拉取 assets 文件夹

适用于首次下载或需要完整同步所有资源时。

```bash
ossutil cp -r oss://battle-grounds-assets/assets/ ./assets/ -f
```

**参数说明：**
- `-r`：递归复制，下载整个目录及其子目录
- `-f`：强制覆盖，跳过确认提示

**注意事项：**
- 全量下载约 330+ MB，300+ 个文件
- 建议在网络环境良好时执行
- 会覆盖本地已有的同名文件

---

## 2. 拉取 assets/data 文件夹（随从/魔法数据同步）

当游戏数据（随从配置、魔法配置等 CSV 或 Tres 文件）有更新时，只需同步 data 目录即可。

```bash
ossutil cp -r oss://battle-grounds-assets/assets/data/ ./assets/data/ -f
```

**适用场景：**
- 随从数据更新（minion_data.csv 等）
- 魔法数据更新（magic_data.csv 等）
- 数据集合文件更新（.tres 文件）
- 翻译文件更新（.translation 文件）

**data 目录包含：**
- `csv/` — CSV 配置文件及翻译文件
- `tres/` — Godot 资源文件（数据集合）

---

## 3. 拉取 assets/image 图片资源

### 3.1 下载指定图片（推荐）

当只需要更新某几张图片时，使用精确路径下载单个文件：

```bash
# 下载单张图片
ossutil cp oss://battle-grounds-assets/assets/image/minion/随从名称.png ./assets/image/minion/ -f

# 示例：下载指定随从图片
ossutil cp oss://battle-grounds-assets/assets/image/minion/南海卖艺者.png ./assets/image/minion/ -f

# 示例：下载指定魔法图片
ossutil cp oss://battle-grounds-assets/assets/image/magic/海潮的祝福.png ./assets/image/magic/ -f
```

### 3.2 下载某个子目录的全部图片

如果需要同步某个分类下的所有图片：

```bash
# 下载所有随从图片
ossutil cp -r oss://battle-grounds-assets/assets/image/minion/ ./assets/image/minion/ -f

# 下载所有魔法图片
ossutil cp -r oss://battle-grounds-assets/assets/image/magic/ ./assets/image/magic/ -f

# 下载主场景图片
ossutil cp -r oss://battle-grounds-assets/assets/image/main_scene/ ./assets/image/main_scene/ -f
```

### 3.3 全量下载 image 文件夹（不推荐）

```bash
ossutil cp -r oss://battle-grounds-assets/assets/image/ ./assets/image/ -f
```

**不推荐原因：**
- 图片文件数量多、体积大，全量下载耗时较长
- 大多数情况下只需更新个别图片
- 浪费带宽和时间

---

## 常用 ossutil 命令参考

### 查看 OSS 目录内容

```bash
# 查看根目录
ossutil ls oss://battle-grounds-assets/

# 查看 assets 目录
ossutil ls oss://battle-grounds-assets/assets/

# 查看 data 目录
ossutil ls oss://battle-grounds-assets/assets/data/

# 递归查看所有文件
ossutil ls -r oss://battle-grounds-assets/assets/
```

### 上传文件到 OSS（谨慎使用）

```bash
# 上传单个文件
ossutil cp ./assets/data/csv/minion_data.csv oss://battle-grounds-assets/assets/data/csv/ -f

# 上传整个目录
ossutil cp -r ./assets/data/ oss://battle-grounds-assets/assets/data/ -f
```

**注意：** 上传操作会覆盖 OSS 上的文件，请确保本地文件是正确的最新版本。

---

## 目录结构说明

```
assets/
├── data/                    # 游戏数据配置
│   ├── csv/                 # CSV 数据文件 + 翻译文件
│   │   ├── minion_data.csv
│   │   ├── magic_data.csv
│   │   └── *.translation
│   └── tres/                # Godot 资源文件
│       ├── minion_data_collection.tres
│       └── magic_data_collection.tres
├── font/                    # 字体文件
├── image/                   # 图片资源
│   ├── card/                # 卡牌相关图片
│   ├── magic/               # 魔法相关图片
│   ├── minion/              # 随从相关图片
│   ├── main_menu/           # 主菜单图片
│   ├── main_scene/          # 主场景图片
│   └── player/              # 玩家相关图片
└── info/                    # 游戏信息配置
```
