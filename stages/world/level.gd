class_name Level
extends Node2D

# 错误代码：会导致严重的内存隐患和架构危机
# @export var next_level_scene: PackedScene
# Godot 底层的 PackedScene 强引用机制：只要你在一个场景的 @export 属性里拖入了一个 .tscn，
#                           Godot 在加载当前场景时，就会同步将引用的 PackedScene 预加载到内存中。

var _total_hearts: int = 0
var _collected_hearts: int = 0

func _ready() -> void:
	# 1. 关卡加载时拉取所有爱心
	# var hearts : Array[Heart]
	var hearts := get_tree().get_nodes_in_group(GameGroups.HEARTS)
	_total_hearts = hearts.size()
	
	# 2. 批量订阅各爱心的 collected 信号
	for heart in hearts:
		if heart is Heart:
			heart.collected.connect(_on_heart_collected)

func _on_heart_collected() -> void:
	_collected_hearts += 1
	print("爱心收集进度: %d/%d" % [_collected_hearts, _total_hearts])
	
	# 逻辑清晰：收集数≥总数 时，判定通关
	if _collected_hearts >= _total_hearts:
		_level_completed()
		
# 完成关卡时，激活信号总线Events的signal
func _level_completed() -> void:
	print("Level Completed!--level.gd")
	Events.level_completed.emit()
	
