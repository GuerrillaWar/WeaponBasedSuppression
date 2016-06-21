class WeaponBasedSuppression_Effect_Suppression extends X2Effect_Suppression config(WeaponBasedSuppression);

var config int Soldier_AimPenalty;     //  inside GetToHitModifiers, this value is used if the Attacker is not on eTeam_XCom (because a soldier hit this unit with suppression)
var config int Alien_AimPenalty;       //  as above, but only for eTeam_XCom (because an alien hit this xcom unit with suppression)
var config int Multiplayer_AimPenalty; //  the value used in MP games

struct SuppressionWeaponMapping
{
	var name WeaponName;
	var name WeaponCat;
	var int AimModifier;
};

var const config array<SuppressionWeaponMapping> SuppressionWeaponMappings;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ShotMod;
	local XComGameState_Ability SourceAbility;

	SourceAbility = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	if (!bIndirectFire)
	{
		ShotMod.ModType = eHit_Success;
		ShotMod.Value = GetAimModifierFromAbility(SourceAbility, Attacker);
		ShotMod.Reason = FriendlyName;

		ShotModifiers.AddItem(ShotMod);
	}
}

function int GetAimModifierFromAbility(XComGameState_Ability SourceAbility, XComGameState_Unit SuppressedUnit)
{
	local XComGameState_Item ItemState;
	local name WeaponName, WeaponCat;
	local int MappingIx;

	ItemState = SourceAbility.GetSourceWeapon();
	WeaponName = ItemState.GetMyTemplateName();
	WeaponCat = ItemState.GetWeaponCategory();
	`log("SuppressionCheck, " @WeaponName@WeaponCat);
	`log("SuppressorMaps," @ SuppressionWeaponMappings.Length);
	MappingIx = SuppressionWeaponMappings.Find('WeaponName', WeaponName);
	

	if (MappingIx != -1)
	{
		`log("WeaponName Based SuppressionModifier" @ SuppressionWeaponMappings[MappingIx].AimModifier);
		return SuppressionWeaponMappings[MappingIx].AimModifier;
	}

	MappingIx = SuppressionWeaponMappings.Find('WeaponCat', WeaponCat);

	if (MappingIx != -1)
	{
		`log("WeaponCat Based SuppressionModifier" @ SuppressionWeaponMappings[MappingIx].AimModifier);
		return SuppressionWeaponMappings[MappingIx].AimModifier;
	}
	else if (`XENGINE.IsMultiplayerGame())
	{
		`log("Multiplayer SuppressionModfier" @ default.Multiplayer_AimPenalty);
		return default.Multiplayer_AimPenalty;
	}
	else if (SuppressedUnit.GetTeam() != eTeam_XCom)
	{
		`log("Soldier SuppressionModfier" @ default.Soldier_AimPenalty);
		return default.Soldier_AimPenalty;
	}
	else
	{
		`log("Alien SuppressionModfier" @ default.Alien_AimPenalty);
		return default.Alien_AimPenalty;
	}
}