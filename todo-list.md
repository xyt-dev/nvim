# TODO-LIST
## issue:
1. lsp 没有加载整个工作区导致references显示不全?
  clangd即使设置了Working directory也没有自动加载cpp文件，除非打开，或者写compile_commands.json文件
  所需基本内容：
```json
{
    "arguments": [
      "/usr/bin/clang++",
      "abc.cpp"
    ],
    "directory": "...",
    "file": "...",
},
```
2. Neotree 切换回编辑区时无法保持ZenMode

## TODO:
* config bottom bar
* colorizer #ffaacc
* fold code

