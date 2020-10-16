/obj/item/stamp
	name = "\improper rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=60)
	item_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamped")
	var/stamp_color = "#1c4b28"

/obj/item/stamp/attack(mob/living/M, mob/living/user)
	. = ..()
	var/mob/living/carbon/human/H
	if(!istype(M, /mob/living/carbon/human) || !((range(1,get_turf(user))).Find(get_turf(M))))
		return

	H = M
	var/xoffset = 0
	var/yoffset = 0
	var/attackedSide //the stamp mark will appear on this side, NORTH = forwards, SOUTH = back, EAST = right, WEST = left

	switch(H.dir) 								//the side that faces the camera
		if(NORTH)
			attackedSide = SOUTH
		if(SOUTH)
			attackedSide = NORTH
		if(EAST)
			attackedSide = EAST
		if(WEST)
			attackedSide = WEST

	switch(user.zone_selected)					//Now we shift the mark to the area the attacker selects
		if("head")								//while appreciating the direction the victim is facing
			yoffset = rand(7, 12)
			switch(attackedSide)				//remember attackedSide is the side of the victim the stamp mark will show on
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = rand(-2, 2)
				if(WEST)
					xoffset = rand(-2, 2)
		if("chest")
			yoffset = rand(-1, 5)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = rand(1, 2)
				if(WEST)
					xoffset = rand(-1, -2)
		if("groin")
			yoffset = rand(-3, -7)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-3, 2)
				if(SOUTH)
					xoffset = rand(-3, 2)
				if(EAST)
					xoffset = 2
				if(WEST)
					xoffset = -2
		if("r_arm")
			yoffset = rand(-1, 4)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-8, -6)
				if(SOUTH)
					xoffset = rand(5, 7)
				if(EAST)
					xoffset = rand(-4, -2)
				if(WEST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //the west side of the right arm is not visible
		if("r_hand")
			yoffset = rand(-5, -2)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-8, -6)
				if(SOUTH)
					xoffset = rand(5, 7)
				if(EAST)
					xoffset = rand(-3, -1)
				if(WEST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
		if("l_arm")
			yoffset = rand(-1, 4)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(5, 7)
				if(SOUTH)
					xoffset = rand(-8, -6)
				if(EAST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
				if(WEST)
					xoffset = rand(2, 4)
		if("l_hand")
			yoffset = rand(-5, -2)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(5, 7)
				if(SOUTH)
					xoffset = rand(-8, -6)
				if(EAST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
				if(WEST)
					xoffset = rand(1, 3)
		if("r_leg")
			yoffset = rand(-12, -7)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-5, -2)
				if(SOUTH)
					xoffset = rand(1, 4)
				if(EAST)
					xoffset = rand(-2, 1)
				if(WEST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
		if("r_foot")
			yoffset = rand(-15, -14)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(-6, -2)
				if(SOUTH)
					xoffset = rand(1, 5)
				if(EAST)
					xoffset = rand(-3, 3)
				if(WEST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
		if("l_leg")
			yoffset = rand(-12, -7)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(1, 4)
				if(SOUTH)
					xoffset = rand(-5, -2)
				if(EAST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
				if(WEST)
					xoffset = rand(-1, 2)
		if("l_foot")
			yoffset = rand(-12, -7)
			switch(attackedSide)
				if(NORTH)
					xoffset = rand(1, 5)
				if(SOUTH)
					xoffset = rand(-6, -2)
				if(EAST)
					to_chat(user, "<span class ='notice'>You cannot reach!</span>")
					return //not visible
				if(WEST)
					xoffset = rand(-3, 2)
		else
			return			//no stamping eyes or mouths

	var/icon/new_stamp_mark = icon('icons/effects/stamp_marks.dmi', "stamp[rand(1,3)]_[attackedSide]")
	new_stamp_mark.Shift(EAST, xoffset)
	new_stamp_mark.Shift(NORTH, yoffset)
	new_stamp_mark.Blend(getFlatIcon(H), BLEND_MULTIPLY)
	var/image/stamp_image = image(new_stamp_mark)
	stamp_image.text = icon_state
	stamp_image.color = stamp_color
	H.ink_marks += stamp_image
	H.update_ink()

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return OXYLOSS

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"
	stamp_color = "#B88F3D"

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"
	stamp_color = "#CC0000"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	stamp_color = "#1F66A0"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"
	stamp_color = "#2A79AD"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"
	stamp_color = "#BA0505"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"
	stamp_color = "#CC9900"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"
	stamp_color = "#D9D9D9"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "medical"
	stamp_color = "#48FEFE"

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	item_color = "qm"
	stamp_color = "#339900"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"
	stamp_color = "#990000"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_color = "#FF66CC"

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcom"
	stamp_color = "#009900"

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_color = "#7B0101"

