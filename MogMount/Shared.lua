local _, addon = ...;
local ns = select(2,...);
local MogMount = ns.MogMount;

local playerName = UnitName("player");



function MogMountSortAlphabetical(a, b)

	return a.name:lower() < b.name:lower();

end



function MogMount:hasValue(table, value)

	for i, v in ipairs(table) do
		if v == value then
			return true;
		end
	end

	return false;

end



function MogMount:GetCollectedMounts()

	
	local collectedMounts = {};
	local mountIDs = C_MountJournal.GetMountIDs();

	for _, mountID in ipairs(mountIDs) do
		local name, _, _, _, isUsable, _, _, _, _, shouldHideOnChar, isCollected, mountID_, _ = C_MountJournal.GetMountInfoByID(mountID);
		if isCollected and not shouldHideOnChar then
			table.insert(collectedMounts, mountID_);
		end
	end

	return collectedMounts;

end



function MogMount:sortMounts(mountsRaw)

	local EXCLUDED_MOUNTS = {
		["Qiraji Battle Tank"] = true,
		["Blue Qiraji Battle Tank"] = true,
		["Red Qiraji Battle Tank"] = true,
		["Yellow Qiraji Battle Tank"] = true,
		["Green Qiraji Battle Tank"] = true,
	}

	local mounts = {};

	for i = 1, #mountsRaw do

		name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isSteadyFlight = C_MountJournal.GetMountInfoByID(mountsRaw[i]);
		creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountsRaw[i]);
		
		local temp = {};
		temp["name"] = name;
		temp["icon"] = icon;
		temp["nameAndIcon"] = "|T"..icon..":18|t "..name;
		temp["id"] = mountID;
		temp["model"] = creatureDisplayInfoID;
		temp["mountTypeID"] = mountTypeID;
		
		if isCollected and not shouldHideOnChar and not EXCLUDED_MOUNTS[name]  then
			table.insert(mounts, temp);
		end

	end

	table.sort(mounts, MogMountSortAlphabetical);

	return mounts;

end



function MogMount:listSearchString(name)

	if MogMount.MountSearchString == "" or MogMount.MountSearchString == nil or string.len(MogMount.MountSearchString) < 2 then
		return true;
	elseif string.len(MogMount.MountSearchString) >= 2 and string.find(name:lower(), MogMount.MountSearchString:lower()) then
		return true;
	else
		return false;
	end

end



-- Mount Type IDs reference:
-- 230  = Ground
-- 231  = Aquatic (basic underwater)
-- 232  = Aquatic (amphibious / can also walk)
-- 241  = Aquatic (unused but safe to include)
-- 248  = Flying (old steady flight)
-- 249  = Flying (Dragonriding / Skyriding)
-- 254  = Aquatic (sea turtle style)
-- 278  = Hybrid ground/flying (included in flying)
-- 407  = Aquatic variant
-- 417  = Aquatic variant (Underlight Angler etc)
-- 436  = Aquatic variant

local flyingMountTypeIDs    = {248, 249, 278};
local aquaticMountTypeIDs   = {231, 232, 241, 254, 407, 417, 436};



function MogMount:getSortedFlyingMounts()

	local mountsRaw = MogMount:sortMounts(MogMount:GetCollectedMounts());
	local mounts = {};

	-- Build a lookup of dragonriding mount IDs
	local dragonridingIDs = {};
	local drIDs = C_MountJournal.GetCollectedDragonridingMounts();
	for _, id in ipairs(drIDs) do
		dragonridingIDs[id] = true;
	end

	for i = 1, #mountsRaw do
		local mount = mountsRaw[i];
		local isFlyingType   = MogMount:hasValue(flyingMountTypeIDs, mount.mountTypeID);
		local isDragonriding = dragonridingIDs[mount.id] == true;
		local showAll        = MogMountSaved and MogMountSaved.ShowAllInFlying;

		if (isFlyingType or isDragonriding or showAll) and MogMount:listSearchString(mount.name) then
			table.insert(mounts, mount);
		end
	end 

	return mounts;

end



function MogMount:getSortedGroundMounts()

	local mountsRaw = MogMount:sortMounts(MogMount:GetCollectedMounts());
	local mounts = {};

	-- Build dragonriding lookup
	local dragonridingIDs = {};
	local drIDs = C_MountJournal.GetCollectedDragonridingMounts();
	for _, id in ipairs(drIDs) do
		dragonridingIDs[id] = true;
	end

	local showFlyingInGround = MogMountSaved and MogMountSaved.ShowFlyingInGround;

	for i = 1, #mountsRaw do
		local mount = mountsRaw[i];
		local isGround    = mount.mountTypeID == 230;
		local isFlyingType = MogMount:hasValue(flyingMountTypeIDs, mount.mountTypeID) or dragonridingIDs[mount.id];

		if (isGround or (isFlyingType and showFlyingInGround)) and MogMount:listSearchString(mount.name) then
			table.insert(mounts, mount);
		end
	end

	return mounts;

