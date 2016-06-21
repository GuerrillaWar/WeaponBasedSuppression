class WeaponBasedSuppression_AddSuppressionToWeapons extends Object config(WeaponBasedSuppression);

var const config array<name> WeaponsWithSuppression;

static function AddSuppressionAbilities()
{
	local X2ItemTemplateManager Manager;
	local XComGameStateHistory History;
	local XComGameStateContext_StrategyGameRule StrategyStartContext;
	local XComGameState StartState;
	local XComGameState_CampaignSettings Settings;
	local int DifficultyIndex;
	local array<X2WeaponTemplate> Templates;
	local X2WeaponTemplate Template;

	Manager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	History = `XCOMHISTORY;
	
	StrategyStartContext = XComGameStateContext_StrategyGameRule(class'XComGameStateContext_StrategyGameRule'.static.CreateXComGameStateContext());
	StrategyStartContext.GameRuleType = eStrategyGameRule_StrategyGameStart;
	StartState = History.CreateNewGameState(false, StrategyStartContext);
	History.AddGameStateToHistory(StartState);

	Settings = new class'XComGameState_CampaignSettings'; // Do not use CreateStateObject() here
	StartState.AddStateObject(Settings);
	
	for( DifficultyIndex = `MIN_DIFFICULTY_INDEX; DifficultyIndex <= `MAX_DIFFICULTY_INDEX; ++DifficultyIndex )
	{
		`log("WeaponBasedSuppression :: Iterating difficulty templates for" @ DifficultyIndex);
		Settings.SetDifficulty(DifficultyIndex);
		Templates = Manager.GetAllWeaponTemplates();

		foreach Templates(Template)
		{
			if (default.WeaponsWithSuppression.Find(Template.WeaponCat) != -1 ||
				default.WeaponsWithSuppression.Find(Template.DataName) != -1)
			{
				`log("WeaponBasedSuppression :: Adding Suppression Ability to" @ Template.DataName);
				AddSuppressionAbility(Template);
			}
		}
	}
	History.ResetHistory(); // Discard the history
}

static function AddSuppressionAbility(X2WeaponTemplate Template)
{
	Template.Abilities.AddItem('Suppression');
	class'X2ItemTemplateManager'.static.GetItemTemplateManager().AddItemTemplate(Template, true);
}
