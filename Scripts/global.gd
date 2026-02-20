class_name GlobalStats

extends Node 

@export var stats: Array[Stat]

signal timer_start(stats_timer_name: String)
signal timer_end(stats_timer_name: String)
signal stat_changed(stats_timer_name: String, new_value: float)
signal reached_zero(stats_timer_name: String)

func find_stat_timer_by_name(timer_name: String) -> StatsTimer:
	var matching_timers := stats.filter(func(stat: Stat): return stat is StatsTimer and stat.stat_name == timer_name)
	
	var matches := matching_timers.size()
	if matches != 1:
		print_debug("found " + str(matches) + " matches for timer with name " + timer_name)
		return
	
	return matching_timers[0]
	
func find_stat_by_name(stat_name: String) -> Stat:
	var matching_stats := stats.filter(func(stat: Stat): return stat.stat_name == stat_name)
	
	var matches := matching_stats.size()
	if matches != 1:
		print_debug("found " + str(matches) + " matches for stat with name " + stat_name)
		return
	
	return matching_stats[0]

func on_timer_end(stats_timer_name: String) -> void:
	timer_end.emit(stats_timer_name)
	
	var stats_timer = find_stat_timer_by_name(stats_timer_name)
	
	if stats_timer == null:
		print_debug("on_timer_end: could not find stats timer with name " + stats_timer_name)
		return
	
	var new_value = stats_timer._current_value - stats_timer.delta
	if new_value < 0:
		new_value = 0
		reached_zero.emit(stats_timer_name)
	
	stats_timer._current_value = new_value
	stat_changed.emit(stats_timer_name, new_value)
	
	_start_timer(stats_timer)
	
	
func _start_timer(stats_timer: StatsTimer) -> void:
	assert(stats_timer._timer != null, "must pass a StatsTimer with a valid _timer property to _start_timer()")
	
	if stats_timer._current_value <= 0:
		print_debug("Not starting timer " + stats_timer.stat_name + " because the value is currently " + str(stats_timer._current_value))
		stats_timer._current_value = 0
		return
		
	stats_timer._timer.start()
	timer_start.emit(stats_timer.stat_name)
	

func set_stat_current_value(stat_name: String, new_value: float):
	var stat: Stat = find_stat_by_name(stat_name)
	if stat == null:
		print_debug("set_stat_current_value: could not find stat with name " + stat_name)
		return
	
	if new_value < 0:
		new_value = 0
		
	stat._current_value = new_value
	stat_changed.emit(stat_name, new_value)
		
	

func _ready() -> void:
	for stat: Stat in stats:
		if stat is not StatsTimer:
			continue
		
		stat._current_value = stat.initial_value		
		
		var timer := Timer.new()
		add_child(timer)
		
		timer.wait_time = stat.initial_duration
		timer.one_shot = true
		
		timer.timeout.connect(on_timer_end.bind(stat.stat_name))
		
		stat._timer = timer
		
		_start_timer(stat)
		
