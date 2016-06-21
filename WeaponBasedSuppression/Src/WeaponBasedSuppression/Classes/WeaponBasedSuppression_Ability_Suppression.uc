class WeaponBasedSuppression_Ability_Suppression extends Object
	dependson(WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo)
	config(WeaponBasedSuppression);

var localized string SuppressionTargetEffectDesc;
var localized string SuppressionSourceEffectDesc;

var config int SuppressionWeaponFallbackCost;
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

}