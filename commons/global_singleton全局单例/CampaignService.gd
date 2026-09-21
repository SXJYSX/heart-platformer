extends Node
# campaign_service.gd (流程编排器) —— 相当于 【导演】

# Q.流程编排的意义在哪？为什么不让一大堆全局单例去直接监听Events
# A.因为有些逻辑有先后顺序的，甚至有场动画的，有严格的先后执行顺序。
# 总的来说
# 如果是“命令”（Command：请去做 X 事）：		由上层/调度单例通过方法直接调用子系统。
# 如果是“通知”（Event：我这边发生了 X 事） ：	由发生变化的单例抛出信号，谁关心谁去监听。


func _ready() -> void:
	# 订阅全局总线事件
	Events.level_completed.connect(_on_level_completed)

func _on_level_completed() -> void:
	# 打开UI面板
	UIService.open_panel(UIPanels.PANEL_LEVEL_COMPLETE)
	# 暂停游戏
	get_tree().paused = true
	print("你赢了")
	

	# 1. 禁用输入
	# InputService.set_input_enabled(false)
	
	# 2. 播放胜利 UI 并阻塞等待 UI 播完
	# await UIService.show_victory_screen()
	
	# 3. 异步保存，等待磁盘 I/O 结束
	# await SaveService.save_progress_async()
	
	# 4. 前置准备无误后，最后执行场景切换
	# SceneService.change_scene("res://scenes/levels/level_02.tscn")
