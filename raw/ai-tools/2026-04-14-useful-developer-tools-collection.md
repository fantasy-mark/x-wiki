# 实用开发者工具收藏

> Source: User paste
> Collected: 2026-04-14
> Published: Unknown

## AI提效

- [佐糖 — 用AI让图像处理](https://picwish.cn/)
- [kimi-书籍阅读神器](https://kimi.moonshot.cn/)
- [创建属于你的 AI 应用](https://www.coze.cn/)
- [**秘塔AI搜索**](https://metaso.cn/)
- [通义万象-艺术创作](https://tongyi.aliyun.com/wanxiang/)
- [度加-热搜一键成稿，文稿一键成片](https://aigc.baidu.com/home)
- [Magic Todo](https://goblin.tools/)
- [Gamma](https://gamma.app/signup?i.cc/ai)
- [AI文生图](https://www.liblib.art/)
- [TTS](https://ttsmaker.cn/)

## 文档工具

- [Remixicon](https://remixicon.com/) ==Icon资源==

- [有道翻译](https://fanyi.youdao.com/trans/#/home)

- [tesseract](https://digi.bib.uni-mannheim.de/tesseract/) ==OCR识别==

  - 1. [下载](https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-5.3.3.20231005.exe)（windows），按装勾选 ==chinese_simple== 或

    ```shell
    pip install pytesseract --url-index https://pypi.tuna.tsinghua.edu.cn/simple/
    sudo apt-get install tesseract-ocr-chi-sim
    ```

  - 2. 设置 **tesseract.exe** 环境变量

  - 3. 执行代码

    ``` python
    import pytesseract
    try:
        from PIL import Image
    except ImportError:
        import Image

    # 列出支持的语言
    print(pytesseract.get_languages(config=''))

    print(pytesseract.image_to_string(Image.open('ocr_test.png'), lang='chi_sim+eng'))
    ```

  - ##### 完整截屏OCR方案

    - 1、安装额外依赖

      ```shell
      pip install pillow pyautogui pytesseract pyperclip
      ```

    - 2、执行代码

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
              self.__win.attributes("-alpha", 0.1)  # 设置窗口半透明
              self.__win.attributes("-fullscreen", True)  # 设置全屏
              self.__win.attributes("-topmost", True)  # 设置窗口在最上层

              self.__width, self.__height = self.__win.winfo_screenwidth(), self.__win.winfo_screenheight()

              # 创建画布
              self.__canvas = tkinter.Canvas(self.__win, width=self.__width, height=self.__height, bg="gray")

              self.__win.bind('<Button-1>', self.xFunc1)  # 绑定鼠标左键点击事件
              self.__win.bind('<ButtonRelease-1>', self.xFunc1)  # 绑定鼠标左键点击释放事件
              self.__win.bind('<B1-Motion>', self.xFunc2)  # 绑定鼠标左键点击移动事件
              self.__win.bind('<Escape>', lambda e: self.__win.destroy())  # 绑定Esc按键退出事件

              user32 = ctypes.windll.user32
              gdi32 = ctypes.windll.gdi32
              dc = user32.GetDC(None)
              widthScale = gdi32.GetDeviceCaps(dc, 8)  # 分辨率缩放后的宽度
              heightScale = gdi32.GetDeviceCaps(dc, 10)  # 分辨率缩放后的高度
              width = gdi32.GetDeviceCaps(dc, 118)  # 原始分辨率的宽度
              height = gdi32.GetDeviceCaps(dc, 117)  # 原始分辨率的高度
              self.__scale = width / widthScale
              print(self.__width, self.__height, widthScale, heightScale, width, height, self.__scale)

              self.__win.mainloop()  # 窗口持久化

          def xFunc1(self, event):
              # print(f"鼠标左键 {event.state} {event.x} {event.y}")
              if event.state == 0:  # 鼠标左键按下
                  self.__start_x, self.__start_y = event.x, event.y
              elif event.state == 256:  # 鼠标左键释放
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
              # print(f"鼠标左键点击了一次坐标是:x={self.__scale * event.x}, y={self.__scale * event.y}")
              if event.x == self.__start_x or event.y == self.__start_y:
                  return
              self.__canvas.delete("prscrn")
              self.__canvas.create_rectangle(self.__start_x, self.__start_y, event.x, event.y,
                                             fill='white', outline='red', tag="prscrn")
              # 包装画布
              self.__canvas.pack()


      if __name__ == '__main__':
          prScrn = CTkPrScrn()
      ```

- [流程图](https://boardmix.cn/app/home/flowchart) ==拖拽流程图==

- [[mkdocs]]

## 编程工具

- [==IT Tools==](https://it-tools.tech/)
- [boardmix](https://boardmix.cn/) ==在线流程图==

## 办公工具

- [[logseq]] ==笔记工具==
- [snipaste](https://www.snipaste.com/download.html)  ==截图贴图== **linux用自带截图**
- ==PPT录屏==
  id:: 65a9e6b5-713a-4889-9a14-0a5428a28611
  ![image.png](../assets/image_1705633477581_0.png)
- [TopMost](https://www.sordum.org/9182/window-topmost-control-v1-3/)  ==置顶窗口==
- [==翻墙下载==](https://d.serctl.com/) 离线下载
- ==[markmap 思维导图](https://markmap.js.org/repl)==
- [在线甘特](https://www.iodraw.com/disk)
- [==win-vind==](https://pit-ray.github.io/win-vind/)
  ![image.png](../assets/image_1724071985879_0.png)

## Chrome插件

- [标签分组扩展](https://chrome.google.com/webstore/detail/tab-groups-extension/nplimhmoanghlebhdiboeellhgmgommi/related)

- [书签管理](https://chrome.google.com/webstore/detail/raindropio/ldgfbffkinooeloadekpmfoklnobpien)

- [vimium](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb)

- [crxMouse](https://chrome.google.com/webstore/detail/crxmouse-chrome-gestures/jlgkpaicikihijadgifklkbpdajbkhjo?hl=zh-CN)

- [ToDo](https://chrome.google.com/webstore/detail/todo/pcofajehbfbjnloomppmdfcjpoaemhmd/related?hl=zh-CN)

- [DeepL](https://www.deepl.com/zh/chrome-extension)

- [URLRedirector](https://chrome.google.com/webstore/detail/urlredirector/maolmdhneopinciaokgohljhpdedekee?utm_source=ext_sidebar&hl=zh-CN)

  - > 比如 https://xx.csdn.net/.../132418713 替换为 https://csdn.net/qq_33487044/.../132418713

- [PostWoman](https://chrome.google.com/webstore/detail/postwoman-http%E6%8E%A5%E5%8F%A3%E8%B0%83%E8%AF%95%E6%8F%92%E4%BB%B6/ieoejemkppmjcdfbnfphhpbfmallhfnc?utm_source=ext_sidebar&hl=zh-TW)

- [画中画](https://chromewebstore.google.com/detail/%E7%94%BB%E4%B8%AD%E7%94%BB%E8%A7%86%E9%A2%91/icmpjbkbjlbfpimllboiokakocdgfijb?hl=zh-TW&utm_source=ext_sidebar) ==网课挂机==

- [彩云小译](https://fanyi.caiyunapp.com/web)

## 学习资源

- AI
  - [aminer](https://www.aminer.cn/) ==**AI帮你理解科学**==
  - [Theia Blog](https://vgel.me/)

## 生活业务

- [虚拟手机号码](https://www.free-sms-receive.com/zh/)

## 论文专利

- [专利查询](https://tysf.cponline.cnipa.gov.cn/am/#/user/login)
- [国际专利分类（IPC）查询](https://pss-system.cponline.cnipa.gov.cn/conventionalSearch)
  ![image.png](../assets/image_1714361399123_0.png)
  ![image.png](../assets/image_1714361302615_0.png)

## 网络工具

- [bilidown](https://zhouql.vip/bilibili/)

- [==Huggingface镜像==](https://hf-mirror.com/)

  - ```powershell
    pip install -U huggingface_hub
    pip install -U hf-transfer
    $env:HF_ENDPOINT="https://hf-mirror.com"
    $env:HF_HUB_ENABLE_HF_TRANSFER=1
    # 下载整个仓库
    huggingface-cli download bartowski/codegeex4-all-9b-GGUF --local-dir bartowski
    # 下载某个文件
    huggingface-cli download --resume-download bartowski/codegeex4-all-9b-GGUF --include="codegeex4-all-9b-Q8_0.gguf" --local-dir bartowski --resume
    ```

- [==离线下载==](https://d.serctl.com/)

- [文件馆](https://wormhole.app/)

- [网盘huang1111](https://pan.huang1111.cn/)
  - `hacker.do@163.com`
    `D*v*l*6*2*`)
  - [AI原型图](https://jsa

*(content truncated)*
