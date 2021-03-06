package states;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import objects.BonusBlock;
import objects.Coin;
import objects.Enemy;
import objects.Player;
import objects.PowerUp;
import utils.LevelLoader;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
	public var player(default, null):FlxSprite;
	public var items(default, null):FlxTypedGroup<FlxSprite>;
	public var enemies(default, null):FlxTypedGroup<Enemy>;
	public var blocks(default, null):FlxTypedGroup<FlxSprite>;

	private var display:Display;
	private var gameCamera:FlxCamera;
	private var displayCamera:FlxCamera;
	private var entities:FlxGroup;
	private var terrain:FlxGroup;

	override public function create()
	{
		Reg.state = this;
		Reg.paused = false;
		Reg.time = 300; // Time limit for level

		gameCamera = new FlxCamera();
		displayCamera = new FlxCamera();

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(displayCamera);
		displayCamera.bgColor = FlxColor.TRANSPARENT;
		FlxCamera.defaultCameras = [gameCamera];

		player = new Player();
		items = new FlxTypedGroup<FlxSprite>();
		terrain = new FlxGroup();
		blocks = new FlxTypedGroup<FlxSprite>();
		enemies = new FlxTypedGroup<Enemy>();
		entities = new FlxGroup();
		display = new Display();
		display.setCamera(displayCamera);

		LevelLoader.loadLevel(this, "Level1");

		add(player);
		entities.add(items);
		entities.add(enemies);
		entities.add(blocks);
		terrain.add(map);
		terrain.add(blocks);
		add(entities);
		add(display);

		FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER);
		FlxG.camera.setScrollBoundsRect(0, 0, map.width, map.height, true);

		openSubState(new Intro(FlxColor.BLACK));

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		updateTime(elapsed);

		if (player.alive)
		{
			FlxG.overlap(entities, player, collideEntity);
			FlxG.collide(terrain, player);
		}

		FlxG.collide(terrain, entities);
		FlxG.collide(enemies, enemies);
	}

	function updateTime(elapsed:Float)
	{
		if (!Reg.paused)
		{
			if (Reg.time > 0)
			{
				Reg.time -= elapsed;
			}
			else
			{
				Reg.time = 0;
				player.kill();
			}
		}
	}

	function collideEntity(entity:FlxSprite, player:Player)
	{
		if (Std.is(entity, Coin))
		{
			(cast entity).collect();
		}

		if (Std.is(entity, Enemy))
		{
			(cast entity).interact(player);
		}

		if (Std.is(entity, BonusBlock))
		{
			(cast entity).hit(player);
		}

		if (Std.is(entity, PowerUp))
		{
			(cast entity).collect(player);
		}
	}
}
