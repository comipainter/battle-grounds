extends MinionComponent
class_name MinionKeywordComponent

var info: MinionKeywordInfo = MinionKeywordInfo.new()
func set_minion(_minion: Minion):
	super.set_minion(_minion)
	info = _minion.get_info().get_keyword_info()
	info.shengdun_changed.connect(update_shengdun)
	info.chaofeng_changed.connect(update_chaofeng)
	info.fengnu_changed.connect(update_fengnu)
	
@onready var shengdun_background_colorrect: ColorRect = $Shengdun/BackgroundColorRect
@onready var shengdun_circle_colorrect: ColorRect = $Shengdun/CircleColorRect
@onready var fengnuParticles: GPUParticles2D = $Fengnu/FengnuParticles
@onready var chaofengSprite: Sprite2D = $ChaoFeng/ChaofengSprite

func use_info() -> void:
	update_info()
	
func update_info() -> void:
	update_shengdun(info.is_shengdun())
	update_fengnu(info.is_fengnu())
	update_chaofeng(info.is_chaofeng())
	
func update_shengdun(new_shengdun: bool) -> void:
	shengdun_background_colorrect.visible = new_shengdun
	shengdun_circle_colorrect.visible = new_shengdun
func update_fengnu(new_fengnu: bool) -> void:
	fengnuParticles.emitting = new_fengnu
func update_chaofeng(new_chaofeng: bool) -> void:
	chaofengSprite.visible = new_chaofeng

func set_able(_able: bool) -> void:
	if _able:
		self.visible = true
		use_info()
	else:
		self.visible = false
