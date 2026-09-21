class_name Player
extends CharacterBody2D

# 以整体进度为优先，这些代码 在 后面的项目 可以迭代。现在没必要扣细节，连状态机都还没呢
# 后面再去看专门的教程，斜坡、移动平台_防止颠勺、状态机、土狼时间、击退、等等 教程详见Gemini对话

# ======================================================
# === 零. 自定义信号 (Custom Signals) ===

# ======================================================
# === 一. 常量定义 (Constants) ===
# Gemini 🌟 核心作弊黑科技：引入重力倍率
const FALL_GRAVITY_MULTIPLIER = 2.5 # 如果在上升期松开按键，施加 2.5 倍疯狂重力

# ======================================================
# === 二. 导出变量 (Exports) ===
@export var movement_data : PlayerMovementData	# 移动相关数据


# ======================================================
# === 三. 状态与普通变量 (State Variables) ===
# 二段跳
var can_air_jump : bool = false
# 蹬墙跳_补丁代码
var just_wall_jumped: bool = false		# 用于记录 这一帧是否执行了蹬墙跳

#region --- 移动数据快捷属性 (Movement Data Shortcuts)
var speed: float: ## 速度
	get: return movement_data.speed
var acceleration: float:
	get: return movement_data.acceleration
var friction: float:
	get: return movement_data.friction
var jump_velocity: float:
	get: return movement_data.jump_velocity
var gravity_scale: float:
	get: return movement_data.gravity_scale
var air_acceleration: float:
	get: return movement_data.air_acceleration
var max_fall_speed: float:
	get: return movement_data.max_fall_speed
var air_jump_speed_multiplier: float:
	get: return movement_data.air_jump_speed_multiplier

#endregion	


# ======================================================
# === 四. @onready 节点引用与初始状态缓存 ===
# 对子节点的引用
@onready var animated_sprite_2d: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var coyote_jump_timer: Timer = %CoyoteJumpTimer
@onready var pivot: Node2D = $Pivot 		# 我用于测试更高级节点父子结构
@onready var hurtbox: Hurtbox = %PlayerHurtbox

# 需要初始化的数据
@onready var starting_position = global_position		# 复活地点

# ======================================================
# === 五. 内置虚函数 (Engine Lifecycle) ===
func _ready() -> void:
	# 查找动作是否存在，如果不存在，则报错
	assert(InputMap.has_action("jump"), "InputMap 中找不到 jump 动作！")
	# movement_data 缺失空指针断言
	assert(movement_data != null, "错误：Player 节点未赋值 PlayerMovementData 资源！")
	pivot.scale.x = facing_direction # 确保初始朝向与变量完全一致
	
	# 父节点主动监听 子节点的通知
	_setup_signals()
	


