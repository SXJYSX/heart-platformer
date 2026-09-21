class_name Hitbox
extends Area2D

# 不同的攻击盒 对应 不同的.tscn，不同的Mask
# .tscn 只有一个节点 ： Area2D


# 🎯 加上这部分：确保信号自动连接！
func _ready() -> void:
	# 检查是否已经连接，防止在编辑器里手动连过导致重复触发
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

# “回调事件”，攻击成功命中时，会被触发
signal hit_landed(target_hurtbox: Hurtbox)

# 没有子类了。（即使有，子类也不要重写）
func _on_area_entered(area: Area2D) -> void:
	if not area is Hurtbox:
		return
	
	# 1. 调用hurtbox的受击方法，并拿到“是否成功命中”的回调
	# (建议传入 global_position 而不是 Vector2.ZERO，方便玩家计算被击退方向)
	# (目前的魔术数字 仅用于测试)
	var is_hit_successful: bool = area.receive_damage(1, Vector2.ZERO )
	
	# 2. 只有确认命中（对方未无敌）时，才触发击中逻辑
	if is_hit_successful:
		print("【Hitbox】确认刺中玩家！触发攻击“回调”！")
		# push_warning("【Hitbox】确认刺中玩家！触发攻击“回调”！")
		hit_landed.emit(area)				# 广播 攻击击中目标
