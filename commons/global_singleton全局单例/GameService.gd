extends Node
# GameService.gd (Autoload 单例)

# GM 目前仅供测试

func _ready() -> void:
	# 设置背景为黑色
	RenderingServer.set_default_clear_color(Color.BLACK)
