class X2Character_Julian extends X2Character_DefaultCharacters;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateJulianTemplate());

	return Templates;
}
static function X2CharacterTemplate CreateJulianTemplate()
{
	local X2CharacterTemplate CharTemplate;

	CharTemplate = CreateSoldierTemplate('RM_XComJulian');
	CharTemplate.DefaultSoldierClass = 'RM_JulianClass';
	CharTemplate.DefaultLoadout = 'RM_JulianLoadout';
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_Xcom.ARC_GameUnit_Android");
	CharTemplate.strPawnArchetypeHQ = "gameunit_rm_julian.ARC_GameUnit_Android";
	//CharTemplate.strMatineePackages.AddItem("CIN_Gunslinger");
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bIsRobotic = true;

	CharTemplate.bCanBeCriticallyWounded = true;
	CharTemplate.bIsAfraidOfFire = false;
	CharTemplate.bCanBeCarried = true;
	CharTemplate.bCanBeRevived = true;

	CharTemplate.Abilities.AddItem('RobotImmunities');

	//CharTemplate.DefaultAppearance.nmVoiceSet.AddItem('AndroidFemale');
	CharTemplate.DefaultAppearance.nmVoice = 'AndroidMale';
	//`log("JULIAN AGENT: We are " $ CharTemplate.DataName);
	return CharTemplate;
}