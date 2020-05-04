//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_AgentJulian.uc
//           
//	The X2DownloadableContentInfo class provides basic hooks into XCOM gameplay events. 
//  Ex. behavior when the player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_AgentJulian extends X2DownloadableContentInfo;


var config(GameData_DialogueData) array<RuleTemplateData>  Rules;
var config(GameData_DialogueData) array<DialogueResponseLine> Responses;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{	
	// local XComGameState NewGameState;
	// local XComGameState_HeadquartersDio DioHQ;
	// local XComGameState_Unit UnitState;
	// local int i;
	// local XComGameStateHistory History;

	// `log("XCOM JULIAN - saved game (one time only)");
	// DioHQ = class'UIUtilities_DioStrategy'.static.GetDioHQ();
	// History = `XCOMHISTORY;
	// for(i = 0; i < DioHQ.Squad.Length; i++)
	// {
	// 	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(DioHQ.Squad[i].ObjectID));
	// 	if(UnitState.GetSoldierClassTemplateName() == 'RM_JulianClass')
	// 	{
	// 		`log("XCOM JULIAN - already in HQ");
	// 		return; // don't do anything
	// 	}
	// }
	// // we get this far, there's no Julian at Chimera HQ
	// NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Fill Squad with All Agent Classes");
	// DioHQ = XComGameState_HeadquartersDio(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDio', `DIOHQ.ObjectID));


	// DioHQ.CreateSquadUnit(NewGameState, 'CA_RM_Julian');
	
	
	// `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);	
}

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{

}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed. When a new campaign is started the initial state of the world
/// is contained in a strategy start state. Never add additional history frames inside of InstallNewCampaign, add new state objects to the start state
/// or directly modify start state objects
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	// local XComGameState_HeadquartersDio DioHQ;

	// // Retrieve the strategy inventory object
	// foreach StartState.IterateByClassType(class'XComGameState_HeadquartersDio', DioHQ)
	// {
	// 	break;
	// }	

	// if(DioHQ != none)
	// 	DioHQ.CreateSquadUnit(StartState, 'CA_RM_Julian');
	
}

/// <summary>
/// Called just before the player launches into a tactical a mission while this DLC / Mod is installed.
/// Allows dlcs/mods to modify the start state before launching into the mission
/// </summary>
static event OnPreMission(XComGameState StartGameState, XComGameState_MissionSite MissionState)
{

}

/// <summary>
/// Called when the player completes a mission while this DLC / Mod is installed.
/// </summary>
static event OnPostMission()
{

}

/// <summary>
/// Called when the player is doing a direct tactical->tactical mission transfer. Allows mods to modify the
/// start state of the new transfer mission if needed
/// </summary>
static event ModifyTacticalTransferStartState(XComGameState TransferStartState)
{

}

/// <summary>
/// Called after the player exits the post-mission sequence while this DLC / Mod is installed.
/// </summary>
static event OnExitPostMissionSequence()
{

}

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	AlterSquadArrays();
	AlterAbilitiesForHello();
	AlterDialogue();
}

static function AlterDialogue()
{
	local XComGameState_DialogueManager DialogueClass;
	local int i;

	DialogueClass = XComGameState_DialogueManager(class'Engine'.static.FindClassDefaultObject("XComGame.XComGameState_DialogueManager"));

	for(i = 0; i < default.Rules.Length; i++)
	{
		DialogueClass.Rules.AddItem(default.Rules[i]);
	}

	for(i = 0; i < default.Responses.Length; i++)
	{
		DialogueClass.Responses.AddItem(default.Responses[i]);
	}	

}

static function AlterAbilitiesForHello()
{
	local X2AbilityTemplateManager							AbilityManager;
	local X2AbilityTemplate									AbilityTemplate;
	local X2Effect_HelloThereDamage						WorldDamage;
	local X2Condition_HelloThere							HelloCondition;
	local X2Condition_AbilityProperty						AbilityCondition;
	local array<name>										AbilitiesToAlter;
	local Name												CurrentAbility;
	// go through the various shoot abilites Julian can get and add the effects of hello there to them
	AbilityManager =class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilitiesToAlter.Length = 0;

	AbilitiesToAlter.AddItem('StandardShot');
	AbilitiesToAlter.AddItem('Deadeye');
	//AbilitiesToAlter.AddItem('MovingFireShot');
	AbilitiesToAlter.AddItem('KillZoneOverwatchShot');
	AbilitiesToAlter.AddItem('RapidFire');
	AbilitiesToAlter.AddItem('RapidFire2');
	AbilitiesToAlter.AddItem('HailOfBullets');	
	AbilitiesToAlter.AddItem('OverwatchShot');
	AbilitiesToAlter.AddItem('RM_LeadTheTargetShot');
	foreach AbilitiesToAlter(CurrentAbility)
	{
		AbilityTemplate = AbilityManager.FindAbilityTemplate(CurrentAbility);
		if(AbilityTemplate != none)
		{
			WorldDamage = new class'X2Effect_HelloThereDamage';
			WorldDamage.bUseWeaponDamageType = true;
			WorldDamage.bUseWeaponEnvironmentalDamage = false;
			WorldDamage.EnvironmentalDamageAmount = 100;
			WorldDamage.bApplyOnHit = false;
			WorldDamage.bApplyOnMiss = false;
			WorldDamage.bApplyToWorldOnHit = true;
			WorldDamage.bApplyToWorldOnMiss = true;
			WorldDamage.bHitAdjacentDestructibles = true;
			WorldDamage.PlusNumZTiles = 1;
			WorldDamage.bHitTargetTile = true;
			WorldDamage.bAllowDestructionOfDamageCauseCover = true;
			HelloCondition = new class'X2Condition_HelloThere';
			AbilityCondition = new class'X2Condition_AbilityProperty';
			AbilityCondition.OwnerHasSoldierAbilities.AddItem('RM_JulianHello');
			WorldDamage.TargetConditions.AddItem(HelloCondition);
			WorldDamage.TargetConditions.AddItem(AbilityCondition);
			AbilityTemplate.AddTargetEffect(WorldDamage);
		}

	}

	AbilityTemplate = AbilityManager.FindAbilityTemplate('SkirmisherStrike');
	AbilityTemplate.bDontDisplayInAbilitySummary = true;

	AbilityTemplate = AbilityManager.FindAbilityTemplate('SoulHarvester');
	AbilityTemplate.bDontDisplayInAbilitySummary = true;	

}
static function AlterSquadArrays()
{
	local int i;

	for(i = 0; i < class'UITacticalQuickLaunch_MapData'.default.Squads.Length; i++)
	{
		if(class'UITacticalQuickLaunch_MapData'.default.Squads[i].SquadID == 'DioPlayableCast' || 
			class'UITacticalQuickLaunch_MapData'.default.Squads[i].SquadID == 'DioDebugStart')
		{
			class'UITacticalQuickLaunch_MapData'.default.Squads[i].SoldierIDs.additem('CA_RM_Julian');
		}
	}
}

