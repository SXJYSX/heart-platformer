class_name Heart
extends Node2D

# ======================================================
# === 零. 自定义信号 (Custom Signals) ===
signal collected


# ======================================================
# === 四. @onready 节点引用与初始状态缓存 ===
@onready var item_receiver: ItemReceiver = %ItemReceiver


# ======================================================
# === 五. 内置虚函数 (Engine Lifecycle) ===
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 父节点主动监听 子节点的通知
	_setup_signals()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# ======================================================
# === 七.信号绑定中心 (Signal Connections) === 在_ready()中 执行
func _setup_signals():
	item_receiver.item_touched.connect(_on_item_collected)	# 监听 道具被拾取


# ======================================================
# === 八.信号响应回调 (Signal Callbacks)** ===
func _on_item_collected() -> void:
	queue_free()
	collected.emit()
	#老师的代码
	#var hearts = get_tree().get_nodes_in_group(GameGroups.HEARTS)
	#if hearts.size() == 1:
		#print("Level Completed")
		
	
	
