local addonName, addon = ...
local ns = select(2,...)
local MogMount = CreateFrame('Frame', 'MogMountAddonFrame', UIParent)

ns.MogMount = MogMount;
local L = MogMountLocales;



local playerName = UnitName("player");
local transmogs = {};
local loaded = false;
local firstLoad = true;
local titleLoaded = false;

local TitleDropdown;

local MogMountFrame;
local flyingMountFrame,  flyingMountTexture,  flyingMountBorder,  flyingMountBorderTexture,  flyingMountBorderHighlightTexture;
local groundMountFrame,  groundMountTexture,  groundMountBorder,  groundMountBorderTexture,  groundMountBorderHighlightTexture;
local aquaticMountFrame, aquaticMountTexture, aquaticMountBorder, aquaticMountBorderTexture, aquaticMountBorderHighlightTexture;

local FlyingMountModel, GroundMountModel;

local FlyingMountListScrollView,  FlyingMountListScrollBox,  FlyingMountListScrollBar,  FlyingMountSelectionBehavior;
local GroundMountListScrollView,  GroundMountListScrollBox,  GroundMountListScrollBar,  GroundMountSelectionBehavior;
local AquaticMountListScrollView, AquaticMountListScrollBox, AquaticMountListScrollBar, AquaticMountSelectionBehavior;
local AquaticMountModel;

local FlyingMountClear, GroundMountClear, AquaticMountClear;
local SetSelectedFlyingMount, SetSelectedGroundMount, SetSelectedAquaticMount;

local SetupReminderFrame;
local MountListSearchBox, FilterDropdown;

MogMount.MountSearchString = "";

MogMountSelectedMount          = {};
MogMountSelectedMount.Flying   = {};
MogMountSelectedMount.Ground   = {};
MogMountSelectedMount.Aquatic  = {};



function getEmptyMountIcon()

	local _, raceName, raceID = UnitRace("Player");

	local emptyFlyingMountIcon  = 773274;
	local emptyGroundMountIcon  = 2143092;
	local emptyAquaticMountIcon = 132328;  -- generic water / seahorse icon

	if raceID == 1 then
		emptyFlyingMountIcon = 773274;   emptyGroundMountIcon = 2143092;
	elseif raceID == 2 then
		emptyFlyingMountIcon = 773276;   emptyGroundMountIcon = 132224;
	elseif raceID == 3 then
		emptyFlyingMountIcon = 294468;   emptyGroundMountIcon = 132248;
	elseif raceID == 4 then
		emptyFlyingMountIcon = 2020396;  emptyGroundMountIcon = 132225;
	elseif raceID == 5 then
		emptyFlyingMountIcon = 1321546;  emptyGroundMountIcon = 132264;
	elseif raceID == 6 then
		emptyFlyingMountIcon = 773276;   emptyGroundMountIcon = 132243;
	elseif raceID == 7 then
		emptyFlyingMountIcon = 132240;   emptyGroundMountIcon = 132247;
	elseif raceID == 8 then
		emptyFlyingMountIcon = 1321546;  emptyGroundMountIcon = 132253;
	elseif raceID == 9 then
		emptyFlyingMountIcon = 6126218;  emptyGroundMountIcon = 1408996;
	elseif raceID == 10 then
		emptyFlyingMountIcon = 132188;   emptyGroundMountIcon = 132227;
	elseif raceID == 11 then
		emptyFlyingMountIcon = 132191;   emptyGroundMountIcon = 132254;
	elseif raceID == 22 then
		emptyFlyingMountIcon = 2020396;  emptyGroundMountIcon = 132261;
	elseif raceID == 24 or raceID == 25 or raceID == 26 then
		emptyFlyingMountIcon = 648627;   emptyGroundMountIcon = 656344;
	elseif raceID == 27 then
		emptyFlyingMountIcon = 132265;   emptyGroundMountIcon = 1781067;
	elseif raceID == 29 then
		emptyFlyingMountIcon = 464141;   emptyGroundMountIcon = 1786404;
	elseif raceID == 30 then
		emptyFlyingMountIcon = 1570763;  emptyGroundMountIcon = 1713157;
	elseif raceID == 31 then
		emptyFlyingMountIcon = 1624590;  emptyGroundMountIcon = 1869253;
	elseif raceID == 32 then
		emptyFlyingMountIcon = 773275;   emptyGroundMountIcon = 2238243;
	elseif raceID == 34 then
		emptyFlyingMountIcon = 526578;   emptyGroundMountIcon = 1992951;
	elseif raceID == 35 then
		emptyFlyingMountIcon = 1929247;  emptyGroundMountIcon = 3045400;
	elseif raceID == 36 then
		emptyFlyingMountIcon = 298596;   emptyGroundMountIcon = 1937816;
	elseif raceID == 37 then
		emptyFlyingMountIcon = 2574427;  emptyGroundMountIcon = 3041211;
	elseif raceID == 52 or raceID == 70 then
		emptyFlyingMountIcon = 4622497;  emptyGroundMountIcon = 4731151;
	elseif raceID == 84 or raceID == 85 then
		emptyFlyingMountIcon = 5306251;  emptyGroundMountIcon = 5767167;
	end

	return emptyFlyingMountIcon, emptyGroundMountIcon, emptyAquaticMountIcon;

end



local function UpdateTitle()

	local SavedCurrentTitle = -1;

	if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Title > 0 then
		SavedCurrentTitle = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Title;
	end

	if SavedCurrentTitle ~= nil and GetCurrentTitle() ~= SavedCurrentTitle and (SavedCurrentTitle == -1 or IsTitleKnown(SavedCurrentTitle)) then
		SetCurrentTitle(SavedCurrentTitle);
	end

end



function MogMountBindingClicked()
	MogMountSummon();
end



function MogMountSummonFlying()

	if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying > 1 then
		C_MountJournal.SummonByID(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying);
	elseif MogMountCharacterSaved.Default.Flying <= 1 then
		local randomMount = MogMount:getRandomMount("flying");
		if randomMount then C_MountJournal.SummonByID(randomMount.id); end
	else
		C_MountJournal.SummonByID(MogMountCharacterSaved.Default.Flying);
	end

end
function MogMountTooltipFlying()

    local mountID;

    if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying > 1 then
        mountID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying;
    elseif MogMountCharacterSaved.Default.Flying > 1 then
        mountID = MogMountCharacterSaved.Default.Flying;
    else
        local randomMount = MogMount:getRandomMount("flying");
        if randomMount then mountID = randomMount.id; end
    end

    if mountID then
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID);
        return name, spellID, icon;
    end

end


function MogMountSummonGround()

	if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground > 1 then
		C_MountJournal.SummonByID(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground);
	elseif MogMountCharacterSaved.Default.Ground <= 1 then
		local randomMount = MogMount:getRandomMount("ground");
		if randomMount then C_MountJournal.SummonByID(randomMount.id); end
	else
		C_MountJournal.SummonByID(MogMountCharacterSaved.Default.Ground);
	end

end
function MogMountTooltipGround()

    local mountID;

    if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground > 1 then
        mountID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground;
    elseif MogMountCharacterSaved.Default.Ground > 1 then
        mountID = MogMountCharacterSaved.Default.Ground;
    else
        local randomMount = MogMount:getRandomMount("ground");
        if randomMount then mountID = randomMount.id; end
    end

    if mountID then
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID);
        return name, spellID, icon;
    end
end



function MogMountSummonAquatic()

	local outfitAquatic = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Aquatic;
	if outfitAquatic and outfitAquatic > 1 then
		C_MountJournal.SummonByID(outfitAquatic);
	elseif MogMountCharacterSaved.Default.Aquatic <= 1 then
		local randomMount = MogMount:getRandomMount("aquatic");
		if randomMount then C_MountJournal.SummonByID(randomMount.id); end
	else
		C_MountJournal.SummonByID(MogMountCharacterSaved.Default.Aquatic);
	end

