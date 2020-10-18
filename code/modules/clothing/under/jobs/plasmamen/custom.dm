/obj/item/clothing/under/plasmaman/custom
	name = "Custom Envirosuit"
	icon_state = "custom"
	var/primary_color = "#FFFFFF"
	var/secondary_color = "#FFFFFF"
	var/tertiary_color = "#FFFFFF"

	var/mutable_appearance/mutable_appearance_override

/obj/item/clothing/under/plasmaman/custom/New()
	mutable_appearance_override = DodoCaca()

/obj/item/clothing/under/plasmaman/custom/proc/DodoCaca()
	var/mutable_appearance/thedood = mutable_appearance(layer = -UNIFORM_LAYER)
	var/image/suit_primary = image('icons/mob/species/plasmaman/custom_suits.dmi', "chest_basic")
	var/image/suit_secondary = image('icons/mob/species/plasmaman/custom_suits.dmi', "chest_basic_vstripe")

	var/image/arms_primary = image('icons/mob/species/plasmaman/custom_suits.dmi', "arms_base")
	var/image/arms_secondary = image('icons/mob/species/plasmaman/custom_suits.dmi', "arms_singlestripe")
	var/image/gloves = image('icons/mob/species/plasmaman/custom_suits.dmi', "arms_gloves")

	var/image/legs_primary = image('icons/mob/species/plasmaman/custom_suits.dmi', "legs_base")
	var/image/legs_secondary = image('icons/mob/species/plasmaman/custom_suits.dmi', "legs_singlestripe")



	suit_primary.color = primary_color
	suit_secondary.color = secondary_color

	arms_primary.color = primary_color
	arms_secondary.color = secondary_color
	gloves.color = primary_color

	legs_primary.color = primary_color
	legs_secondary.color = secondary_color

	thedood.overlays += suit_primary
	thedood.overlays += suit_secondary

	thedood.overlays += arms_primary
	thedood.overlays += arms_secondary
	thedood.overlays += gloves

	thedood.overlays += legs_primary
	thedood.overlays += legs_secondary

	return thedood

/obj/item/clothing/under/plasmaman/custom/AltClick(var/mob/user)
	var/mob/living/carbon/human/H
	if(istype(user, /mob/living/carbon/human))
		H = user
	else
		return
	if(H.w_uniform != src)
		return
	var/temp = input(user, "Choose a dye color", "Dye Color") as color
	primary_color = temp
	color = temp
	mutable_appearance_override = DodoCaca()
	user.update_inv_w_uniform()

/obj/item/clothing/under/plasmaman/custom/AltShiftClick(mob/user)

	var/mob/living/carbon/human/H
	if(istype(user, /mob/living/carbon/human))
		H = user
	else
		return
	if(H.w_uniform != src)
		return
	var/temp = input(user, "Choose a dye color", "Dye Color") as color
	secondary_color = temp
	mutable_appearance_override = DodoCaca()
	user.update_inv_w_uniform()
