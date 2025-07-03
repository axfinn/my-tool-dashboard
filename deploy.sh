#!/bin/bash

# 部署脚本 for jaxiu.com
# 使用方法: ./deploy.sh [dev|prod]

set -e

ENV=${1:-dev}
PROJECT_NAME="my-tool-dashboard"
DOMAIN="jaxiu.com"

echo "🚀 开始部署 $PROJECT_NAME 到 $ENV 环境..."

# 检查Node.js版本
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装，请先安装 Node.js"
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✅ Node.js 版本: $NODE_VERSION"

# 安装依赖
echo "📦 安装依赖..."
npm install

# 运行测试（如果有）
if [ -f "package.json" ] && grep -q '"test"' package.json; then
    echo "🧪 运行测试..."
    npm test || echo "⚠️ 测试失败，但继续部署"
fi

if [ "$ENV" = "prod" ]; then
    echo "🔨 构建生产版本..."
    
    # 设置生产环境变量
    export NODE_ENV=production
    export VUE_APP_DOMAIN=$DOMAIN
    
    # 构建
    npm run build
    
    # 创建部署目录
    DEPLOY_DIR="/var/www/$DOMAIN"
    sudo mkdir -p $DEPLOY_DIR
    
    # 备份当前版本
    if [ -d "$DEPLOY_DIR/dist" ]; then
        echo "📦 备份当前版本..."
        sudo mv $DEPLOY_DIR/dist $DEPLOY_DIR/dist.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # 复制新版本
    echo "📂 复制文件到 $DEPLOY_DIR..."
    sudo cp -r dist $DEPLOY_DIR/
    sudo chown -R www-data:www-data $DEPLOY_DIR
    sudo chmod -R 755 $DEPLOY_DIR
    
    # 复制Nginx配置
    echo "⚙️ 配置Nginx..."
    sudo cp nginx.conf /etc/nginx/sites-available/$DOMAIN
    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    
    # 测试Nginx配置
    sudo nginx -t
    
    # 重启Nginx
    echo "🔄 重启Nginx..."
    sudo systemctl reload nginx
    
    echo "✅ 生产环境部署完成!"
    echo "🌐 访问: https://$DOMAIN"
    
elif [ "$ENV" = "dev" ]; then
    echo "🛠️ 启动开发服务器..."
    
    # 停止之前的进程
    pkill -f "vue-cli-service serve" || true
    
    # 启动开发服务器
    echo "🚀 在后台启动开发服务器..."
    nohup npm run serve > server.log 2>&1 &
    
    # 等待服务器启动
    echo "⏳ 等待服务器启动..."
    sleep 5
    
    # 检查服务是否启动成功
    if curl -s http://localhost:8081 > /dev/null; then
        echo "✅ 开发服务器启动成功!"
        echo "🌐 本地访问: http://localhost:8081"
        echo "🌐 网络访问: http://$(hostname -I | awk '{print $1}'):8081"
        echo "📋 日志文件: $(pwd)/server.log"
    else
        echo "❌ 服务器启动失败，请检查日志: $(pwd)/server.log"
        exit 1
    fi
    
else
    echo "❌ 无效的环境参数: $ENV"
    echo "用法: $0 [dev|prod]"
    exit 1
fi

echo "🎉 部署完成!"