/*
	These are simple defaults for your project.
 */

var/global/player_saves_root = "../../VOREStation/data/player_saves/"
var/global/debugging = FALSE

/world
	tick_lag = 0.1
	icon_size = 32	// 32x32 icon size by default

/world/New()
	if(length(world.params) > 0)
		for(var/thing in world.params)
			if(thing == "player_saves_root")
				player_saves_root = trim(world.params[thing])

	if(!fexists(player_saves_root))
		world.log << "ERROR: Player Saves Folder '[player_saves_root]' not found!"
		world.log << "Specify which folder to use as a world startup parameter 'player_saves_root'"
		world.log << "For example: DreamDaemon -trusted -params player_saves_root=../data/player_saves"
		shutdown()
		return

	// List all files in player_saves dir.  It is a hashed directory structure so these will be just single letters
	world.log << "Searching for player saves in [player_saves_root]"
	var/list/player_save_dirs = enumerate_player_savedirs()
	for(var/save_dir in player_save_dirs)
		// export_save_file_txt(save_dir)
		convert_vore_prefs(save_dir)
		sleep(1*world.tick_lag)
	shutdown()

/proc/convert_vore_prefs(var/save_dir)
	var/savefile/S = new("[save_dir]preferences.sav")
	if(!S)
		world.log << "WARN: [save_dir]preferences.sav does not exist"
		return
	if(debugging)	world.log << "Opened [save_dir]preferences.sav"

	for(var/chardir in S.dir)
		if(copytext(chardir, 1, 10) != "character")
			continue // Not a save dir
		S.cd = "/[chardir]"

		var/digestable = TRUE
		var/allowmobvore = TRUE
		var/list/belly_prefs = list()
		var/vore_taste = "nothing in particular"
		var/can_be_drop_prey = FALSE
		var/can_be_drop_pred = FALSE
		// Now load the things!
		S["digestable"] >> digestable
		S["allowmobvore"] >> allowmobvore
		S["belly_prefs"] >> belly_prefs
		S["vore_taste"] >> vore_taste
		S["can_be_drop_prey"] >> can_be_drop_prey
		S["can_be_drop_pred"] >> can_be_drop_pred
		if(debugging)	world.log << "Now processing [S.name]:[S.cd] - belly_prefs.len = [length(belly_prefs)]"

		// CONVERT BELLY PREFS FROM DATUM TO OBJECTS
		var/list/belly_objects = list()
		for(var/belly_name in belly_prefs)
			var/datum/belly/BD = belly_prefs[belly_name]
			if(!istype(BD))
				world.log << "Thats odd, [chardir] has a belly_prefs entry ([belly_name]) that is [BD] ([BD.type])"
				continue
			world.log << "Converting [chardir] belly [belly_name] to /obj/belly"
			var/obj/belly/new_belly = new(null)
			BD.copy(new_belly)
			belly_objects += new_belly

		// CREATE vore preferences datum to save
		var/datum/vore_preferences/VP = new()
		VP.path = "[save_dir]vore/[chardir].json"
		VP.digestable = digestable
		VP.allowmobvore = allowmobvore
		VP.vore_taste = vore_taste
		VP.can_be_drop_prey = can_be_drop_prey
		VP.can_be_drop_pred = can_be_drop_pred
		VP.belly_prefs = list()

		var/list/serialized = list()
		for(var/belly in belly_objects)
			var/obj/belly/B = belly
			serialized += list(B.serialize()) //Can't add a list as an object to another list in Byond. Thanks.
		VP.belly_prefs = serialized

		world.log << "Saving [VP.path]"
		VP.save_vore()


/proc/export_save_file_txt(var/save_dir)
	var/savefile/SF = new("[save_dir]/preferences.sav")
	var/txtfile = file("[save_dir]/preferences.txt")
	fdel(txtfile)
	SF.ExportText("/", txtfile)

/proc/enumerate_player_savedirs()
	. = list()
	var/list/hashDirs = flist(player_saves_root)
	for(var/hashDirName in hashDirs)
		for(var/ckeyDir in flist("[player_saves_root][hashDirName]"))
			if(copytext(ckeyDir, -1) == "/")
				. += "[player_saves_root][hashDirName][ckeyDir]"

/proc/islist(list/list)
	return(istype(list))

/proc/log_debug(text)
	world.log << text
	world << text

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)
	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))
