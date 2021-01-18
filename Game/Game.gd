extends Node2D


var time = 0
var flags = 0

func _ready():
	$Timer.start()
	$WinLose.hide()
	setFlagLabel()


func _process(delta):
	flags = $GameBoard.flags - $GameBoard.visible_fields_amount
	setFlagLabel()


func setFlagLabel():
	if flags < 10:
		$FlagLabel.text = "0" + String(flags)
	else:
		$FlagLabel.text = String(flags)


func _on_Timer_timeout():
	time += 1
	if time < 10:
		$TimerLabel.text = "00" + String(time)
	elif time < 100:
		$TimerLabel.text = "0" + String(time)
	else:
		$TimerLabel.text = String(time)


func _on_GameBoard_lose_game():
	$Timer.stop()
	$WinLose.show()
	$WinLose.text = "Lose"
	$WinLose.add_color_override("font_color", Color(1,0,0))


func _on_GameBoard_win_game():
	$Timer.stop()
	$WinLose.show()
	$WinLose.text = "Win"
	$WinLose.add_color_override("font_color", Color(0,1,0))
	if time > Settings.bestTime[Settings.level]:
		Settings.bestTime[Settings.level] = time
