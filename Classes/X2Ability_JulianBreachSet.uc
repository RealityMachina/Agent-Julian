class X2Ability_JulianBreachSet extends X2Ability_BreachAbilities;

/// <summary>
/// Creates the set of default abilities every unit should have in X-Com 2
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
		
	Templates.AddItem(AddBreachJulianAbility());

	return Templates;	
}
static function X2AbilityTemplate AddBreachJulianAbility()
{
	local X2AbilityTemplate         Template;
	local X2Condition				LoopCondition;
	local X2Condition_Visibility	VisibilityCondition;
	local X2AbilityToHitCalc_StandardAim StandardAim;
	local X2Effect_ApplyDirectionalWorldDamage		WorldDamage;
	local X2AbilityCost_Ammo            AmmoCost;

	Template = class'X2Ability_WeaponCommon'.static.Add_StandardShot('RM_BreachJulianAbility');
	Template.BuildInterruptGameStateFn = None;
	Template.bDontDisplayInAbilitySummary = false;
	if (default.SKIP_BREACH_VISUALIZATION)
	{
		Template.BuildVisualizationFn = None;
	}
	Template.AbilityCosts.Length = 0;
	Template.AbilityTriggers.Length = 0;
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_Placeholder');
	if (!`DIO_DEBUG_SHOW_ALL_BREACH_ABILITY_ICONS)
		Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailableOrNoTargets;
	
	Template.AbilitySourceName = 'eAbilitySource_Perk'; // color of the icon
	Template.IconImage = "img:///UILibrary_Common.Ability_LancerShot";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.BREACH_CLASS_PRIORITY;
	Template.bLimitTargetIcons = true;
//	Template.bFragileDamageOnly = true;

	// Breach Targeting: Ignore gameplay visible, just check Room
	foreach Template.AbilityTargetConditions(LoopCondition)
	{
		VisibilityCondition = X2Condition_Visibility(LoopCondition);
		if (VisibilityCondition != None)
		{
			VisibilityCondition.bRequireGameplayVisible = false;
			if (!class'X2TacticalGameRuleset'.default.bAllowBreachFireAtAllRoomEnemies)
			{
				VisibilityCondition.bRequireBreachVisibility = true;
			}

		}
	}

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_Room');
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.default.LivingHostileUnitOnlyProperty);
	// End: Breach Targeting

	if (!default.SKIP_BREACH_VISUALIZATION)
	{
		Template.bManualBreachTargeting = true;
		Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
		Template.bUsesFiringCamera = true;
		Template.CinescriptCameraType = "";
	}

	Template.AssociatedPlayTiming = SPT_AfterSequential;
	Template.bIgnoreCoverMitigation = true;
	Template.bIgnoreArmorMitigation = true;

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
//	StandardAim.bIgnoreCoverBonus = true;
	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;

	
	WorldDamage = new class'X2Effect_ApplyDirectionalWorldDamage';
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
	Template.AddTargetEffect(WorldDamage);

	 //Ammo Cost of Use
	 AmmoCost = new class'X2AbilityCost_Ammo';
	 AmmoCost.iAmmo = 1;
	 Template.AbilityCosts.AddItem(AmmoCost);

	Template.bRequireTargetDuringBreach = true;

	Template.bFeatureInCharacterUnlock = true;

	return Template;
}