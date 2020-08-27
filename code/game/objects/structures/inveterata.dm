/obj/structure/inveterata
	icon = 'icons/mob/inveterata.dmi'
	max_integrity = 100

/obj/structure/inveterata/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee")
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 0.25
	. = ..()

/obj/structure/inveterata/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/*
 * mycelium
 */

#define NODERANGE 6

/obj/structure/inveterata/mycelium
	gender = PLURAL
	name = "mycelium"
	desc = "A thick mycelium covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "no name"
	max_integrity = 15
	level = 1
	var/obj/structure/inveterata/mycelium/node/linked_node = null

/obj/structure/inveterata/mycelium/New(loc, node)
	..()
	var/turf/T = get_turf(src)   //code to hide under floor tiles if they exist
	if(level == 1)
		hide(T.intact)

	linked_node = node

	if(istype(loc, /turf/space))
		qdel(src)
		return

	fullUpdateMyceliumOverlays()
	Life()

/obj/structure/inveterata/mycelium/Destroy()
	fullUpdateMyceliumOverlays()
	linked_node = null
	return ..()

/obj/structure/inveterata/mycelium/proc/Life()
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space))   //mycelium cant spread onto space
		fullUpdateMyceliumOverlays()
		qdel(src)
		return

	if(!linked_node || linked_node == null)  //mycelium needs a node or else die
		fullUpdateMyceliumOverlays()
		addtimer(CALLBACK(src, .proc/qdel, src), 100)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())     //checks ajacent turfs if they can be spread to and tells their node
		if(!locate(/obj/structure/inveterata/mycelium) in T && !istype(T, /turf/space))
			if(get_dist(linked_node, T) <= linked_node.node_range)
				linked_node.updateSpreadList(T)



/obj/structure/inveterata/mycelium/hide()
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = INVISIBILITY_OBSERVER //ghosts gotta see the infestation too you know.
	else
		invisibility = 0

#define NORTH_ADJOIN var/list(TRUE, FALSE, FALSE, FALSE)
#define SOUTH_ADJOIN var/list(FALSE, TRUE, FALSE, FALSE)
#define EAST_ADJOIN var/list(FALSE, FALSE, TRUE, FALSE)
#define WEST_ADJOIN var/list(FALSE, FALSE, FALSE, TRUE)

#define NORTH_EAST_ADJOIN var/list(TRUE, FALSE, TRUE, FALSE)
#define NORTH_WEST_ADJOIN var/list(TRUE, FALSE, FALSE, TRUE)
#define SOUTH_EAST_ADJOIN var/list(FALSE, TRUE, TRUE, FALSE)
#define SOUTH_WEST_ADJOIN var/list(FALSE, TRUE, FALSE, TRUE)

#define NORTH_EAST_WEST_ADJOIN var/list(TRUE, FALSE, TRUE, FALSE)
#define SOUTH_EAST_WEST_ADJOIN var/list(TRUE, FALSE, FALSE, TRUE)
#define EAST_NORTH_SOUTH_ADJOIN var/list(FALSE, TRUE, TRUE, FALSE)
#define WEST_NORTH_SOUTH_ADJOIN var/list(FALSE, TRUE, FALSE, TRUE)

#define ALLSIDES_ADJOIN var/list(FALSE, TRUE, FALSE, TRUE)

/obj/structure/inveterata/mycelium/proc/updateMyceliumOverlays()

	var/turf/N = get_step(src, NORTH)
	var/turf/S = get_step(src, SOUTH)
	var/turf/E = get_step(src, EAST)
	var/turf/W = get_step(src, WEST)
	var/list/neighbors = new /list(FALSE, FALSE, FALSE, FALSE) //this will store values to be compared against to determine what sprite states to use.

	overlays.Cut()

	if(locate(/obj/structure/inveterata/mycelium) in N)
		neighbors[1] = TRUE
	if(locate(/obj/structure/inveterata/mycelium) in S)
		neighbors[2] = TRUE
	if(locate(/obj/structure/inveterata/mycelium) in E)
		neighbors[3] = TRUE
	if(locate(/obj/structure/inveterata/mycelium) in W)
		neighbors[4] = TRUE

	if(neighbors == )

	overlays += pick(image('icons/mob/inveterata.dmi', "mycelium", layer=2.11), image('icons/mob/inveterata.dmi', "mycelium_alt", layer=2.11))


/obj/structure/inveterata/mycelium/proc/fullUpdateMyceliumOverlays()
	for(var/obj/structure/inveterata/mycelium/W in range(1,src))
		W.updateMyceliumOverlays()

//Mycelium nodes

/obj/structure/inveterata/mycelium/node
	name = "mycelium node"
	desc = "The mycelium seems to be spreading from this."
	icon_state = "mycelium_node"
	light_range = 1
	var/node_range = NODERANGE
	var/list/spread_buffer =  new /list(0)

/obj/structure/inveterata/mycelium/node/proc/updateSpreadList(var/turf/target)
	spread_buffer += target
	addtimer(CALLBACK(src, .proc/spread), 100)

/obj/structure/inveterata/mycelium/node/proc/spread()
	if(spread_buffer.len)
		for(var/turf/target in spread_buffer)
			if(!locate(/obj/structure/inveterata/mycelium) in target)
				new /obj/structure/inveterata/mycelium(target, linked_node)
				spread_buffer -= target
			else
				spread_buffer -= target
		for(var/obj/structure/inveterata/mycelium/imbuetarget in range(node_range, src))
			imbuetarget.Life()



/obj/structure/inveterata/mycelium/node/New()
	..(loc, src)

/obj/structure/inveterata/mycelium/node/updateMyceliumOverlays()
	return


#undef NODERANGE
