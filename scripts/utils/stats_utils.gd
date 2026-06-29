class_name StatsUtils

static func copy(stats: Stats) -> Stats:
	return Stats.new(
		stats.attack, stats.health
	)

static func equal(stats1: Stats, stats2: Stats) -> bool:
	return stats1.attack == stats2.attack and stats1.health == stats2.health

static func add_stats(stats1: Stats, stats2: Stats) -> Stats:
	return Stats.new(
			stats1.attack + stats2.attack,
			stats1.health + stats2.health
		)

static func double(stats: Stats) -> Stats:
	return Stats.new(stats.attack*2, stats.health*2)
	
static func mul_stats(stats: Stats, mul: int) -> Stats:
	return Stats.new(stats.attack*mul, stats.health*mul)

static func sub_stats(originStats: Stats, subStats: Stats) -> Stats:
	return Stats.new(originStats.attack-subStats.attack, originStats.health-subStats.health)
	
static func max_stats(stats1: Stats, stats2: Stats) -> Stats:
	return Stats.new(
		maxi(stats1.attack, stats2.attack),
		maxi(stats1.health, stats2.health)
	)

static func half(stats: Stats) -> Stats:
	return Stats.new(floor(stats.attack / 2.0), floor(stats.health / 2.0))
