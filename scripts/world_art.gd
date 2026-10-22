extends Node2D

func _draw() -> void:
	# Fundo de fantasia em camadas, feito com formas vetoriais provisórias.
	draw_rect(Rect2(0.0, 0.0, 3000.0, 648.0), Color("#182b43"))
	draw_rect(Rect2(0.0, 320.0, 3000.0, 328.0), Color("#253e55"))
	draw_circle(Vector2(2460.0, 135.0), 46.0, Color("#f2c889"))
	draw_circle(Vector2(2460.0, 135.0), 62.0, Color(0.95, 0.72, 0.48, 0.12))

	# Estrelas pequenas para dar textura ao céu.
	for i in range(42):
		var x := fposmod(float(i * 173 + 61), 3000.0)
		var y := float((i * 67 + 38) % 245)
		var radius := 1.0 if i % 3 == 0 else 2.0
		draw_circle(Vector2(x, y), radius, Color(0.83, 0.88, 0.87, 0.72))

	# Morros ao fundo e uma linha distante de pinheiros.
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 365), Vector2(180, 280), Vector2(355, 365),
		Vector2(590, 260), Vector2(820, 370), Vector2(1070, 275),
		Vector2(1320, 365), Vector2(1570, 250), Vector2(1815, 370),
		Vector2(2070, 285), Vector2(2330, 375), Vector2(2580, 265),
		Vector2(2825, 365), Vector2(3000, 305), Vector2(3000, 648), Vector2(0, 648)
	]), Color("#344e63"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, 450), Vector2(240, 350), Vector2(490, 455),
		Vector2(760, 345), Vector2(1030, 455), Vector2(1300, 350),
		Vector2(1580, 455), Vector2(1850, 355), Vector2(2120, 455),
		Vector2(2400, 350), Vector2(2700, 455), Vector2(3000, 365),
		Vector2(3000, 648), Vector2(0, 648)
	]), Color("#22384a"))

	# Bosque estilizado em silhueta, distribuído por todo o percurso.
	for i in range(16):
		var x := 75.0 + float(i) * 195.0
		var base_y := 530.0 + float((i % 3) * 8)
		var trunk_width := 14.0 + float(i % 3) * 3.0
		draw_rect(Rect2(x, base_y - 108.0, trunk_width, 108.0), Color("#172b37"))
		draw_circle(Vector2(x + trunk_width * 0.5, base_y - 120.0), 36.0 + float(i % 2) * 8.0, Color("#1b3540"))
		draw_circle(Vector2(x - 18.0, base_y - 91.0), 26.0, Color("#1b3540"))
		draw_circle(Vector2(x + 30.0, base_y - 88.0), 29.0, Color("#1b3540"))
