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
	var/list/Timers = list()

/obj/structure/inveterata/mycelium/New(pos, nucleus, ctimer)
	..()
	if(ctimer != null)
		for(ctimer in Timers)
			Timers -= ctimer
	if(!istype(src, /obj/structure/inveterata/mycelium/nucleus))
		linked_nucleus = nucleus
	var/turf/currentturf = get_turf(src)
	if(icon_state == "mycelium")
		pick(icon_state = "mycelium", icon_state = "mycelium_alt")      //so sprites are not repetative
	if(linked_nucleus)
		linked_nucleus.addmyc(src)
	else Destroy()						//mycelium needs a nucleus or die
	greaterUpdateMyceliumOverlays()

/obj/structure/inveterata/mycelium/Destroy()
	if(linked_nucleus != null)
		linked_nucleus.submyc(src)
		if(linked_nucleus.isstagnant == TRUE)
			linked_nucleus.restartSpread()

	for(var/obj/structure/inveterata/mycelium/target in range(1,src))
		target.updateMyceliumOverlays()
		target.issurrounded = FALSE

	for(var/i=1, i<=Timers.len,i++)
		deltimer(Timers[i])
	return ..()

/obj/structure/inveterata/mycelium/proc/life()
	var/turf/currentturf = get_turf(src)
	if(linked_nucleus == null || linked_nucleus == 0 || istype(currentturf,  /turf/space))
		var/deleteTimer = addtimer(CALLBACK(src, .Destroy), rand(20, 200), TIMER_STOPPABLE)
		Timers += deleteTimer

/obj/structure/inveterata/mycelium/proc/updateMyceliumOverlays()
/*
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
*/

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
	var/spread_range = 2

/obj/structure/inveterata/mycelium/nucleus/New()
	linked_nucleus = src
	..()
	spread()

/obj/structure/inveterata/mycelium/nucleus/Destroy()
	..()
	for(var/obj/structure/inveterata/mycelium/target in mycelium_children)
		target.linked_nucleus = null
		target.life()
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
	for(var/i = 1, i <= mycelium_canidates.len, i++)
		if(/obj/structure/inveterata in mycelium_canidates[i]) 			// this really shouldnt be necessary but I am paranoid
			mycelium_canidates -= mycelium_canidates[i]
		if(loc == mycelium_canidates[i]) 								//this is acutally necessary, since I cant think of a way...
			return														//...that isnt stupid to check if a turf is already checked yet
	mycelium_canidates += loc

/obj/structure/inveterata/mycelium/nucleus/proc/spread()
	if(isstagnant == TRUE)
		return

	mycelium_canidates.Cut()
	mycelium_canidates += 0

	for(var/obj/structure/inveterata/mycelium/sourcemyc in range(spread_range, src))
		var/turf/N = NORTH_OF_TURF(sourcemyc)
		var/turf/S = SOUTH_OF_TURF(sourcemyc)
		var/turf/E = EAST_OF_TURF(sourcemyc)
		var/turf/W = WEST_OF_TURF(sourcemyc)
		var/list/spreadDirections = list(N, S, E, W)
		var/invalid = 0
		if(sourcemyc.linked_nucleus == src && !sourcemyc.issurrounded)
			for(var/turf/spreadtarget in spreadDirections)
				if(!locate(/obj/structure/inveterata) in spreadtarget.contents)
					src.updatecanidates(spreadtarget)
					message_admins("new turf on list!")
				else invalid++
			if(invalid == 4)
				sourcemyc.issurrounded = TRUE
		else if(sourcemyc.linked_nucleus == 0 || sourcemyc.linked_nucleus == null)
			sourcemyc.linked_nucleus = src
	if(locate(/turf) in mycelium_canidates)
		for(var/turf/spreadsource in mycelium_canidates)
			var/createTimer
			createTimer = addtimer(CALLBACK(src, .proc/createNewMycelium, spreadsource, linked_nucleus, createTimer), 20, TIMER_STOPPABLE)
			Timers += createTimer
		var/spreadTimer = addtimer(CALLBACK(src, .proc/spread), 100, TIMER_STOPPABLE)
		Timers += spreadTimer
	else isstagnant = TRUE


/obj/structure/inveterata/mycelium/nucleus/proc/createNewMycelium(loc)
	new /obj/structure/inveterata/mycelium(loc, linked_nucleus)

/obj/structure/inveterata/mycelium/nucleus/proc/restartSpread()
	isstagnant = FALSE
	var/spreadTimer = addtimer(CALLBACK(src, .proc/spread), 100, TIMER_STOPPABLE)
	Timers += spreadTimer