end
function MogMountTooltipAquatic()

    local mountID;
    local outfitAquatic = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Aquatic;

    if outfitAquatic and outfitAquatic > 1 then
        mountID = outfitAquatic;
    elseif MogMountCharacterSaved.Default.Aquatic > 1 then
        mountID = MogMountCharacterSaved.Default.Aquatic;
    else
        local randomMount = MogMount:getRandomMount("aquatic");
        if randomMount then mountID = randomMount.id; end
    end

    if mountID then
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID);
        return name, spellID, icon;
    end

end



function MogMountSummonSpecial()

	if MogMountCharacterSaved.Default.Special <= 1 then
		local randomMount = MogMount:getRandomMount("special");
		if randomMount then C_MountJournal.SummonByID(randomMount.id); end
	else
		C_MountJournal.SummonByID(MogMountCharacterSaved.Default.Special);
	end

end
function MogMountTooltipSpecial()

    local mountID;

    if MogMountCharacterSaved.Default.Special > 1 then
        mountID = MogMountCharacterSaved.Default.Special;
    else
        local randomMount = MogMount:getRandomMount("special");
        if randomMount then mountID = randomMount.id; end
    end

    if mountID then
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID);
        return name, spellID, icon;
    end

end



function MogMountSummonAlternative()
	C_MountJournal.SummonByID(MogMountCharacterSaved.Default.Alternative);
end
function MogMountTooltipAlternative()

    local mountID = MogMountCharacterSaved.Default.Alternative;

    if mountID and mountID > 0 then
        local name, spellID, icon = C_MountJournal.GetMountInfoByID(mountID);
        return name, spellID, icon;
    end

end

function MogMountSummon()
	
	if CanExitVehicle() then
		VehicleExit();
	elseif IsMounted() then
		Dismount();
	elseif IsSwimming() and IsControlKeyDown() then
		MogMountSummonAquatic();
	elseif IsShiftKeyDown() then
		MogMountSummonSpecial();
	elseif IsAltKeyDown() then
		MogMountSummonAlternative();
	elseif IsFlyableArea() and not IsControlKeyDown() then
		MogMountSummonFlying();
	else
		MogMountSummonGround();
	end

	UpdateTitle();

end

function MogMountUpdateMacroIcon()

    if not MogMountSaved or not MogMountSaved.MacroID or MogMountSaved.MacroID == 0 then return; end

    local name, spellID, icon;

    if IsSwimming() and IsControlKeyDown() then
        name, spellID, icon = MogMountTooltipAquatic();
    elseif IsShiftKeyDown() then
        name, spellID, icon = MogMountTooltipSpecial();
    elseif IsAltKeyDown() then
        name, spellID, icon = MogMountTooltipAlternative();
    elseif IsFlyableArea() and not IsControlKeyDown() then
        name, spellID, icon = MogMountTooltipFlying();
    else
        name, spellID, icon = MogMountTooltipGround();
    end

    if icon then
        EditMacro(MogMountSaved.MacroID, "MogMount", icon, nil);
    end

end


local function OnSettingChanged(setting, value)
	MogMountCharacterSaved[setting:GetVariable()] = value;
end



local function CreateDisplayTitle(titleID)

	local title, _ = GetTitleName(titleID);

	if titleID == 0 then return playerName; end

	if title:sub(-1) == " " then
		return title..playerName;
	else
		return playerName.." "..title;
	end

end



local function SetSelectedTitle(value)

	titleLoaded = false;
	TitleDropdown:SetDefaultText(CreateDisplayTitle(value));
	MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Title = value;
	UpdateTitle();

end



local function GetTitles()

	TitleDropdown = CreateFrame("DropdownButton", nil, TransmogFrame.CharacterPreview, "WowStyle1DropdownTemplate");

	local function GeneratorFunctionTitles(dropdown, rootDescription)

		rootDescription:CreateButton(playerName, SetSelectedTitle, 0);

		local titlesRaw = {};
		local count = 1;

		for i = 1, GetNumTitles() do
			if IsTitleKnown(i) then
				titlesRaw[count] = { id = i, name = CreateDisplayTitle(i) };
				count = count + 1;				
			end
		end

		table.sort(titlesRaw, MogMountSortAlphabetical);

		for i = 1, #titlesRaw do
			rootDescription:CreateButton(titlesRaw[i].name, SetSelectedTitle, titlesRaw[i].id);
		end

		rootDescription:SetScrollMode(20 * 20);

	end

	TransmogFrame.CharacterPreview.ModelScene.ControlFrame:SetPoint("TOP", 0, -64);

	if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Title == 0 then
		TitleDropdown:SetDefaultText(playerName);
	else
		TitleDropdown:SetDefaultText(CreateDisplayTitle(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Title));
	end

	TitleDropdown:SetWidth(240);
	TitleDropdown:SetPoint("TOP", TransmogFrame.CharacterPreview, "TOP", 0, -27);
	TitleDropdown:SetFrameStrata("MEDIUM");
	TitleDropdown:SetFrameLevel(200);
	TitleDropdown.Text:SetJustifyH("CENTER");
	TitleDropdown:SetupMenu(GeneratorFunctionTitles);

	TitleDropdown:SetScript("OnEnter", function()
		GameTooltip:SetOwner(TitleDropdown, "ANCHOR_RIGHT");
		GameTooltip:AddLine(L["Character Title Tooltip"], 1, 1, 1);
		GameTooltip:Show();
	end)

	TitleDropdown:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end)

end



local function OpenSettingsToMogMount()
	if MogMountSettingsCategoryID > 0 then
   		Settings.OpenToCategory(MogMountSettingsCategoryID);
   	end
end



local function OpenKeybindingsToMogMount()

	Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, "MogMount");
	local children = {SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren()};
	
	for i, child in ipairs(children) do
		local children2 = {child:GetChildren()};
		for j, child2 in ipairs(children2) do
			if child2.Text ~= nil and child2.Text:GetText() == "MogMount" then
				local initializer = child:GetElementData();
				local data = initializer.data;
				data.expanded = not data.expanded;
				child:SetHeight(child:CalculateHeight());
				child:OnExpandedChanged(data.expanded);
			end
		end
	end

end



local function ToggleReminder()
	if MissingKeybindOrMacro() then
		SetupReminderFrame:Hide();
		ShortcutSettings:Show();
		MountListSearchBox:Show();
		FilterDropdown:Show();	
	else
		SetupReminderFrame:Hide();
		ShortcutSettings:Show();
		MountListSearchBox:Show();
		FilterDropdown:Show();			
	end
end


local function GetMogMountMacroID()

    for i = 1, 120 do
        if C_Macro.GetMacroName(i) == "MogMount" then
            return i;
        end
    end

    return nil;

end


