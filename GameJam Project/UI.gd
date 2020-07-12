extends Control

onready var healthBar : TextureProgress = get_node("HealthBarBG/HealthBar")

func update_health(curHealth, maxHealth):
	healthBar.value = (100 / maxHealth) * curHealth
