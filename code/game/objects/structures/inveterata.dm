#define MYCELIUM_NORTH_EDGING "north"
#define MYCELIUM_SOUTH_EDGING "south"
#define MYCELIUM_EAST_EDGING "east"
#define MYCELIUM_WEST_EDGING "west"

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
 * Mycelium
 */
 /*
/obj/structure/inveterata/mycelium
	name = "mycelium"
	desc = "Looks like some kind of space mycelium."
	icon = 'icons/obj/smooth_structures/inveterata/mycelium_wall.dmi'
	icon_state = "mycelium"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	canSmoothWith = list(/obj/structure/inveterata/mycelium)
	max_integrity = 200
	smooth = SMOOTH_TRUE
	var/myceliumtype = null

/obj/structure/inveterata/mycelium/Initialize()
	air_update_turf(1)
	..()

/obj/structure/inveterata/mycelium/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/inveterata/mycelium/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/inveterata/mycelium/CanAtmosPass()
	return !density

/obj/structure/inveterata/mycelium/wall
	name = "mycelium wall"
	desc = "Thick mycelium solidified into a wall."
	icon = 'icons/obj/smooth_structures/inveterata/mycelium_wall.dmi'
	icon_state = "wall"	//same as mycelium, but consistency ho!
	myceliumtype = "wall"
	canSmoothWith = list(/obj/structure/inveterata/mycelium/wall,
	 /obj/structure/inveterata/mycelium/membrane)

/obj/structure/inveterata/mycelium/wall/BlockSuperconductivity()
	return 1

/obj/structure/inveterata/mycelium/membrane
	name = "mycelium membrane"
	desc = "mycelium just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/inveterata/mycelium_membrane.dmi'
	icon_state = "membrane"
	opacity = 0
	max_integrity = 160
	myceliumtype = "membrane"
	canSmoothWith = list(/obj/structure/inveterata
/mycelium/wall, /obj/structure/inveterata
/mycelium/membrane)

/obj/structure/inveterata/mycelium/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density
*/

/*
 * mycelium
 */

#define NODERANGE 2

/obj/structure/inveterata/mycelium
	gender = PLURAL
	name = "mycelium"
	desc = "A thick mycelium covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "mycelium"
	max_integrity = 15
	var/obj/structure/inveterata/mycelium/node/linked_node = null
	var/static/list/myceliumImageCache


/obj/structure/inveterata/mycelium/New(pos, node)
	..()
	linked_node = node
	if(istype(loc, /turf/space))
		qdel(src)
		return
	if(!istype(src, /obj/structure/inveterata/mycelium/node))
		icon_state = pick("mycelium", "mycelium_alt")
	fullUpdateMyceliumOverlays()
	spawn(rand(150, 200))
		if(src)
			Life()

/obj/structure/inveterata/mycelium/Destroy()
	var/turf/T = loc
	for(var/obj/structure/inveterata/mycelium/W in range(1,T))
		W.updateMyceliumOverlays()
	linked_node = null
	return ..()

/obj/structure/inveterata/mycelium/proc/Life()
	var/turf/U = get_turf(src)

	if(istype(U, /turf/space))
		qdel(src)
		return

	if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
		if(!istype(src, /obj/structure/inveterata/mycelium/node))
			qdel(src)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())

		if(locate(/obj/structure/inveterata/mycelium) in T || istype(T, /turf/space))
			continue

		new /obj/structure/inveterata/mycelium(T, linked_node)

/obj/structure/inveterata/mycelium/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/inveterata/mycelium/proc/updateMyceliumOverlays()

	overlays.Cut()

	if(!myceliumImageCache || !myceliumImageCache.len)
		myceliumImageCache = list()
		myceliumImageCache.len = 4
		myceliumImageCache[MYCELIUM_NORTH_EDGING] = image('icons/mob/inveterata.dmi', "mycelium_edge_n", layer=2.11, pixel_y = -32)
		myceliumImageCache[MYCELIUM_SOUTH_EDGING] = image('icons/mob/inveterata.dmi', "mycelium_edge_s", layer=2.11, pixel_y = 32)
		myceliumImageCache[MYCELIUM_EAST_EDGING] = image('icons/mob/inveterata.dmi', "mycelium_edge_e", layer=2.11, pixel_x = -32)
		myceliumImageCache[MYCELIUM_WEST_EDGING] = image('icons/mob/inveterata.dmi', "mycelium_edge_w", layer=2.11, pixel_x = 32)

	var/turf/N = get_step(src, NORTH)
	var/turf/S = get_step(src, SOUTH)
	var/turf/E = get_step(src, EAST)
	var/turf/W = get_step(src, WEST)
	if(!locate(/obj/structure/inveterata) in N.contents)
		if(istype(N, /turf/simulated/floor))
			overlays += myceliumImageCache[MYCELIUM_SOUTH_EDGING]
	if(!locate(/obj/structure/inveterata) in S.contents)
		if(istype(S, /turf/simulated/floor))
			overlays += myceliumImageCache[MYCELIUM_NORTH_EDGING]
	if(!locate(/obj/structure/inveterata) in E.contents)
		if(istype(E, /turf/simulated/floor))
			overlays += myceliumImageCache[MYCELIUM_WEST_EDGING]
	if(!locate(/obj/structure/inveterata) in W.contents)
		if(istype(W, /turf/simulated/floor))
			overlays += myceliumImageCache[MYCELIUM_EAST_EDGING]


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

/obj/structure/inveterata/mycelium/node/New()
	..(loc, src)

#undef NODERANGE
#undef MYCELIUM_NORTH_EDGING
#undef MYCELIUM_SOUTH_EDGING
#undef MYCELIUM_EAST_EDGING
#undef MYCELIUM_WEST_EDGING
