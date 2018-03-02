
/*
VVVVVVVV           VVVVVVVV     OOOOOOOOO     RRRRRRRRRRRRRRRRR   EEEEEEEEEEEEEEEEEEEEEE
V::::::V           V::::::V   OO:::::::::OO   R::::::::::::::::R  E::::::::::::::::::::E
V::::::V           V::::::V OO:::::::::::::OO R::::::RRRRRR:::::R E::::::::::::::::::::E
V::::::V           V::::::VO:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEEE::::E
 V:::::V           V:::::V O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
  V:::::V         V:::::V  O:::::O     O:::::O  R::::R     R:::::R  E:::::E
   V:::::V       V:::::V   O:::::O     O:::::O  R::::RRRRRR:::::R   E::::::EEEEEEEEEE
    V:::::V     V:::::V    O:::::O     O:::::O  R:::::::::::::RR    E:::::::::::::::E
     V:::::V   V:::::V     O:::::O     O:::::O  R::::RRRRRR:::::R   E:::::::::::::::E
      V:::::V V:::::V      O:::::O     O:::::O  R::::R     R:::::R  E::::::EEEEEEEEEE
       V:::::V:::::V       O:::::O     O:::::O  R::::R     R:::::R  E:::::E
        V:::::::::V        O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
         V:::::::V         O:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEE:::::E
          V:::::V           OO:::::::::::::OO R::::::R     R:::::RE::::::::::::::::::::E
           V:::V              OO:::::::::OO   R::::::R     R:::::RE::::::::::::::::::::E
            VVV                 OOOOOOOOO     RRRRRRRR     RRRRRRREEEEEEEEEEEEEEEEEEEEEE

-Aro <3 */

/datum/vore_preferences
	//Actual preferences
	var/digestable = TRUE
	var/allowmobvore = TRUE
	var/list/belly_prefs = list()
	var/vore_taste = "nothing in particular"
	var/can_be_drop_prey = FALSE
	var/can_be_drop_pred = FALSE

	//Mechanically required
	var/path

/datum/vore_preferences/proc/save_vore()
	if(!path)				return 0
	
	var/version = 1	//For "good times" use in the future
	var/list/settings_list = list(
			"version"				= version,
			"digestable"			= digestable,
			"allowmobvore"			= allowmobvore,
			"vore_taste"			= vore_taste,
			"can_be_drop_prey"		= can_be_drop_prey,
			"can_be_drop_pred"		= can_be_drop_pred,
			"belly_prefs"			= belly_prefs,
		)

	//List to JSON
	var/json_to_file = json_encode(settings_list)
	if(!json_to_file)
		log_debug("Saving: [path] failed jsonencode")
		return 0
	
	//Write it out
	if(fexists(path))
		fdel(path) //Byond only supports APPENDING to files, not replacing.
	text2file(json_to_file,path)
	if(!fexists(path))
		log_debug("Saving: [path] failed file write")
		return 0

	return 1
