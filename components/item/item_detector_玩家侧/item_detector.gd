class_name ItemDetector
extends Area2D


# “回调事件”，成功捡到道具之后，会被触发
signal collect_item(item_receiver: ItemReceiver)

# 🎯 加上这部分：确保信号自动连接！
func _ready() -> void:
	# 检查是否已经连接，防止在编辑器里手动连过导致重复触发
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not area is ItemReceiver:
		return
	
	print("道具被捡到了")
	
	area.receiver_touched() 	# 将来会接收返回值
	collect_item.emit(area)		# 广播 拾取了物品（将来 由玩家监听）
