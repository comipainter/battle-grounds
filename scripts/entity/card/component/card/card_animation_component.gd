extends Control
class_name CardAnimationComponent

@onready var collection: AnimationCollection = AnimationCollection.new()
@onready var card: Card = get_parent()

func is_idle() -> bool:
	return collection.is_idle()

func _process(delta: float) -> void:
	collection.play()

func get_card_animation_collection() -> AnimationCollection:
	return collection

func add_animation(_animation: BaseAnimation) -> void:
	collection.add_animation(_animation)
