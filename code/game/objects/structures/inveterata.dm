/obj/structure/inveterata
	icon = 'icons/mob/inveterata.dmi'
	max_integrity = 100

/obj/structure/inveterata/mycelium
	gender = PLURAL
	name = "mycelium"
	desc = "A dense growth of mycelium covering the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "mycelium"
	max_integrity = 30
	var/obj/structure/inveterata/mycelium/nucleus/linked_nucleus= null
	var/issurrounded = FALSE

/obj/structure/inveterata/mycelium/New(pos, nucleus)
	..()
	if(!istype(src, /obj/structure/inveterata/mycelium/nucleus))
		linked_nucleus = nucleus
	var/turf/currentturf = get_turf(src)
	if(icon_state == "mycelium")
		pick(icon_state = "mycelium", icon_state = "mycelium_alt")      //so sprites are not repetative
	if(linked_nucleus)
		linked_nucleus.addmyc(src)
	else qdel(src)							//mycelium needs a nucleus or die
	greaterUpdateMyceliumOverlays()

/obj/structure/inveterata/mycelium/Destroy()
	linked_nucleus.submyc(src)

	for(var/obj/structure/inveterata/mycelium/target in range(1,src))
		target.updateMyceliumOverlays()
		target.issurrounded = FALSE

	if(linked_nucleus.isstagnant == TRUE)
		linked_nucleus.restartSpread()
	return ..()

/obj/structure/inveterata/mycelium/proc/life()
	var/turf/currentturf = get_turf(src)
	if(linked_nucleus == null || linked_nucleus == 0 || istype(currentturf,  /turf/space))
		qdel(src)

/*
/obj/structure/inveterata/mycelium/proc/spreadCheck()
	var/turf/currentturf = get_turf(src)
	var/invalid = 0
	var/turf/N = get_step(currentturf, NORTH)
	var/turf/S = get_step(currentturf, SOUTH)
	var/turf/E = get_step(currentturf, EAST)
	var/turf/W = get_step(currentturf, WEST)
	var/list/spreaddirections = list(N, S, E, W)
	if(!issurrounded)
		for(var/turf/spreadtarget in spreaddirections)
			if(!locate(/obj/structure/inveterata/mycelium) in spreadtarget)
				if(!istype(spreadtarget, /turf/space))
					if(spreadtarget in range(linked_nucleus.spread_range, currentturf))
						linked_nucleus.updatecanidates(spreadtarget)
			invalid++
		if(invalid == 4)
			issurrounded = TRUE
			return FALSE
*/

/obj/structure/inveterata/mycelium/proc/updateMyceliumOverlays()

	overlays.Cut()

	var/turf/N = get_step(src, NORTH)
	var/turf/S = get_step(src, SOUTH)
	var/turf/E = get_step(src, EAST)
	var/turf/W = get_step(src, WEST)

	if(!locate(/obj/structure/inveterata) in N.contents)
		if(istype(N, /turf/simulated/floor))
			overlays += image('icons/mob/inveterata.dmi', "mycelium_north", layer=2.11, pixel_y = -32)
	if(!locate(/obj/structure/inveterata) in S.contents)
		if(istype(S, /turf/simulated/floor))
			overlays += image('icons/mob/inveterata.dmi', "mycelium_south", layer=2.11, pixel_y = 32)
	if(!locate(/obj/structure/inveterata) in E.contents)
		if(istype(E, /turf/simulated/floor))
			overlays += image('icons/mob/inveterata.dmi', "mycelium_east", layer=2.11, pixel_x = -32)
	if(!locate(/obj/structure/inveterata) in W.contents)
		if(istype(W, /turf/simulated/floor))
			overlays += image('icons/mob/inveterata.dmi', "mycelium_west", layer=2.11, pixel_x = 32)

/obj/structure/inveterata/mycelium/proc/greaterUpdateMyceliumOverlays()
	for(var/obj/structure/inveterata/mycelium/target in range(1,src))
		target.updateMyceliumOverlays()


/obj/structure/inveterata/mycelium/nucleus
	name = "Mycelium Nucleus"
	desc = "The mycelium appears to be spreading from this."
	icon_state =  "mycelium_nucleus"
	var/list/mycelium_children = list()
	var/list/mycelium_canidates = list()
	var/isstagnant = FALSE
	var/spread_range = 4

/obj/structure/inveterata/mycelium/nucleus/New()
	linked_nucleus = src //locate(/obj/structure/inveterata/mycelium/nucleus) in get_turf(src)
	..()
	spread()

/obj/structure/inveterata/mycelium/nucleus/Destroy()
	isstagnant = TRUE
	for(var/obj/structure/inveterata/mycelium/target in mycelium_children)
		target.linked_nucleus = null
		target.life()
	return..()



/obj/structure/inveterata/mycelium/nucleus/updateMyceliumOverlays()
	return

/obj/structure/inveterata/mycelium/nucleus/proc/addmyc(obj/input)
	if(istype(input, /obj/structure/inveterata/mycelium))
		mycelium_children += input
		return TRUE
	return FALSE

/obj/structure/inveterata/mycelium/nucleus/proc/submyc(obj/input)
	if(istype(input, /obj/structure/inveterata/mycelium))
		mycelium_children -= input
		return TRUE
	return FALSE

/obj/structure/inveterata/mycelium/nucleus/proc/updatecanidates(loc)
	if(loc in mycelium_canidates || locate(/obj/structure/inveterata) in loc)
		return
	mycelium_canidates += loc

/obj/structure/inveterata/mycelium/nucleus/proc/spread()
	if(isstagnant == TRUE)
		return
	/*for(var/obj/structure/inveterata/mycelium/target in mycelium_children)
		target.spreadCheck()
		target.updateMyceliumOverlays()
		target.life()

	if(mycelium_canidates.len == 0)
		isstagnant = TRUE

	for(var/turf/target in mycelium_canidates)
		if(target in range(spread_range, src))
			new /obj/structure/inveterata/mycelium(target, linked_nucleus)
			var/list/deletetarget = list(mycelium_canidates.Find(target))
			mycelium_canidates -= deletetarget */

	for(var/turf/target in range(spread_range, src))
		var/turf/N = get_step(target, NORTH)
		var/turf/S = get_step(target, SOUTH)
		var/turf/E = get_step(target, EAST)
		var/turf/W = get_step(target, WEST)
		var/list/spreadDirections = list(N, S, E, W)

		for(var/obj/structure/inveterata/mycelium/sourcemyc in target.contents)
			var/invalid = 0
			var/myccount = 0
			if(sourcemyc.linked_nucleus == src && !sourcemyc.issurrounded)
				myccount++
				if(myccount > 1)
					message_admins("something terrible has happened")
				for(var/turf/spreadtarget in spreadDirections)
					if(!locate(/obj/structure/inveterata) in spreadtarget.contents)
						addtimer(CALLBACK(src, .proc/createNewMycelium, spreadtarget), 10)
					else invalid++
				if(invalid == 4)
					sourcemyc.issurrounded = TRUE
			else if(sourcemyc.linked_nucleus == 0 || sourcemyc.linked_nucleus == null)
				sourcemyc.linked_nucleus = src

	addtimer(CALLBACK(src, .proc/spread), 100)


/obj/structure/inveterata/mycelium/nucleus/proc/createNewMycelium(loc)
	new /obj/structure/inveterata/mycelium(loc, linked_nucleus)

/obj/structure/inveterata/mycelium/nucleus/proc/restartSpread()
	isstagnant = FALSE
	addtimer(CALLBACK(src, .proc/spread), 100)
