extends BaseAnimation
class_name MagicAnimation

class DeleteAnimation extends MagicAnimation:
	var magic: Magic
	func _init(magic: Magic):
		self.magic = magic
	func play() -> void:
		print(magic.get_info().get_card_name() + "： 执行移除动画")
		# 先关闭自己的动效
		magic.get_vfx_component().visible = false
		magic.shadowComponent.visible = false
		magic.find_child("MagicInfo").visible = false
		
		var texture_rect: MagicViewportComponent = magic.viewportComponent
		# 启用溶解shader效果
		texture_rect.material.set_shader_parameter("enable_dissolve", true)
		texture_rect.material.set_shader_parameter("dissolve_amount", true)

		# 创建溶解动画
		var tween = magic.create_tween()
		tween.tween_method(func(value):texture_rect.material.set_shader_parameter("dissolve_amount", value), 0.0, 1.0, 0.6).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
			magic.deleted.emit(magic)
			CardUtils.delete_card(magic)
		)
		await tween.finished
