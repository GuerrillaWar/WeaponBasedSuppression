This is a hastily put together extraction of a feature we're working on for Guerrilla War Tactical.

Suppression effectiveness and ability changes based on the weapon used, which is good for balancing. Some base thoughts are Suppression should require a full magazine on an Assault Rifle, which you'll see in the ini file.

Note that this mod doesn't fix Suppression Animations: use this mod for that: http://steamcommunity.com/sharedfiles/filedetails/?id=663828094

Here's the ini file in all it's glory.

--------------------------------------------------
WeaponBasedSuppression.ini
--------------------------------------------------

[WeaponBasedSuppression.WeaponBasedSuppression_Effect_Suppression]

; fallbacks for standard suppression handling
Soldier_AimPenalty= -30
Alien_AimPenalty= -30
Multiplayer_AimPenalty= -30

; WeaponCat for categories, WeaponName for a specific name of weapon
+SuppressionWeaponMappings=(WeaponCat="rifle", AimModifier=-15)
+SuppressionWeaponMappings=(WeaponCat="cannon", AimModifier=-30)

[WeaponBasedSuppression.WeaponBasedSuppression_Ability_Suppression]
; fallback if weapon doesnt match any of the default costs
SuppressionWeaponFallbackCost=2

; WeaponCat for categories, WeaponName for a specific name of weapon
+SuppressionWeaponCostMappings=(WeaponCat="rifle", Cost=4)
+SuppressionWeaponCostMappings=(WeaponCat="cannon", Cost=2)


[WeaponBasedSuppression.WeaponBasedSuppression_AddSuppressionToWeapons]
; this adds the ability directly to the weapon, so you get it by default
; this does NOT fix suppression animations, use this for that:
; http://steamcommunity.com/sharedfiles/filedetails/?id=663828094

; these can be names or weapon categories
+WeaponsWithSuppression="AssaultRifle_CV"
+WeaponsWithSuppression="AssaultRifle_MG"
; I left out the BM variant to test, also I think it makes sense that the
; beam rifle can't suppress given the lack of burst fire.
+WeaponsWithSuppression="cannon"


-----------------------
KNOWN ISSUES
-----------------------

Localisation tags don't work, I'd love if it did cause then you could see what
the modifier is for the effect, this is to be resolved.