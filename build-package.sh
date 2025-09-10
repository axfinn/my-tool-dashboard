#!/bin/bash
# 生成构建产物 zip 包脚本
# 使用: ./build-package.sh [version-tag]
# 若传入 version-tag 则 zip 文件名包含之，否则使用 package.json 中 version
set -e

if ! command -v jq &>/dev/null; then
  echo "⚠️ 没有安装 jq (用于读取 package.json)，将尝试使用 grep 简单解析版本"
fi

PROJECT_NAME="my-tool-dashboard"

# 读取版本
if command -v jq &>/dev/null; then
  VERSION=$(jq -r .version package.json)
else
  VERSION=$(grep '"version"' package.json | head -n1 | sed -E 's/.*"version" *: *"([^"]+)".*/\1/')
fi

INPUT_VERSION=$1
if [ -n "$INPUT_VERSION" ]; then
  VERSION="$INPUT_VERSION"
fi

TS=$(date +%Y%m%d_%H%M%S)
OUT_DIR="release"
ZIP_NAME="${PROJECT_NAME}-dist-v${VERSION}-${TS}.zip"

echo "🧹 清理旧的 dist..."
rm -rf dist

echo "🔨 构建项目..."
npm run build

if [ ! -d dist ]; then
  echo "❌ 构建失败，未找到 dist 目录" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# 生成一个文件列表清单（忽略 node_modules 等）
echo "📄 生成文件清单 manifest.txt"
( cd dist && find . -type f | sort ) > "$OUT_DIR/manifest-dist-${TS}.txt"

# 打包 dist 目录
echo "🗜️ 创建压缩包 $ZIP_NAME"
(cd dist && zip -r "../$OUT_DIR/$ZIP_NAME" . >/dev/null)

# 生成 SHA256 校验
( cd "$OUT_DIR" && shasum -a 256 "$ZIP_NAME" > "$ZIP_NAME.sha256" )

echo "✅ 完成: $OUT_DIR/$ZIP_NAME"
echo "🔐 校验文件: $OUT_DIR/$ZIP_NAME.sha256"
echo "📦 文件清单: $OUT_DIR/manifest-dist-${TS}.txt"
