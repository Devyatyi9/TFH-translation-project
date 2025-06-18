# Описание

Здесь у нас тулза которая объединяет инфу из gbs (бинарный формат [OtterUI](https://github.com/ppiecuch/OtterUI/tree/master/Distributions)) файлов и генерирует новые.

Объединение происходит тулзой из `src/Main.hx`, при компиляции создаётся `otterui-cli.hl` (сразу же запускается).

- `hl-otterui-cli.hxml`: Конфиг для компиляции тулзы в .hl файл ([HashLink](https://hashlink.haxe.org/#download))

- `otterui-cli.hxml`: Конфиг для работы тулзы в режиме интерпретатора

Назначение папок в **otterui-project**:
- OtterExport - папка в которую попадают файлы при экспортировании проекта в OtterUI
- Import - папка в которую нужно кидать файлы распакованные из gfs-архива игры
- Merged - папка в которой создаются готовые к использованию файлы после выполнения программы

> [!IMPORTANT]
> Для корректного открытия проекта в IDE необходимо выбирать __эту__ директорию в качестве корневой

[SkullGirls fonts repacker](https://github.com/Devyatyi9/TFH-translation-project/releases/tag/SG-1.0)
