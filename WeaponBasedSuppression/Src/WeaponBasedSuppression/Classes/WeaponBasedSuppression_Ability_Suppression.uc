class WeaponBasedSuppression_Ability_Suppression extends Object
	dependson(WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo)
	config(WeaponBasedSuppression);

var localized string SuppressionTargetEffectDesc;
var localized string SuppressionSourceEffectDesc;

var config int SuppressionWeaponFallbackCost;
var config bool SuppressionCancelsOverwatch;
var const config array<WeaponAmmoCostMapping> SuppressionWeaponCostMappings;

static function UpdateSuppressionAbility()
{
	local X2AbilityTemplateManager Manager;
	local array<X2AbilityTemplate> Templates;
	local X2AbilityTemplate Template;
	local WeaponAmmoCostMapping CostMapping;
	local WeaponBasedSuppression_Effect_Suppression SuppressionEffect;
	local WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo   AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;

	Manager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	Manager.FindAbilityTemplateAllDifficulties('Suppression', Templates);

	foreach Templates(Template)
	{
		Template.AbilityCosts.Length = 0;

		AmmoCost = new class'WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo';

		foreach default.SuppressionWeaponCostMappings(CostMapping)
		{
			AmmoCost.WeaponAmmoCosts.AddItem(CostMapping);
		}

		AmmoCost.FallbackAmmoCost = default.SuppressionWeaponFallbackCost;
		Template.AbilityCosts.AddItem(AmmoCost);
	
		ActionPointCost = new class'X2AbilityCost_ActionPoints';
		ActionPointCost.bConsumeAllPoints = true;   //  this will guarantee the unit has at least 1 action point
		ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
		Template.AbilityCosts.AddItem(ActionPointCost);

		SuppressionEffect = WeaponBasedSuppression_Effect_Suppression(Template.AbilityTargetEffects[0]); // get first effect
		SuppressionEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, default.SuppressionTargetEffectDesc, Template.IconImage);
		SuppressionEffect.SetSourceDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, default.SuppressionSourceEffectDesc, Template.IconImage);

	}
	
	if (!default.SuppressionCancelsOverwatch)
	{
		`log("WeaponBasedSuppression :: Removing Overwatch Exclusions");

		Manager.FindAbilityTemplateAllDifficulties('Overwatch', Templates);
		foreach Templates(Template){ RemoveSuppressionExcludeEffect(Template); }

		Manager.FindAbilityTemplateAllDifficulties('PistolOverwatch', Templates);
		foreach Templates(Template){ RemoveSuppressionExcludeEffect(Template); }

		Manager.FindAbilityTemplateAllDifficulties('LongWatch', Templates);
		foreach Templates(Template){ RemoveSuppressionExcludeEffect(Template); }

		Manager.FindAbilityTemplateAllDifficulties('SniperRifleOverwatch', Templates);
		foreach Templates(Template){ RemoveSuppressionExcludeEffect(Template); }
	}
}

static function RemoveSuppressionExcludeEffect(X2AbilityTemplate Template)
{
	local int ix, suppressionIx;
	local X2Condition_UnitEffects Condition;
	local EffectReason ExcludeEffect;

	for (ix = 0; ix < Template.AbilityShooterConditions.Length; ix++)
	{
		Condition = X2Condition_UnitEffects(Template.AbilityShooterConditions[ix]);
		if (Condition.ExcludeEffects.Length == 1 &&
			Condition.ExcludeEffects[0].EffectName == class'X2Effect_Suppression'.default.EffectName)
		{
			suppressionIx = ix;
			`log("WeaponBasedSuppression :: Found Suppression Exclusion for" @ Template.DataName @ "at" @ suppressionIx);
		}
	}
	`log("WeaponBasedSuppression :: Removing Exclusion for" @ Template.DataName @ "at" @ suppressionIx);
	Template.AbilityShooterConditions.Remove(suppressionIx, 1);
}