func _physics_process(delta: float) -> void:
	# 用户按键输入 → 物理提交 → 自定义检测 → 更新动画
	# apply = 算数 		（ 纯物理公式 ）
	# handle = 检测		（ 判断 + 物理公式）

	# ==========================================
	# 1. 输入读取：获取水平轴向（左 -1, 右 1, 挂机/冲突 0）
	# ==========================================
	var input_axis := Input.get_axis("move_left", "move_right") # 用于确定玩家按下的方向键
	
	# 转向（目前没考虑角色受伤导致无法转向）
	if input_axis != 0:
		facing_direction = sign(input_axis)						# 修改记录玩家朝向

	# ==========================================
	# 2. 垂直物理计算 (Y轴：重力与跳跃)
	# ==========================================
	apply_gravity_by_Gemini(delta)	# 重力
	# 玩家动作：按下空格触发跳跃，需要按顺序执行，因为just_wall_jumped
	handle_wall_jump()				# 蹬墙跳，目前改成了跳跃键触发，但手感稀烂
	handle_jump_by_Gemini()			# 地面&空中二段跳
	
	
	# ==========================================
	# 3. 水平物理计算 (X轴：加速与减速)
	# ==========================================
	# 速度计算：有输入就奔跑，没输入就减速
	apply_acceleration(input_axis,delta)		# 地面加速
	apply_air_acceleration(input_axis,delta)	# 空中加速
	apply_friction(input_axis, delta)			# 地面减速
	apply_air_resistance(input_axis, delta)		# 空中减速
	# 小bug：按反向方向键来反方向加速的减速效果 不如 啥也不按的减速效果
	# 这是由于 在PlayerMovementData中，acceleration < friction 导致的
	
	# ==========================================
	# 4. 物理提交 与 环境监测 与 更新变量，比如CoyoteJump
	# ==========================================
	# 更大的项目需要状态机
	var was_on_floor:bool = is_on_floor()	# 上一“帧”是否离开地面
	
	move_and_slide()	# 物理提交：把算好的 velocity 交付引擎，执行移动与全自动斜坡/碰撞处理
	
	# 关于just_left_ledge：老师写的很粗糙：只考虑了 静止平台，如果是正在向上移动的移动平台，则不适用
	var just_left_ledge:bool = was_on_floor and not is_on_floor() and velocity.y >= 0	
										# 总结：just_left_ledge 这一“帧”是否刚刚 “走”下地面
										# 即 【上一“帧”在地面】 且 【经过这一“帧”移动之后 不在地面】 且 【正在向下运动】
	if just_left_ledge: coyote_jump_timer.start()	# 如果这一“帧”刚刚 “走”下地面，则 启用土狼计时器
	
	if is_on_floor(): can_air_jump = true	# 对应模块2_1_B
											# 每次落地时，设置：可以二段跳	
	
	just_wall_jumped = false				# 重置状态
	
	# ===
	# 5.表现层更新。 动画完全依赖于物理碰撞的最终结果（比如到底有没有真正在地上），所以放最后
	# ==========================================
	update_animations(input_axis)	# 更新动画
	# P1 46:32 老师当时是 先更新动画，后move_and_slide
	# 	但 老师的最终文件中，是先move_and_slide，后更新动画。Claude也建议这么做
	
	# 6.按空格 修改当前的 【移速预设movement_data】
	#if Input.is_action_just_pressed("ui_accept"):
		#movement_data = load("res://resources/PlayerMovementData/SlowerMovementData.tres")


# ======================================================
# === 六.自定义功能模块/辅助函数 (Private/Helper Methods) ===

# 1 输入读取：在方法 _physics_process 中


# 2 垂直物理计算 (Y轴：重力与跳跃)
# 注意：实现“长按大跳，短按小跳”有两种实现方式：
# 2_1_A 与 2_2_A 是我正在用一种实现方式：由Claude建议，			核心是 【重力欺骗魔术】
# 2_1_B 与 2_2_B 是视频作者的实现方式：作者Heartbeast的腰斩法，	核心是 【腰斩跳跃速度】

# 2_1 重力
# 2_1_A Gemini核心物理：动态重力计算
func apply_gravity_by_Gemini(delta: float):
	if not is_on_floor():
		var current_gravity: Vector2 = get_gravity() * movement_data.gravity_scale # 获取项目设置里的默认重力	
		# 🧙‍♂️ 动态重力欺骗魔术：
		# 如果角色正在往上冲 (velocity.y < 0)，且玩家【已经松开了】空格键
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			# 瞬间降临 2.5 倍重力，强行让上升弧度变得极扁平！
			velocity += current_gravity * FALL_GRAVITY_MULTIPLIER * delta
		else:
			# 正常大跳、或者已经到达顶点开始下落时，恢复 1.0 倍正常重力
			velocity += current_gravity * delta	
		# 🪂 终端速度截断（新增逻辑）：
		# 限制下落速度不超过 movement_data 设定的上限
		velocity.y = min(velocity.y, max_fall_speed)
	
# 2_1_B 作者的重力计算，很简单
func apply_gravity_by_Heartbeast(delta: float):
	# Add the gravity apply_gravity_by_Heartbeast
	if not is_on_floor():
		velocity += get_gravity() * delta
	# 同理，move_toward(...)可以实现 最大下落速度