function MogMountUpdateMacroIcon()

    local macroId = GetMogMountMacroID();
    if not macroId then return; end

    local function getMountIcon(mountID)
        if not mountID or mountID <= 1 then return nil; end
        local _, _, icon = C_MountJournal.GetMountInfoByID(mountID);
        return icon;
    end

    local function getSpellName(mountID)
        if not mountID or mountID <= 1 then return nil; end
        local _, spellID = C_MountJournal.GetMountInfoByID(mountID);
        if spellID then return C_Spell.GetSpellName(spellID); end
        return nil;
    end

    -- Always use active outfit - that's what gets summoned
    local outfitID = C_TransmogOutfitInfo.GetActiveOutfitID();

    -- Pick icon based on current context
    local icon;
    if IsSwimming() and IsControlKeyDown() then
        icon = getMountIcon(MogMountCharacterSaved["Outfit"..outfitID].Aquatic)
            or getMountIcon(MogMountCharacterSaved.Default.Aquatic);
    elseif IsShiftKeyDown() then
        icon = getMountIcon(MogMountCharacterSaved.Default.Special);
    elseif IsAltKeyDown() then
        icon = getMountIcon(MogMountCharacterSaved.Default.Alternative);
    elseif IsFlyableArea() then
        icon = getMountIcon(MogMountCharacterSaved["Outfit"..outfitID].Flying)
            or getMountIcon(MogMountCharacterSaved.Default.Flying);
    else
        icon = getMountIcon(MogMountCharacterSaved["Outfit"..outfitID].Ground)
            or getMountIcon(MogMountCharacterSaved.Default.Ground);
    end

    -- Always rebuild body alongside icon so it never gets wiped
    local flyName = getSpellName(MogMountCharacterSaved["Outfit"..outfitID].Flying)  or "Flying Mount";
    local gndName = getSpellName(MogMountCharacterSaved["Outfit"..outfitID].Ground)  or "Ground Mount";
    local aqName  = getSpellName(MogMountCharacterSaved["Outfit"..outfitID].Aquatic) or "Aquatic Mount";
    local spcName = getSpellName(MogMountCharacterSaved.Default.Special)              or "Traveler's Tundra Mammoth";
    local altName = getSpellName(MogMountCharacterSaved.Default.Alternative)          or gndName;

    local body =
        "#showtooltip [swimming,mod:ctrl] "..aqName..
        "; [mod:shift] "..spcName..
        "; [mod:alt] "..altName..
        "; [flyable,nomod:ctrl] "..flyName..
        "; "..gndName..
        "\n/run MogMountSummon()";

    EditMacro(macroId, "MogMount", icon, body);

end

local function CreateMacroButton(Parent)

    local macroId;

    for i = 1, 120 do
        if C_Macro.GetMacroName(i) == "MogMount" then
            macroId = i;
            break;
        end
    end

    if not macroId then
        macroId = CreateMacro("MogMount", 1769015, "/run MogMountSummon();", nil);
    end

    MogMountUpdateMacroIcon();

    -- Defer pickup one frame so EditMacro finishes first
    C_Timer.After(0, function()
        PickupMacro(macroId);
    end)

    GameTooltip:SetOwner(Parent, "ANCHOR_CURSOR_RIGHT");
    GameTooltip:AddLine(L["Drop Macro Tooltip"], 1, 1, 1);
    GameTooltip:Show();

    local MacroDropEventFrame = CreateFrame("EventFrame");
    MacroDropEventFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED");

    MacroDropEventFrame:SetScript("OnEvent", function(self, event, slot)
        if slot then
            local actionType, id = GetActionInfo(slot);
            if actionType == "macro" then
                ToggleReminder();
                MacroDropEventFrame:UnregisterAllEvents();
                MacroDropEventFrame = nil;
            end
        end
    end)

end


local function InitTitles(reset)

	if not reset then
		if MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Title == 0 then
			TitleDropdown:SetDefaultText(playerName);
		else
			TitleDropdown:SetDefaultText(CreateDisplayTitle(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Title));
		end
		TitleDropdown:GenerateMenu();
	else
		GetTitles();
	end

end



-- ─────────────────────────────────────────────────────────────
--  Helper: build one mount slot icon (flying / ground / aquatic)
-- ─────────────────────────────────────────────────────────────
local function MakeMountSlot(parent, yOffset, emptyIconGetter, slotKey)

	local frame = CreateFrame("Frame", nil, parent);
	frame:SetFrameStrata("MEDIUM");
	frame:SetSize(44, 44);
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset);
	frame:Show();

	local tex = frame:CreateTexture(nil, "BACKGROUND");
	tex:SetAllPoints(frame);

	local borderSize   = 59;
	local borderOffset = 7;

	local border = CreateFrame("Frame", nil, frame);
	border:SetFrameStrata("HIGH");
	border:SetSize(borderSize, borderSize);
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderOffset, borderOffset);
	border:Show();

	local borderTex = border:CreateTexture(nil, "BACKGROUND");
	borderTex:SetAtlas("transmog-gearSlot-default");
	borderTex:SetAllPoints(border);

	local highlightFrame = CreateFrame("Frame", nil, frame);
	highlightFrame:SetFrameStrata("HIGH");
	highlightFrame:SetSize(borderSize, borderSize);
	highlightFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderOffset, borderOffset);
	highlightFrame:Hide();

	local highlightTex = highlightFrame:CreateTexture(nil, "BACKGROUND");
	highlightTex:SetAtlas("transmog-gearSlot-default");
	highlightTex:SetAllPoints(highlightFrame);
	highlightTex:SetBlendMode("ADD");

	local clearBtn = CreateFrame("Button", nil, border, "UIResetButtonTemplate");
	clearBtn:SetPoint("CENTER", border, "TOPRIGHT", -8, -8);
	clearBtn:Hide();

	return frame, tex, border, borderTex, highlightFrame, highlightTex, clearBtn;

end



