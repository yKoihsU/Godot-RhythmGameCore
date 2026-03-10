@abstract
class_name RGCParser extends RefCounted
## 此类属于 RhythmGameCore 插件[br]
## 谱面解析器的基类，解析词条按照 osu 的谱面格式作为标准

## 解析谱面基础信息（例如谱面模式、预览时间） 
func parse_general(file_content: String):
	pass

## 解析文件数据（例如音乐作者、音乐名称）
func parse_metadata(file_content: String):
	pass

## 解析难度信息（例如判定严格程度）
func parse_difficulty(file_content: String):
	pass

## 解析时间点
func parse_timing_points(file_content: String):
	pass

## 解析打击物件 [br]
## [br]
## [b]注意[/b]：传入参数中的 [param keys] 指的是 [lb]Difficulty[rb] 字段中的 [param CircleSize]
func parse_hit_objects(keys: int, file_content: String):
	pass
