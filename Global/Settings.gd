extends Node

enum Level{
	EASY,
	NORMAL,
	HARD
}
var level = Level.NORMAL setget setLevel
var bestTime = [0, 0, 0]

func getBestTime(lvl: String):
	match lvl.to_upper():
		"EASY":
			return bestTime[0]
		"NORMAL":
			return bestTime[1]
		"HARD":
			return bestTime[2]
		_:
			return -1
 
func setLevel(lvl):
	level = lvl