exec function ShowSquadArrays()
{
	local ConfigurableSquad squad;
	local name soldierID;
	foreach class'UITacticalQuickLaunch_MapData'.default.Squads(squad)
	{
		if(squad.SquadID == 'DioPlayableCast' || squad.SquadID == 'DioDebugStart')
		{
			`log("Our array " $ squad.SquadID $ " is: ");
			foreach squad.SoldierIDs(soldierID)
			{
				`log(soldierID);
			}
		}
	}

}

exec function AddJulianToHQ()
{
	local XComGameState NewGameState;
	local XComGameState_HeadquartersDio DioHQ;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Fill Squad with All Agent Classes");
	DioHQ = XComGameState_HeadquartersDio(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDio', `DIOHQ.ObjectID));


	DioHQ.CreateSquadUnit(NewGameState, 'CA_RM_Julian');
	
	
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

/// <summary>
/// Called when the difficulty changes and this DLC is active
/// </summary>
static event OnDifficultyChanged()
{
	// local XComGameState NewGameState;
	// local XComGameState_HeadquartersDio DioHQ;
	// local XComGameState_Unit UnitState;
	// local int i;
	// local XComGameStateHistory History;

	// DioHQ = `DIOHQ;
	// History = `XCOMHISTORY;
	// for(i = 0; i < DioHQ.Squad.Length; i++)
	// {
	// 	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(DioHQ.Squad[i].ObjectID));
	// 	if(UnitState.GetSoldierClassTemplateName() == 'RM_JulianClass')
	// 	{
	// 		`log("XCOM JULIAN - already in HQ");
	// 		return; // don't do anything
	// 	}
	// }
	// // we get this far, there's no Julian at Chimera HQ
	// NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("CHEAT: Fill Squad with All Agent Classes");
	// DioHQ = XComGameState_HeadquartersDio(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersDio', `DIOHQ.ObjectID));


	// DioHQ.CreateSquadUnit(NewGameState, 'CA_RM_Julian');
	
	
	// `XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
}

/// <summary>
/// Called by the Geoscape tick
/// </summary>
static event UpdateDLC()
{

}

/// <summary>
/// Called after HeadquartersAlien builds a Facility
/// </summary>
static event OnPostAlienFacilityCreated(XComGameState NewGameState, StateObjectReference MissionRef)
{

}

/// <summary>
/// Called after a new Alien Facility's doom generation display is completed
/// </summary>
static event OnPostFacilityDoomVisualization()
{

}

/// <summary>
/// Called when viewing mission blades, used primarily to modify tactical tags for spawning
/// Returns true when the mission's spawning info needs to be updated
/// </summary>
static function bool ShouldUpdateMissionSpawningInfo(StateObjectReference MissionRef)
{
	return false;
}

/// <summary>
/// Called when viewing mission blades, used primarily to modify tactical tags for spawning
/// Returns true when the mission's spawning info needs to be updated
/// </summary>
static function bool UpdateMissionSpawningInfo(StateObjectReference MissionRef)
{
	return false;
}

/// <summary>
/// Called when viewing mission blades, used to add any additional text to the mission description
/// </summary>
static function string GetAdditionalMissionDesc(StateObjectReference MissionRef)
{
	return "";
}

/// <summary>
/// Called from X2AbilityTag:ExpandHandler after processing the base game tags. Return true (and fill OutString correctly)
/// to indicate the tag has been expanded properly and no further processing is needed.
/// </summary>
static function bool AbilityTagExpandHandler(string InString, out string OutString)
{	
	local name Type;

	Type = name(InString);

	switch(Type)
	{
	case 'JULIANREFLEXES':
		OutString = string(class'X2Ability_JulianSet'.default.JULIAN_REFLEXES_BONUS);
		return true;
	case 'LEAD_TARGET_COOLDOWN':
		OutString = string(class'X2Ability_JulianSet'.default.LEAD_TARGET_COOLDOWN);
		return true;	
	default:
		return false;
	}
	return false;
}

/// <summary>
/// Called from XComGameState_Unit:GatherUnitAbilitiesForInit after the game has built what it believes is the full list of
/// abilities for the unit based on character, class, equipment, et cetera. You can add or remove abilities in SetupData.
/// </summary>
static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{

}

/// <summary>
/// Calls DLC specific popup handlers to route messages to correct display functions
/// </summary>
static function bool DisplayQueuedDynamicPopup(DynamicPropertySet PropertySet)
{

}