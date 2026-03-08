@tool
extends EditorPlugin

# Constants
const SETTINGS_PATH = "res://addons/build_version_manager/record.json"
const EXPORT_PLUGIN_PATH = "res://addons/build_version_manager/build_version_export.gd"
const DOCK_SCENE_PATH = "res://addons/build_version_manager/build_version_manager_dock.tscn"
const UPDATE_INTERVAL_MS = 2000


# Runtime properties
var dock
var export_plugin
var versions: Array = [get_default_version()]
var last_json_string = ""
var update_timer = 0
var versions_dirty = true

# Lifecycle Methods
func _enter_tree():
	add_autoload_singleton("BuildVersion", "res://addons/build_version_manager/BuildVersion.gd")
	
	var BuildVersionExportPlugin = preload(EXPORT_PLUGIN_PATH)
	export_plugin = BuildVersionExportPlugin.new()
	export_plugin.BuildVersionManager = self
	add_export_plugin(export_plugin)
	
	scene_saved.connect(_on_scene_saved)

	dock = preload(DOCK_SCENE_PATH).instantiate()
	dock.BuildVersionManager = self
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)

	_load_version_data()

func _exit_tree():
	remove_control_from_docks(dock)
	remove_autoload_singleton("BuildVersion")
	remove_export_plugin(export_plugin)
	dock.free()

func _process(delta):
	if not Engine.is_editor_hint():
		return

	if not versions_dirty and Time.get_ticks_msec() < update_timer:
		return

	versions_dirty = false
	update_timer = Time.get_ticks_msec() + UPDATE_INTERVAL_MS

	var json_string = JSON.stringify(versions)
	if json_string == last_json_string:
		return

	ProjectSettings.set_setting("application/config/version", versions[-1])
	ProjectSettings.save()

	dock.update()
	last_json_string = json_string
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	file.store_line(json_string)

# Version History I/O
func _load_version_data():
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		while file.get_position() < file.get_length():
			var json_string = file.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result != OK:
				push_warning("JSON Parse Error: %s in %s at line %d" % [
					json.get_error_message(), json_string, json.get_error_line()
				])
				continue

			versions = json.get_data()

	if versions.is_empty() or versions == [null]:
		reset_version_history()

func reset_version_history():
	versions = [get_default_version()]
	versions_dirty = true

# Versioning Logic
func increment_version(increment_type: String, friendly_name: String = "") -> void:
	if versions.is_empty():
		versions.append(get_default_version())

	var last = versions[-1]
	var new_version := {
		"major": last.get("major", 0),
		"minor": last.get("minor", 0),
		"sub": last.get("sub", 0),
		"friendly_name": "",
		"release_timestamp": Time.get_unix_time_from_system()
	}

	match increment_type:
		"major":
			new_version["major"] += 1
			new_version["minor"] = 0
			new_version["sub"] = 0
		"minor":
			new_version["minor"] += 1
			new_version["sub"] = 0
		"sub":
			new_version["sub"] += 1
		_:
			push_error("Invalid increment type: %s" % increment_type)
			return

	new_version["friendly_name"] = (
		friendly_name if friendly_name != "" else _generate_friendly_name()
	)

	versions.append(new_version)
	versions_dirty = true

# Utility Methods
func get_default_version() -> Dictionary:
	return {
		"major": 0,
		"minor": 0,
		"sub": 0,
		"friendly_name": _generate_friendly_name(),
		"release_timestamp": Time.get_unix_time_from_system()
	}

func get_readable_time(timestamp: int) -> String:
	var datetime = Time.get_datetime_dict_from_unix_time(timestamp)
	return "%02d/%02d/%02d %02d:%02d" % [
		datetime.day, datetime.month, datetime.year % 100,
		datetime.hour, datetime.minute
	]

func _generate_friendly_name() -> String:
	var used_names := versions.map(func(v): return v.get("friendly_name"))
	for attempt in range(20):
		var name = "%s%s" % [
			adjectives[randi() % adjectives.size()],
			nouns[randi() % nouns.size()]
		]
		if name not in used_names:
			return name

	push_warning("Could not generate unique name after 20 attempts.")
	return "Unnamed Version %d" % Time.get_unix_time_from_system()

