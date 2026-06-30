class_name MinionAnimationDefinition

enum Type{
	NONE,
	SELL,               # 出售
	BUY,                # 购买
	USE,                # 上场
	ZHANHOU,            # 战吼
	USE_MINION,         # 使用时其他随从
	USE_MAGIC,          # 使用法术
	USE_MAGIC_PLAYER,   # 玩家主动使用法术
	ROUND_START,        # 回合开始
	ROUND_END,          # 回合结束
	DIE,                # 死亡
	DIE_AFTER,          # 亡语
	DIE_AFTER_MINION,   # 复仇
	COIN_ADD,      # 金币增加
	COIN_SUB,      # 金币扣除
	ADD_HAND,           # 置入手牌
	ADD_DESK,           # 置入桌面
	ATTACK_BEFORE,      # 进击
	ATTACK_ING,         # 攻击时
	ATTACK_AFTER,       # 攻击后
	ATTACK_BEFORE_MINION,# 攻击时其他随从
	TAKE_DAMAGE,        # 受到伤害
	ON_CLICK,           # 被点击（特殊交互）
	LIEJIE_MINION,      # 裂解时其他随从
	RONGHE_MINION,      # 融合时其他随从
	BE_RONGHE,          # 被融合
}