local function InitTransmog(reset)

	if reset then

		-- Push the armour slots up a bit to leave a visible gap before mount slots
		local point, relativeTo, relativePoint, xOfs, yOfs = TransmogFrame.CharacterPreview.RightSlots:GetPoint();
		TransmogFrame.CharacterPreview.RightSlots:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + 100);

		-- Container for all 3 mount slots (sits below armour slots)
		MogMountFrame = CreateFrame("Frame", "MogMountFrame", TransmogFrame.CharacterPreview.RightSlots);
		MogMountFrame:SetFrameStrata("MEDIUM");
		MogMountFrame:SetSize(44, 200);

		local point2, relativeTo2, relativePoint2, xOfs2, yOfs2 = TransmogFrame.CharacterPreview.RightSlots:GetPoint();
		-- Extra -20 gap between last armour slot and first mount slot
		MogMountFrame:SetPoint("TOPLEFT", TransmogFrame.CharacterPreview.RightSlots, "BOTTOMLEFT", xOfs2 + 35, yOfs2 - 144);

		-- Flying slot  (top)
		flyingMountFrame, flyingMountTexture,
		flyingMountBorder, flyingMountBorderTexture,
		flyingMountBorderHighlightTexture_frame, flyingMountBorderHighlightTexture,
		FlyingMountClear
			= MakeMountSlot(MogMountFrame, 0, getEmptyMountIcon, "Flying");

		-- Alias the old variable names the rest of the code expects
		local flyingHighlightFrame = flyingMountBorderHighlightTexture_frame;
		flyingMountBorderHighlightTexture = flyingMountBorderHighlightTexture;  -- same ref

		-- Ground slot  (-64 below flying)
		groundMountFrame, groundMountTexture,
		groundMountBorder, groundMountBorderTexture,
		groundMountBorderHighlight_frame, groundMountBorderHighlightTexture,
		GroundMountClear
			= MakeMountSlot(MogMountFrame, -68, getEmptyMountIcon, "Ground");

		-- Aquatic slot  (-64 below ground)
		aquaticMountFrame, aquaticMountTexture,
		aquaticMountBorder, aquaticMountBorderTexture,
		aquaticMountBorderHighlight_frame, aquaticMountBorderHighlightTexture,
		AquaticMountClear
			= MakeMountSlot(MogMountFrame, -136, getEmptyMountIcon, "Aquatic");

		-- Re-alias highlight frames under the names used in hover handlers below
		local flyingMountBorderHighlight  = flyingHighlightFrame;
		local groundMountBorderHighlight  = groundMountBorderHighlight_frame;
		local aquaticMountBorderHighlight = aquaticMountBorderHighlight_frame;

		-- ── Flying clear button ──
		FlyingMountClear:SetScript("OnEnter", function()
			GameTooltip:SetOwner(FlyingMountClear, "ANCHOR_RIGHT");
			GameTooltip:SetText(L["Item Slot Flying Mount Clear Tooltip"]);
			GameTooltip:Show();
			FlyingMountClear:Show();
		end)
		FlyingMountClear:SetScript("OnLeave", function()
			FlyingMountClear:Hide();
			GameTooltip:Hide();
		end)
		FlyingMountClear:SetScript("OnClick", function()
			SetSelectedFlyingMount(1);
			if FlyingMountModel then FlyingMountModel:SetAlpha(0); end
			FlyingMountClear:Hide();
			ClearSelectedFlyingMount();
		end)

		-- ── Ground clear button ──
		GroundMountClear:SetScript("OnEnter", function()
			GameTooltip:SetOwner(GroundMountClear, "ANCHOR_RIGHT");
			GameTooltip:SetText(L["Item Slot Ground Mount Clear Tooltip"]);
			GameTooltip:Show();
			GroundMountClear:Show();
		end)
		GroundMountClear:SetScript("OnLeave", function()
			GroundMountClear:Hide();
			GameTooltip:Hide();
		end)
		GroundMountClear:SetScript("OnClick", function()
			SetSelectedGroundMount(1);
			if GroundMountModel then GroundMountModel:SetAlpha(0); end
			GroundMountClear:Hide();
			ClearSelectedGroundMount();
		end)

		-- ── Aquatic clear button ──
		AquaticMountClear:SetScript("OnEnter", function()
			GameTooltip:SetOwner(AquaticMountClear, "ANCHOR_RIGHT");
			GameTooltip:SetText(L["Item Slot Aquatic Mount Clear Tooltip"] or "Clear Aquatic Mount");
			GameTooltip:Show();
			AquaticMountClear:Show();
		end)
		AquaticMountClear:SetScript("OnLeave", function()
			AquaticMountClear:Hide();
			GameTooltip:Hide();
		end)
		AquaticMountClear:SetScript("OnClick", function()
			SetSelectedAquaticMount(1);
			AquaticMountClear:Hide();
			ClearSelectedAquaticMount();
		end)

	end  -- end reset block

	-- ── Update icons ──

	-- Flying
	local fIcon, fID;
	fID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Flying;
	MogMount:UpdateSelectMountDetails("Flying", fID);
	local _, _, fIconTex = C_MountJournal.GetMountInfoByID(fID);

	if fID == 1 then
		local ei, _, _ = getEmptyMountIcon();
		flyingMountTexture:SetTexture(ei);
		flyingMountTexture:SetDesaturated(true);
		flyingMountTexture:SetVertexColor(0.63,0.63,0.63);
		flyingMountBorderTexture:SetAtlas("transmog-gearSlot-default");
	else
		flyingMountTexture:SetTexture(fIconTex);
		flyingMountTexture:SetDesaturated(false);
		flyingMountTexture:SetVertexColor(1,1,1);
		flyingMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
	end
	flyingMountTexture:SetAllPoints(flyingMountFrame);

	-- Ground
	local gID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Ground;
	MogMount:UpdateSelectMountDetails("Ground", gID);
	local _, _, gIconTex = C_MountJournal.GetMountInfoByID(gID);

	if gID == 1 then
		local _, ei, _ = getEmptyMountIcon();
		groundMountTexture:SetTexture(ei);
		groundMountTexture:SetDesaturated(true);
		groundMountTexture:SetVertexColor(0.63,0.63,0.63);
		groundMountBorderTexture:SetAtlas("transmog-gearSlot-default");
	else
		groundMountTexture:SetTexture(gIconTex);
		groundMountTexture:SetDesaturated(false);
		groundMountTexture:SetVertexColor(1,1,1);
		groundMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
	end
	groundMountTexture:SetAllPoints(groundMountFrame);

	-- Aquatic
	local aqID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Aquatic or 1;
	MogMount:UpdateSelectMountDetails("Aquatic", aqID);
	local _, _, aqIconTex = C_MountJournal.GetMountInfoByID(aqID);

	if aqID == 1 then
		local _, _, ei = getEmptyMountIcon();
		aquaticMountTexture:SetTexture(ei);
		aquaticMountTexture:SetDesaturated(true);
		aquaticMountTexture:SetVertexColor(0.63,0.63,0.63);
		aquaticMountBorderTexture:SetAtlas("transmog-gearSlot-default");
	else
		aquaticMountTexture:SetTexture(aqIconTex);
		aquaticMountTexture:SetDesaturated(false);
		aquaticMountTexture:SetVertexColor(1,1,1);
		aquaticMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
	end
	aquaticMountTexture:SetAllPoints(aquaticMountFrame);

	if reset then

		-- ── Border hover / click scripts ──

		flyingMountBorder:HookScript("OnEnter", function()
			GameTooltip:SetOwner(flyingMountBorder, "ANCHOR_RIGHT");
			local curID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Flying;
			if curID > 1 then
				GameTooltip:AddLine(MogMountSelectedMount.Flying.name);
				GameTooltip:AddLine("|cFFFFFFFF"..L["Item Slot Flying Mount Title"].."|r");
				FlyingMountClear:Show();
			else
				GameTooltip:SetText(L["Item Slot Flying Mount Title"]);
			end
			GameTooltip:Show();
			flyingMountBorderHighlightTexture:Show();
		end)
		flyingMountBorder:HookScript("OnLeave", function()
			GameTooltip:Hide();
			flyingMountBorderHighlightTexture:Hide();
			FlyingMountClear:Hide();
		end)
		flyingMountBorder:SetScript("OnMouseDown", function()
			TransmogFrame.WardrobeCollection:SetTab(TransmogFrame.WardrobeCollection.mountsTabID);
			PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
		end)

		groundMountBorder:HookScript("OnEnter", function()
			GameTooltip:SetOwner(groundMountBorder, "ANCHOR_RIGHT");
			local curID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Ground;
			if curID > 1 then
				GameTooltip:AddLine(MogMountSelectedMount.Ground.name);
				GameTooltip:AddLine("|cFFFFFFFF"..L["Item Slot Ground Mount Title"].."|r");
				GroundMountClear:Show();
			else
				GameTooltip:AddLine(L["Item Slot Ground Mount Title"]);
			end
			GameTooltip:Show();
			groundMountBorderHighlightTexture:Show();
		end)
		groundMountBorder:HookScript("OnLeave", function()
			GameTooltip:Hide();
			groundMountBorderHighlightTexture:Hide();
			GroundMountClear:Hide();
		end)
		groundMountBorder:SetScript("OnMouseDown", function()
			TransmogFrame.WardrobeCollection:SetTab(TransmogFrame.WardrobeCollection.mountsTabID);
			PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
		end)

		aquaticMountBorder:HookScript("OnEnter", function()
			GameTooltip:SetOwner(aquaticMountBorder, "ANCHOR_RIGHT");
			local curID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Aquatic or 1;
			if curID > 1 then
				GameTooltip:AddLine(MogMountSelectedMount.Aquatic.name);
				GameTooltip:AddLine("|cFFFFFFFF"..(L["Item Slot Aquatic Mount Title"] or "Aquatic Mount").."|r");
				AquaticMountClear:Show();
			else
				GameTooltip:SetText(L["Item Slot Aquatic Mount Title"] or "Aquatic Mount");
			end
			GameTooltip:Show();
			aquaticMountBorderHighlightTexture:Show();
		end)
		aquaticMountBorder:HookScript("OnLeave", function()
			GameTooltip:Hide();
			aquaticMountBorderHighlightTexture:Hide();
			AquaticMountClear:Hide();
		end)
		aquaticMountBorder:SetScript("OnMouseDown", function()
			TransmogFrame.WardrobeCollection:SetTab(TransmogFrame.WardrobeCollection.mountsTabID);
			PlaySound(SOUNDKIT.UI_TRANSMOG_GEAR_SLOT_CLICK);
		end)

	end  -- end reset hover/click block

end  -- end InitTransmog



local function OnFlyingMountSelectionChanged(self, data, selected)

	local button   = FlyingMountListScrollBox:FindFrame(data);
	local children = {FlyingMountListScrollBox.ScrollTarget:GetChildren()};

	for i, child in ipairs(children) do
		child.isSelected = false;
		child:UnlockHighlight();
	end
	if button ~= nil then
		if button.isSelected then
			button.isSelected = false;
			button:UnlockHighlight();
		else
			button.isSelected = true;
			button:LockHighlight();
		end
	end

end



