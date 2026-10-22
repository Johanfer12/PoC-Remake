class_name NativeClock
## Ritmo nativo de los tres juegos. El bucle principal (Yugi 40c140) limita a [5aa180]
## fotogramas por segundo con 481a30/481890: 30 por defecto (Kaiba 5ad184, Joey 5eb618); solo
## la opcion de linea de ordenes -speedy pone 60. Toda la logica y las animaciones avanzan por
## este reloj; el dibujo va a la frecuencia del monitor.

const HZ := 30.0
## Interpolar entre ticks al dibujar. Sin pantalla no hay nada que suavizar y las pruebas leen
## el estado exacto de cada tick.
static var interpolate := DisplayServer.get_name() != "headless"


## Ticks nativos que corresponden a `delta` segundos. Ajusta a entero los valores a menos de
## 1e-6 de uno: n / HZ * HZ no siempre es exacto en coma flotante y truncaria un tick.
static func ticks(delta: float) -> float:
	var t := delta * HZ
	var whole := roundf(t)
	return whole if absf(t - whole) < 1e-6 else t
