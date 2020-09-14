#define AIRLOCK_CONTROLLER_FRAME  0
#define AIRLOCK_CONTROLLER_BUILDING  1
#define AIRLOCK_CONTROLLER_READY  2
#define AIRLOCK_CONTROLLER_MAINTENANCE  3

#define ACCESS_BUTTON_FRAME  0
#define ACCESS_BUTTON_READY  1

//Marker decal
/obj/effect/decal/airlockmarker
	name = "airlock marker"
	desc = "marks where a airlock-button's airlock is."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "marker"
	anchored = 1
	level = 1

/obj/effect/decal/airlockmarker/Initialize(mapload)
	. = ..()
	var/turf/currentturf = get_turf(src.loc)
	hide(currentturf)

/obj/effect/decal/airlockmarker/hide(i)
	if(i)
		invisibility = 101
	else
		invisibility = 0


//FRAMES
/obj/item/mounted/frame/access_button
	name = "access button frame"
	desc = "Used in conjunction with a airlock controller. It initates airlock cycles."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_frame"
	materials = list(MAT_METAL = 1000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/airlock_sensor
	name = "airlock sensor frame"
	desc = "Used in conjunction with a airlock controller. It monitors the air inside the airlock."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_frame"
	materials = list(MAT_METAL = 1000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/airlock_controller
	name = "airlock control frame"
	desc = "Used for building airlock control interfaces."
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_control_frame"
	materials = list(MAT_METAL = 2000)
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/access_button/do_build(turf/on_wall, mob/user)
	var/turf/currentturf = get_turf(src)
	var/tileoffset = get_dir(user, on_wall)
	var/Xoffset = 0
	var/Yoffset = 0
	qdel(src)
	new /obj/machinery/access_button_custom(currentturf)
	for(var/obj/machinery/access_button_custom/createdframe in (currentturf).contents)
		if(tileoffset == NORTH)
			Xoffset = 0
			Yoffset = 32
		else if(tileoffset == SOUTH)
			Xoffset = 0
			Yoffset = -32
		else if(tileoffset == EAST)
			Xoffset = 32
			Yoffset = 0
		else if(tileoffset == WEST)
			Xoffset = -32
			Yoffset = 0
		createdframe.place(Xoffset, Yoffset)
		createdframe.buildstage = ACCESS_BUTTON_FRAME
		createdframe.wiresadded = FALSE
		createdframe.update_icon()
		return

/obj/item/mounted/frame/airlock_sensor/do_build(turf/on_wall, mob/user)
	var/turf/currentturf = get_turf(src)
	var/tileoffset = get_dir(user, on_wall)
	var/Xoffset = 0
	var/Yoffset = 0
	qdel(src)
	new /obj/machinery/airlock_sensor(currentturf)
	for(var/obj/machinery/airlock_sensor/createdframe in (currentturf).contents)
		if(tileoffset == NORTH)
			Xoffset = 0
			Yoffset = 32
		else if(tileoffset == SOUTH)
			Xoffset = 0
			Yoffset = -32
		else if(tileoffset == EAST)
			Xoffset = 32
			Yoffset = 0
		else if(tileoffset == WEST)
			Xoffset = -32
			Yoffset = 0
		createdframe.place(Xoffset, Yoffset)
		createdframe.update_icon()
		return

/obj/item/mounted/frame/airlock_controller/do_build(turf/on_wall, mob/user)
	var/turf/currentturf = get_turf(src)
	var/tileoffset = get_dir(user, on_wall)
	var/Xoffset = 0
	var/Yoffset = 0
	qdel(src)
	new /obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom(currentturf)
	for(var/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/createdframe in (currentturf).contents)
		if(tileoffset == NORTH)
			Xoffset = 0
			Yoffset = 32
		else if(tileoffset == SOUTH)
			Xoffset = 0
			Yoffset = -32
		else if(tileoffset == EAST)
			Xoffset = 32
			Yoffset = 0
		else if(tileoffset == WEST)
			Xoffset = -32
			Yoffset = 0
		createdframe.place(Xoffset, Yoffset)
		createdframe.buildstage = AIRLOCK_CONTROLLER_FRAME
		createdframe.update_icon()
		return

//CUSTOM ACCESS BUTTON
/obj/machinery/access_button_custom
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"
	anchored = 1
	power_channel = ENVIRON
	var/master_tag
	var/frequency = AIRLOCK_FREQ
	var/command = "cycle"
	var/orientation = null
	var/datum/radio_frequency/radio_connection
	var/buildstage = ACCESS_BUTTON_READY
	var/wiresadded = TRUE
	var/on = 1

/obj/machinery/access_button_custom/update_icon()
	if(buildstage == ACCESS_BUTTON_READY)
		if(on)
			icon_state = "access_button_standby"
		else
			icon_state = "access_button_off"
	else
		if(wiresadded)
			icon_state = "access_button_wired"
		else
			icon_state = "access_button_placed"

/obj/machinery/access_button_custom/attackby(obj/item/I, mob/user, params)
	//Swiping ID on the access button
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))
		attack_hand(user)
		return
	else if(buildstage == ACCESS_BUTTON_FRAME && !wiresadded)
		if(iscoil(I))
			var/obj/item/stack/cable_coil/coil = I
			to_chat(user, "You wire [src]!")
			playsound(get_turf(src), coil.usesound, 50, 1)
			coil.amount -= 1
			if(!coil.amount)
				qdel(coil)
			wiresadded = TRUE
			update_icon()
			return
	return ..()

