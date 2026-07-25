# Guia de Parâmetros e Balanceamento do Jogo

Este guia mapeia os arquivos e variáveis que definem a economia, dificuldade, tempos e força do projeto. Todos esses parâmetros foram ou estão sendo refatorados para ficarem acessíveis a game designers no topo dos scripts (constantes) ou via painel *Inspector* (`@export`).

---

## 1. Loop de Jogo e Tempos (Ondas)
**Arquivo:** `scripts/game_manager.gd`

O coração da progressão de dificuldade e do cronômetro de jogo.
- **`STARTING_MONEY` (50):** O dinheiro inicial do jogador.
- **`WAVES_CONFIG`:** Um Array contendo a configuração exata de cada onda.
  - `prep_time`: Tempo em segundos da fase de compras/preparação.
  - `wave_time`: Tempo em segundos de duração do combate.
  - `difficulty_mult`: Multiplicador que escala a vida, dano e recompensas dos inimigos durante aquela onda.
- **`INFINITE_TESTING_MODE`:** Se verdadeiro, impede a vitória e repete o combate da última onda infinitamente (ótimo para testes).
- **`COMBO_TIERS`:** Array que define com quantos inimigos derrotados (streak) o jogador atinge multiplicadores de pontos (x2, x3, x5, x8, x10).
- **`DAMAGE_PER_HIT`:** Quanto de integridade a vila perde por cada "mordida" de um morcego.

## 2. Orbes Mágicas (Vampire Survivors)
**Arquivos:** `scripts/orbs/orb_blade.gd`, `orb_explosive.gd`, `orb_combo.gd`

Totalmente modularizadas com grupos de `@export_group` para serem editadas direto na cena pelo *Inspector*.
- **`damage_amount`:** O dano base por acerto/explosão.
- **`hit_cooldown` / `attack_cooldown_base`:** O tempo de espera entre um golpe e outro no mesmo alvo.
- **`attack_step` / `contact_radius_step`:** O quanto o dano ou tamanho crescem a cada upgrade de pergaminho.
- **`POWER_TIERS` (OrbCombo):** No `orb_combo.gd`, há uma tabela que mapeia o Multiplicador de Combo para `damage`, `cooldown`, e `orbit_speed`.

## 3. Inimigos (Morcegos)
**Arquivos:** `scripts/enemy_base.gd`, `bat.gd`, `giant_bat.gd`

A base de todos os inimigos possui variáveis modulares (`@export`) de fácil acesso.
- **`max_hp`:** Vida máxima (cresce com o `difficulty_mult` da Wave).
- **`base_speed`:** A velocidade de perseguição no mapa.
- **`money_value` / `score_value`:** A quantidade de Orbs de XP/Dinheiro e pontos que cada morcego deixa cair (Drop).
- **`max_village_hits`:** Quantas mordidas o inimigo consegue dar no portão antes de "morrer" de bater a cabeça.
- **Timings de Ataque (`attack_hit_delay`, `attack_recoil_delay`):** O tempo exato que o morcego demora na animação de bater na vila e recuar.

## 4. Habilidades da Morgana e Lógica de Personagem
**Arquivos:** `scripts/player_manager.gd`, `scripts/abilities/wand_ability.gd` e `scripts/aura_manager.gd`

Definem as skills ativas e o comportamento base da Morgana. Para facilitar o balanceamento e não sujar o código do player, os status bases foram extraídos:
- No `player_manager.gd`:
  - **`BASE_WAND_DAMAGE`:** Dano dos tiros mágicos antes de qualquer upgrade.
  - **`MOVE_SPEED`:** Velocidade de corrida da personagem.
  - **`HIT_FREEZE_TIME`:** Quanto tempo (em segundos) a Morgana fica paralisada/congelada sempre que sofre dano.
  - **`BASE_GLOBAL_COOLDOWN` / `WAND_COOLDOWN_MULT` / `AURA_COOLDOWN_MULT`:** A matemática por trás do cooldown que a Morgana tem entre uma ação e outra.
- No `aura_manager.gd`:
  - **`BASE_RADIUS` / `BASE_DAMAGE`:** Raio (tamanho base da área mágica) e dano inicial.
  - **`BASE_TRIGGER_COOLDOWN` / `COOLDOWN_STEP`:** O ritmo que os pulsos batem e o quanto encurta por upgrade.
  - **`HOLD_DURATION`:** O tempo em segundos que o visual da aura fica travado na tela em seu ápice.
- No `wand_ability.gd` (ainda local no script):
  - **`DAMAGE_STEP` / `SPEED_STEP`:** O quanto a varinha melhora (dano e velocidade do tiro) a cada upgrade de pergaminho.

## 5. Lojinha e Custos (EconomyManager)
**Arquivo:** `scripts/economy_manager.gd`

Todos os custos do jogo foram centralizados nesse arquivo estático para fácil acesso e balanceamento.
- **Custos de Habilidades Base:** `COST_ORB_COMBO`, `COST_ORB_BLADE`, `COST_ORB_EXPLOSIVE`, `COST_WAND`
- **Custos de Upgrades (Pergaminhos):** 
  - `SCROLL_BASE_COST`: O custo do primeiro pergaminho.
  - `SCROLL_COST_PER_LEVEL`: Adicional somado a cada nível subsequente que o jogador já possua daquela habilidade.
  - `SCROLL_TRANSFORM_COST`: Custo fixo da evolução final da habilidade.
- **Utilitários:** `COST_COIN_MAGNET` e futuros itens extras.
