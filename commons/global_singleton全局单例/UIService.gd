extends Node

# UIService 是如何知道 自己要打开某个面板的？
# 换句话说 UIService 应该怎么做？
# 1、UIservice直接监听Events
# 对于 HUD（如血条、金币计数、小地图更新），选“做法一”即可。
# 2、CampaignService监听Events，CampaignService调用UIService
# 对于面板（如通关、死亡、暂停、剧情），应该选“做法二”
signal panel_open_requested(panel_name:StringName)



func open_panel(panel_name: StringName):
	panel_open_requested.emit(panel_name)
