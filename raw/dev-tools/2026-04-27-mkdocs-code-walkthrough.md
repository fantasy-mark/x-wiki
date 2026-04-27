# MkDocs 源码走读笔记

> 来源: 用户笔记, 2026-04-27; MkDocs GitHub
> 走读版本: 0.2 → 0.13 → 1.4.3
> 参考: [[mkdocs-user-guide]]

## 版本演化

### v0.2 — 最简结构

```python
# mkdocs/mkdocs.py
def main(cmd, options=None):
    if cmd == 'build':
        config = mkdocs.load_config(options=options)
        mkdocs.build(config)

# mkdocs/build.py
def build(config):
    build_theme(config)
    build_statics(config)
    build_pages(config)
```

代码干爽，架构清晰：命令行解析 → 加载配置 → 执行 build（主题 + 静态资源 + 页面）。

### v0.13 — 引入 Click 库

```python
# mkdocs/cli.py
@cli.command(name="build")
@click.option('--clean', is_flag=True)
@click.option('--config-file', type=click.File('rb'))
@click.option('--strict', is_flag=True)
@click.option('--theme', type=click.Choice(theme_choices))
@click.option('--site-dir', type=click.Path())
def build_command(clean, config_file, strict, theme, site_dir):
    build.build(load_config(
        config_file=config_file,
        strict=strict,
        theme=theme,
        site_dir=site_dir
    ), clean_site_dir=clean)
```

突然引入的 `@cli.command` 装饰器其实是 **Click 库** 提供的。Click 是 Python 最流行的 CLI 框架，通过装饰器简化命令行参数定义。

### v1.4.3 — 完整 Click 集成

```python
# mkdocs/__main__.py
@cli.command(name="build")
@click.option('-c', '--clean/--dirty', is_flag=True, default=True)
@common_config_options
@click.option('-d', '--site-dir', type=click.Path())
@common_options
def build_command(clean, **kwargs):
    cfg = config.load_config(**kwargs)
    cfg['plugins'].run_event('startup', command='build', dirty=not clean)
    try:
        build.build(cfg, dirty=not clean)
    finally:
        cfg['plugins'].run_event('shutdown')
```

## Click 装饰器机制

### @click.group

```python
@click.group(context_settings={'help_option_names': ['-h', '--help']})
def cli():
    """Main entry point."""
    pass

@cli.command()
def subcommand():
    """Sub command."""
    ...
```

`@click.group` 将函数转换为命令组（Group），具有 `.command()` 方法用于定义子命令。

### @click.command

```python
@click.command()
@click.option('--count', default=1)
@click.option('--name', prompt='Your name')
def hello(count, name):
    for x in range(count):
        click.echo(f"Hello {name}!")
```

### @click.option

| 形式 | 说明 |
|------|------|
| `--count` | 长选项 |
| `-c` | 短选项 |
| `is_flag=True` | 布尔开关 |
| `default=1` | 默认值 |
| `type=click.Path()` | 类型验证 |
| `prompt='Your name'` | 交互式提示 |

## 关键收获

1. **装饰器是 Python CLI 的标准做法**：Click 把函数变成命令，@option/@argument 把参数绑定到函数参数
2. **版本对比是理解架构的好方法**：从 0.2 的简单 if-elif 到 1.4.3 的插件系统，MkDocs 演化的每一步都有迹可循
3. **GPT 可以很好地辅助源码阅读**：遇到不懂的装饰器语法，问 GPT 比直接翻文档更高效

## 相关

- [[mkdocs-user-guide]] — MkDocs 使用指南
