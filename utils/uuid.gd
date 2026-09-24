extends Node
class_name UuidUtil            # Makes it visible in the editor & code

# ------------------------------------------------------------------
# Public API ---------------------------------------------------------
# ------------------------------------------------------------------

## Return a new RFC‑4122 UUID string (e.g. "3f8b9c6a-4c1e-4f8d-b7aa-e5b0d1c2f3d4")
static func uuid() -> String:
	# 16 random bytes
	var bytes = _get_random_bytes(16)

	# Set the version (0100) in byte 6
	bytes[6] = (bytes[6] & 0x0F) | 0x40

	# Set the variant (10xx) in byte 8
	bytes[8] = (bytes[8] & 0x3F) | 0x80

	var hex_bytes : PackedStringArray = []
	for b in bytes:
		hex_bytes.append("%02x" % b)

	return "%s-%s-%s-%s-%s" % [
		"".join(hex_bytes.slice(0, 4)),
		"".join(hex_bytes.slice(4, 6)),
		"".join(hex_bytes.slice(6, 8)),
		"".join(hex_bytes.slice(8,10)),
		"".join(hex_bytes.slice(10,16))
	]
# ------------------------------------------------------------------
# Optional helpers ----------------------------------------------------
# ------------------------------------------------------------------
static func _get_random_bytes(count : int) -> PackedByteArray:
	var rng = RandomNumberGenerator.new()
	rng.randomize()          # Seed with entropy
	var arr : Array = []
	for i in range(count):
		arr.append(rng.randi_range(0, 255))
	return PackedByteArray(arr)