local function OnGroundMountSelectionChanged(self, data, selected)

	local button   = GroundMountListScrollBox:FindFrame(data);
	local children = {GroundMountListScrollBox.ScrollTarget:GetChildren()};

	for i, child in ipairs(children) do
		child.isSelected = false;
		child:UnlockHighlight();
	end
	if button ~= nil then
		if button.isSelected then
			button.isSelected = false;
			button:UnlockHighlight();
		else
			button.isSelected = true;
			button:LockHighlight();
		end
	end

end



local function OnAquaticMountSelectionChanged(self, data, selected)

	local button   = AquaticMountListScrollBox:FindFrame(data);
	local children = {AquaticMountListScrollBox.ScrollTarget:GetChildren()};

	for i, child in ipairs(children) do
		child.isSelected = false;
		child:UnlockHighlight();
	end
	if button ~= nil then
		if button.isSelected then
			button.isSelected = false;
			button:UnlockHighlight();
		else
			button.isSelected = true;
			button:LockHighlight();
		end
	end

end



function MissingKeybindOrMacro()

	local key1, key2 = GetBindingKey("Mount/Dismount");
	local missingKeys  = (not key1 or key1 == '') and (not key2 or key2 == '');
	local missingMacro = true;

	for i = 1, 180 do
		if HasAction(i) then
			local actionType, actionId = GetActionInfo(i);
			if actionType == 'macro' then
				local name = GetMacroInfo(actionId);
				if name == "MogMount" then
					missingMacro = false;
				end
			end
  		end
	end

	return missingMacro and missingKeys;

end



local CheckboxShowFlyingInGroundList;
local CheckboxShowAllInFlying;



local function CreateShortcuts(f)

	local ShortcutSettings = CreateFrame("DropdownButton", "ShortcutSettings", f, "DamageMeterSettingsDropdownButtonTemplate");
	ShortcutSettings:SetPoint("TOPRIGHT", f, "TOPRIGHT", -26, -22);
	ShortcutSettings:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateTitle("MogMount");
		rootDescription:CreateButton(L["Open Settings"],  function() OpenSettingsToMogMount()    end);
		rootDescription:CreateButton(L["Open Keybinds"],  function() OpenKeybindingsToMogMount() end);
		rootDescription:CreateButton(L["Create Macro"],   function() CreateMacroButton(ShortcutSettings) end);
	end)
	ShortcutSettings:Hide();

end



local function FilterIsChecked_FlyingInGround()
	return MogMountSaved.ShowFlyingInGround;
end

local function FilterSetChecked_FlyingInGround()

	MogMountSaved.ShowFlyingInGround = not MogMountSaved.ShowFlyingInGround;

	local mounts = MogMount:getSortedGroundMounts();
	local provider = CreateDataProvider();
	local scrollTo = 0;
	local count = 0;

	for i, mount in ipairs(mounts) do
		count = count + 1;
		if mount.id == MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground then
			scrollTo = count;
		end
		provider:Insert(mount);
	end

	GroundMountListScrollView:SetDataProvider(provider);
	GroundMountListScrollBox:ScrollToElementDataIndex(scrollTo);

end



local function FilterIsChecked_AllInFlying()
	return MogMountSaved.ShowAllInFlying;
end

local function FilterSetChecked_AllInFlying()

	MogMountSaved.ShowAllInFlying = not MogMountSaved.ShowAllInFlying;

	local mounts = MogMount:getSortedFlyingMounts();
	local provider = CreateDataProvider();
	local scrollTo = 0;
	local count = 0;

	for i, mount in ipairs(mounts) do
		count = count + 1;
		if mount.id == MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying then
			scrollTo = count;
		end
		provider:Insert(mount);
	end

	FlyingMountListScrollView:SetDataProvider(provider);
	FlyingMountListScrollBox:ScrollToElementDataIndex(scrollTo);

end


function CreateSetupReminder(f)

	SetupReminderFrame = CreateFrame("Frame", "MogMountSetupReminder", f);
	SetupReminderFrame:SetAllPoints(f);

	local icon = SetupReminderFrame:CreateTexture(nil,"BACKGROUND");
	icon:SetAtlas("transmog-icon-warning");
	icon:SetSize(20,20);
	icon:SetPoint("TOPLEFT", 24, -24);

	local txt = SetupReminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	txt:SetJustifyH("LEFT");
	txt:SetPoint("TOPLEFT", 48, -28);
	txt:SetText("|cFFE36F1B"..L["Setup Reminder"].."|r");

	local cw = 8;
	local bp = 12;

	local btnMacro = CreateFrame("Button", "CreateMacroButtonFrame", SetupReminderFrame, "UIPanelButtonTemplate");
	btnMacro:SetPoint("TOPRIGHT", SetupReminderFrame, "TOPRIGHT", -26, -22);
	local ml = string.len(L["Create Macro"]);
	btnMacro:SetSize(ml * cw + bp, 22);
	btnMacro:SetText(L["Create Macro"]);
	btnMacro:SetScript("OnMouseDown", function() CreateMacroButton(btnMacro); end);

	local btnBind = CreateFrame("Button", nil, SetupReminderFrame, "UIPanelButtonTemplate");
	btnBind:SetPoint("TOPRIGHT", SetupReminderFrame, "TOPRIGHT", (-1 * ml * cw) - bp - 26 - 8, -22);
	local bl = string.len(L["Open Keybinds"]);
	btnBind:SetSize(bl * cw + bp, 22);
	btnBind:SetText(L["Open Keybinds"]);
	btnBind:SetScript("OnClick", function() OpenKeybindingsToMogMount(); end);

end


-- ─────────────────────────────────────────────────────────────
--  Helper: build one section (preview + list) inside the Mounts tab
-- ─────────────────────────────────────────────────────────────
local function BuildMountSection(f, topY, previewX, previewW, previewH, listX, listW, listH, modelID)

	local inset = 10;

	local preview = CreateFrame("Frame", nil, f);
	preview:SetPoint("TOPLEFT", f, "TOPLEFT", previewX, topY);
	preview:SetFrameStrata("HIGH");
	preview:SetSize(previewW, previewH);

	local bg = preview:CreateTexture(nil, "BACKGROUND");
	bg:SetAtlas("professions-recipe-background");
	bg:SetPoint("CENTER", preview, "CENTER", 0, 0);
	bg:SetSize(previewW - inset, previewH - inset);
	bg:SetVertexColor(0,0,0);

	local model = CreateFrame("PlayerModel", nil, preview);
	model:SetPoint("CENTER", preview, "CENTER", 0, 0);
	model:SetSize(previewW - inset, previewH - inset);
	model:SetPortraitZoom(0);
	model:SetFacing(-5.5);
	if modelID and modelID > 0 then
		model:SetDisplayInfo(modelID);
		model:SetAlpha(1);
	end

	local border = preview:CreateTexture(nil, "OVERLAY");
	border:SetAtlas("transmog-itemCard-default", true);
	border:SetPoint("CENTER", preview, "CENTER", 0, 0);
	border:SetSize(previewW, previewH);

	-- list container
	local listFrame = CreateFrame("Frame", nil, f);
	listFrame:SetPoint("TOPLEFT", f, "TOPLEFT", listX, topY + 4);
	listFrame:SetFrameStrata("HIGH");
	listFrame:SetSize(listW, listH);

	local listBG = listFrame:CreateTexture(nil, "BACKGROUND");
	listBG:SetAtlas("transmog-situations-containerbg", true);
	listBG:SetAllPoints(true);

	local scrollBox = CreateFrame("Frame", nil, listFrame, "WowScrollBoxList");
	scrollBox:SetSize(listW - 40, listH - 4);
	scrollBox:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 12, -2);

	local scrollBar = CreateFrame("EventFrame", nil, listFrame, "MinimalScrollBar");
	scrollBar:SetPoint("TOPLEFT",    scrollBox, "TOPRIGHT",    10, -6);
	scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 10,  6);
	scrollBar:SetHideIfUnscrollable(true);

	local scrollView = CreateScrollBoxListLinearView();

	return model, scrollBox, scrollBar, scrollView, listFrame;