# 2_2 垂直跳跃
# 2_2_A Gemini玩家跳跃：纯粹的快乐起飞
func handle_jump_by_Gemini():
	# if is_on_floor(): can_air_jump = true	# 每次落地时，设置_可以二段跳	
	# 虽然作者写在了这个位置，但是根据AI工具Claude的建议，挪到了 move_and_slide() 之后

	if just_wall_jumped: return		# 如果这一帧蹬墙跳了，则返回
	
	# if条件1：【在地面 或 土狼跳跃计时器>0】 —— 判定在地面上
	# if条件2： 这一帧 按下了跳跃键
	# 执行：基础跳跃
	# elif条件：不在地面 且 可以二段跳 且 按下了跳跃键
	# 执行：二段跳
	if (is_on_floor() or coyote_jump_timer.time_left > 0.0) and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity # 不管大跳小跳，第一帧一视同仁，全力冲天
	elif not is_on_floor() and can_air_jump and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity * movement_data.air_jump_speed_multiplier  # 不管大跳小跳，第一帧一视同仁，全力冲天
		can_air_jump = false

# 2_2_B 作者的腰斩法：“修改结果”。简单粗暴，适合新手快速见效，但曲线有断层。
func handle_jump_by_Heartbeast():
	# if is_on_floor(): can_air_jump = true	# 每次落地时，设置_可以二段跳	
											# AI工具Claude的建议，挪到了 move_and_slide() 之后
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:	# 【在地面 或 土狼跳跃计时器>0】 —— 判定在地面上
		if Input.is_action_just_pressed("jump"):		# 这一帧 按下了跳跃键
			velocity.y = movement_data.jump_velocity		# 地面起跳
			coyote_jump_timer.stop()						# 停止土狼计时器
	
	# if外层条件：在空中
	# if内层条件：松开跳跃键的一瞬 且 速度向上足够快 时，腰斩
	# elif	：	按下跳跃键的一瞬 且 可以二段跳时，二段跳
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = jump_velocity / 2
		elif Input.is_action_just_pressed("jump") and can_air_jump:
			velocity.y = jump_velocity
			can_air_jump = false

# 2_3 蹬墙跳 作者的代码
func handle_wall_jump():
	if not is_on_wall_only(): return		# 仅贴墙时，才去取法线，这样绝对安全
	
	# 跳离墙壁
	var wall_normal:Vector2 = get_wall_normal()		# 先 获取墙壁法线
													# 后 根据墙壁法线 确定跳跃方向
		
	# -------------------------------------------------------------
	# 角度过滤：计算法线在重力轴（up_direction）上的投影长度，即 垂直分量（Vertical Component）
	# 90° 垂直墙面时该值为 0；倾斜越厉害，值越大。
	# sin(10°) ≈ 0.1736，表示只允许 ±10°（即 80°~100°）的墙面触发
	# -------------------------------------------------------------
	var vertical_component: float = abs(wall_normal.dot(up_direction))
	if vertical_component > sin(deg_to_rad(10.0)):
		return # 属于陡坡而非陡峭墙壁，拒绝蹬墙跳
		
	# if：按下跳跃的一瞬 

	if Input.is_action_just_pressed("jump") : 
		velocity.x = wall_normal.x * speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true
	# 1.我发现有一点不对劲
	# 按键是由 ←或→ 触发的，而不是【跳跃键】，这可能是由于没有状态机导致的。如果强行用【空格键】，可能会与其他方法冲突。
	#		状态机的做法是，在各个状态中，持续监测某些特定的按键。
	# 2. 我修改了判定墙壁的逻辑，以第一个if条件为例：
	# 以前：wall_normal == Vector2.LEFT
	# 现在：wall_normal.x < 0
