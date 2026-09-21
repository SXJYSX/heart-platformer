class_name GameUI
extends Node

@onready var level_completed: ColorRect = $LevelCompleted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 关键：保证游戏暂停时，UI 依然能响应输入和渲染动画！
	process_mode = Node.PROCESS_MODE_ALWAYS	# 会自动对所有子节点生效!
	_setup_signals()


# ======================================================
# === 七.信号绑定中心 (Signal Connections) === 在_ready()中 执行

func _setup_signals():
	UIService.panel_open_requested.connect(_open_panel)

func _open_panel(panel_name:StringName) -> void:
	match panel_name:
		UIPanels.PANEL_LEVEL_COMPLETE:
			level_completed.show()
			print("已打开面板: ", panel_name)
			
		# 未来新增面板直接在这里扩充：
		# UIPanels.PANEL_PAUSE:
		# 	pause_menu.show()
		# 	get_tree().paused = true
			
		_:
			push_warning("未知的 UI 面板名称: ", panel_name)
	
	
