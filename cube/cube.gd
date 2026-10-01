@tool

extends MeshInstance3D

@export var cube_size: float = 1.0
var cube_mesh : ArrayMesh

@export var width: int = 4
@export var height: int = 16
@export var depth: int = 4

@export var atlas_texture: Texture2D
@export var atlas_cols: int = 4
@export var atlas_rows: int = 4

var voxels = []
var rng := RandomNumberGenerator.new()

const FACE_TOP := 0
const FACE_BOTTOM := 1
const FACE_SIDE := 2

const BLOCKS := {
	0: { "name": "air", "solid": false, "tiles": { FACE_TOP: Vector2i(0, 0), FACE_BOTTOM: Vector2i(0, 0), FACE_SIDE: Vector2i(0, 0) }},
	1: { "name": "water", "solid": false, "tiles": { FACE_TOP: Vector2i(1, 0), FACE_BOTTOM: Vector2i(1, 0), FACE_SIDE: Vector2i(1, 0) }},
	2: { "name": "grass", "solid": true, "tiles": { FACE_TOP: Vector2i(0, 0), FACE_BOTTOM: Vector2i(2, 0), FACE_SIDE: Vector2i(2, 0) }},
	3: { "name": "stone", "solid": true, "tiles": { FACE_TOP: Vector2i(0, 1), FACE_BOTTOM: Vector2i(0, 1), FACE_SIDE: Vector2i(0, 1) }},
	4: { "name": "ice", "solid": true, "tiles": { FACE_TOP: Vector2i(1, 1), FACE_BOTTOM: Vector2i(1, 1), FACE_SIDE: Vector2i(1, 1) }},
	5: { "name": "snow", "solid": true, "tiles": { FACE_TOP: Vector2i(1, 2), FACE_BOTTOM: Vector2i(1, 2), FACE_SIDE: Vector2i(1, 2) }},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	voxels = generate_voxels()
	generate_mesh(voxels)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = atlas_texture
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material_override = mat

func generate_mesh(voxels):
	var faces = []
	
	for x in range(voxels.size()):
		for y in range(voxels[x].size()):
			for z in range(voxels[x][y].size()):
				var block_id: int = voxels[x][y][z]
				if block_id == 0:
					continue

				if voxels[x][y][z] != 0:
					var position = Vector3(x, y, z) * cube_size
					if x == 0 or voxels[x-1][y][z] == 0:
						var t := block_tile_for_face(block_id, Vector3.LEFT)
						faces.append(create_face(Vector3.LEFT, position, get_tile_uvs(t.x, t.y)))
						
					if x == voxels.size() - 1 or voxels[x+1][y][z] == 0:
						var t := block_tile_for_face(block_id, Vector3.RIGHT)
						faces.append(create_face(Vector3.RIGHT, position, get_tile_uvs(t.x, t.y)))
						
					if y == 0 or voxels[x][y - 1][z] == 0:
						var t := block_tile_for_face(block_id, Vector3.DOWN)
						faces.append(create_face(Vector3.DOWN, position, get_tile_uvs(t.x, t.y)))
						
					if y == voxels[x].size() - 1 or voxels[x][y + 1][z] == 0:
						var t := block_tile_for_face(block_id, Vector3.UP)
						faces.append(create_face(Vector3.UP, position, get_tile_uvs(t.x, t.y)))
						
					if z == 0 or voxels[x][y][z - 1] == 0:
						var t := block_tile_for_face(block_id, Vector3.FORWARD)
						faces.append(create_face(Vector3.FORWARD, position, get_tile_uvs(t.x, t.y)))
						
					if z == voxels[x][y].size() - 1 or voxels[x][y][z + 1] == 0:
						var t := block_tile_for_face(block_id, Vector3.BACK)
						faces.append(create_face(Vector3.BACK, position, get_tile_uvs(t.x, t.y)))
	var vertices = []
	var normals = []
	var uvs = []
	
	for face in faces:
		vertices += face["vertices"]
		normals += face["normals"]
		uvs += face["uvs"]
	
	var vertex_array = PackedVector3Array(vertices)
	var normal_array = PackedVector3Array(normals)
	var uv_array = PackedVector2Array(uvs)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	
	cube_mesh = ArrayMesh.new()
	
	cube_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = cube_mesh

func generate_voxels() -> Array:
	rng.randomize()
	
	var array = []
	array.resize(width)
	
	for x in width:
		array[x] = []
		array[x].resize(height)
		
		for y in height:
			array[x][y] = []
			array[x][y].resize(depth)

	for x in width:
		for y in height:
			for z in depth:
				array[x][y][z] = rng.randi_range(0,5)

	return array

func create_face(direction: Vector3, position: Vector3, uv_coords: Array) -> Dictionary:
	var vertices = []
	var normals = []
	var uvs = []
	normals.resize(4)
	
	match direction:
		Vector3.UP:
			vertices = [
				position + Vector3(-0.5, 0.5, -0.5) * cube_size,
				position + Vector3( 0.5, 0.5, -0.5) * cube_size,
				position + Vector3( 0.5, 0.5,  0.5) * cube_size,
				position + Vector3(-0.5, 0.5,  0.5) * cube_size,
			]
			normals.fill(Vector3.UP)
			uvs = uv_coords
			
		Vector3.DOWN: 
			vertices = [
				position + Vector3(-0.5, -0.5, -0.5) * cube_size,
				position + Vector3( 0.5, -0.5, -0.5) * cube_size,
				position + Vector3( 0.5, -0.5,  0.5) * cube_size,
				position + Vector3(-0.5, -0.5,  0.5) * cube_size,
			]
			normals.fill(Vector3.DOWN)
			uvs = uv_coords
		Vector3.LEFT:
			vertices = [
				position + Vector3(-0.5, -0.5, -0.5) * cube_size,
				position + Vector3(-0.5,  0.5, -0.5) * cube_size,
				position + Vector3(-0.5,  0.5,  0.5) * cube_size,
				position + Vector3(-0.5, -0.5,  0.5) * cube_size
			]
			normals.fill(Vector3.LEFT)
			uvs = uv_coords
		Vector3.RIGHT:
			vertices = [
				position + Vector3(0.5, -0.5,  0.5) * cube_size,
				position + Vector3(0.5,  0.5,  0.5) * cube_size,
				position + Vector3(0.5,  0.5, -0.5) * cube_size,
				position + Vector3(0.5, -0.5, -0.5) * cube_size
			]
			normals.fill(Vector3.RIGHT)
			uvs = uv_coords
		Vector3.BACK:
			vertices = [
				position + Vector3(-0.5,  0.5, 0.5) * cube_size,
				position + Vector3( 0.5,  0.5, 0.5) * cube_size,
				position + Vector3( 0.5, -0.5, 0.5) * cube_size,
				position + Vector3(-0.5, -0.5, 0.5) * cube_size
			]
			normals.fill(Vector3.BACK)
			uvs = uv_coords
		Vector3.FORWARD:
			vertices = [
				position + Vector3(-0.5, -0.5, -0.5) * cube_size,
				position + Vector3( 0.5, -0.5, -0.5) * cube_size,
				position + Vector3( 0.5,  0.5, -0.5) * cube_size,
				position + Vector3(-0.5,  0.5, -0.5) * cube_size
			]
			normals.fill(Vector3.FORWARD)
			uvs = uv_coords
	return {
		"vertices" : [
			vertices[0], vertices[1], vertices[2],
			vertices[0], vertices[2], vertices[3]
		],
		"normals" : [
			normals[0], normals[1], normals[2],
			normals[0], normals[2], normals[3]
		],
		"uvs" : [
			uvs[0], uvs[1], uvs[2],
			uvs[0], uvs[2], uvs[3]
		]
	}

func block_tile_for_face(block_id: int, face_dir: Vector3) -> Vector2i:
	var block = BLOCKS.get(block_id, BLOCKS[0])
	var tiles = block["tiles"]
	
	if face_dir == Vector3.UP:
		return tiles[FACE_TOP]
	elif face_dir == Vector3.DOWN:
		return tiles[FACE_BOTTOM]
	else:
		return tiles[FACE_SIDE]

func get_tile_uvs(tile_x: int, tile_y:int) -> Array:
	var tex_w := float(atlas_texture.get_width())
	var tex_h := float(atlas_texture.get_height())
	
	var tile_w_px := tex_w / float(atlas_cols)
	var tile_h_px := tex_h / float(atlas_rows)
	
	var u0 := (tile_x * tile_w_px) / tex_w
	var v0 := (tile_y * tile_h_px) / tex_h
	var u1 := ((tile_x + 1) * tile_w_px) / tex_w
	var v1 := ((tile_y + 1) * tile_w_px) / tex_w
	
	return [
		Vector2(u0, v1),
		Vector2(u1, v1),
		Vector2(u1, v0),
		Vector2(u0, v0),
	]
	
