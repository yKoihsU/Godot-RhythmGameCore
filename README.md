# Rhythm Game Core

基于 Godot 4 的下落式音游框架插件（Rhythm Game Core，RGC）。

> 这是一个面向开发者的插件，提供从 osu! 文件解析、编辑器内预览、可扩展的渲染层与逻辑层分离、以及完整分数/音效系统的一套实现，方便在 Godot 中快速搭建 beatmania 风格的下落式节奏游戏。

---

## 主要功能

1. **osu 文件解析** — 支持 4K、7K 模式的 Mania 谱面解析并转换为插件可用的资源。
2. **自定义资源系统** — 在编辑器中可预览与编辑已转换的 osu 文件信息（谱面、BPM 变化、判断窗口等）。
3. **变速谱面支持** — 完整支持非无限 BPM（即存在 BPM 变化或节拍映射变化）的谱面。
4. **视觉节点与功能节点分离** — 渲染（Visual）与逻辑（Core）分离，允许按需自定义布局与表现层。
5. **分数与音效系统** — 内置完整分数统计、判定、连锁与打击音效触发机制。

---

## 设计亮点 / 优点

* **高性能**：将音符判定与处理放在轨道（Track）节点内，减小对全局 `_process()` 的依赖，降低每帧开销。
* **更稳定的音符生成**：不再以「当前时间」作为播放推进源，而是构建一条时间轴（timeline），通过时间轴位置推进游戏状态，避免时间漂移与生成抖动。
* **易于扩展**：音符节点以 `Node2D` 为根，可任意挂载 `Control` 或自定义节点作为视觉表示，方便实现多样化效果。
* **文件数据精简可读**：转换后资源仅保留 osu 文件中的关键字段，利于调试与排查问题。

---

## 安装

1. 将 `rhythm_game_core` 插件文件夹复制到项目：

```
res://addons/rhythm_game_core/
```

2. 打开 Godot 编辑器：**Project → Project Settings → Plugins**，启用 `Rhythm Game Core` 插件。

---

## 快速开始

已提供一个 4K 下落式的 Demo 场景供快速上手：

1. 在项目资源中打开场景文件：

   * 路径：`./Scenes/play_scene.tscn`（该场景为 4K 下落式示例）。
2. 打开该场景后：

   * 点击场景编辑器上方的 **运行当前场景**（Run Current Scene）按钮；或点击窗口右上角的 **运行项目**（Run Project）来运行整个项目。
3. 进入运行中的场景后，点击场景界面中的 **导入文件** 按钮，选择要导入的 `.osu` 谱面文件以及对应的音频文件。
4. 导入完成后，Demo 会自动解析谱面并将其加载到场景中，点击 **开始** 即可开始游戏。

> 提示：该 Demo 场景已配置好必要的轨道（Track）、分数显示与音频系统，适合作为快速测试与参考实现。若需在自定义场景中使用，请参考后文的节点说明与代码示例进行集成。

---

## 常见用例代码示例

```gdscript
## 轨道管理器
@export var track_manager: RGCTrackManager

## 加载谱面文件
func load_beatmap(path: String) -> void:
	var beatmap_res: RGCBeatmap
	
	# 加载已经过转换的文件
	if path.get_extension() == "beatmap":
		beatmap_res = ResourceLoader.load(path, "RGCBeatmap")
		track_manager.convert_data_to_track_event(beatmap_res)
		return
	
	var parser := RGCParserOM.new()
	
	var file := FileAccess.open(path, FileAccess.READ)
	var timing_points: PackedStringArray = parser.parse_timing_points(file.get_as_text())
	var hit_objects: PackedStringArray = parser.parse_hit_objects(4, file.get_as_text())
	
	# 保存转换文件
	var file_name := path.get_file().get_basename()
	var save_file_path: String = path.get_base_dir().path_join(file_name) + ".beatmap"
	RGCFileManager.save_parse_file(save_file_path, timing_points, hit_objects)
	
	# 从转换文件中加载
	beatmap_res = ResourceLoader.load(save_file_path, "RGCBeatmap")
	track_manager.convert_data_to_track_event(beatmap_res)
```

（上例为示意；具体 API 名称请参照本项目的源码注释。）

---

## 关键概念与节点说明

* **Timeline（时间轴）**：将谱面事件映射到时间轴位置，作为播放推进器而非直接使用系统时间。
* **NoteTrack（轨道）**：负责本轨道的音符生成、判定逻辑与对象池管理。高频逻辑局限在 Track 内以减少全局开销。
* **NoteNode（音符节点）**：以 `Node2D` 为根，可挂载 `Control` 子节点或自定义特效节点作为视觉表现。
* **OSUParser（谱面解析器）**：将 `.osu` 文件解析并生成插件内部使用的精简资源格式。
* **ScoreManager / FileManager**：分数统计与文件管理模块，提供 API 用于分数查询、谱面文件的加载和保存等。

---

## 自定义与扩展

* **自定义视觉**：继承或替换 Note 的子节点（`Control` / `CanvasItem`）以实现不同皮肤与动画。
* **自定义判定**：可替换或扩展 NoteTrack 或 NoteNode 内的判定方法（例如实现按键延迟补偿、Flick/Slide 判定等）。
* **布局调整**：由于视觉层和功能层分离，您可以自由移动、缩放每个 Track 的视觉容器以实现不同排布（竖向、横向、斜向等）。

---

## 编辑器支持

* 谱面资源在导入后可在资源检视器内查看 BPM 列表、HitObject 列表。
* 支持在编辑器设置中调整游玩偏移（Music Offset, Hit Offset）与音量设置。

---

## 文件格式说明（导出资源示例）

```text
# 时间点信息
# 格式：time(int), bpm(float), speed(float)
[TimingPoints]
1105, 160.00, 1.00
55105, 160.00, 1.00
...

# 音符信息
# 格式：start_time(int), end_time(int), note_type(string), track(string)
[NoteInfos]
1105, -1, tap, 1
1292, -1, tap, 3
1480, -1, tap, 2
...
```

---

## 常见问题（FAQ）

* **Q：是否支持其它键位谱面模式（如 5K、9K）？**
  A：1K-9K 谱面都支持，但需要在导入选项卡中修改 Keys 重新再导入一次。（提供演示场景仅支持4K）

* **Q：变速谱面中支持的BPM范围？**
  A：BPM 不可为负数、0、无穷。RGC 使用时间轴（timeline）作为播放推进源，如果计算位置时出现 inf，会导致不可预料的结果。 

---

## 贡献（Contributing）

欢迎提交 Issue、PR 或讨论：

* 在提交 PR 前请先创建 Issue 描述你的改动意图。
* 代码风格请遵循 Godot GDScript 的常用风格。

---

## 许可（License）

本项目中 **非美术资源**（源码、脚本、导入/转换器、示例场景中除美术以外的资源等）采用 **MIT 许可证** 许可。美术资源（例如贴图、音频样本、UI 资产等）若有单独声明，将以各自声明为准。

**MIT 许可证（简要说明）：**

- 你被授权免费使用、复制、修改、合并、发布、分发、再授权及/或出售本软件的副本；
- 在软件的所有副本或重要部分中必须包含上述版权声明和本许可声明；
- 本软件按“原样”提供，不附带任何明示或暗示的保证；在任何情况下作者或版权持有人均不对因软件或软件的使用而产生的任何索赔、损害或其他责任负责。

---

## 联系方式

如果你在使用过程中遇到问题或有功能建议，请在仓库中提交 Issue，或通过 README 中提供的联系信息联系我们。
