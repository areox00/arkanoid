extends Node
class_name Game

onready var transition_sector := $TransitionSector as TransitionSector;
onready var effects := $ScreenEffects as ScreenEffects;
onready var ui := $UI as GameUI;
onready var ball_spawner := $BallSpawner as BallSpawner;
onready var paddle := $Paddle as Paddle;
onready var game_data := $"/root/game_data" as GameData;
onready var bricks := $Bricks as Bricks;

onready var event_bus := $"%GameEventsBus" as GameEvents;

var powerup_scene := load("res://Scenes/PowerUp.tscn");

const powerup_resources := [
	preload("res://Resources/PowerUps/MoreBalls.tres"),
	preload("res://Resources/PowerUps/StrongerBall.tres"),
	preload("res://Resources/PowerUps/ExtendPaddle.tres"),
	preload("res://Resources/PowerUps/Laser.tres"),
	preload("res://Resources/PowerUps/CatchBall.tres"),
	preload("res://Resources/PowerUps/Health.tres"),
];

const game_sectors := [
	preload("res://Resources/Sectors/1.res"),
	preload("res://Resources/Sectors/2.res"),
	preload("res://Resources/Sectors/3.res"),
	preload("res://Resources/Sectors/4.res"),
	preload("res://Resources/Sectors/5.res"),
	preload("res://Resources/Sectors/6.res"),
	preload("res://Resources/Sectors/7.res"),
	preload("res://Resources/Sectors/8.res"),
	preload("res://Resources/Sectors/9.res"),
	preload("res://Resources/Sectors/10.res"),
	preload("res://Resources/Sectors/11.res"),
	preload("res://Resources/Sectors/12.res"),
	preload("res://Resources/Sectors/13.res"),
	preload("res://Resources/Sectors/14.res"),
	preload("res://Resources/Sectors/15.res"),
	preload("res://Resources/Sectors/16.res"),
	preload("res://Resources/Sectors/17.res"),
	preload("res://Resources/Sectors/18.res"),
	preload("res://Resources/Sectors/19.res"),
	preload("res://Resources/Sectors/20.res"),
	preload("res://Resources/Sectors/21.res"),
	preload("res://Resources/Sectors/22.res"),
	preload("res://Resources/Sectors/23.res"),
	preload("res://Resources/Sectors/24.res"),
	preload("res://Resources/Sectors/25.res"),
	preload("res://Resources/Sectors/26.res"),
	preload("res://Resources/Sectors/27.res"),
	preload("res://Resources/Sectors/28.res"),
	preload("res://Resources/Sectors/29.res"),
	preload("res://Resources/Sectors/30.res"),
	preload("res://Resources/Sectors/31.res"),
	preload("res://Resources/Sectors/32.res"),
];

var bricks_left: int;
var release_ready := false;
var current_points := 0;
var total_points := 0;
var current_sector := 1;
var total_bricks_destroyed := 0;
var total_powerups_collected := 0;

func unlock_paddle():
	paddle.paused = false;

func reset_powerups_effects():
	paddle.laser_off();
	paddle.extend_off();
	get_tree().call_group("ball", "make_normal_damage");
	get_tree().call_group("ball", "disable_catching");

func reset_player():
	release_ready = false;
	reset_powerups_effects();
	
	paddle.global_position.x = 0.0;
	paddle.paused = true;

	ball_spawner.kill_all();
	ball_spawner.spawn_ball(paddle.global_position + Vector2.UP * 20);

	get_tree().call_group("ball", "lock", paddle);

func clear_sector():
	get_tree().call_group("power_up", "queue_free");
	bricks.clear_bricks();

func game_end():
	get_tree().paused = true;
	$EndGame.visible = true;
	$"EndGame/Title".text = "You won!\nThanks for playing the game!";
	$"EndGame/Bricks".text = "Total bricks destroyed: " + str(total_bricks_destroyed);
	$"EndGame/PowerUps".text = "Total power ups collected: " + str(total_powerups_collected);
	$"EndGame/Points".text = "Points earned: " + str(total_points);
	
func game_over():
	get_tree().paused = true;
	$EndGame.visible = true;
	$"EndGame/Bricks".text = "Total bricks destroyed: " + str(total_bricks_destroyed);
	$"EndGame/PowerUps".text = "Total power ups collected: " + str(total_powerups_collected);
	$"EndGame/Points".text = "Points earned: " + str(total_points);

