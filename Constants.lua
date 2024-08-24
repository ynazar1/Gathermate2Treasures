--[[
	Below are constants needed for DB storage and retrieval
	The core of gathermate handles adding new node that collector finds
	data shared between Collector and Display also live in GatherMate for sharing like zone_data for sizes, and node ids with reverses for display and comparison
	Credit to Astrolabe (http://www.gathereraddon.com) for lookup tables used in GatherMate. Astrolabe is licensed LGPL
]]
local GatherMateTreasures = LibStub("AceAddon-3.0"):GetAddon("GatherMate2Treasures")
local NL = LibStub("AceLocale-3.0"):GetLocale("GatherMate2TreasuresNodes",true)
local L = LibStub("AceLocale-3.0"):GetLocale("GatherMate2Treasures")

--[[
	Node Identifiers
]]
local node_ids = {
	["Fishing"] = {
	},
	["Mining"] = {
	},
	["Extract Gas"] = {
	},
	["Herb Gathering"] = {
	},
	["Treasure"] = {
		-- Dragonflight
		[NL["Expedition Scout's Pack"]]			= 566,
		[NL["Disturbed Dirt"]]					= 567,
		[NL["Magic-Bound Chest"]]				= 568,
		[NL["Clan Chest"]]						= 569,
		[NL["Decay Covered Chest"]]				= 570,
		[NL["Djaradin Cache"]]					= 571,
		[NL["Dracthyr Supply Chest"]]			= 572,
		[NL["Frostbound Chest"]]				= 573,
		[NL["Ice Bound Chest"]]					= 574,
		[NL["Icemaw Storage Cache"]]			= 575,
		[NL["Lightning Bound Chest"]]			= 576,
		[NL["Molten Chest"]]					= 577,
		[NL["Nomad Cache"]]						= 578,
		[NL["Reed Chest"]]						= 579,
		[NL["Simmering Chest"]]					= 580,
		[NL["Titan Chest"]]						= 581,
		[NL["Tuskarr Chest"]]					= 582,
	},
	["Archaeology"] = {
	},
	["Logging"] = {
	},
}
GatherMateTreasures.nodeIDs = node_ids
local reverse = {}
for k,v in pairs(node_ids) do
	reverse[k] = GatherMateTreasures:CreateReversedTable(v)
end
GatherMateTreasures.reverseNodeIDs = reverse
-- Special fix because "Battered Chest" (502) and "Tattered Chest" (503) both translate to "Ramponierte Truhe" in deDE
if GetLocale() == "deDE" then GatherMateTreasures.reverseNodeIDs["Treasure"][502] = "Ramponierte Truhe" end

--[[
	Collector data for rare spawn determination
]]
local Collector = GatherMateTreasures:GetModule("Collector")
--[[
	Rare spawns are formatted as such the rareid = [nodes it replaces]
]]
local rare_spawns = {
}
GatherMateTreasures.rareNodes = rare_spawns
Collector.rareNodes = rare_spawns
-- Format zone = { "Database", "new node id"}
local nodeRemap = {
}
Collector.specials = nodeRemap
--[[
	Below are Display Module Constants
]]
local Display = GatherMateTreasures:GetModule("Display")
local icon_path = "Interface\\AddOns\\GatherMate2Treasures\\Artwork\\"
Display.trackingCircle = icon_path.."track_circle.tga"
-- Find xxx spells
Display:SetTrackingSpell("Mining", 2580)
Display:SetTrackingSpell("Herb Gathering", 2383)
Display:SetTrackingSpell("Fishing", 43308)
Display:SetTrackingSpell("Treasure", 2481) -- Left this in, however it appears that the spell no longer exists. Maybe added as a potion TreasureFindingPotion
Display:SetTrackingSpell("Logging", 167924)
-- Profession markers
Display:SetSkillProfession("Herb Gathering", L["Herbalism"])
Display:SetSkillProfession("Mining", L["Mining"])
Display:SetSkillProfession("Fishing", L["Fishing"])
Display:SetSkillProfession("Extract Gas", L["Engineering"])
Display:SetSkillProfession("Archaeology", L["Archaeology"])

--[[
	Textures for display
]]
local node_textures = {
	["Fishing"] = {
	},
	["Mining"] = {
	},
	["Extract Gas"] = {
	},
	["Herb Gathering"] = {
	},
	["Treasure"] = {
		-- DF
		[566] = icon_path.."Treasure\\footlocker.tga",
		[567] = icon_path.."Treasure\\dirt.tga",
		[568] = icon_path.."Treasure\\chest.tga",
		[569] = icon_path.."Treasure\\treasure.tga",
		[570] = icon_path.."Treasure\\treasure.tga",
		[571] = icon_path.."Treasure\\treasure.tga",
		[572] = icon_path.."Treasure\\treasure.tga",
		[573] = icon_path.."Treasure\\treasure.tga",
		[574] = icon_path.."Treasure\\treasure.tga",
		[575] = icon_path.."Treasure\\treasure.tga",
		[576] = icon_path.."Treasure\\treasure.tga",
		[577] = icon_path.."Treasure\\treasure.tga",
		[578] = icon_path.."Treasure\\treasure.tga",
		[579] = icon_path.."Treasure\\treasure.tga",
		[580] = icon_path.."Treasure\\treasure.tga",
		[581] = icon_path.."Treasure\\treasure.tga",
		[582] = icon_path.."Treasure\\treasure.tga",
	},
	["Archaeology"] = {
	},
	["Logging"] = {
	},
}
GatherMateTreasures.nodeTextures = node_textures

local CLASSIC = 1
local BC      = 2
local WRATH   = 3
local CATA    = 4
local MOP     = 5
local WOD     = 6
local LEGION  = 7
local BFA     = 8
local SL      = 9
local DF      = 10
local TWW     = 11
local node_expansion = {
	["Mining"] = {
	},
	["Herb Gathering"] = {
	},
}
GatherMateTreasures.nodeExpansion = node_expansion

--[[
	Minimap scale settings for zoom
]]
local minimap_size = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}
Display.minimapSize = minimap_size
--[[
	Minimap shapes lookup table to determine round of not
	borrowed from strolobe for faster lookups
]]
local minimap_shapes = {
	-- { upper-left, lower-left, upper-right, lower-right }
	["SQUARE"]                = { false, false, false, false },
	["CORNER-TOPLEFT"]        = { true,  false, false, false },
	["CORNER-TOPRIGHT"]       = { false, false, true,  false },
	["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
	["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
	["SIDE-LEFT"]             = { true,  true,  false, false },
	["SIDE-RIGHT"]            = { false, false, true,  true },
	["SIDE-TOP"]              = { true,  false, true,  false },
	["SIDE-BOTTOM"]           = { false, true,  false, true },
	["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
	["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}
Display.minimapShapes = minimap_shapes

local map_phasing = {
}

GatherMateTreasures.phasing = map_phasing

local map_blacklist = {
	[582] = true, -- Alliance Garrison
	[590] = true, -- Horde Garrison
}

GatherMateTreasures.mapBlacklist = map_blacklist
