class WeaponBasedSuppression_Effect_Suppression extends X2Effect_Suppression
	implements(XMBEffectInterface)
	config(WeaponBasedSuppression);

var config int Soldier_AimPenalty;     //  inside GetToHitModifiers, this value is used if the Attacker is not on eTeam_XCom (because a soldier hit this unit with suppression)
var config int Alien_AimPenalty;       //  as above, but only for eTeam_XCom (because an alien hit this xcom unit with suppression)
var config int Multiplayer_AimPenalty; //  the value used in MP games
var config bool StackingSuppression;

struct SuppressionWeaponMapping
{
	var name WeaponName;
	var name WeaponCat;
	var int AimModifier;
};

var const config array<SuppressionWeaponMapping> SuppressionWeaponMappings;

function bool UniqueToHitModifiers() { return !StackingSuppression; } // false = stacking, true = no stacking

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

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit SourceUnit, TargetUnit;
	local XComGameStateContext_Ability AbilityContext;

	// pulled out of X2Effect_Persistent because overrides MUST be subclasses
	if (EffectAddedFn != none)
		EffectAddedFn(self, ApplyEffectParameters, kNewTargetState, NewGameState);

	if (bTickWhenApplied)
	{
		if (NewEffectState != none)
		{
			if (!NewEffectState.TickEffect(NewGameState, true))
				NewEffectState.RemoveEffect(NewGameState, NewGameState, false, true);
		}
	}
	// end extraction out of X2Effect_Persistent because overrides MUST be subclasses

	TargetUnit = XComGameState_Unit(kNewTargetState);

	if (class'WeaponBasedSuppression_Ability_Suppression'.default.SuppressionCancelsOverwatch)
	{
		`log("WeaponBasedSuppression :: Removing Overwatch ReservePoints");
		TargetUnit.ReserveActionPoints.Length = 0;              //  remove overwatch when suppressed
	}
	else
	{
		`log("WeaponBasedSuppression :: Keeping Overwatch ReservePoints");
	}
	SourceUnit = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());
	SourceUnit.m_SuppressionAbilityContext = AbilityContext;
	NewGameState.AddStateObject(SourceUnit);
}

// From XMBEffectInterface // required for interface to not return none
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }
function bool GetExtValue(LWTuple Tuple) { return false; }

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local XComGameState_Unit SuppressedUnit;
	SuppressedUnit = new class'XComGameState_Unit';
	`log("GetTagValue:" @ Tag);
	if (Tag == 'WeaponBasedSuppressionPenalty')
	{
		TagValue = string(GetAimModifierFromAbility(AbilityState, SuppressedUnit)); // just using a dummy target here
		return true;
	}

	return false;
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


DefaultProperties
{
	EffectName="Suppression"
	bUseSourcePlayerState=true
	CleansedVisualizationFn=CleansedSuppressionVisualization
}