extends Node

func _ready() -> void:
	var playerEffectCollection: PlayerEffectCollection = DataManager.get_player_info().get_player_effect_collection()
	GameManager.main_scene_registered.connect(
		func(mainScene: MainScene):
			mainScene.get_shop_component().get_card_component().card_created.connect(
				func(card:Card):
					playerEffectCollection._on_card_created(card)
					if card.get_info().is_minion():
						(card as Minion).attack_aftered.connect(playerEffectCollection._on_minion_attack_after)
					elif card.get_info().is_magic():
						(card as Magic).used.connect(playerEffectCollection._on_used_magic)
			)
			mainScene.get_fight_component().get_card_component().card_created.connect(
				func(card:Card):
					playerEffectCollection._on_card_created(card)
					if card.get_info().is_minion():
						(card as Minion).attack_aftered.connect(playerEffectCollection._on_minion_attack_after)
					elif card.get_info().is_magic():
						(card as Magic).used.connect(playerEffectCollection._on_used_magic)
			)
			mainScene.get_fight_component().fight_started.connect(
				func():
					playerEffectCollection._on_fight_started("player")
					DataManager.get_enemy_info().get_player_effect_collection()._on_fight_started("enemy")
			)
			mainScene.get_shop_component().get_fresh_component().freshed.connect(
				playerEffectCollection._on_freshed
			)
			mainScene.get_shop_component().round_started.connect(
				playerEffectCollection._on_round_started
			)
			mainScene.get_shop_component().round_ended.connect(
				playerEffectCollection._on_round_ended
			)
			mainScene.get_shop_component().used.connect(
				func(used_card: Card):
					if used_card.get_info().is_minion():
						playerEffectCollection._on_used_minion(used_card)
					elif used_card.get_info().is_magic():
						pass
					else:
						push_error("unknown card type")
			)
			## 以下的信号的连接存在风险：当游戏结束重新开始时，下面的信号仍然保留没有移除
			var shopInfo: ShopInfo = DataManager.get_shop_info()
			shopInfo.coin_subed.connect(
				playerEffectCollection._on_coin_subed
			)
	)
	