func start_sector(index: int):
	release_ready = false;
	reset_player();
	current_points = 0;
	clear_sector();
		
	var sector: SectorResource;
	
	if game_data.game_mode == game_data.game_modes.story and index < 33:
		sector = game_sectors[index-1] as SectorResource;
		transition_sector.set_text("Sector " + str(index));
		ui.set_sector(index);
		
		yield(bricks.create_bricks(sector, index), "completed");
		yield(transition_sector.play(), "completed");
		
		bricks_left = bricks.amount;
	elif game_data.game_mode == game_data.game_modes.custom:
		sector = game_data.sector_resource;
		transition_sector.set_text(game_data.sector_name);
		ui.hide_sectors();
		
		yield(bricks.create_bricks(sector, index), "completed");
		yield(transition_sector.play(), "completed");
		
		bricks_left = bricks.amount;
	elif current_sector == 33:
		get_tree().call_group("boss", "queue_free");
		transition_sector.set_text("FINAL BOSS!");
		ui.hide_sectors();
		
		var instance = load("res://Scenes/Boss.tscn").instance() as Boss;
		instance.global_position = Vector2.ZERO;
		instance.connect("death", self, "game_end");
		add_child(instance);
		yield(transition_sector.play(), "completed");
	
	unlock_paddle();
	
	release_ready = true;

func drop_powerup(position: Vector2):
	var instance := powerup_scene.instance() as PowerUp;
	
	var rng := RandomNumberGenerator.new();
	rng.randomize();
	
	instance.resource = powerup_resources[rng.randi_range(0, powerup_resources.size()-1)];
	instance.global_position = position;
	add_child(instance);

func on_brick_destroyed(brick: Brick):
	total_bricks_destroyed += 1;
	
	total_points += brick.resource.points;
	current_points += brick.resource.points;
	ui.animate_points(total_points, brick.resource.points, Color.white);
	bricks_left -= 1;
	
	if bricks_left % 5 as int == 0:
		drop_powerup(brick.global_position);
	
	if bricks_left == 0:
		yield(freeze(), "completed");
		current_sector += 1;
		if current_sector > 33:
			game_end();
			
			var dir := Directory.new();
			dir.remove("user://game_state.res");
		elif game_data.game_mode == game_data.game_modes.custom:
			game_end();
		else:
			start_sector(current_sector);

func freeze():
	Engine.time_scale = 0.05;
	yield(get_tree().create_timer(0.75 * Engine.time_scale), "timeout");
	Engine.time_scale = 1.0;

func on_paddle_hit():
	$DeathSound.play();
	
	total_points -= current_points;
	ui.animate_points(total_points, -current_points, Color.red);
	start_sector(current_sector);
	
	effects.abberation_on();
	yield(freeze(), "completed");
	effects.abberation_off();
	
	ui.set_lives(paddle.lives);

func on_ball_death():
	paddle.take_live(1);

func on_player_death():
	$DeathSound.play();
	game_over();
	
	var dir := Directory.new();
	dir.remove("user://game_state.res");

func stronger_ball():
	get_tree().call_group("ball", "make_stronger_damage");

func catch_ball():
	get_tree().call_group("ball", "enable_catching");
	
func spawn_balls():
	ball_spawner.spawn_more_balls(ball_spawner.pick_first().global_position);

func health():
	paddle.add_live(1);
	ui.set_lives(paddle.lives);

func add_collected_count():
	total_powerups_collected += 1;

func setup_game():
	if game_data.continue_game:
		var state = load("user://game_state.res") as GameState;
		total_points = state.total_points;
		paddle.lives = state.lives;
		current_sector = state.current_sector;
		total_powerups_collected = total_powerups_collected;
		total_bricks_destroyed = total_bricks_destroyed;
		
		ui.set_lives(paddle.lives);
	
	# setup stuff
	event_bus.connect("brick_destroyed", self, "on_brick_destroyed");
	ball_spawner.connect("all_dead", self, "on_ball_death");
	
	paddle.connect("death", self, "on_player_death");
	paddle.connect("hit", self, "on_paddle_hit");
	
	event_bus.connect("powerup_collected", self, "reset_powerups_effects");
	event_bus.connect("powerup_collected", self, "add_collected_count");
	
	event_bus.connect("powerup_more_balls", self, "spawn_balls");
	event_bus.connect("powerup_stronger_ball", self, "stronger_ball");
	event_bus.connect("powerup_extend_paddle", paddle, "extend_on");
	event_bus.connect("powerup_laser", paddle, "laser_on");
	event_bus.connect("powerup_catch_ball", self, "catch_ball");
	event_bus.connect("powerup_health", self, "health");

	start_sector(current_sector);

func quit():
	get_tree().paused = false;
	get_tree().change_scene("res://Scenes/States/MainMenu.tscn");

func save_and_quit():
	get_tree().paused = false;
	
	if game_data.game_mode == game_data.game_modes.story:
		var sector = GameState.new();
		sector.lives = paddle.lives;
		sector.current_sector = current_sector;
		sector.total_points = total_points;
		sector.total_bricks_destroyed = total_bricks_destroyed;
		sector.total_powerups_collected = total_powerups_collected;
	
		ResourceSaver.save("user://game_state.res", sector);

	get_tree().change_scene("res://Scenes/States/MainMenu.tscn");

func _ready():
	setup_game();

func _process(delta):
	if Input.is_action_pressed("release") and release_ready:
		get_tree().call_group("ball", "release", paddle.direction.x, ball_spawner);
