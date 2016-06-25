//---------------------------------------------------------------------------------------
//  FILE:    XMBAbilityTag.uc
//  AUTHOR:  xylthixlm
//
//  This file contains internal implementation of XModBase. You don't need to, and
//  shouldn't, use it directly.
//
//  INSTALLATION
//
//  Copy all the files in XModBase_Core_1_1_0/Classes/, XModBase_Interfaces/Classes/,
//  and LW_Tuple/Classes/ into similarly named directories under Src/.
//
//  DO NOT EDIT THIS FILE. This class is shared with other mods that use XModBase. If
//  you change this file, your mod will become incompatible with any other mod using
//  XModBase.
//---------------------------------------------------------------------------------------
class XMBAbilityTag extends X2AbilityTag implements(XMBOverrideInterface);

// The previous X2AbilityTag. We save it so we can just call it to handle any tag we don't
// recognize, so we don't have to include a copy of the regular X2AbilityTag code. This also
// makes it so we will play well with any other mods that replace X2AbilityTag this way.
var X2AbilityTag WrappedTag;

// XModBase version
var int MajorVersion, MinorVersion, PatchVersion;

// From X2AbilityTag. Expands a tag. The specific tags we handle depend on the ability the tag
// applies to. We look inside the ability template and check each effect to see if we know how
// to get the tag value from that effect - usually this is because the effect implements
// XMBEffectInterface and we call GetTagValue on it. We also have special handling for
// X2Effect_PersistentStatChange.
event ExpandHandler(string InString, out string OutString)
{
	local name Type;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local XComGameState_Item ItemState;
	local X2ItemTemplate ItemTemplate;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityToHitCalc_StandardAim ToHitCalc;
	local X2Effect EffectTemplate;
	local XMBEffectInterface EffectInterface;
	local XComGameStateHistory History;
	local array<string> Split;
	local int idx;

	History = `XCOMHISTORY;

	OutString = "";

	Split = SplitString(InString, ":");

	Type = name(Split[0]);

	// Depending on where this tag is being expanded, ParseObj may be an XComGameState_Effect, an
	// XComGameState_Ability, or an X2AbilityTemplate.
	EffectState = XComGameState_Effect(ParseObj);
	AbilityState = XComGameState_Ability(ParseObj);
	AbilityTemplate = X2AbilityTemplate(ParseObj);
		
	// If we have an XComGameState_Effect or XComGameState_Ability, find the ability template from it.
	if (EffectState != none)
	{
		AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	}
	if (AbilityState != none)
	{
		AbilityTemplate = AbilityState.GetMyTemplate();
	}

	// We allow tags of the form "<Ability:[tag]:[name]/>", which causes us to look for the tag's 
	// value in the ability with template name [name] instead of the template with the tag itself.
	// This is useful for abilities where the actual effect is in a secondary ability.
	if (Split.Length == 2)
	{
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(name(Split[1]));
	}

	// Check for handling by XMBEffectInterface::GetTagValue.
	if (AbilityTemplate != none)
	{
		foreach AbilityTemplate.AbilityTargetEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				return;
			}
		}
		foreach AbilityTemplate.AbilityMultiTargetEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				return;
			}
		}
		foreach AbilityTemplate.AbilityShooterEffects(EffectTemplate)
		{
			EffectInterface = XMBEffectInterface(EffectTemplate);
			if (EffectInterface != none && EffectInterface.GetTagValue(Type, AbilityState, OutString))
			{
				return;
			}
		}

		// If this tag is a stat name, look for an X2Effect_PersistentStatChange that modifies that
		// stat.
		idx = class'XMBConfig'.default.m_aCharStatTags.Find(Type);
		if (idx != INDEX_NONE && FindStatBonus(AbilityTemplate, ECharStatType(idx), OutString))
		{
			return;
		}
	}

	switch (Type)
	{
		// <Ability:AssociatedWeapon/> returns the actual name of the associated weapon or item
		// for an ability. For example, if it is associated with a Gauss Rifle, it will return
		// "Gauss Rifle".
		case 'AssociatedWeapon':
			if (AbilityState != none)
			{
				ItemState = AbilityState.GetSourceWeapon();
				ItemTemplate = ItemState.GetMyTemplate();

				OutString = ItemTemplate.GetItemFriendlyName();
			}
			else
			{
				OutString = "weapon";
			}
			break;

		// <Ability:ToHit/> can be an actual to-hit bonus granted by the ability (handled earlier),
		// a negative defense modifier granted by the ability, or the inherent to-hit modifier of
		// the ability itself.
		case 'ToHit':
			if (FindStatBonus(AbilityTemplate, eStat_Defense, OutString, -1))
			{
				break;
			}
			// Fallthrough
		// <Ability:BaseToHit/> returns the inherent to-hit modifier of the ability itself.
		case 'BaseToHit':
			ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);
			if (ToHitCalc != none)
			{
				OutString = string(ToHitCalc.BuiltInHitMod);
			}
			break;

		// <Ability:Crit/> can be a crit bonus granted by the ability (handled earlier), or the
		// inherent crit modifier of the ability itself.
		case 'Crit':
		// <Ability:BaseCrit/> returns the inherent crit modifier of the ability itself.
		case 'BaseCrit':
			ToHitCalc = X2AbilityToHitCalc_StandardAim(AbilityTemplate.AbilityToHitCalc);
			if (ToHitCalc != none)
			{
				OutString = string(ToHitCalc.BuiltInCritMod);
			}
			break;

		// We don't handle this tag, check the wrapped tag.
		default:
			WrappedTag.ParseObj = ParseObj;
			WrappedTag.StrategyParseObj = StrategyParseObj;
			WrappedTag.GameState = GameState;
			WrappedTag.ExpandHandler(InString, OutString);
			return;
	}

	// no tag found
	if (OutString == "")
	{
		`RedScreenOnce(`location $ ": Unhandled localization tag: '"$Tag$":"$InString$"'");
		OutString = "<Ability:"$InString$"/>";
	}
}

// Looks for a stat bonus in an X2EFfect_PersistentStatChange or subclass.
function bool FindStatBonus(X2AbilityTemplate AbilityTemplate, ECharStatType StatType, out string OutString, optional float Multiplier = 1)
{
	local X2Effect EffectTemplate;
	local X2Effect_PersistentStatChange StatChangeEffect;
	local int idx;

	if (AbilityTemplate == none)
		return false;

	foreach AbilityTemplate.AbilityTargetEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount * Multiplier));
				return true;
			}
		}
	}
	foreach AbilityTemplate.AbilityMultiTargetEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount * Multiplier));
				return true;
			}
		}
	}
	foreach AbilityTemplate.AbilityShooterEffects(EffectTemplate)
	{
		StatChangeEffect = X2Effect_PersistentStatChange(EffectTemplate);
		if (StatChangeEffect != none)
		{
			idx = StatChangeEffect.m_aStatChanges.Find('StatType', StatType);
			if (idx != INDEX_NONE)
			{
				OutString = string(int(StatChangeEffect.m_aStatChanges[idx].StatAmount * Multiplier));
				return true;
			}
		}
	}

	return false;
}

// From XMBOverrideInterace
function class GetOverrideBaseClass() 
{ 
	return class'X2AbilityTag';
}

// From XMBOverrideInterace
function GetOverrideVersion(out int Major, out int Minor, out int Patch)
{
	Major = MajorVersion;
	Minor = MinorVersion;
	Patch = PatchVersion;
}

// From XMBOverrideInterace
function bool GetExtValue(LWTuple Tuple)
{
	local LWTValue Value;

	switch (Tuple.Id)
	{
	// Get our wrapped tag. Used in the case where this is being replaced by a newer version.
	case 'WrappedTag':
		Value.o = WrappedTag;
		Value.kind = LWTVObject;
		Tuple.Data.Length = 0;
		Tuple.Data.AddItem(Value);
		return true;
	}

	return false;
}


// From XMBOverrideInterace
function bool SetExtValue(LWTuple Data) { return false; }
