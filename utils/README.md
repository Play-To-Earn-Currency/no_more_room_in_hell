# Utils

``read_files_dir_win.bat``: creates a file containing all paths from the actual directory, used for when converting a skin to [Skin Reader](https://github.com/GxsperMain/nmrih_play_to_earn?tab=readme-ov-file#skin-reader)

``read_files_dir_linux.sh`` creates a file containing all paths from the actual directory, used for when converting a skin to [Skin Reader](https://github.com/GxsperMain/nmrih_play_to_earn?tab=readme-ov-file#skin-reader)

``kit_starter.sp`` plugin for spawning items when player spawn

``round_timer.sp`` plugin for adding a time limit for each round

## PTE Ruleset
This is some in game variables changes for making gameplay a bit more fun

Changes:
- Bullets will penetrate over 10 zombies
- No tokens for survival mode
- Arrow will penetrate over 3 zombies
- Player inventory is increased
- No slow by full inventory
- Survival Safezone will not be lowered while a player standing inside
- Military zombies will drop more ammo
- No stamina for shove and jump
- Less stamina drained while running
- Stamina regens more faster

```txt
"Ruleset"
{
	"Name"	"PTEConfig"
	"Author"	"GxsperMain"
	"Description"	"Configurations for PTE Official Servers"

	"Base"
	{
		sv_bullet_pen_count 10,
		sv_respawn_token_survival 0,
		sv_arrow_max_passthroughs 3,
		sv_arrow_passthrough_chance 100,
		inv_maxcarry 2500,
		inv_speedfactor_full 1,
		inv_speedfactor_half 1,
		inv_speedfactor_norm 1,
		sv_safezone_counter_per_player_sec 999,
		sv_drop_ammobox_pct 2,
		sv_respawn_ammo_pct 2,
		sv_shove_cost 0,
		sv_bash_cost_per_sec 50,
		sv_stam_jumpcost 0,
		sv_sprint_penalty 15,
		sv_stam_drainrate 5,
		sv_stam_regen_crouch 25,
		sv_stam_regen_idle 15,
		sv_stam_regen_moving 15,
		sv_stam_regen_sprint 5,
		sv_max_stamina 150
	}
}
```