# MkDocs 使用指南

> 来源: 用户笔记, 2026-04-27; MkDocs 官方文档
> 参考: [[mkdocs-code-walkthrough]]

## 创建项目

```bash
pip install mkdocs mkdocs-material

# 创建项目
mkdocs new my-project
cd my-project

# 添加 material 主题
notepad.exe .\mkdocs.yml

# 本地预览
mkdocs serve

# 初始化 git 并推送
git init .
git remote add origin https://gitee.com/git4mark/docs.git
git add . && git commit -m "1st build"
git push --set-upstream origin master

# 发布到 GitHub Pages（推送到 gh-pages 分支）
mkdocs.exe gh-deploy
```

## mkdocs.yml 配置

### 左侧导航

```yaml
nav:
  - 一. 介绍: index.md
  - 二. 安装:
      - 1. 本地环境搭建: install/local.md
      - 2. 发布至GitHub Pages: install/github-pages.md
  - 三. 语法:
      - 1. 语法总览: syntax/main.md
```

### drawio 集成（进阶）

安装 drawio 桌面版并配置环境变量，然后安装插件：

```bash
pip install mkdocs-drawio-exporter
```

yaml 中配置插件：

```yaml
plugins:
  - search
  - drawio-exporter
```

使用方式：

```markdown
![My alt text](my-diagram.drawio)
# 多页
![Page 1](my-diagram.drawio#0)
```

注意：draw 文件路径不能包含中文。

## 阿里云部署

### 安全组配置

在阿里云 ECS → 安全组 → 管理实例 → 手动添加，开启 11000~12000 端口范围。

### Nginx 安装与配置

```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
sudo ufw allow 'Nginx Full'
```

修改 `/etc/nginx/sites-available/default`：

```ini
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/mydocs;  # 必须放在 /var/www/ 下
}
```

### 部署 MkDocs

```bash
git clone https://github.com/fantasy-mark/mydocs.git
git checkout gh-pages
git pull

# 重载 nginx
nginx -s reload
```

## 思维导图（markmap）

```bash
sudo npm install -g markmap-cli
markmap input.txt --no-toolbar
```

## 相关

- [[mkdocs-code-walkthrough]] — MkDocs 源码走读（0.2→1.4.3 演化）
