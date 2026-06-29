@tool
extends EditorPlugin


func _enter_tree() -> void:
	# 添加菜单项到"工具"菜单
	add_tool_menu_item("转换CSV为TRES", _on_convert_csv)


func _exit_tree() -> void:
	# 移除菜单项
	remove_tool_menu_item("转换CSV为TRES")


func _on_convert_csv() -> void:
	var converter_script: GDScript = load("res://addons/csv_converter/csv_converter.gd")
	converter_script.convert_all()
	print_rich("[color=green]CSV转换完成！[/color]")
