# Ghoscript二进制插件
+ 二进制标识：`gs`
+ 插件源代码：
  - [Codeberg](https://codeberg.org/XmacsLabs/mogan/src/branch/branch-1.2/TeXmacs/plugins/binary/progs/binary/gs.scm)
  - [Gitee](https://gitee.com/XmacsLabs/mogan/blob/branch-1.2/TeXmacs/plugins/binary/progs/binary/gs.scm)
  - [Github](https://github.com/XmacsLabs/mogan/blob/branch-1.2/TeXmacs/plugins/binary/progs/binary/gs.scm)
+ 功能：
  - 将PS/PDF矢量图转换为PDF位图，以在墨干中渲染
  - 将PS矢量图转换为PDF矢量图，以将TeXmacs文档导出为PDF文档

## 如何安装Ghostscript
### Windows
前往[Ghostscript官网](https://www.ghostscript.com)下载安装包并按照默认路径安装到系统C盘。

如果用户没有按照默认路径安装，则需要手动将`gs.exe`所在目录添加到PATH中。

### macOS
使用`brew install ghostscript`安装。

### Linux
使用`sudo apt install ghostscript`等方式安装。
