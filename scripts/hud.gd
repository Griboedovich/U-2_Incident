extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Мэйдей! Вас сбили!")
	#функция встаёт на паузу пока таймер не выдаст сигнал
	await $MessageTimer.timeout
	
	$Message.text = "Ты под Свердловском\nУклонись от Ср-75"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	$ExitButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)



func _on_message_timer_timeout() -> void:
	$Message.hide()


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$ExitButton.hide()
	start_game.emit()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
