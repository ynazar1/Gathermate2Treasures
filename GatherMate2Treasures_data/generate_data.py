#!/usr/bin/env python3
import requests
import re
import json
from dataclasses import dataclass
import typing
import math


@dataclass
class WowheadObject:
    name: str
    ids: typing.List[str]
    coordinates: dict
    gathermate_id: str
    url_part: str = "object"

    def __init__(self, name: str, ids: typing.List[str], gathermate_id: str):
        self.name = name
        self.ids = ids
        self.coordinates = dict()
        self.gathermate_id = gathermate_id

        for object_id in self.ids:
            result = requests.get(f'https://wowhead.com/{self.url_part}={object_id}')
            data = re.search(r'var g_mapperData = (.*);', result.text)
            try:
                data_parsed = json.loads(data.group(1))
            except AttributeError:
                print(f"No locations for {object_id} ({self.name})")
                continue
            for zone in data_parsed:
                wow_zone = WOWHEAD_ZONE_MAP.get(zone)
                if wow_zone is None:
                    print(f"Found unlisted zone: {zone}")
                    continue
                coords = list()
                for coord in data_parsed[zone][0]["coords"]:
                    coords.append(Coordinate(coord[0], coord[1]))
                if self.coordinates.get(wow_zone) is None:
                    self.coordinates[wow_zone] = coords
                else:
                    self.coordinates[wow_zone] += coords
        print(f"Finished processing {self.name}")


class WowheadNpc(WowheadObject):
    url_part: str = "npc"


@dataclass(eq=True, frozen=True)
class Zone:
    name: str
    id: str


@dataclass
class Coordinate:
    x: float
    y: float
    coord: int = 0

    def __repr__(self):
        return str(self.as_gatherer_coord())

    def as_gatherer_coord(self):
        if self.coord == 0:
          self.coord = math.floor((self.x/100)*10000+0.5)*1000000+math.floor((self.y/100)*10000+0.5)*100
        return self.coord


@dataclass
class GathererEntry:
    coordinate: Coordinate
    entry_id: str

    def __repr__(self):
        return f"		[{self.coordinate}] = {self.entry_id},"

    def __lt__(self, other):
        return self.coordinate.as_gatherer_coord() < other.coordinate.as_gatherer_coord()


@dataclass
class GathererZone:
    zone: Zone
    entries: typing.List[GathererEntry]

    def __repr__(self):
        output = f'	[{self.zone.id}] = {{\n'
        for entry in sorted(self.entries):
            output += f'{str(entry)}\n'
        output += '	},\n'
        return output

    def __lt__(self, other):
        return int(self.zone.id) < int(other.zone.id)


@dataclass
class Aggregate:
    type: str
    zones: typing.List[GathererZone]

    def __init__(self, type, objects):
        self.type = type
        self.zones = []
        for object in objects:
            for zone in object.coordinates:
                for coord in object.coordinates[zone]:
                    self.add(zone, GathererEntry(coord, object.gathermate_id))

    def __repr__(self):
        output = f"GatherMateData2{self.type}DB = {{\n"
        for zone in sorted(self.zones):
            output += f'{str(zone)}'
        output += '}'
        return output

    def add(self, zone: Zone, entry: GathererEntry):
        for gatherer_zone in self.zones:
            if gatherer_zone.zone == zone:
                while entry.coordinate in [x.coordinate for x in gatherer_zone.entries]:
                  entry.coordinate.coord = entry.coordinate.as_gatherer_coord() + 1
                gatherer_zone.entries.append(entry)
                return
        self.zones.append(GathererZone(zone, [entry]))


# key is zone id as it appears in wowhead
# GathererEntry is the id from `/dump C_Map.GetBestMapForUnit("player");` while in the zone
WOWHEAD_ZONE_MAP = {
    '13644': Zone("The Waking Shores", "2022"),
    '13645': Zone("Ohn'ahran Plains", "2023"),
    '13646': Zone("The Azure Span", "2024"),
    '13647': Zone("Thaldraszus", "2025"),
}

# Objects in comments have no locations, typically inside instances
# They are removed to speed up the script
HERBS = [
]

ORES = [
]

TREASURES = [
    WowheadObject(name="Expedition Scout's Pack", ids=['376587'], gathermate_id='566'),
    WowheadObject(name="Disturbed Dirt", ids=['376587'], gathermate_id='567'),
    WowheadObject(name="Magic-Bound Chest", ids=['376426', '385074', '385075'], gathermate_id='568'),
    WowheadObject(name="Clan Chest", ids=['376581'], gathermate_id='569'),
    WowheadObject(name="Decay Covered Chest", ids=['376583'], gathermate_id='570'),
    WowheadObject(name="Djaradin Cache", ids=['376580'], gathermate_id='571'),
    WowheadObject(name="Dracthyr Supply Chest", ids=['376584'], gathermate_id='572'),
    WowheadObject(name="Frostbound Chest", ids=['381041'], gathermate_id='573'),
    WowheadObject(name="Ice Bound Chest", ids=['377540'], gathermate_id='574'),
    WowheadObject(name="Icemaw Storage Cache", ids=['376585'], gathermate_id='575'),
    WowheadObject(name="Lightning Bound Chest", ids=['381043'], gathermate_id='576'),
    WowheadObject(name="Molten Chest", ids=['377587'], gathermate_id='577'),
    WowheadObject(name="Nomad Cache", ids=['376036'], gathermate_id='578'),
    WowheadObject(name="Reed Chest", ids=['376579'], gathermate_id='579'),
    WowheadObject(name="Simmering Chest", ids=['381042'], gathermate_id='580'),
    WowheadObject(name="Titan Chest", ids=['376578'], gathermate_id='581'),
    WowheadObject(name="Tuskarr Chest", ids=['376582'], gathermate_id='582'),
]

# Fishing pools have no locations on wowhead
FISHES = [
]

GASES = [
]

if __name__ == '__main__':
    with open("GatherMate2_Data/HerbalismData.lua", "w") as file:
        print(Aggregate("Herb", HERBS), file=file)
    with open("GatherMate2_Data/MiningData.lua", "w") as file:
        print(Aggregate("Mine", ORES), file=file)
    with open("GatherMate2_Data/TreasureData.lua", "w") as file:
        print(Aggregate("Treasure", TREASURES), file=file)
    with open("GatherMate2_Data/FishData.lua", "w") as file:
        print(Aggregate("Fish", FISHES), file=file)
    with open("GatherMate2_Data/GasData.lua", "w") as file:
        print(Aggregate("Gas", GASES), file=file)
