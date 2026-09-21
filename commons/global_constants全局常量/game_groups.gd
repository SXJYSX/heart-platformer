class_name GameGroups
# 正因为 Godot 编辑器对字符串补全的不稳定性，
# 正规项目开发中极少直接在代码里手敲 &"Hearts"。绝大多数团队会创建一个专门的【组名常量类】
# 在任何脚本中直接调用：GameGroups.HEARTS
# 敲出 GameGroups. 时，编辑器会弹出 100% 稳定的强类型代码补全！

# const 		声明一个常量。在 GDScript 中，常量默认就是类级别（C# static 语义）的，所以可以直接 GameGroups.HEARTS 调用，全体共享。
# HEARTS		常量名称（习惯大写）。
# :=  			告诉编辑器：“请自动推导右边 &"Hearts" 的类型（即 StringName），并锁定 HEARTS 为 StringName 静态类型”。
# &"Hearts"  	高性能 StringName 字面量。

const HEARTS := &"Hearts"
