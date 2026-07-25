class_name EconomyManager
extends RefCounted

## ==========================================
## CUSTOS DE HABILIDADES BASE
## ==========================================
const COST_ORB_COMBO: int = 400
const COST_ORB_BLADE: int = 550
const COST_ORB_EXPLOSIVE: int = 750
const COST_WAND: int = 45

## ==========================================
## CUSTOS DE UPGRADES (PERGAMINHOS)
## ==========================================
## O custo do primeiro pergaminho (nível 1 para nível 2)
const SCROLL_BASE_COST: int = 30
## O valor que é adicionado ao custo base para cada nível subsequente
const SCROLL_COST_PER_LEVEL: int = 15
## Custo fixo do pergaminho final que transforma a habilidade
const SCROLL_TRANSFORM_COST: int = 150

## ==========================================
## CUSTOS DE UTILITÁRIOS
## ==========================================
const COST_COIN_MAGNET: int = 50
