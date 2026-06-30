class_name ShopConstant

const MINION_NUM: Array[int] = [0, 4, 5, 6, 7, 7, 7]
const MAGIC_NUM: int = 1
const UPGRADE_COST: Array[int] = [0, 0, 5, 7, 8, 9, 10]
const MAX_LEVEL: int = 6
const INIT_COIN: int = 100
const COIN_LIMIT: int = 100
const COIN_MAX_LIMIT: int = 10
const BUY_MINION_COST: int = 3
const FRESH_COST: int = 1
const INIT_TIME: int = 120
const INIT_LEVEL: int = 1

static func get_minion_num() -> Array[int]:
	return MINION_NUM

static func get_magic_num() -> int:
	return MAGIC_NUM

static func get_upgrade_cost() -> Array[int]:
	return UPGRADE_COST

static func get_max_level() -> int:
	return MAX_LEVEL

static func get_init_coin() -> int:
	return INIT_COIN

static func get_coin_limit() -> int:
	return COIN_LIMIT
	
static func get_coin_max_limit() -> int:
	return COIN_MAX_LIMIT

static func get_buy_minion_cost() -> int:
	return BUY_MINION_COST

static func get_fresh_cost() -> int:
	return FRESH_COST

static func get_init_time() -> int:
	return INIT_TIME

static func get_init_level() -> int:
	return INIT_LEVEL