end



function MogMount:getSortedAquaticMounts()

	local mountsRaw = MogMount:sortMounts(MogMount:GetCollectedMounts());
	local mounts = {};

	for i = 1, #mountsRaw do
		local mount = mountsRaw[i];
		if MogMount:hasValue(aquaticMountTypeIDs, mount.mountTypeID) and MogMount:listSearchString(mount.name) then
			table.insert(mounts, mount);			
		end
	end

	return mounts;

end



function MogMount:getSortedSpecialMounts()

	local mountsRaw = MogMount:sortMounts(MogMount:GetCollectedMounts());
	local mounts = {};
	local specialMountIDs = {460, 280, 284, 273, 274, 1039, 2237};

	for i = 1, #mountsRaw do
		local mount = mountsRaw[i];
		if MogMount:hasValue(specialMountIDs, mount.id) then
			table.insert(mounts, mount);
		end
	end

	return mounts;

end



function MogMount:getSortedAlternativeMounts()

	local mountsRaw = MogMount:sortMounts(MogMount:GetCollectedMounts());
	local mounts = {};

	for i = 1, #mountsRaw do
		local mount = mountsRaw[i];
		table.insert(mounts, mount);
	end

	return mounts;

end



function MogMount:getRandomMount(type)

	local mounts = {}

	if type == "flying" then
		mounts = MogMount:getSortedFlyingMounts();
	elseif type == "ground" then
		mounts = MogMount:getSortedGroundMounts();
	elseif type == "aquatic" then
		mounts = MogMount:getSortedAquaticMounts();
	elseif type == "special" then
		mounts = MogMount:getSortedSpecialMounts();
	elseif type == "alternative" then
		mounts = MogMount:getSortedAlternativeMounts();		
	else
		mounts = MogMount:getSortedFlyingMounts();
	end

	if #mounts == 0 then
		return nil;
	end
	
	local rand = math.random(1, #mounts);

	return mounts[rand];

end



local function CreateDisplayTitle(titleID)

	local title, _ = GetTitleName(titleID);
	local displayTitle = "";

	if titleID == 0 then
		return playerName;
	end

	if title:sub(-1) == " " then
		displayTitle = title..playerName;
	else
		displayTitle = playerName.." "..title;
	end

	return displayTitle;

end



function MogMount:getSortedTitles()

	local titlesRaw = {}
	local count = 1;

	for i = 1, GetNumTitles() do
		if IsTitleKnown(i) then
			titlesRaw[count] = {};
			titlesRaw[count].id = i;
			titlesRaw[count].name = CreateDisplayTitle(i);
			count = count + 1;				
		end
	end

	table.sort(titlesRaw, MogMountSortAlphabetical)

	return titlesRaw;
end



function MogMount:UpdateSelectMountDetails(type, id)

	name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isSteadyFlight = C_MountJournal.GetMountInfoByID(id);
	creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(id);
			
	MogMountSelectedMount[type].name = name;
	MogMountSelectedMount[type].spellID = name;
	MogMountSelectedMount[type].icon = icon;
	MogMountSelectedMount[type].id = mountID;
	MogMountSelectedMount[type].display = creatureDisplayInfoID;
	MogMountSelectedMount[type].type = mountTypeID;

end



function MogMount:CreateEmptyOutfit(id)

	if MogMountCharacterSaved ~= nil and MogMountCharacterSaved["Outfit"..id] == nil then
		MogMountCharacterSaved["Outfit"..id] = {};
		MogMountCharacterSaved["Outfit"..id].Flying  = 1;
		MogMountCharacterSaved["Outfit"..id].Ground  = 1;
		MogMountCharacterSaved["Outfit"..id].Aquatic = 1;
		MogMountCharacterSaved["Outfit"..id].Title   = 0;
	end

	-- Migrate old outfits that pre-date the Aquatic field
	if MogMountCharacterSaved ~= nil
	and MogMountCharacterSaved["Outfit"..id] ~= nil
	and MogMountCharacterSaved["Outfit"..id].Aquatic == nil then
		MogMountCharacterSaved["Outfit"..id].Aquatic = 1;
	end

end
