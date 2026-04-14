# 实用开发者工具导航

> Sources: User collection, 2026-04-14
> Raw: [2026-04-14-useful-developer-tools-collection.md](../../raw/ai-tools/2026-04-14-useful-developer-tools-collection.md)
> Updated: 2026-04-14

整理了各类提升开发效率的实用工具网站、插件和代码片段。

## AI 提效

AI 辅助工具集合：

| 工具 | 用途 | 链接 |
|------|------|------|
| 佐糖 | AI 图像处理 | [picwish.cn](https://picwish.cn/) |
| Kimi | AI 阅读助手 | [kimi.moonshot.cn](https://kimi.moonshot.cn/) |
| Coze | 创建 AI 应用 | [coze.cn](https://www.coze.cn/) |
| 秘塔AI搜索 | AI 搜索 | [metaso.cn](https://metaso.cn/) |
| 通义万象 | AI 艺术创作 | [tongyi.aliyun.com](https://tongyi.aliyun.com/wanxiang/) |
| 度加 | AI 内容生成 | [aigc.baidu.com](https://aigc.baidu.com/home) |
| Magic Todo | AI 任务管理 | [goblin.tools](https://goblin.tools/) |
| Gamma | AI 演示文档 | [gamma.app](https://gamma.app/signup?i.cc/ai) |
| 哩布AI | AI 文生图 | [liblib.art](https://www.liblib.art/) |
| TTSMaker | 文字转语音 | [ttsmaker.cn](https://ttsmaker.cn/) |

## 文档工具

文档处理、图标、OCR 等工具：

| 工具 | 用途 | 链接 |
|------|------|------|
| Remixicon | 图标资源 | [remixicon.com](https://remixicon.com/) |
| 有道翻译 | 在线翻译 | [fanyi.youdao.com](https://fanyi.youdao.com/trans/#/home) |
| Tesseract | OCR 识别 | [github.com/tesseract-ocr](https://digi.bib.uni-mannheim.de/tesseract/) |
| Boardmix | 在线流程图 | [boardmix.cn](https://boardmix.cn/app/home/flowchart) |

### Tesseract OCR 完整截屏方案

完整的 Python 截屏 OCR 工具：

**安装依赖：**
```shell
pip install pillow pyautogui pytesseract pyperclip
```

**完整代码：**
```python
from time import sleep
from PIL import Image, ImageGrab
import tkinter
import ctypes
import pytesseract
import pyperclip


def ocr():
    ocr_str = pytesseract.image_to_string(Image.open('tmp.png'), lang='chi_sim+eng')
    pyperclip.copy(ocr_str)

class CTkPrScrn:
    def __init__(self):
        self.__start_x, self.__start_y = 0, 0
        self.__scale = 1

        self.__win = tkinter.Tk()
        self.__win.attributes("-alpha", 0.1)
        self.__win.attributes("-fullscreen", True)
        self.__win.attributes("-topmost", True)

        self.__width, self.__height = self.__win.winfo_screenwidth(), self.__win.winfo_screenheight()

        self.__canvas = tkinter.Canvas(self.__win, width=self.__width, height=self.__height, bg="gray")

        self.__win.bind('<Button-1>', self.xFunc1)
        self.__win.bind('<ButtonRelease-1>', self.xFunc1)
        self.__win.bind('<B1-Motion>', self.xFunc2)
        self.__win.bind('<Escape>', lambda e: self.__win.destroy())

        user32 = ctypes.windll.user32
        gdi32 = ctypes.windll.gdi32
        dc = user32.GetDC(None)
        widthScale = gdi32.GetDeviceCaps(dc, 8)
        heightScale = gdi32.GetDeviceCaps(dc, 10)
        width = gdi32.GetDeviceCaps(dc, 118)
        height = gdi32.GetDeviceCaps(dc, 117)
        self.__scale = width / widthScale
        print(self.__width, self.__height, widthScale, heightScale, width, height, self.__scale)

        self.__win.mainloop()

    def xFunc1(self, event):
        if event.state == 0:
            self.__start_x, self.__start_y = event.x, event.y
        elif event.state == 256:
            if event.x == self.__start_x or event.y == self.__start_y:
                return
            im = ImageGrab.grab((self.__scale * self.__start_x, self.__scale * self.__start_y,
                                 self.__scale * event.x, self.__scale * event.y))
            imgName = 'tmp.png'
            im.save(imgName)

            ocr()

            print('保存成功')
            self.__win.update()
            sleep(0.5)
            self.__win.destroy()

    def xFunc2(self, event):
        if event.x == self.__start_x or event.y == self.__start_y:
            return
        self.__canvas.delete("prscrn")
        self.__canvas.create_rectangle(self.__start_x, self.__start_y, event.x, event.y,
                                       fill='white', outline='red', tag="prscrn")
        self.__canvas.pack()


if __name__ == '__main__':
    prScrn = CTkPrScrn()
```

## 编程工具

开发辅助工具：

| 工具 | 用途 | 链接 |
|------|------|------|
| IT Tools | 在线开发工具集合 | [it-tools.tech](https://it-tools.tech/) |
| Boardmix | 在线协作流程图 | [boardmix.cn](https://boardmix.cn/) |

## 办公工具

生产力工具：

| 工具 | 用途 | 链接 |
|------|------|------|
| Logseq | 笔记工具 | - |
| Snipaste | 截图贴图 | [snipaste.com](https://www.snipaste.com/download.html) |
| TopMost | 窗口置顶 | [sordum.org](https://www.sordum.org/9182/window-topmost-control-v1-3/) |
| Serctl | 百度网盘离线下载 | [d.serctl.com](https://d.serctl.com/) |
| Markmap | 思维导图 | [markmap.js.org](https://markmap.js.org/repl) |
| IOdraw | 在线甘特图 | [iodraw.com](https://www.iodraw.com/disk) |
| win-vind | Vim 操作窗口 | [pit-ray.github.io](https://pit-ray.github.io/win-vind/) |

## Chrome 插件

浏览器增强插件：

| 插件 | 用途 | 链接 |
|------|------|------|
| Tab Groups Extension | 标签分组 | [Chrome Web Store](https://chrome.google.com/webstore/detail/tab-groups-extension/nplimhmoanghlebhdiboeellhgmgommi/related) |
| Raindrop.io | 书签管理 | [Chrome Web Store](https://chrome.google.com/webstore/detail/raindropio/ldgfbffkinooeloadekpmfoklnobpien) |
| Vimium | Vim 式导航 | [Chrome Web Store](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb) |
| crxMouse | 鼠标手势 | [Chrome Web Store](https://chrome.google.com/webstore/detail/crxmouse-chrome-gestures/jlgkpaicikihijadgifklkbpdajbkhjo?hl=zh-CN) |
| Todo | 待办事项 | [Chrome Web Store](https://chrome.google.com/webstore/detail/todo/pcofajehbfbjnloomppmdfcjpoaemhmd/related?hl=zh-CN) |
| DeepL | 翻译 | [Chrome Web Store](https://www.deepl.com/zh/chrome-extension) |
| URLRedirector | URL 重定向 | [Chrome Web Store](https://chrome.google.com/webstore/detail/urlredirector/maolmdhneopinciaokgohljhpdedekee?utm_source=ext_sidebar&hl=zh-CN) |
| PostWoman | API 接口调试 | [Chrome Web Store](https://chrome.google.com/webstore/detail/postwoman-http%E6%8E%A5%E5%8F%A3%E8%B0%83%E8%AF%95%E6%8F%92%E4%BB%B6/ieoejemkppmjcdfbnfphhpbfmallhfnc?utm_source=ext_sidebar&hl=zh-TW) |
| Picture-in-Picture | 画中画（网课挂机） | [Chrome Web Store](https://chromewebstore.google.com/detail/%E7%94%BB%E4%B8%AD%E7%94%BB%E8%A7%86%E9%A2%91/icmpjbkbjlbfpimllboiokakocdgfijb?hl=zh-TW&utm_source=ext_sidebar) |
| 彩云小译 | 翻译 | [caiyunapp.com](https://fanyi.caiyunapp.com/web) |

### URLRedirector 使用示例

```
比如 https://xx.csdn.net/.../132418713 替换为 https://csdn.net/qq_33487044/.../132418713
```

## 学习资源

| 工具 | 用途 | 链接 |
|------|------|------|
| AMiner | AI 科学理解 | [aminer.cn](https://www.aminer.cn/) |
| Theia Blog | 技术博客 | [vgel.me](https://vgel.me/) |

## 生活业务

| 工具 | 用途 | 链接 |
|------|------|------|
| Free SMS Receive | 虚拟手机号码接收短信 | [free-sms-receive.com](https://www.free-sms-receive.com/zh/) |

## 论文专利

| 工具 | 用途 | 链接 |
|------|------|------|
| 专利查询 | 中国专利查询 | [cponline.cnipa.gov.cn](https://tysf.cponline.cnipa.gov.cn/am/#/user/login) |
| IPC 查询 | 国际专利分类查询 | [cponline.cnipa.gov.cn](https://pss-system.cponline.cnipa.gov.cn/conventionalSearch) |

## 网络工具

网络相关工具：

| 工具 | 用途 | 链接 |
|------|------|------|
| Bilibili 下载 | B 站视频下载 | [zhouql.vip](https://zhouql.vip/bilibili/) |
| Huggingface 镜像 | Huggingface 国内镜像 | [hf-mirror.com](https://hf-mirror.com/) |
| Serctl | 离线下载 | [d.serctl.com](https://d.serctl.com/) |
| Wormhole | 文件分享 | [wormhole.app](https://wormhole.app/) |
| Huang1111 网盘 | 网盘服务 | [pan.huang1111.cn](https://pan.huang1111.cn/) |

### Huggingface 镜像配置

```powershell
pip install -U huggingface_hub
pip install -U hf-transfer
$env:HF_ENDPOINT="https://hf-mirror.com"
$env:HF_HUB_ENABLE_HF_TRANSFER=1
# 下载整个仓库
huggingface-cli download bartowski/codegeex4-all-9b-GGUF --local-dir bartowski
# 下载某个文件
huggingface-cli download --resume-download bartowski/codegeex4-all-9b-GGUF --include="codegeex4-all-9b-Q8_0.gguf" --local-dir bartowski --resume
```

## See Also

- [Chrome DevTools MCP 安装配置](./chrome-devtools-mcp-setup.md)

*(原始内容被截断，收录到此为止)*
