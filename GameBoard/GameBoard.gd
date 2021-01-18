extends Node2D

# Tiles id
onready var earth_id = $Map.tile_set.find_tile_by_name("Earth")
onready var water_id = $Map.tile_set.find_tile_by_name("Water")
onready var one_id = $Map.tile_set.find_tile_by_name("One")
onready var two_id = $Map.tile_set.find_tile_by_name("Two")
onready var three_id = $Map.tile_set.find_tile_by_name("Three")
onready var four_id = $Map.tile_set.find_tile_by_name("Four")
onready var five_id = $Map.tile_set.find_tile_by_name("Five")
onready var six_id = $Map.tile_set.find_tile_by_name("Six")
onready var seven_id = $Map.tile_set.find_tile_by_name("Seven")
onready var eight_id = $Map.tile_set.find_tile_by_name("Eight")
onready var nine_id = $Map.tile_set.find_tile_by_name("Nine")
onready var flag_id = $Map.tile_set.find_tile_by_name("Flag")
onready var mine_id = $Map.tile_set.find_tile_by_name("Mine")

enum State{
	GAME,
	WIN,
	LOSE
}

enum Field{
	HIDDEN,
	VISIBLE,
	FLAG
}

# Procent of mines on level
export(float, 0.1, 0.9) var procent_of_mines = 0.1

# Current game state
var state = State.GAME

# Star drawing tilemap from half of grid size
var center_grid = Vector2.ZERO

# Mouse position offset
var mouse_pos_offset = Vector2.ZERO

# grid map
var grid = []

# map of visible field at grid
var grid_visibility = []

# Amount of visible fields, use at checking win
var visible_fields_amount = 0 setget setVisibleFieldsAmount

# Size grid of level
var size = Vector2.ZERO

# Flags
var flags = 0 setget setFlags

# Used flags
var used_flags = 0

# First click on Tile Set -> Prepare game
var start = true

# Neigbours relative position
const neighbours = [Vector2(-1, -1), Vector2(-1, 0), 
					Vector2(-1, 1), Vector2(0, 1),
					Vector2(1, 1), Vector2(1, 0), 
					Vector2(1, -1), Vector2(0, -1)]
					

# Signals
signal win_game
signal lose_game


 # Invoke: prepare_level, grid_initialize and draw
func _ready():
	set_level()
	grid_initialize()
	draw()


# Handle input (if cell of tilemap was clicked)
func _input(event):
	# If current state is GAME
	if state == State.GAME:
		if event is InputEventMouseButton:
			# Left button clicked
			if event.button_index == BUTTON_LEFT and event.pressed:
				var cell = $Map.world_to_map(event.position - mouse_pos_offset)
				# If cell is in grid
				if (cell.x >= 0 and cell.x < size.x and 
					cell.y >= 0 and cell.y < size.y):
					# If it's first click -> start game
					if start:
						start(cell.x, cell.y)
						start = false
					# Invoke: click
					click(cell.x, cell.y)
					draw()
					
			# Right button clicked (and game was started)
			if event.button_index == BUTTON_RIGHT and event.pressed and not start:
				var cell = $Map.world_to_map(event.position - mouse_pos_offset)
				# If cell is in grid
				if (cell.x >= 0 and cell.x < size.x and 
					cell.y >= 0 and cell.y < size.y):
					# Invoke: setFlag
					setFlag(cell.x, cell.y)
					draw()


# Set level (size, minesize, center_grid)
func set_level():
	# EASY LEVEL
	if Settings.level == Settings.Level.EASY:
		size = Vector2(10, 10)
		center_grid = Vector2(5, 5)

	# NORMAL LEVEL
	elif Settings.level == Settings.Level.NORMAL:
		size = Vector2(16, 14)
		center_grid = Vector2(8, 7)

	# HARD LEVEL
	elif Settings.level == Settings.Level.HARD:
		size = Vector2(22, 20)
		center_grid = Vector2(11, 10)
	
	mouse_pos_offset = Vector2(
			position.x - center_grid.x * $Map.cell_size.x, 
			position.y - center_grid.y * $Map.cell_size.y
			)
	flags = int(size.x * size.y * procent_of_mines)


# First click generate grid
func start(x: int, y: int):
	grid_make(x, y)


# Invoke: grid_set_mines(and set_mines), prin_prepare and printGrind(console print grid)
func grid_make(x: int, y: int):
	grid_set_mines(set_mines(x, y))
	grid_prepare()


# Set grid and grid_visibility on default value(create array 2d)
func grid_initialize():
	for x in range(0, size.x):
		grid.append([])
		grid_visibility.append([])
		for y in range(0, size.y):
			grid[x].append(0)
			grid_visibility[x].append(Field.HIDDEN)