# 3. 水平物理计算 (X轴：加速与减速)  # 包括：3_1 用户按键时的加减速度; 3_2 用户止输入时的减速度
# 3_1_1 地面加速度
func apply_acceleration(input_axis:float, delta:float):
	if not is_on_floor(): return	#只在地面生效
	if input_axis == 0: return		# 只有当 input_axis 不等于 0 时，才会进到这里！
	# 判断是否在“急转弯”：当前有速度，且速度方向与输入方向相反
	# sign() 函数返回 1 (正数), -1 (负数), 或 0
	if velocity.x != 0 and sign(velocity.x) != sign(input_axis):
		# 转向时的减速。取 acceleration 与 friction 中的最大值
		var turn_force:float = maxf(acceleration, friction)
		velocity.x = move_toward(velocity.x, input_axis * speed, turn_force * delta)
	else:
		# 正常的同向加速，或者从 0 开始起步
		velocity.x = move_toward(velocity.x, input_axis * speed, acceleration * delta)# 加速度改变速度

# 3_1_2 空中加速度（包含空中转向判断）
func apply_air_acceleration(input_axis: float, delta: float):
	if is_on_floor(): return	#只在空中生效
	if input_axis == 0: return		# 只有当 input_axis 不等于 0 时，才会进到这里！
	# 判断是否在空中“急转弯”：当前有水平速度，且速度方向与按键方向相反
	if velocity.x != 0 and sign(velocity.x) != sign(input_axis):
		# 空中转向时的拉回力度：取 air_acceleration 与 air_resistance 中的最大值
		var turn_force:float = maxf(air_acceleration, movement_data.air_resistance)
		velocity.x = move_toward(velocity.x, input_axis * speed, turn_force * delta)
	else:
		# 正常的空中同向加速
		velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.air_acceleration * delta)

# 3_2_1 地面摩擦力
func apply_friction(input_axis:float, delta:float):
	# 在用户未按下水平方向键时 施加摩擦力
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	# 旧代码 velocity.x = 0

# 3_2_2 空中阻力
func apply_air_resistance(input_axis:float, delta:float):
	# 在用户未按下水平方向键时 施加空气阻力
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

# 将来要做状态机，就不能像这样 写成“意大利面条“代码。
# “显式”永远比“简洁”重要。“意大利面条“代码如下 ↓
#func apply_deceleration(input_axis: float, delta: float):
	#if input_axis == 0:
		#var decel = friction if is_on_floor() else movement_data.air_resistance
		#velocity.x = move_toward(velocity.x, 0, decel * delta)


# 4. 物理提交 与 环境监测，比如 CoyoteJump
# 目前写在了 _physics_process(...) 中


# 5 动画
# 与Unity不同：与角色相关的动画 ，Gemini建议在 "物理更新"中 执行。
# Unity是强物理引擎
# Godot 4 内置 2D 物理插值，它的平滑对象不仅仅是贴图，
#   而是这个节点以及它膝下所有子节点的整个空间状态（Transform2D，包含坐标、旋转、缩放）！

# Claude 也建议这么做：你的 update_animations 依赖 is_on_floor()，
# 而且它在 move_and_slide() 之后调用——这个顺序很关键，保证了拿到的是本帧物理结算后的最新状态。
# 如果挪到 _process 里，is_on_floor() 的结果就不可靠了。
func update_animations(input_axis):
	if input_axis != 0:
		# 废弃代码 animated_sprite_2d.flip_h = (input_axis < 0) 	# 转向的逻辑 挪到了 属性facing_direction中
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

# 当 facing_direction 被修改时，自动触发 setter
var facing_direction: float = 1.0:
	set(value):
		if value != facing_direction and value != 0:
			facing_direction = value
			if pivot: # 确保节点已初始化
				pivot.scale.x = facing_direction
# 斜坡 对应节点中的Floor的Snap length
#30:49 开始讲 自定义跳跃高度

# 关于Godot中的翻转：Gemini推荐翻转Sprite，而不是像Unity那样直接改Scale
#	视频作者也是翻转Sprite


# ======================================================
# === 七.信号绑定中心 (Signal Connections) === 在_ready()中 执行

func _setup_signals():
	hurtbox.hit_received.connect(_on_hurtbox_hit_received)	# 监听受击


# ======================================================
# === 八.信号响应回调 (Signal Callbacks)** ===

# 受击
func _on_hurtbox_hit_received(damage: int, attacker_pos: Vector2) -> void:
	global_position = starting_position		# 重置位置
	velocity = Vector2.ZERO					# 重置速度
