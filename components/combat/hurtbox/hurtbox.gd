class_name Hurtbox		# hurtbox基类
extends Area2D

# 不同的受击盒 对应 不同的.tscn，不同的Layer
# .tscn 只有一个节点 ： Area2D

# 1. 统一的受击信号：当收到伤害且没处于无敌时，向外广播
signal hit_received(damage: int, attacker_pos: Vector2)

# 2. 公共属性：所有东西（玩家、敌人、木箱）都可能需要“无敌状态”
# 将来由XXBrain统一管理
@export var is_invulnerable: bool = false
# Q.为什么要加上@export？
# A.因为：有的敌人刚出现时 处于 无敌状态

# 3. 核心入口方法，向上广播：我受击了！把数据抛出去！
func receive_damage(damage: int, attacker_pos: Vector2) -> bool:
	if is_invulnerable: 
		return false				# 如果当前处于无敌状态，直接拦截，不吃伤害
		
	hit_received.emit(damage, attacker_pos)  # 广播 自身受到伤害
	return true		# 判定成功