# Signal Callbacks
func _on_scene_saved(filepath: String) -> void:
	if dock.increment_on_save():
		increment_version("sub")

func _on_project_exported():
	if dock.increment_on_export():
		increment_version("sub")


const adjectives = [
"Abiding","Ablaze","Advancing","Aerial","Aged","Ancient","Arcane","Ardent","Ascending","Ashen",
"Awaiting","Balanced","Bearing","Bending","Bleak","Blended","Blowing","Blue","Bound","Braced",
"Braving","Bright","Brisk","Broad","Bronze","Building","Calm","Calling","Carried","Carrying",
"Cast","Celestial","Charted","Circling","Clear","Climbing","Cold","Coming","Constant","Coursing",
"Crossing","Dark","Dawnlit","Deep","Delving","Descending","Distant","Dividing","Drifting","Driving",
"Dying","Earnest","Eastern","Ebbing","Echoing","Endless","Enduring","Entering","Even","Fading",
"Far","Fastening","Filling","Firm","Fixed","Flowing","Foaming","Following","Forged","Forward",
"Found","Gathering","Gilded","Gliding","Glimmering","Glooming","Going","Golden","Gray","Great",
"Guiding","Hardened","Hidden","Holding","Hollow","Hushed","Illuming","Inching","Inner","Iron",
"Joining","Keeping","Kindling","Known","Lasting","Leading","Leaning","Lingering","Living","Lone",
"Long","Looking","Lost","Lowering","Luminous","Marked","Measuring","Mending","Midnight","Mild",
"Misty","Moored","Moving","Muted","Narrow","Near","Northern","Noted","Obscure","Old",
"Opening","Outer","Passing","Patient","Perilous","Plain","Poised","Polished","Pressing","Quiet",
"Ranging","Raising","Ready","Reaching","Rising","Rolling","Rough","Roving","Running","Salted",
"Sanded","Scarred","Sealed","Seeking","Sent","Settled","Shaded","Shaping","Sharp","Shifting",
"Shining","Silent","Silver","Solemn","Sounding","Spanning","Steady","Steering","Still","Stirring",
"Stony","Stranded","Strong","Subtle","Sweeping","Swift","Tending","Turning","Timeless","Traveling",
"True","Unbroken","Unending","Unfolding","Unseen","Untaken","Unworn","Vast","Veiled","Waking",
"Wandering","Watching","Weathered","Western","Widening","Windborne","Windward","Worn","Yielding","Adventuring",
"Arriving","Assembling","Attuned","Awakening","Balancing","Beating","Beckoning","Belaying","Binding","Bleached",
"Blending","Blown","Bordering","Bringing","Broadening","Burnished","Carving","Casting","Centering","Chasing",
"Choosing","Clearing","Closing","Coiling","Cooling","Crowning","Curving","Cutting","Daring","Dawning",
"Deepening","Defining","Departing","Deriving","Dimming","Drawing","Dressing","Dulling","Easing","Edging",
"Emerging","Endowing","Enfolding","Equaling","Escaping","Evening","Exposing","Extending","Facing","Falling",
"Feeding","Finding","Fitting","Fixing","Flaring","Flattening","Fleeting","Floating","Folding","Forming",
"Framing","Giving","Glowing","Gracing","Grasping","Grounding","Hardening","Honoring","Inclining","Inhering",
"Judging","Landing","Laying","Leaving","Lifting","Lighting","Linking","Lofting","Maintaining","Marking",
"Meeting","Moistening","Naming","Nearing","Ordering","Placing","Poising","Proving","Reading","Refining",
"Releasing","Remaining","Resolving","Resting","Rounding","Saving","Seasoning","Setting","Sharing","Showing",
"Standing","Striking","Studying","Uniting","Unsealing","Uplifting","Valuing","Warding","Weighing","Wending",
"Winding","Working","Answering","Attending","Beholding","Borne","Chiseled","Chosen","Clad","Cloaked",
"Clothed","Compelled","Cooled","Cresting","Crowned","Cured","Directed","Drawn","Draped","Earned",
"Enshrined","Etched","Famed","Fashioned","Favored","Finished","Formed","Guarded","Hallowed","Held",
"Hewn","Inscribed","Kept","Laid","Lifted","Locked","Maintained","Measured","Molded","Ordered",
"Prepared","Raised","Ranked","Recorded","Refined","Reinforced","Rendered","Respected","Seated","Shaped",
"Shielded","Signed","Smoothed","Strengthened","Structured","Tempered","Tested","Threaded","Trimmed","Trusted",
"Upheld","Verified","Weighted","Wrought"
];

