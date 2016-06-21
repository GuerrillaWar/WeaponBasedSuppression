class WeaponBasedSuppression_AbilityCost_WeaponConditionalAmmo extends X2AbilityCost_Ammo;

struct WeaponAmmoCostMapping
{
	var name WeaponName;
	var name WeaponCat;
	var int Cost;
};

var int FallbackAmmoCost;
var array<WeaponAmmoCostMapping> WeaponAmmoCosts;

simulated function int CalcAmmoCost(XComGameState_Ability Ability, XComGameState_Item ItemState, XComGameState_BaseObject TargetState)
{
	local int MappingIx;

	MappingIx = WeaponAmmoCosts.Find('WeaponName', ItemState.GetMyTemplateName());

	if (MappingIx != -1)
	{
		return WeaponAmmoCosts[MappingIx].Cost;
	}
	else if (ItemState.GetWeaponCategory() == '')
	{
		return FallbackAmmoCost;
	}

	MappingIx = WeaponAmmoCosts.Find('WeaponCat', ItemState.GetWeaponCategory());

	if (MappingIx != -1)
	{
		return WeaponAmmoCosts[MappingIx].Cost;
	}
	else if (ItemState.GetWeaponCategory() == '')
	{
		return FallbackAmmoCost;
	}

}

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
	local XComGameState_Item Weapon, SourceAmmo;
	local int Cost;
	Weapon = kAbility.GetSourceWeapon();
	Cost = CalcAmmoCost(kAbility, Weapon, ActivatingUnit);

	if (UseLoadedAmmo)
	{
		SourceAmmo = kAbility.GetSourceAmmo();
		if (SourceAmmo != None)
		{
			if (SourceAmmo.HasInfiniteAmmo() || SourceAmmo.Ammo >= Cost)
				return 'AA_Success';
		}
	}
	else
	{
		Weapon = kAbility.GetSourceWeapon();
		if (Weapon != none)
		{
			// If the weapon has infinite ammo, the weapon must still have an ammo value
			// of at least one. This could happen if the weapon becomes disabled.
			if ((Weapon.HasInfiniteAmmo() && (Weapon.Ammo > 0)) || Weapon.Ammo >= Cost)
				return 'AA_Success';
		}	
	}

	if (bReturnChargesError)
		return 'AA_CannotAfford_Charges';

	return 'AA_CannotAfford_AmmoCost';
}