class X2Item_Julian extends X2Item config(GameData_WeaponData);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

    Weapons.AddItem(CreateTemplate_JulianRifle());

    return Weapons;
}

static function X2DataTemplate CreateTemplate_JulianRifle()
{
	local X2WeaponTemplate Template;

	Template = X2WeaponTemplate(class'X2Item_DefaultWeapons'.static.CreateTemplate_XComSMG('WPN_RM_JulianRifle'));
//	Template.bIsEpic = true;
//	Template.bLimitOneOwned = true;
	Template.GameArchetype = "WP_JulianRifle.WP_JulianRifle_Mag";
//	Template.EquipSound = "UI_Strategy_Armory_Equip_WeaponEpic";
	Template.WeaponCat = 'JulianRifle';
//	Template.Abilities.AddItem('ChainShot');
	Template.strImage = "img:///UILibrary_Common.Armory_W_AssaultRifle_R";
//	Template.strImage = "img:///wp_mod_$ModSafeName$_cv.CentralAR";
//	Template.LeavesExplosiveRemains = false;
//	Template.bAlwaysRecovered = true;

	Template.Abilities.Length = 0;
	
	Template.BaseDamage = class'X2Item_DefaultWeapons'.default.EPICSMG1_BASEDAMAGE;
	Template.Aim = class'X2Item_DefaultWeapons'.default.EPICSMG1_AIM;
	Template.CritChance = class'X2Item_DefaultWeapons'.default.EPICSMG1_CRITCHANCE;
	Template.iClipSize = class'X2Item_DefaultWeapons'.default.EPICSMG1_ICLIPSIZE;
	Template.iEnvironmentDamage = class'X2Item_DefaultWeapons'.default.EPIC_SMG_IENVIRONMENTDAMAGE;

	return Template;
}