/obj/machinery/access_button_custom/screwdriver_act(mob/living/user, obj/item/I)
	if(!wiresadded)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(buildstage == ACCESS_BUTTON_READY)
		buildstage = ACCESS_BUTTON_FRAME
	else
		buildstage = ACCESS_BUTTON_READY
	update_icon()

/obj/machinery/access_button_custom/wirecutter_act(mob/living/user, obj/item/I)
	if(!wiresadded || buildstage == ACCESS_BUTTON_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresadded = FALSE
	update_icon()

/obj/machinery/access_button_custom/multitool_act(mob/living/user, obj/item/I)
	if(buildstage != ACCESS_BUTTON_READY)
		return
	. = ..()
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)
	flick("access_button_maintenance", src)

/obj/machinery/access_button_custom/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/access_button_custom/attack_hand(mob/user)
	if(buildstage != ACCESS_BUTTON_READY)
		return
	add_fingerprint(usr)

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, "<span class='warning'>Access denied.</span>")

	else if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	flick("access_button_cycle", src)

/obj/machinery/access_button_custom/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/access_button_custom/Initialize()
	. = ..()
	if(SSradio)
		set_frequency(frequency)
	new /obj/effect/decal/airlockmarker(src.loc)

/obj/machinery/access_button_custom/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/access_button_custom/airlock_interior
	frequency = 1379
	command = "cycle_interior"

/obj/machinery/access_button_custom/airlock_exterior
	frequency = 1379
	command = "cycle_exterior"


/obj/machinery/access_button_custom/proc/place(Xoffset, Yoffset)
	pixel_x = Xoffset
	pixel_y = Yoffset

//CUSTOM AIRLOCK SENSOR
/obj/machinery/airlock_sensor/proc/place(Xoffset, Yoffset)
	pixel_x = Xoffset
	pixel_y = Yoffset


