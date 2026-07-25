class_name PlayerManager
extends RefCounted

## ==========================================
## MOVIMENTAÇÃO
## ==========================================
## Velocidade de caminhada da Morgana
static var MOVE_SPEED: float = 300.0

## ==========================================
## STATUS QUANDO SOFRE DANO (FREEZE)
## ==========================================
## Quanto tempo a Morgana fica paralisada/congelada após tomar um hit
static var HIT_FREEZE_TIME: float = 0.75

## ==========================================
## COOLDOWNS GLOBAIS DE ATAQUE
## ==========================================
## Tempo base de recarga global de todas as magias. Alterar isso acelera/desacelera tudo.
static var BASE_GLOBAL_COOLDOWN: float = 1.0

## Multiplicador aplicado no tempo base ao usar a varinha de tiro (ataque rápido)
static var WAND_COOLDOWN_MULT: float = 0.35

## Multiplicador aplicado no tempo base ao invocar a aura (ataque pesado)
static var AURA_COOLDOWN_MULT: float = 0.75

## ==========================================
## DANO DE ATAQUE PADRÃO
## ==========================================
## Dano base da varinha antes dos upgrades
static var BASE_WAND_DAMAGE: int = 50