#Set mines in grid(-1 value) from mines
func grid_set_mines(mines):
	for x in range(0, size.x):
		for y in range(0, size.y):
			if Vector2(x,y) in mines:
				grid[x][y] = -1


# generate mines
func set_mines(start_x: int, start_y: int):
	var rng = RandomNumberGenerator.new() # RNG
	var mines = [] # Position of mines
	var amount_mines = int(size.x * size.y * procent_of_mines) # Max mines
	var randend = 0 # Randend position of mines
	while randend < amount_mines:
		var x = rng.randi() % int(size.x)
		var y = rng.randi() % int(size.y)
		# If position is not in mines and isn't start position, add to mines
		if not Vector2(x,y) in mines and x != start_x and y != start_y:
			mines.append(Vector2(x,y))
			randend += 1
	return mines


# set amount of mines near field
func grid_prepare():
	for x in range(0, size.x):
		for y in range(0, size.y):
			if grid[x][y] != -1: # if field is not mine
				var amount = 0
				for neighbour in neighbours: # count mines at neighbours
					var pos = Vector2(x + neighbour.x, y + neighbour.y)
					if (pos.x >= 0 and pos.x < size.x and 
						pos.y >= 0 and pos.y < size.y):
							if grid[pos.x][pos.y] == -1:
								amount += 1
				grid[x][y] = amount


func click(x: int, y: int):
	if grid_visibility[x][y] == Field.HIDDEN:
		var visited = [] # Visited fields
		var open = [Vector2(x, y)] # Fields to check
		while not open.empty():
			var visit = open[0] # Get visit
			visited.append(visit) # Add visit to visited
			open.remove(0) # Remove visit from open
			
			if grid_visibility[visit.x][visit.y] == Field.HIDDEN:
				grid_visibility[visit.x][visit.y] = Field.VISIBLE # Set field to visible
				visible_fields_amount += 1
				
			if grid[visit.x][visit.y] == -1: # If this field is mine, set state on LOSE
				state = State.LOSE
				emit_signal("lose_game")
			else:
				for neighbour in neighbours: # check neigbours
					var pos = Vector2(visit.x  + neighbour.x, visit.y + neighbour.y)
					if (pos.x >= 0 and pos.x < size.x and 
						pos.y >= 0 and pos.y < size.y):
						if grid_visibility[pos.x][pos.y] == Field.HIDDEN:
							# If neighbour is not mine and visit is empty field
							# Set neighbour on visible
							if (grid[pos.x][pos.y] != -1 and
								grid[visit.x][visit.y] == 0):
									grid_visibility[pos.x][pos.y] = Field.VISIBLE
									visible_fields_amount += 1
							# If neighbour is empty, add to open list
							if grid[pos.x][pos.y] == 0:
								if not pos in open and not pos in visited:
									open.append(pos)
								
				# Check if you won
				check_win()


func setFlag(x: int, y: int):
	if grid_visibility[x][y] == Field.HIDDEN:
		grid_visibility[x][y] = Field.FLAG
		used_flags += 1
	elif grid_visibility[x][y] == Field.FLAG:
		grid_visibility[x][y] = Field.HIDDEN
		used_flags -= 1


# Check win condition
func check_win():
	if visible_fields_amount == (size.x * size.y) - flags:
		state = State.WIN
		emit_signal("win_game")


# Invoke setTile method for all field at grid
func draw():
	for x in range(0, size.x):
		for y in range(0, size.y):
			setTile(x, y)


# Set tile in grid position x and y
func setTile(x: int, y: int):
	if grid_visibility[x][y] == Field.VISIBLE:
		if grid[x][y] == -1:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, mine_id)
		elif grid[x][y] == 0:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, water_id)
		elif grid[x][y] == 1:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, one_id)
		elif grid[x][y] == 2:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, two_id)
		elif grid[x][y] == 3:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, three_id)
		elif grid[x][y] == 4:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, four_id)
		elif grid[x][y] == 5:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, five_id)
		elif grid[x][y] == 6:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, six_id)
		elif grid[x][y] == 7:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, seven_id)
		elif grid[x][y] == 8:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, eight_id)
		elif grid[x][y] == 9:
			$Map.set_cell(x - center_grid.x, y - center_grid.y, nine_id)
	elif grid_visibility[x][y] == Field.HIDDEN:
		$Map.set_cell(x - center_grid.x, y - center_grid.y, earth_id)
	else:
		$Map.set_cell(x - center_grid.x, y - center_grid.y, flag_id)


func setFlags(value):
	flags = value
	
	
func setVisibleFieldsAmount(value):
	visible_fields_amount = value
