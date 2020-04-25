class X2Ability_JulianSet extends X2Ability config(GameData_SoldierStats);

var config int JULIAN_REFLEXES_BONUS;
var config float KILL_CONFIRM_DAMAGE_MULTIPLIER;
// ; Hello There - the first two shots with the assault rifle destroys cover even if they miss
// Robotic Reflexes - reaction fire gains +20 aim and can crit
// Kill Confirmer - the last two shots with the assault rifle deal double damage
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Abilities;

    Abilities.AddItem(CreateJulianSkirmisher());
    Abilities.AddItem(CreateJulianHello());
    Abilities.AddItem(CreateJulianReflexes());
    Abilities.AddItem(CreateJulianKillConfirm());
    return Abilities;
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
