# 2D Platform RPG Prototype

An early Godot 4 prototype for a real-time RPG platformer, guided by the project's game design document. It currently focuses on side-scrolling movement and continuous-time combat. Visuals and combat values are provisional.

## Open and run

1. Open `project.godot` from the Godot Project Manager.
2. Run the main scene with **F6**.

The main scene is `scenes/main.tscn`.

## Controls

- Left / Right arrows: move
- Down arrow: drop through a platform
- Space or Enter: jump
- F: basic melee strike
- G: magic projectile
- Q: temporary defense

Combat abilities can only start when the initiative bar is full. Movement and jumping remain available during combat.

## Current prototype

- Exploration starts without combat or the combat HUD. The combatants' initiative does not charge yet.
- Approaching any enemy starts one encounter without a warning. All surviving enemies join that encounter.
- During combat, initiative fills continuously in real time, including during an action's windup, execution, and recovery. Starting an ability consumes the full bar.
- Melee damage is applied by an active hitbox when it overlaps an enemy's hurtbox.
- Magic projectiles travel through the scene and continue after the caster's recovery.
- Defense reduces incoming damage during its active window.
- The encounter ends when the player is defeated or all enemies are defeated. The combat HUD then hides without showing a result message.
- The scene contains a goblin, a thorn wolf, and a flying willow wisp. The wisp uses projectiles.
- Down-arrow platform dropping only applies to tagged platforms; the ground remains solid.

## Project layout

- `scenes/main.tscn`: exploration area, actors, and combat HUD
- `scenes/combat/projectile.tscn`: reusable magic projectile
- `scripts/player_controller.gd`: player movement and input
- `scripts/combatant.gd`: health, initiative, combat states, and ability timing
- `scripts/ability_executor.gd`: melee hitboxes, projectile creation, and defense visuals
- `scripts/enemy_controller.gd`: ground enemy behavior
- `scripts/flying_enemy_controller.gd`: flying enemy behavior
- `scripts/combat_manager.gd`: encounter start/end and HUD updates

Combat values, encounter rules, and controls are still subject to playtesting and iteration.