const nouns = [
"Abyss","Anchorage","Anchor","Arch","Arsenal","Atoll","Backwater","Bank","Bar","Basin",
"Beacon","Beam","Bight","Breakwater","Brine","Brink","Bulkhead","Buoy","Cable","Cape",
"Causeway","Channel","Chart","Cistern","Cliff","Coast","Compass","Confluence","Cordage","Cove",
"Crag","Current","Deep","Delta","Depth","Dock","Domain","Downfall","Downreach","Drift",
"Dune","Edge","Embankment","Entrance","Estuary","Expanse","Fathom","Fleet","Flow","Foam",
"Ford","Foreland","Fortress","Gale","Gate","Gulf","Gutter","Harbor","Haven","Headland",
"Horizon","Inlet","Island","Jetty","Keel","Lagoon","Landing","Latitude","Ledger","Ledge",
"Light","Lighthouse","Line","Lookout","Main","Marina","Meridian","Mooring","Narrows","Needle",
"North","Notch","Ocean","Offing","Outfall","Outpost","Passage","Path","Pier","Pillar",
"Plank","Point","Port","Reach","Reef","Reserve","Ridge","Roadstead","Rock","Route",
"Sail","Salt","Sand","Scarp","Sea","Seaboard","Seaway","Sector","Shelf","Shell",
"Shoal","Shore","Sound","Spire","Spur","Stack","Station","Stone","Strait","Stronghold",
"Summit","Surf","Survey","Tide","Tideland","Tombolo","Tower","Trace","Track","Trench",
"Tributary","Turn","Underway","Vault","Watch","Water","Waypoint","Wind","Yard","Zone",
"Abutment","Approach","Armory","Artery","Ascent","Barrow","Beaconlight","Bench","Bend","Block",
"Border","Breach","Break","Bridge","Brinkland","Cause","Center","Chamber","Chartroom","Circle",
"Cisternhall","Clasp","Climb","Closure","Column","Command","Compassroom","Conduit","Contour","Course",
"Cover","Crest","Crown","Cut","Deepwater","Defile","Divide","Dockyard","Downway","Driftway",
"Edgewater","Entry","Escarpment","Field","Flag","Floor","Fold","Forecourt","Foredeck","Fork",
"Front","Gatehouse","Ground","Guardpost","Guide","Hall","Harborwall","Head","Highland","Hold",
"Ingress","Innerreach","Isle","Jettyhead","Junction","Key","Landfall","Landmark","Lane","Lineage",
"Lock","Look","Lowerreach","March","Mark","Measure","Midreach","Mile","Moat","Mount",
"Mouth","Narrowsgate","Node","Northreach","Notchway","Opening","Outlook","Overlook","Pass","Passageway",
"Pathmark","Pillarhall","Place","Plain","Platform","Pointreach","Portal","Post","Promontory","Quay",
"Quoin","Rampart","Range","Redoubt","Refuge","Rest","Rise","Rivergate","Road","Roost",
"Round","Row","Ruin","Saltway","Sanctum","Seat","Seawall","Section","Sentinel","Set",
"Shaft","Shelfway","Signal","Site","Slip","Sounding","Span","Spindrift","Spoke","Spurway",
"Stand","Stationhall","Step","Stockade","Strand","Strongpoint","Surveyor","Table","Terrace","Threshold",
"Tidegate","Tier","Top","Towerhall","Traceway","Transit","Traverse","Turnway","Underpass","Union",
"Upperreach","Vaultway","Verge","Vesselway","View","Walk","Wall","Watchpost","Waterline","Waypoint",
"Westreach","Wharf","Windline","Windward","Work","Yardarm","Zonehead"
];