end



local function InitMountTab()

	if not TransmogFrame.WardrobeCollection.mountsTabID then

		hooksecurefunc(TransmogFrame.WardrobeCollection, "OnLoad", function(self)
			self.mountsTabID = self:AddNamedTab(L["Mount Tab Title"], self.TabContent.MountsFrame);
			self:UpdateTabs();
		end)

		-- FIX: hook instead of override — prevents collection-set tabs disappearing
		hooksecurefunc(TransmogFrame.WardrobeCollection, "UpdateTabs", function(self)
			if self.mountsTabID then
				self.TabHeaders:SetTabShown(self.mountsTabID, true);
			end
		end)

		-- ── Layout constants ──
		-- The tab content panel is roughly 830 px wide × 680 px tall.
		-- We split it into 3 equal rows.  Each row = titlebar (22) + content (185).
		-- Preview panel: 185×185 square.  List box: remaining width × 185.

		local sectionH    = 220;   -- height of each preview + list row
		local sectionGap  = 28;    -- gap between sections (title text height + padding)
		local previewW    = 220;
		local previewX    = 18;
		local headerY1    = -50;   -- Flying title top
		local contentY1   = headerY1 - 22;
		local headerY2    = contentY1 - sectionH - 8;
		local contentY2   = headerY2 - 22;
		local headerY3    = contentY2 - sectionH - 8;
		local contentY3   = headerY3 - 22;

		-- list starts right of preview
		local listX       = previewX + previewW + 12;

		local f = CreateFrame("Frame", "MountsFrame", TransmogFrame.WardrobeCollection.TabContent);
		f:SetAllPoints(true);
		f:SetFrameStrata("HIGH");
		f:Hide();

		local fw, fh = f:GetSize();
		local listW = fw - listX - 24;   -- leave right margin

		-- ── Filter dropdown ──
		FilterDropdown = CreateFrame("DropdownButton", nil, f, "WowStyle1FilterDropdownTemplate");
		FilterDropdown:SetPoint("TOPRIGHT", f, "TOPRIGHT", -60, -22);
		FilterDropdown:SetWidth(148);
		FilterDropdown.resizeToText = false;
		FilterDropdown:SetupMenu(function(dropdown, rootDescription)
			CheckboxShowFlyingInGroundList = rootDescription:CreateCheckbox(
				L["Show Flying In Ground Toggle"],
				FilterIsChecked_FlyingInGround,
				FilterSetChecked_FlyingInGround);
			CheckboxShowAllInFlying = rootDescription:CreateCheckbox(
				L["Show All In Flying Toggle"] or "Show All Mounts in Flying",
				FilterIsChecked_AllInFlying,
				FilterSetChecked_AllInFlying);
		end)

		-- ── Search box ──
		MountListSearchBox = CreateFrame("EditBox", "MountListSearchBox", f, "TransmogSearchBoxTemplate");
		MountListSearchBox:SetPoint("TOPRIGHT", -215, -21);
		local ip, ipar, irp, ix, iy = MountListSearchBox.searchIcon:GetPoint();
		MountListSearchBox.searchIcon:SetPoint(ip, ipar, irp, ix, iy + 1);

		-- ── Setup reminder / shortcuts ──
		CreateSetupReminder(f);
		CreateShortcuts(f);
		ToggleReminder();

		-- ── Section header helper ──
		local function MakeSectionHeader(text, topY)
			local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge");
			title:SetJustifyH("LEFT");
			title:SetPoint("TOPLEFT", f, "TOPLEFT", previewX, topY);
			title:SetText(text);
			local divider = f:CreateTexture(nil, "OVERLAY");
			divider:SetAtlas("transmog-tabs-header-line", true);
			divider:SetAlpha(0.12);
			divider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2);
		end

		MakeSectionHeader(L["Mount Tab Flying Section Title"],  headerY1);
		MakeSectionHeader(L["Mount Tab Ground Section Title"],  headerY2);
		MakeSectionHeader(L["Mount Tab Aquatic Section Title"] or "Aquatic", headerY3);

		-- ── Current saved IDs ──
		local activID = C_TransmogOutfitInfo.GetActiveOutfitID();
		local flyModelID  = C_MountJournal.GetMountInfoExtraByID(MogMountCharacterSaved["Outfit"..activID].Flying);
		local gndModelID  = C_MountJournal.GetMountInfoExtraByID(MogMountCharacterSaved["Outfit"..activID].Ground);
		local aqSavedID   = MogMountCharacterSaved["Outfit"..activID].Aquatic or 1;
		local aqModelID   = C_MountJournal.GetMountInfoExtraByID(aqSavedID);

		-- ── Build sections ──
		local flyingModel, flyScrollBox, flyScrollBar, flyScrollView, flyListFrame =
			BuildMountSection(f, contentY1, previewX, previewW, sectionH, listX, listW, sectionH, flyModelID);
		FlyingMountModel        = flyingModel;
		FlyingMountListScrollBox = flyScrollBox;
		FlyingMountListScrollBar = flyScrollBar;
		FlyingMountListScrollView = flyScrollView;

		local groundModel, gndScrollBox, gndScrollBar, gndScrollView, gndListFrame =
			BuildMountSection(f, contentY2, previewX, previewW, sectionH, listX, listW, sectionH, gndModelID);
		GroundMountModel         = groundModel;
		GroundMountListScrollBox = gndScrollBox;
		GroundMountListScrollBar = gndScrollBar;
		GroundMountListScrollView = gndScrollView;

		local aquModel, aqScrollBox, aqScrollBar, aqScrollView, aqListFrame =
			BuildMountSection(f, contentY3, previewX, previewW, sectionH, listX, listW, sectionH, aqModelID);
		AquaticMountModel         = aquModel;
		AquaticMountListScrollBox = aqScrollBox;
		AquaticMountListScrollBar = aqScrollBar;
		AquaticMountListScrollView = aqScrollView;

		-- ── Selection behaviours ──
		FlyingMountSelectionBehavior  = ScrollUtil.AddSelectionBehavior(FlyingMountListScrollBox,  SelectionBehaviorFlags.Intrusive);
		GroundMountSelectionBehavior  = ScrollUtil.AddSelectionBehavior(GroundMountListScrollBox,  SelectionBehaviorFlags.Intrusive);
		AquaticMountSelectionBehavior = ScrollUtil.AddSelectionBehavior(AquaticMountListScrollBox, SelectionBehaviorFlags.Intrusive);

		FlyingMountSelectionBehavior:RegisterCallback( SelectionBehaviorMixin.Event.OnSelectionChanged, OnFlyingMountSelectionChanged,  self);
		GroundMountSelectionBehavior:RegisterCallback( SelectionBehaviorMixin.Event.OnSelectionChanged, OnGroundMountSelectionChanged,  self);
		AquaticMountSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnAquaticMountSelectionChanged, self);

		-- ─────────────────────────────
		--  SetSelectedFlyingMount
		-- ─────────────────────────────
		function SetSelectedFlyingMount(value)

			local _, _, icon = C_MountJournal.GetMountInfoByID(value);
			MogMount:UpdateSelectMountDetails("Flying", value);

			if value == 1 then
				local ei, _, _ = getEmptyMountIcon();
				flyingMountTexture:SetTexture(ei);
				flyingMountTexture:SetDesaturated(true);
				flyingMountTexture:SetVertexColor(0.63,0.63,0.63);
				flyingMountBorderTexture:SetAtlas("transmog-gearSlot-default");
				flyingMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-default");
			else
				flyingMountTexture:SetTexture(icon);
				flyingMountTexture:SetDesaturated(false);
				flyingMountTexture:SetVertexColor(1,1,1);
				flyingMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
				flyingMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-transmogrified");
			end
			flyingMountFrame.texture = flyingMountTexture;
			MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Flying = value;
			MogMountUpdateMacroIcon();
			PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);

		end

		-- ─────────────────────────────
		--  SetSelectedGroundMount
		-- ─────────────────────────────
		function SetSelectedGroundMount(value)

			local _, _, icon = C_MountJournal.GetMountInfoByID(value);
			MogMount:UpdateSelectMountDetails("Ground", value);

			if value == 1 then
				local _, ei, _ = getEmptyMountIcon();
				groundMountTexture:SetTexture(ei);
				groundMountTexture:SetDesaturated(true);
				groundMountTexture:SetVertexColor(0.63,0.63,0.63);
				groundMountBorderTexture:SetAtlas("transmog-gearSlot-default");
				groundMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-default");
			else
				groundMountTexture:SetTexture(icon);
				groundMountTexture:SetDesaturated(false);
				groundMountTexture:SetVertexColor(1,1,1);
				groundMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
				groundMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-transmogrified");
			end
			groundMountFrame.texture = groundMountTexture;
			MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Ground = value;
			MogMountUpdateMacroIcon();
			PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);

		end

		-- ─────────────────────────────
		--  SetSelectedAquaticMount
		-- ─────────────────────────────
		function SetSelectedAquaticMount(value)

			local _, _, icon = C_MountJournal.GetMountInfoByID(value);
			MogMount:UpdateSelectMountDetails("Aquatic", value);

			if value == 1 then
				local _, _, ei = getEmptyMountIcon();
				aquaticMountTexture:SetTexture(ei);
				aquaticMountTexture:SetDesaturated(true);
				aquaticMountTexture:SetVertexColor(0.63,0.63,0.63);
				aquaticMountBorderTexture:SetAtlas("transmog-gearSlot-default");
				aquaticMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-default");
			else
				aquaticMountTexture:SetTexture(icon);
				aquaticMountTexture:SetDesaturated(false);
				aquaticMountTexture:SetVertexColor(1,1,1);
				aquaticMountBorderTexture:SetAtlas("transmog-gearSlot-transmogrified");
				aquaticMountBorderHighlightTexture:SetAtlas("transmog-gearSlot-transmogrified");
			end
			aquaticMountFrame.texture = aquaticMountTexture;
			MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Aquatic = value;
			MogMountUpdateMacroIcon();
			PlaySound(SOUNDKIT.UI_TRANSMOG_ITEM_CLICK);

		end

		-- ─────────────────────────────
		--  List row initializers
		-- ─────────────────────────────
		local function FlyingMountListInitializer(button, data)

			button.Name:SetText("|T"..data.icon..":18|t "..data.name);
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			button.MountID = data.id;

			local isSelected = data.id == MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Flying;
			if isSelected then button:LockHighlight() else button:UnlockHighlight() end

			button:SetScript("OnEnter", function()
				if data.model and FlyingMountModel:GetDisplayInfo() ~= data.model then
					FlyingMountModel:SetDisplayInfo(data.model);
				end
				FlyingMountModel:SetAlpha(1);
			end)
			button:SetScript("OnLeave", function()
				local saved = C_MountJournal.GetMountInfoExtraByID(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Flying);
				if saved and saved > 0 then FlyingMountModel:SetDisplayInfo(saved); FlyingMountModel:SetAlpha(1);
				else FlyingMountModel:SetAlpha(0); end
			end)
			button:SetScript("OnClick", function()
				FlyingMountSelectionBehavior:Select(button);
				SetSelectedFlyingMount(data.id);
				if data.model and data.model > 0 then FlyingMountModel:SetDisplayInfo(data.model); end
				FlyingMountModel:SetAlpha(1);
			end)

		end

		local function GroundMountListInitializer(button, data)

			button.Name:SetText("|T"..data.icon..":18|t "..data.name);
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			button.MountID = data.id;

			local isSelected = data.id == MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Ground;
			if isSelected then button:LockHighlight() else button:UnlockHighlight() end

			button:SetScript("OnEnter", function()
				if data.model and GroundMountModel:GetDisplayInfo() ~= data.model then
					GroundMountModel:SetDisplayInfo(data.model);
				end
				GroundMountModel:SetAlpha(1);
			end)
			button:SetScript("OnLeave", function()
				local saved = C_MountJournal.GetMountInfoExtraByID(MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Ground);
				if saved and saved > 0 then GroundMountModel:SetDisplayInfo(saved); GroundMountModel:SetAlpha(1);
				else GroundMountModel:SetAlpha(0); end
			end)
			button:SetScript("OnClick", function()
				GroundMountSelectionBehavior:Select(button);
				SetSelectedGroundMount(data.id);
				if data.model and data.model > 0 then GroundMountModel:SetDisplayInfo(data.model); end
				GroundMountModel:SetAlpha(1);
			end)

		end

		local function AquaticMountListInitializer(button, data)

			button.Name:SetText("|T"..data.icon..":18|t "..data.name);
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			button.MountID = data.id;

			local aqSaved = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetActiveOutfitID()].Aquatic or 1;
			local isSelected = data.id == aqSaved;
			if isSelected then button:LockHighlight() else button:UnlockHighlight() end

			button:SetScript("OnEnter", function()
				if data.model and AquaticMountModel:GetDisplayInfo() ~= data.model then
					AquaticMountModel:SetDisplayInfo(data.model);
				end
				AquaticMountModel:SetAlpha(1);
			end)
			button:SetScript("OnLeave", function()
				local savedID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Aquatic or 1;
				local saved   = C_MountJournal.GetMountInfoExtraByID(savedID);
				if saved and saved > 0 then AquaticMountModel:SetDisplayInfo(saved); AquaticMountModel:SetAlpha(1);
				else AquaticMountModel:SetAlpha(0); end
			end)
			button:SetScript("OnClick", function()
				AquaticMountSelectionBehavior:Select(button);
				SetSelectedAquaticMount(data.id);
				if data.model and data.model > 0 then AquaticMountModel:SetDisplayInfo(data.model); end
				AquaticMountModel:SetAlpha(1);
			end)

		end

		-- ── Wire up scroll views ──
		FlyingMountListScrollView:SetElementInitializer( "MogMountListButtonTemplate", FlyingMountListInitializer);
		GroundMountListScrollView:SetElementInitializer( "MogMountListButtonTemplate", GroundMountListInitializer);
		AquaticMountListScrollView:SetElementInitializer("MogMountListButtonTemplate", AquaticMountListInitializer);

		FlyingMountListScrollView:SetElementExtent(22);
		GroundMountListScrollView:SetElementExtent(22);
		AquaticMountListScrollView:SetElementExtent(22);

		-- ── Populate lists ──
		local function PopulateList(scrollView, scrollBox, scrollBar, mounts, savedID)
			local provider = CreateDataProvider();
			local scrollTo = 0;
			for i, mount in ipairs(mounts) do
				if mount.id == savedID then scrollTo = i; end
				provider:Insert(mount);
			end
			ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);
			scrollView:SetDataProvider(provider);
			scrollBox:ScrollToElementDataIndex(scrollTo);
		end

		PopulateList(FlyingMountListScrollView,  FlyingMountListScrollBox,  FlyingMountListScrollBar,
			MogMount:getSortedFlyingMounts(),  MogMountCharacterSaved["Outfit"..activID].Flying);

		PopulateList(GroundMountListScrollView,  GroundMountListScrollBox,  GroundMountListScrollBar,
			MogMount:getSortedGroundMounts(),  MogMountCharacterSaved["Outfit"..activID].Ground);

		PopulateList(AquaticMountListScrollView, AquaticMountListScrollBox, AquaticMountListScrollBar,
			MogMount:getSortedAquaticMounts(), aqSavedID);

		-- ── Search box refresh ──
		MountListSearchBox:SetScript("OnTextChanged", function()

			MogMount.MountSearchString = MountListSearchBox:GetText();

			if string.len(MogMount.MountSearchString) > 0 then
				MountListSearchBox.Instructions:Hide();
			else
				MountListSearchBox.Instructions:Show();
			end

			local curID = C_TransmogOutfitInfo.GetActiveOutfitID();

			PopulateList(FlyingMountListScrollView,  FlyingMountListScrollBox,  FlyingMountListScrollBar,
				MogMount:getSortedFlyingMounts(),  MogMountCharacterSaved["Outfit"..curID].Flying);

			PopulateList(GroundMountListScrollView,  GroundMountListScrollBox,  GroundMountListScrollBar,
				MogMount:getSortedGroundMounts(),  MogMountCharacterSaved["Outfit"..curID].Ground);

			PopulateList(AquaticMountListScrollView, AquaticMountListScrollBox, AquaticMountListScrollBar,
				MogMount:getSortedAquaticMounts(), MogMountCharacterSaved["Outfit"..curID].Aquatic or 1);

		end)

		-- ── Add the tab ──
		TransmogFrame.WardrobeCollection.mountsTabID = TransmogFrame.WardrobeCollection:AddNamedTab(L["Mount Tab Title"], MountsFrame);
		TransmogFrame.WardrobeCollection:UpdateTabs();

	end  -- end first-time init

	ToggleReminder();