//CUSTOM AIRLOCK CONTROLLER
/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom
	name = "Airlock Controller"
	tag_secure = 1
	req_access = list(ACCESS_ENGINE_EQUIP)
	var/datum/wires/airlockcontroller/wires = null
	var/buildstage = AIRLOCK_CONTROLLER_READY
	var/wiresexposed = FALSE
	var/aidisabled = FALSE
	var/locked = TRUE
	var/electrified = FALSE

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/Initialize(mapload, given_id_tag, given_frequency, given_tag_exterior_door, given_tag_interior_door, given_tag_airpump, given_tag_chamber_sensor)
	. = ..()
	if(given_id_tag)
		id_tag = given_id_tag
	if(given_frequency)
		set_frequency(given_frequency)
	if(given_tag_exterior_door)
		tag_exterior_door = given_tag_exterior_door
	if(given_tag_interior_door)
		tag_interior_door = given_tag_interior_door
	if(given_tag_airpump)
		tag_airpump = given_tag_airpump
	if(given_tag_chamber_sensor)
		tag_chamber_sensor = given_tag_chamber_sensor
	wires = new(src)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/update_icon()
	if(buildstage == AIRLOCK_CONTROLLER_READY)
		if(wiresexposed)
			icon_state = "access_control_wires"
		else if(!locked)
			icon_state = "access_control_maintenance"
		else if(on && program)
			if(program.memory["processing"])
				icon_state = "access_control_process"
			else
				icon_state = "access_control_standby"
		else
			icon_state = "access_control_off"
	else if(buildstage == AIRLOCK_CONTROLLER_BUILDING)
		icon_state = "access_control_circuited"
	else
		if(buildstage == AIRLOCK_CONTROLLER_FRAME)
			icon_state = "access_control_placed"

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/attack_hand(mob/user)
	if(electrified)
		shock(user, 50)
	. = ..()
	if(.)
		return
	return interact(user)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/interact(mob/user)
	if(buildstage != 2)
		return

	if(wiresexposed)
		wires.Interact(user)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/proc/place(Xoffset, Yoffset)
	pixel_x = Xoffset
	pixel_y = Yoffset

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/CanUseTopic(var/mob/user, var/datum/topic_state/state, var/href_list = list())
	if(buildstage != 2 || wiresexposed)
		return STATUS_CLOSE

	if(aidisabled && (isAI(user) || isrobot(user)))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return STATUS_CLOSE

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(buildstage != 2)
		return
	else if(wiresexposed)
		return
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "simple_airlock_console.tmpl", name, 470, 290)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data = list(
		"chamber_pressure" = round(program.memory["chamber_sensor_pressure"]),
		"exterior_status" = program.memory["exterior_status"],
		"interior_status" = program.memory["interior_status"],
		"processing" = program.memory["processing"],
	)

	return data

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/multitool_menu(mob/user, obj/item/multitool/P)
	var/dat= {"
	<ul>
	<b>Bingus</b>
	</ul>"}
	return dat

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(!wiresexposed)
				if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda)) //unlocking maintenance mode with an ID card
					if(stat & (NOPOWER|BROKEN))
						to_chat(user, "It does nothing")
						return
					else
						if(allowed(usr) && !wires.IsIndexCut(ARLKCNTRL_WIRE_IDSCAN))
							locked = !locked
							to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] maintenance mode.</span>")
							updateUsrDialog()
						else
							to_chat(user, "<span class='warning'>Access denied.</span>")
					return

		if(1)
			if(iscoil(I))
				var/obj/item/stack/cable_coil/coil = I
				if(coil.amount < 5)
					to_chat(user, "You need more cable for this!")
					return

				to_chat(user, "You wire [src]!")
				playsound(get_turf(src), coil.usesound, 50, 1)
				coil.amount -= 5
				if(!coil.amount)
					qdel(coil)

				buildstage = 2
				wires.GenerateWires()
				wiresexposed = TRUE
				update_icon()
				return
		if(0)
			if(istype(I, /obj/item/airlockcontrol_electronics))
				to_chat(user, "You insert the circuit!")
				playsound(get_turf(src), I.usesound, 50, 1)
				qdel(I)
				buildstage = AIRLOCK_CONTROLLER_BUILDING
				locked = TRUE
				wiresexposed = FALSE
				update_icon()
				return
	return ..()

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/crowbar_act(mob/user, obj/item/I)
	if(buildstage != AIRLOCK_CONTROLLER_BUILDING)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	to_chat(user, "You start prying out the circuit.")
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	if(buildstage != AIRLOCK_CONTROLLER_BUILDING)
		return
	to_chat(user, "You pry out the circuit!")
	new /obj/item/airlockcontrol_electronics(user.drop_location())
	buildstage = AIRLOCK_CONTROLLER_FRAME
	update_icon()

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/multitool_act(mob/user, obj/item/I)
	if(buildstage != AIRLOCK_CONTROLLER_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(wiresexposed)
		attack_hand(user)
		return
	else if(!locked)
		update_multitool_menu(user)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != AIRLOCK_CONTROLLER_READY || !wiresexposed)
		return
	. = TRUE
	if(wires.IsAllCut()) // all wires cut
		var/obj/item/stack/cable_coil/new_coil = new /obj/item/stack/cable_coil(user.drop_location())
		new_coil.amount = 5
		buildstage = AIRLOCK_CONTROLLER_BUILDING
		wiresexposed = FALSE
		electrified = FALSE
		update_icon()
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
	if(wiresexposed)
		wires.Interact(user)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/wrench_act(mob/user, obj/item/I)
	if(buildstage != AIRLOCK_CONTROLLER_FRAME)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	new /obj/item/mounted/frame/airlock_controller(get_turf(user))
	WRENCH_UNANCHOR_WALL_MESSAGE
	qdel(src)

/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != AIRLOCK_CONTROLLER_READY)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresexposed = !wiresexposed
	update_icon()
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
