class_name ItemReceiver		# hurtbox基类
extends Area2D

# 不同的受击盒 对应 不同的.tscn，不同的Layer
# .tscn 只有一个节点 ： Area2D

# 1. 统一的 被拾取 信号：被拾取时，向外广播
signal item_touched()


# 2. 核心入口方法，向上广播：我被捡到了！
# 目前还没有返回值，将来可能会有
func receiver_touched() -> void:
	item_touched.emit()  # 广播 我被捡到了
	
