class X2Ability_JulianSet extends X2Ability config(GameData_SoldierStats);

var config int JULIAN_REFLEXES_BONUS;
var config float KILL_CONFIRM_DAMAGE_MULTIPLIER;
var config int LEAD_TARGET_COOLDOWN;

var name					LeadTheTargetMarkEffectName;
var name					LeadTheTargetReserveActionName;
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Abilities;

    Abilities.AddItem(CreateJulianSkirmisher());
    Abilities.AddItem(CreateJulianHello());
    Abilities.AddItem(CreateJulianReflexes());
    Abilities.AddItem(CreateJulianKillConfirm());
	Abilities.AddItem(RM_LeadTheTarget());
	Abilities.AddItem(RM_LeadTheTargetShot());
    return Abilities;
}


// Lead The Target - Active: Queue a shot on a target that will be taken on the enemy's turn with an increased chance to hit. Does not count as reaction fire.
static function X2AbilityTemplate RM_LeadTheTarget()
{

	local X2AbilityTemplate										Template;
	local X2AbilityCooldown										Cooldown;
	local X2AbilityCost_Ammo									AmmoCost;
	local X2AbilityCost_ActionPoints							ActionPointCost;
	local X2Effect_ReserveActionPoints							ReservePointsEffect;
	local X2Condition_Visibility								TargetVisibilityCondition;
	local X2Effect_Persistent									MarkEffect;
	

	`CREATE_X2ABILITY_TEMPLATE (Template, 'RM_LeadTheTarget');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bShowPostActivation = true;
	Template.bSkipFireAction = true;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.bCrossClassEligible = false;
	Template.bFeatureInCharacterUnlock = true;
	// Set ability costs, cooldowns, and restrictions
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.LEAD_TARGET_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	AmmoCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;   //  this will guarantee the unit has at least 1 action point
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	ActionPointCost.DoNotConsumeAllEffects.Length = 0;
	ActionPointCost.DoNotConsumeAllSoldierAbilities.Length = 0;
	ActionPointCost.AllowedTypes.RemoveItem(class'X2CharacterTemplateManager'.default.SkirmisherInterruptActionPoint);
	Template.AbilityCosts.AddItem(ActionPointCost);

	ReservePointsEffect = new class'X2Effect_ReserveActionPoints';
	ReservePointsEffect.ReserveType = default.LeadTheTargetReserveActionName;
	Template.AddShooterEffect(ReservePointsEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);
	Template.bIgnoreCoverMitigation = true;

	// Create effect to identify the SourceUnit and facilitate charge counting post-mission and to show a passive icon in the tactical UI
	MarkEffect = new class'X2Effect_Persistent';
	MarkEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	MarkEffect.EffectName = default.LeadTheTargetMarkEffectName;
	MarkEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, Template.LocLongDescription, Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(MarkEffect);

	Template.AdditionalAbilities.AddItem('RM_LeadTheTargetShot');


	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	return Template;
}

// Lead The Target Shot - Passive: Triggered Lead the Target shot fired at the enemy
static function X2AbilityTemplate RM_LeadTheTargetShot()
{
	local X2AbilityTemplate										Template;
	local X2AbilityCost_Ammo									AmmoCost;
	local X2AbilityCost_ReserveActionPoints						ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim						StandardAim;
	local X2AbilityTarget_Single								SingleTarget;
	local X2AbilityTrigger_EventListener						Trigger;
	local X2Condition_Visibility								TargetVisibilityCondition;
	local X2Condition_UnitEffectsWithAbilitySource				TargetEffectCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_LeadTheTargetShot');

	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem(default.LeadTheTargetReserveActionName);
	Template.AbilityCosts.AddItem(ReserveActionPointCost);
	Template.bIgnoreCoverMitigation = true;
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bReactionFire = false;
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;
		
	TargetEffectCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	TargetEffectCondition.AddRequireEffect(default.LeadTheTargetMarkEffectName, 'AA_MissingRequiredEffect');
	Template.AbilityTargetConditions.AddItem(TargetEffectCondition);
	
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	//Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	SingleTarget = new class'X2AbilityTarget_Single';
	SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	Template.bAllowAmmoEffects = true;
	Template.bAllowBonusWeaponEffects = true;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);
	//  trigger on an attack
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'AbilityActivated';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalAttackListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_overwatch";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_aim";
	Template.bUsesFiringCamera = true;
	Template.bShowActivation = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

static function X2AbilityTemplate CreateJulianKillConfirm()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_ConditionalDamageModifier		DamageModifierEffect;
	local X2Condition_AbilitySourceWeapon   WeaponCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_JulianKillConfirm');

	Template.IconImage = class'UIUtilities'.static.GetAbilityIconPath('FondFarewell');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	DamageModifierEffect = new class'X2Effect_ConditionalDamageModifier';
	DamageModifierEffect.BuildPersistentEffect(1, true, false, false);
	DamageModifierEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	DamageModifierEffect.bModifyOutgoingDamage = true;
	DamageModifierEffect.bDisplayInSpecialDamageMessageUI = true;
	DamageModifierEffect.DamageModifier = default.KILL_CONFIRM_DAMAGE_MULTIPLIER;
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('MovingFireShot');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('StandardShot');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('Deadeye');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('KillZoneOverwatchShot');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('RapidFire');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('RapidFire2');
	DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('HailOfBullets');
    DamageModifierEffect.RequireAbilityNamesToApplyOutgoingDamageMod.AddItem('OverwatchShot');
	WeaponCondition = new class'X2Condition_AbilitySourceWeapon';
	WeaponCondition.AddAmmoCheck( 2, eCheck_LessThanOrEqual, 2, 2); // Only passes condition if there's two rounds or less
	DamageModifierEffect.ApplyDamageModConditions.AddItem(WeaponCondition);
	Template.AddTargetEffect(DamageModifierEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}
static function X2AbilityTemplate CreateJulianReflexes()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle                  TargetStyle;
	local X2AbilityTrigger						Trigger;
	local X2Effect_ModifyReactionFire           ReactionFire;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_JulianReflexes');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_coolpressure";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	ReactionFire = new class'X2Effect_ModifyReactionFire';
	ReactionFire.bAllowCrit = true;
	ReactionFire.ReactionModifier = default.JULIAN_REFLEXES_BONUS;
	ReactionFire.BuildPersistentEffect(1, true, true, true);
	ReactionFire.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(ReactionFire);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate CreateJulianHello()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityTrigger					Trigger;
	local X2AbilityTarget_Self				TargetStyle;
	local X2Effect_Persistent           PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RM_JulianHello');

	Template.IconImage = class'UIUtilities'.static.GetAbilityIconPath('WarmWelcome');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  This is a dummy effect so that an icon shows up in the UI.
	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	return Template;
}

static function X2AbilityTemplate CreateJulianSkirmisher()
{
	local X2AbilityTemplate                 Template;
	Template = PurePassive('RM_JulianSkirmisherStrike', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_strike");
	//Template.bBreachAbility = true;
    Template.AdditionalAbilities.AddItem('SkirmisherStrike');
	return Template;
}

defaultproperties
{
	LeadTheTargetMarkEffectName = "RM_LeadTheTargetMarked";
	LeadTheTargetReserveActionName = "RM_LeadTheTargetAction";
}