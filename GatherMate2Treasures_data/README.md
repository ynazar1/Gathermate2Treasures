# Gathermate2Treasures_data

This contains data for all the treasures in Dragonflight that give rep tokens as of 10.0.2 patch.
I've excluded pure resouce caches and herbs as they are of no interest
I've also also excluded the 3 weekly chests as there's only one location that each can spawn. 

I *STRONGLY* encourage to use filtering options and filter out dirt and explorer packs unless you're actively searching for them, they are so densely packed in some areas they cover everything else on the map

Magic-bound chests and dirt are also invisible unless you have the reputation, but they do show up on the minimap as a treasure icon... The chests and caches are untracked on the map thus the need for data

# Installation

Copy The contents of the TreasureData.lua file into GatherMate2TreasuresTreasureDB section of GatherMate2Treasures.lua file under WTF folder... 

```
GatherMate2TreasuresTreasureDB = {
	[2022] = {
		[1500944000] = 566,
		[1500944001] = 567,
....
....

		[6690582001] = 567,
	},
}
```
