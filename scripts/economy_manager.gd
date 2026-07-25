class_name EconomyManager
extends RefCounted

## ==========================================
## CUSTOS DE HABILIDADES BASE
## ==========================================
static var COST_ORB_COMBO: int = 400
static var COST_ORB_BLADE: int = 550
static var COST_ORB_EXPLOSIVE: int = 750

## ==========================================
## CUSTOS DE UPGRADES (PERGAMINHOS)
## ==========================================
## O custo do primeiro pergaminho (nível 1 para nível 2)
static var SCROLL_BASE_COST: int = 50
## O valor que é adicionado ao custo base para cada nível subsequente
static var SCROLL_COST_PER_LEVEL: int = 35
## Custo fixo do pergaminho final que transforma a habilidade (10x o valor
## original — é a evolução máxima, tem que doer no bolso)
static var SCROLL_TRANSFORM_COST: int = 1500

## ==========================================
## CUSTOS DE UTILITÁRIOS
## ==========================================
static var COST_COIN_MAGNET: int = 800
