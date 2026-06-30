extends Control
class_name PlayerComponent

@onready var heroSprite: Sprite2D = $HeroSprite
@onready var backgroundSprite: Sprite2D = $BackgroundSprite
@onready var bloodSprite: Sprite2D = $BloodSprite
@onready var shieldSprite: Sprite2D = $ShieldSprite
@onready var bloodLabel: Label = $BloodLabel
@onready var shieldLabel: Label = $ShieldLabel
@onready var winsBarComponent: PlayerWinsBarComponent = $WinBar
@onready var scoreSprite: Sprite2D = $ScoreSprite
@onready var scoreLabel: Label = $ScoreLabel
@onready var effectDisplayButton: Button = $EffectDisplayButton
@onready var effectDisplay: Control = $EffectDisplay

@onready var playerAnimationComponent: PlayerAnimationComponent = $PlayerAnimationComponent

func add_animation(_animation: BaseAnimation) -> void:
	playerAnimationComponent.add_animation(_animation)
	
func get_animation_component() -> PlayerAnimationComponent:
	return playerAnimationComponent
	
@onready var info: PlayerInfo = DataManager.get_player_info()

func init() -> void:
	info.blood_changed.connect(_update_blood)
	info.shield_changed.connect(_update_shield)
	info.win_num_changed.connect(_update_wins_bar)
	info.score_changed.connect(_update_score)

func start() -> void:
	_update_blood()
	_update_shield()
	_update_wins_bar()
	_update_score()
	
func _update_blood() -> void:
	bloodLabel.text = str(info.get_blood())
func _update_shield() -> void:
	if info.get_shield() <= 0:
		shieldSprite.visible = false
		shieldLabel.visible = false
	else:
		shieldLabel.text = str(info.get_shield())
		
var _bar_active_num: int = 0
func _update_wins_bar() -> void:
	if info.get_curr_win_num() > _bar_active_num:
		while _bar_active_num < info.get_curr_win_num():
			winsBarComponent.add_bar()
			_bar_active_num += 1
	else:
		winsBarComponent.set_bar_num(info.get_curr_win_num())
		_bar_active_num = info.get_curr_win_num()

func _update_score() -> void:
	scoreLabel.text = str(info.get_score())


func _on_effect_display_button_button_up() -> void:
	effectDisplay.add_child(
		DataManager.effectTabScene.instantiate()
	)