end  -- end InitMountTab





function ClearSelectedFlyingMount()

	if FlyingMountModel then FlyingMountModel:SetAlpha(0); end
	if FlyingMountListScrollBox then
		for _, child in ipairs({FlyingMountListScrollBox.ScrollTarget:GetChildren()}) do
			child.isSelected = false;
			child:UnlockHighlight();
		end
		FlyingMountListScrollBox:ScrollToElementDataIndex(1);
	end

end



function ClearSelectedGroundMount()

	if GroundMountModel then GroundMountModel:SetAlpha(0); end
	if GroundMountListScrollBox then
		for _, child in ipairs({GroundMountListScrollBox.ScrollTarget:GetChildren()}) do
			child.isSelected = false;
			child:UnlockHighlight();
		end
		GroundMountListScrollBox:ScrollToElementDataIndex(1);
	end

end



function ClearSelectedAquaticMount()

	if AquaticMountModel then AquaticMountModel:SetAlpha(0); end
	if AquaticMountListScrollBox then
		for _, child in ipairs({AquaticMountListScrollBox.ScrollTarget:GetChildren()}) do
			child.isSelected = false;
			child:UnlockHighlight();
		end
		AquaticMountListScrollBox:ScrollToElementDataIndex(1);
	end

end



function UpdateSelectedMountRow()

	-- Flying
	if FlyingMountListScrollBox then
		ClearSelectedFlyingMount();
		local savedID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Flying;
		local mounts  = MogMount:getSortedFlyingMounts();
		for i, mount in ipairs(mounts) do
			if mount.id == savedID then
				FlyingMountListScrollBox:ScrollToElementDataIndex(i);
				for _, child in ipairs({FlyingMountListScrollBox.ScrollTarget:GetChildren()}) do
					if child.MountID == mount.id then
						FlyingMountSelectionBehavior:Select(child);
						if mount.model then FlyingMountModel:SetDisplayInfo(mount.model); FlyingMountModel:SetAlpha(1); end
					else
						child.isSelected = false; child:UnlockHighlight();
					end
				end
			end
		end
	end

	-- Ground
	if GroundMountListScrollBox then
		ClearSelectedGroundMount();
		local savedID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Ground;
		local mounts  = MogMount:getSortedGroundMounts();
		for i, mount in ipairs(mounts) do
			if mount.id == savedID then
				GroundMountListScrollBox:ScrollToElementDataIndex(i);
				for _, child in ipairs({GroundMountListScrollBox.ScrollTarget:GetChildren()}) do
					if child.MountID == mount.id then
						GroundMountSelectionBehavior:Select(child);
						GroundMountModel:SetDisplayInfo(mount.model);
						GroundMountModel:SetAlpha(1);
					else
						child.isSelected = false; child:UnlockHighlight();
					end
				end
			end
		end
	end

	-- Aquatic
	if AquaticMountListScrollBox then
		ClearSelectedAquaticMount();
		local savedID = MogMountCharacterSaved["Outfit"..C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID()].Aquatic or 1;
		local mounts  = MogMount:getSortedAquaticMounts();
		for i, mount in ipairs(mounts) do
			if mount.id == savedID then
				AquaticMountListScrollBox:ScrollToElementDataIndex(i);
				for _, child in ipairs({AquaticMountListScrollBox.ScrollTarget:GetChildren()}) do
					if child.MountID == mount.id then
						AquaticMountSelectionBehavior:Select(child);
						if mount.model and mount.model > 0 then
							AquaticMountModel:SetDisplayInfo(mount.model);
							AquaticMountModel:SetAlpha(1);
						end
					else
						child.isSelected = false; child:UnlockHighlight();
					end
				end
			end
		end
	end

