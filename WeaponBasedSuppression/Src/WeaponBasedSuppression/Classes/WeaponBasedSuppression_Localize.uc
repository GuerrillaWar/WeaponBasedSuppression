class WeaponBasedSuppression_Localize extends XGLocalizeTag
	dependson(WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo, WeaponBasedSuppression_Effect_Suppression);

var Object ParseObj;

event ExpandHandler(string InString, out string OutString)
{
	local name Type;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local XComGameState_Unit TargetUnitState;
	local WeaponBasedSuppression_Effect_Suppression Effect;
	local WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo AmmoCost;
	local int Idx;


	Type = name(InString);
	History = `XCOMHISTORY;

	switch (Type)
	{
		case 'COST':
			OutString = "0";
			AbilityTemplate = X2AbilityTemplate(ParseObj);
			AbilityState = XComGameState_Ability(ParseObj);
			TargetUnitState = XComGameState_Unit(ParseObj);
			if (AbilityTemplate == none)
			{
				AbilityState = XComGameState_Ability(ParseObj);
				if (AbilityState != none)
					AbilityTemplate = AbilityState.GetMyTemplate();
			}
			if (AbilityTemplate != none)
			{
				for (Idx = 0; Idx < AbilityTemplate.AbilityCosts.Length; ++Idx)
				{
					AmmoCost = WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo(AbilityTemplate.AbilityCosts[Idx]);
					if (AmmoCost != none)
					{
						OutString = string(AmmoCost.CalcAmmoCost(
							AbilityState,
							AbilityState.GetSourceWeapon(),
							TargetUnitState
						));
						break;
					}
				}
			}
			break;

		case 'PENALTY':
			if (`XENGINE.IsMultiplayerGame())
			{
				OutString = string(class'WeaponBasedSuppression_Effect_Suppression'.default.Multiplayer_AimPenalty);
			}
			else
			{
				OutString = string(class'WeaponBasedSuppression_Effect_Suppression'.default.Soldier_AimPenalty);
				EffectState = XComGameState_Effect(ParseObj);
				AbilityState = XComGameState_Ability(ParseObj);
				TargetUnitState = XComGameState_Unit(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

				OutString = string(Effect.GetAimModifierFromAbility(AbilityState, TargetUnitState));
				`log("Translating OutString:" @ OutString);
			}
			break;

	}

	// no tag found
	if (OutString == "")
	{
		`RedScreenOnce("Unhandled localization tag: '"$Tag$":"$InString$"'");
		OutString = "<WeaponBasedSuppression:"$InString$"/>";
	}
}

DefaultProperties
{
	Tag = "WeaponBasedSuppression";
}