/datum/wires/airlockcontroller
	holder_type = /obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom
	wire_count = 3

#define ARLKCNTRL_WIRE_IDSCAN 1
#define ARLKCNTRL_WIRE_SHOCKER 2
#define ARLKCNTRL_WIRE_AI_CONTROL 3

/datum/wires/airlockcontroller/GetWireName(index)
	switch(index)
		if(ARLKCNTRL_WIRE_IDSCAN)
			return "ID Scan"

		if(ARLKCNTRL_WIRE_SHOCKER)
			return "Primary Power"

		if(ARLKCNTRL_WIRE_AI_CONTROL)
			return "AI Control"

/datum/wires/airlockcontroller/get_status()
	. = ..()
	var/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/A = holder
	. += "The 'AI control allowed' light is [A.aidisabled ? "off" : "on"]."
	if(A.locked == FALSE)
		. += "Maintenance mode is unlocked"


/datum/wires/airlockcontroller/CanUse(mob/living/L)
	var/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/A = holder
	if(A.wiresexposed)
		return TRUE
	return FALSE

/datum/wires/airlockcontroller/UpdatePulsed(index)

	var/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/A = holder

	switch(index)

		if(ARLKCNTRL_WIRE_IDSCAN)
			A.locked = 0

			spawn(300)
				if(A)
					A.locked = 1
					A.updateDialog()

		if(ARLKCNTRL_WIRE_SHOCKER)
			A.shock(usr, 50)
			A.electrified = TRUE

			spawn(300)
				A.updateDialog()
				A.electrified = FALSE

		if(ARLKCNTRL_WIRE_AI_CONTROL)
			if(A.aidisabled == 0)
				A.aidisabled = 1

				spawn(10)
					if(A && !IsIndexCut(ARLKCNTRL_WIRE_AI_CONTROL))
						A.aidisabled = 0
						A.updateDialog()

	..()

/datum/wires/airlockcontroller/UpdateCut(index, mended)
	var/obj/machinery/embedded_controller/radio/airlock/airlock_controller_custom/A = holder

	switch(index)
		if(ARLKCNTRL_WIRE_SHOCKER)
			if(!mended)
				A.shock(usr, 50)
				A.electrified = TRUE

		if(ARLKCNTRL_WIRE_AI_CONTROL)
			if(!mended)
				if(A.aidisabled == 0)
					A.aidisabled = 1
			else
				if(A.aidisabled == 1)
					A.aidisabled = 0
		if(ARLKCNTRL_WIRE_IDSCAN)
			A.locked = 0
	..()
