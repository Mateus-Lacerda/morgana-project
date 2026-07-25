class_name AuraManager
extends RefCounted

## ==========================================
## PARÂMETROS BASE E ESCALONAMENTO DA AURA
## ==========================================
const BASE_RADIUS: float = 120.0
const RADIUS_STEP: float = 20.0

const BASE_DAMAGE: int = 60
const DAMAGE_STEP: int = 15

## ==========================================
## CADÊNCIA E COOLDOWN
## ==========================================
const BASE_TRIGGER_COOLDOWN: float = 3.0
const COOLDOWN_STEP: float = 0.55
const MIN_TRIGGER_COOLDOWN: float = 0.15

## ==========================================
## TEMPOS DE ANIMAÇÃO DO VISUALIZADOR (FREEZE/PULSO)
## ==========================================
## Quanto tempo demora pra aura crescer até o máximo
const EXPAND_DURATION: float = 0.16
## O tempo de "Freeze" que ela segura no tamanho máximo
const HOLD_DURATION: float = 0.28
## Quanto tempo demora para ela sumir recuando
const RECEDE_DURATION: float = 0.45

## Duração total do pulso
const PULSE_DURATION: float = EXPAND_DURATION + HOLD_DURATION + RECEDE_DURATION
