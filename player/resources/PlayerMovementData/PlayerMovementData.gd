class_name PlayerMovementData
# C# 里每个类天然就有类名，不需要额外声明。GDScript 默认情况下脚本没有全局类名
# class_name 就是手动补上这个能力。
# 这样就能在【创建新的Resource的窗口】 中 看到 ↑ 的 'class_name'

extends Resource

@export var speed:float = 100.0				## 水平移速(像素/秒)
											# 其实是：玩家在地面&空中的最大移动速度

@export var acceleration:float = 800.0		## 地面加速度 (像素/秒²)

@export var friction:float = 1000.0			## 地面摩擦力 (像素/秒²)，其实就是 减速的 加速度

@export var jump_velocity:float = -300.0	## 跳跃速度，负值向上

@export var gravity_scale:float = 1.0		## 重力倍率,以防万一设置此项


@export var air_acceleration:float = 600.0	## 空中加速 (像素/秒²)

@export var air_resistance:float = 500.0	## 空气阻力 (像素/秒²)

@export var air_jump_speed_multiplier: float = 0.8	## 二段跳力度系数（0.8 倍普通跳跃初速度）

## 最大下落速度 (像素/秒)
## 防止自由落体速度无限增大，建议设在 400.0 ~ 800.0 之间
@export var max_fall_speed: float = 500.0