#const adjectives = [
#"Ancient","Amber","Arctic","Ashen","Azure","Balanced","Beaming","Bold","Bright","Brisk",
#"Calm","Candid","Carefree","Celestial","Charmed","Cheery","Chill","Clear","Cloudy","Cool",
#"Cosmic","Crafted","Crisp","Crystal","Daring","Dawn","Deep","Delicate","Distant","Divine",
#"Dreamy","Dusky","Early","Earthy","Electric","Elegant","Emerald","Endless","Epic","Even",
#"Fabled","Fair","Faint","Fancy","Far","Feathered","Fiery","Firm","Floral","Fluid",
#"Flying","Foggy","Forest","Fresh","Frozen","Full","Gentle","Giant","Glassy","Gleaming",
#"Golden","Grand","Grassy","Great","Green","Hidden","High","Hollow","Honest","Horizon",
#"Icy","Ideal","Infinite","Iron","Jade","Jolly","Jovial","Joyful","Kind","Kinetic",
#"Lively","Light","Lime","Liquid","Lone","Long","Lost","Lucky","Lunar","Lush",
#"Magic","Majestic","Mellow","Merry","Metal","Mighty","Mild","Mint","Modern","Morning",
#"Mossy","Mystic","Narrow","Natural","Neat","Nimble","Noble","Northern","Odd","Open",
#"Orange","Outer","Pale","Peaceful","Perfect","Pine","Playful","Polished","Prime","Proud",
#"Pure","Quick","Quiet","Radiant","Rapid","Rare","Ready","Red","Refined","Rich",
#"Rising","Robust","Rocky","Royal","Sacred","Sandy","Serene","Shaded","Sharp","Shimmering",
#"Shiny","Silent","Silver","Simple","Sincere","Sky","Sleek","Smooth","Soft","Solar",
#"Solid","Sparkling","Spiral","Spring","Stable","Starry","Steady","Steel","Stone","Stormy",
#"Strong","Subtle","Sudden","Summer","Sunny","Swift","Tall","Tender","Thin","Thunder",
#"Tiny","True","Twilight","Unified","Urban","Vast","Velvet","Verdant","Vivid","Warm",
#"Watery","Wild","Windy","Wise","Witty","Wooden","Young","Zesty","Zonal","Zippy",
#"Aerial","Agile","Airy","Alpine","Ancient","Ardent","Atomic","Autumn","Azure","Bare",
#"Basic","Blazing","Blooming","Blue","Blunt","Bold","Breezy","Bronze","Burnished","Calm",
#"Centered","Charming","Clean","Clever","Cold","Collected","Cosy","Curious","Daily","Dapper",
#"Dark","Dazzling","Decent","Dense","Desert","Direct","Dramatic","Dry","Dual","Dune",
#"Dynamic","Earnest","Eastern","Easy","Echoing","Elastic","Electric","Elite","Empty","Enchanted",
#"Equal","Eternal","Evening","Exact","Exotic","Fair","Faithful","Famous","Fast","Fertile",
#"Final","Fine","Firm","First","Fluent","Flying","Focused","Formal","Free","Friendly",
#"Full","Funky","Future","Galactic","General","Global","Glorious","Grand","Grave","Gray",
#"Great","Green","Grim","Groovy","Handy","Happy","Hardy","Harmless","Hasty","Hazy",
#"Healthy","Heavy","Heroic","Hidden","Hollow","Holy","Honest","Hot","Human","Humble",
#"Hungry","Hybrid","Ideal","Idle","Immense","Inner","Instant","Intense","Iron","Ivory",
#"Jagged","Jazzy","Joint","Jolly","Juicy","Keen","Kindly","Knotted","Known","Lanky",
#"Large","Late","Lazy","Lean","Legal","Level","Light","Linear","Little","Local"
#]
#const nouns = [
#"Abyss","Anchor","Anvil","Arch","Arena","Ash","Aspen","Atlas","Aurora","Avalanche",
#"Badger","Basin","Bay","Beacon","Beetle","Birch","Blaze","Bluff","Bloom","Boulder",
#"Branch","Breeze","Brook","Burrow","Canyon","Cape","Cavern","Cedar","Chamber","Channel",
#"Charm","Cliff","Cloud","Coast","Comet","Compass","Coral","Cosmos","Cove","Crater",
#"Creek","Crest","Crystal","Current","Cypress","Dagger","Dawn","Delta","Desert","Drift",
#"Dune","Dunes","Dust","Eagle","Echo","Ember","Estuary","Falcon","Feather","Field",
#"Firefly","Flame","Flint","Flower","Fog","Forest","Forge","Fort","Frost","Galaxy",
#"Garden","Gate","Geyser","Glacier","Glade","Glen","Glow","Granite","Grove","Harbor",
#"Harmony","Haven","Hawk","Heights","Hill","Hollow","Horizon","Iceberg","Island","Jade",
#"Jungle","Keystone","Lagoon","Lake","Lantern","Leaf","Ledge","Lightning","Lily","Lotus",
#"Marble","Marsh","Meadow","Mesa","Meteor","Mist","Moon","Mountain","Nebula","Nest",
#"Nova","Oak","Oasis","Ocean","Orbit","Orchid","Peak","Pebble","Phoenix","Pillar",
#"Pine","Plain","Planet","Plateau","Pond","Prairie","Quartz","Quill","Rain","Range",
#"Raven","Reef","Resin","Ridge","River","Rock","Root","Ruby","Sage","Sand",
#"Sapphire","Sea","Shadow","Shore","Shrine","Sky","Slate","Snow","Solstice","Spark",
#"Spire","Spring","Star","Stone","Storm","Stream","Summit","Sun","Sylvan","Temple",
#"Thicket","Thorn","Thunder","Tide","Topaz","Torch","Trail","Tree","Tundra","Vale",
#"Valley","Velvet","Vine","Vista","Volcano","Wave","Well","Whale","Willow","Wind",
#"Wing","Wolf","Wood","World","Zenith",
#"Acorn","Aerie","Alcove","Amber","Amulet","Antler","Archway","Ashfall","Aurora","Backwater",
#"Bamboo","Barrow","Bastion","Bayou","Beech","Bell","Beryl","Blossom","Bog","Bolt",
#"Bonfire","Bracken","Bramble","Breach","Briar","Bridge","Brooklet","Cairn","Canopy","Cascade",
#"Causeway","Cavern","Cedarwood","Chasm","Cinder","Citadel","Clay","Cliffside","Cluster","Comet",
#"Copse","Crescent","Crossing","Crown","Current","Cypress","Dale","Dawnlight","Deep","Dell",
#"Den","Dew","Domain","Dragonfly","Drizzle","Dusk","Earth","Eddy","Elm","Emberfall",
#"Estuary","Evergreen","Fable","Fathom","Fen","Fern","Fjord","Flare","Flora","Flux",
#"Foam","Ford","Forge","Fountain","Furrow","Galaxy","Gale","Gardenia","Gatehouse","Glimmer",
#"Gorge","Grain","Gust","Harborlight","Hearth","Heath","Helix","Henge","Heron","Holloway",
#"Isle","Jetty","Junction","Knoll","Lagoon","Lantern","Lattice","Laurel","Lighthouse","Loam",
#"Lookout","Lumen","Mangrove","Meadowland","Meridian","Mirage","Monolith","Moonbeam","Moor",
#"Moss","Needle","Nimbus","North","Oxbow","Palm","Paragon","Passage","Pathway","Pebble",
#"Perch","Petal","Pinnacle","Pond","Pool","Prairie","Promontory","Quarry","Quasar","Rainfall",
#"Ravine","Reach","Redwood","Refuge","Ripple","Roost","Runestone","Sanctum","Sedge","Serpent",
#"Shadowfall","Shelter","Shoal","Signal","Skyline","Song","Spiral","Starfall","Stillwater",
#"Stonework","Sunrise","Swale","Talon","Terrace","Thicket","Timber","Torchlight","Torrent",
#"Trill","Turn","Underpass","Updraft","Vale","Vapor","Verge","Vortex","Warden","Waterfall",
#"Waypoint","Wetland","Whisper","Wildwood","Windfall","Woodland","Wreath"
#]
