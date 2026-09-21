extends Node
# SceneService.gd (Autoload 单例)


func _ready() -> void:
	pass
	# Events.level_completed.connect(change_scene)
	# 单一职责原则：SceneService只负责切换场景，只负责被导演调用，只负责监听“切换场景”这种事件
	# 不再直接监听 level_completed 事件总线，
	# 要么，等着 【导演CampaignService】 按照顺序调用SceneService各种方法；
	# 要么，将来可能监听Events另一个信号，比如“切换到下一关”，而不是“关卡完成”；


func change_scene() -> void:
	print("Level Completed!--scene_service.gd")