end

local MogMountIconWatcher = CreateFrame("Frame");
local lastIconState = "";

MogMountIconWatcher:SetScript("OnUpdate", function()

    if not GetMogMountMacroID() then return; end

    local swimming = IsSwimming()       and "1" or "0";
    local ctrl     = IsControlKeyDown() and "1" or "0";
    local shift    = IsShiftKeyDown()   and "1" or "0";
    local alt      = IsAltKeyDown()     and "1" or "0";
    local flyable  = IsFlyableArea()    and "1" or "0";

    local state = swimming..ctrl..shift..alt..flyable;

    if state ~= lastIconState then
        lastIconState = state;
        MogMountUpdateMacroIcon();
    end

end)

function MogMount:OnEvent(event, addOnName)

	if event == "PLAYER_ENTERING_WORLD" and not loaded then

		if MogMountCharacterSaved == nil then
			MogMountCharacterSaved = {};
			MogMountCharacterSaved.Default = {
				Flying      = 0,
				Ground      = 0,
				Aquatic     = 0,
				Special     = 0,
				Alternative = 0,
			};
		end

		for t = 1, #C_TransmogOutfitInfo.GetOutfitsInfo() do
			local outfitInfo = C_TransmogOutfitInfo.GetOutfitsInfo()[t];
			MogMount:CreateEmptyOutfit(outfitInfo.outfitID);
		end

		if MogMountSaved == nil then
			MogMountSaved = {
				MacroID           = 0,
				ShowFlyingInGround = false,
				ShowAllInFlying    = false,
			};
		end

		-- Migration guards
		if MogMountCharacterSaved.Default.Alternative == nil then MogMountCharacterSaved.Default.Alternative = 0; end
		if MogMountSaved.ShowFlyingInGround  == nil then MogMountSaved.ShowFlyingInGround  = false; end
		if MogMountSaved.ShowAllInFlying     == nil then MogMountSaved.ShowAllInFlying     = false; end

		loaded = true;

	end

	if event == "VIEWED_TRANSMOG_OUTFIT_CHANGED" then
		MogMount:CreateEmptyOutfit(C_TransmogOutfitInfo.GetCurrentlyViewedOutfitID());
		InitTransmog(firstLoad);
		InitTitles(firstLoad);
		C_Timer.After(0.1, function()
			UpdateSelectedMountRow();
		end)
		firstLoad = false;
	end

	if event == "PLAYER_EQUIPMENT_CHANGED" then
		C_Timer.After(0.1, function()
			MogMountUpdateMacroIcon();
		end)
	end

	if event == "TRANSMOGRIFY_OPEN" then
		C_Timer.After(0.1, function()
			InitMountTab();
		end)
	end

	if event == "ZONE_CHANGED_NEW_AREA" then
		MogMountUpdateMacroIcon();
	end

end

MogMount:RegisterEvent("ADDON_LOADED");
MogMount:RegisterEvent("PLAYER_ENTERING_WORLD");
MogMount:RegisterEvent("TRANSMOGRIFY_OPEN");
MogMount:RegisterEvent("VIEWED_TRANSMOG_OUTFIT_CHANGED");
MogMount:RegisterEvent("ZONE_CHANGED_NEW_AREA");
MogMount:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
MogMount:SetScript("OnEvent", MogMount.OnEvent);
