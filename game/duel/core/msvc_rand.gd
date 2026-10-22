class_name MsvcRand
extends RefCounted
## rand()/srand() de la biblioteca de Visual C++ que usa el original (0x585d66 / 0x585d59):
## holdrand = holdrand * 214013 + 2531011; devuelve los bits 16-30.
## El duelo lo siembra con time(NULL) al empezar (cabecera del .ydr) y lo vuelve a sembrar
## con el argumento de cada comando 0x60 (barajar).

var holdrand := 0


func srand(seed: int) -> void:
	holdrand = seed & 0xffffffff


func rand() -> int:
	holdrand = (holdrand * 0x343fd + 0x269ec3) & 0xffffffff
	return (holdrand >> 16) & 0x7fff
