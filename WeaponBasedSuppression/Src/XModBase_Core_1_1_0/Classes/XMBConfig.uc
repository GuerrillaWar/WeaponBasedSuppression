class XMBConfig extends Object config(GameCore);

var config array<name> AllSoldierAbilitySet;	// List of names of abilities that will be given to all soldiers.
var config array<name> UniversalAbilitySet;		// List of names of abilities that will be given to ALL units, including enemies.

var const array<name> m_aCharStatTags;

defaultproperties
{
	// These define the mapping between ability tags in XComGame.int and stats.
	m_aCharStatTags[0]=Invalid
	m_aCharStatTags[1]=UtilityItems
	m_aCharStatTags[2]=HP
	m_aCharStatTags[3]=ToHit				// Offense
	m_aCharStatTags[4]=Defense
	m_aCharStatTags[5]=Mobility
	m_aCharStatTags[6]=Will
	m_aCharStatTags[7]=Hacking
	m_aCharStatTags[8]=SightRadius
	m_aCharStatTags[9]=FlightFuel
	m_aCharStatTags[10]=AlertLevel
	m_aCharStatTags[11]=BackpackSize
	m_aCharStatTags[12]=Dodge
	m_aCharStatTags[13]=ArmorChance
	m_aCharStatTags[14]=ArmorMitigation
	m_aCharStatTags[15]=ArmorPiercing
	m_aCharStatTags[16]=PsiOffense
	m_aCharStatTags[17]=HackDefense
	m_aCharStatTags[18]=DetectionRadius
	m_aCharStatTags[19]=DetectionModifier
	m_aCharStatTags[20]=Crit				// CritChance
	m_aCharStatTags[21]=Strength
	m_aCharStatTags[22]=SeeMovement
	m_aCharStatTags[23]=HearingRadius
	m_aCharStatTags[24]=CombatSims
	m_aCharStatTags[25]=FlankingCritChance
	m_aCharStatTags[26]=ShieldHP
	m_aCharStatTags[27]=Job
	m_aCharStatTags[28]=FlankingAimBonus
}