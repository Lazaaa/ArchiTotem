local _G = getfenv()
local L = ArchiTotemLocale
local version = GetAddOnMetadata("ArchiTotem", "Version")
local author = GetAddOnMetadata("ArchiTotem", "Author")

local _, class = UnitClass("player")
local CLOCK_UPDATE_RATE = 0.1

-- Global variables
ArchiTotemCasted = nil
ArchiTotemCastedTotem = nil
ArchiTotemCastedElement = nil
ArchiTotemCastedButton = nil
ArchiTotemActiveTotem = {}

local totemElements = { "Earth", "Fire", "Water", "Air" }

local ArchiTotemPopout = {
    "ArchiTotemButton_Earth2", "ArchiTotemButton_Earth3", "ArchiTotemButton_Earth4", "ArchiTotemButton_Earth5",
    "ArchiTotemButton_Fire2", "ArchiTotemButton_Fire3", "ArchiTotemButton_Fire4", "ArchiTotemButton_Fire5",
    "ArchiTotemButton_Water2", "ArchiTotemButton_Water3", "ArchiTotemButton_Water4", "ArchiTotemButton_Water5", "ArchiTotemButton_Water6",
    "ArchiTotemButton_Air2", "ArchiTotemButton_Air3", "ArchiTotemButton_Air4", "ArchiTotemButton_Air5", "ArchiTotemButton_Air6", "ArchiTotemButton_Air7",
}

-- =====================================================
--  CENTRAL TOTEM DATA DEFINITION (Single source of truth)
-- =====================================================
local ArchiTotem_DefaultTotemData = {
    -- Earth
    ["ArchiTotemButton_Earth1"] = {
        icon = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02",
        name = "Earthbind Totem",
        duration = 45,
        cooldown = 15,
    },
    ["ArchiTotemButton_Earth2"] = {
        icon = "Interface\\Icons\\Spell_Nature_TremorTotem",
        name = "Tremor Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Earth3"] = {
        icon = "Interface\\Icons\\Spell_Nature_EarthBindTotem",
        name = "Strength of Earth Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Earth4"] = {
        icon = "Interface\\Icons\\Spell_Nature_StoneSkinTotem",
        name = "Stoneskin Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Earth5"] = {
        icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem",
        name = "Stoneclaw Totem",
        duration = 15,
        cooldown = 30,
    },

    -- Fire
    ["ArchiTotemButton_Fire1"] = {
        icon = "Interface\\Icons\\Spell_Fire_SearingTotem",
        name = "Searing Totem",
        duration = 55,
        cooldown = 0,
    },
    ["ArchiTotemButton_Fire2"] = {
        icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
        name = "Fire Nova Totem",
        duration = 5,
        cooldown = 15,
    },
    ["ArchiTotemButton_Fire3"] = {
        icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",
        name = "Magma Totem",
        duration = 20,
        cooldown = 0,
    },
    ["ArchiTotemButton_Fire4"] = {
        icon = "Interface\\Icons\\Spell_FrostResistanceTotem_01",
        name = "Frost Resistance Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Fire5"] = {
        icon = "Interface\\Icons\\Spell_Nature_GuardianWard",
        name = "Flametongue Totem",
        duration = 120,
        cooldown = 0,
    },

    -- Water
    ["ArchiTotemButton_Water1"] = {
        icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem",
        name = "Mana Spring Totem",
        duration = 60,
        cooldown = 0,
    },
    ["ArchiTotemButton_Water2"] = {
        icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
        name = "Mana Tide Totem",
        duration = 12,
        cooldown = 300,
    },
    ["ArchiTotemButton_Water3"] = {
        icon = "Interface\\Icons\\Spell_FireResistanceTotem_01",
        name = "Fire Resistance Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Water4"] = {
        icon = "Interface\\Icons\\Spell_Nature_PoisonCleansingTotem",
        name = "Poison Cleansing Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Water5"] = {
        icon = "Interface\\Icons\\Spell_Nature_DiseaseCleansingTotem",
        name = "Disease Cleansing Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Water6"] = {
        icon = "Interface\\Icons\\INV_Spear_04",
        name = "Healing Stream Totem",
        duration = 60,
        cooldown = 0,
    },

    -- Air
    ["ArchiTotemButton_Air1"] = {
        icon = "Interface\\Icons\\Spell_Nature_Brilliance",
        name = "Tranquil Air Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Air2"] = {
        icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
        name = "Grounding Totem",
        duration = 45,
        cooldown = 15,
    },
    ["ArchiTotemButton_Air3"] = {
        icon = "Interface\\Icons\\Spell_Nature_Windfury",
        name = "Windfury Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Air4"] = {
        icon = "Interface\\Icons\\Spell_Nature_InvisibilityTotem",
        name = "Grace of Air Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Air5"] = {
        icon = "Interface\\Icons\\Spell_Nature_NatureResistanceTotem",
        name = "Nature Resistance Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Air6"] = {
        icon = "Interface\\Icons\\Spell_Nature_EarthBind",
        name = "Windwall Totem",
        duration = 120,
        cooldown = 0,
    },
    ["ArchiTotemButton_Air7"] = {
        icon = "Interface\\Icons\\Spell_Nature_RemoveCurse",
        name = "Sentry Totem",
        duration = 300,
        cooldown = 0,
    },
}

-- =====================================================
--  FUNCTIONS
-- =====================================================

function ArchiTotem_Print(msg, type)
    local prefix
    if type == "error" then
        prefix = "|cff20b2aaArchiTotem |cffff0000ERROR|r  "
    elseif type == "debug" then
        prefix = "|cff20b2aaArchiTotem |cff0000cdDEBUG|r  "
    else
        prefix = "|cff20b2aaArchiTotem|r  "
    end
    return DEFAULT_CHAT_FRAME:AddMessage(prefix .. msg)
end

function ArchiTotem_Noop() return end

-- =====================================================
--  INITIALIZATION
-- =====================================================

function ArchiTotem_InitDefaults()
    if not ArchiTotem_Options then
        ArchiTotem_Options = {
            Ear = { max = 5, shown = 1 },
            Fir = { max = 5, shown = 1 },
            Wat = { max = 6, shown = 1 },
            Air = { max = 7, shown = 1 },
            Apperance = {
                direction = "up",
                scale = 1,
                allonmouseover = false,
                bottomoncast = true,
                shownumericcooldowns = true,
                showtooltips = true,
				tooltipScale = 1.0,   
                shortTooltip = false,
            },
            Order = { first = "Earth", second = "Fire", third = "Water", forth = "Air" },
            Debug = false,
        }
    end

    if not ArchiTotem_Options["Apperance"].position then
        ArchiTotem_Options["Apperance"].position = {
            point = "CENTER",
            relativeTo = UIParent,
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
        }
    end

    ArchiTotem_TotemData = {}
    for k, v in pairs(ArchiTotem_DefaultTotemData) do
        ArchiTotem_TotemData[k] = {
            icon = v.icon,
            name = v.name,
            duration = v.duration,
            cooldown = v.cooldown,
            cooldownstarted = nil,
            casted = nil,
        }
    end

    if ArchiTotem_TotemData then
        for _, element in ipairs(totemElements) do
            local threeLetter = string.sub(element, 1, 3)
            local maxShown = ArchiTotem_Options[threeLetter].shown
            
            for i = ArchiTotem_Options[threeLetter].max, 1, -1 do
                local buttonName = "ArchiTotemButton_" .. element .. i
                local totemData = ArchiTotem_TotemData[buttonName]
                
                if totemData then
                    local spellName = L[totemData.name] or totemData.name
                    local spellID = ArchiTotem_GetSpellId(spellName)
                    
                    if spellID == 0 then
                        ArchiTotem_TotemData[buttonName] = nil
                        if i <= maxShown then
                            ArchiTotem_Options[threeLetter].shown = maxShown - 1
                            maxShown = maxShown - 1
                        end
                    end
                end
            end
        end
    end

    for _, element in ipairs(totemElements) do
        local threeLetter = string.sub(element, 1, 3)
        local max = ArchiTotem_Options[threeLetter].max
        
        local tempList = {}
        for i = 1, max do
            local btnName = "ArchiTotemButton_" .. element .. i
            if ArchiTotem_TotemData[btnName] then
                table.insert(tempList, ArchiTotem_TotemData[btnName])
            end
        end
        
        for i = 1, max do
            local btnName = "ArchiTotemButton_" .. element .. i
            ArchiTotem_TotemData[btnName] = nil
        end
        
        for i, data in ipairs(tempList) do
            local btnName = "ArchiTotemButton_" .. element .. i
            ArchiTotem_TotemData[btnName] = data
        end
        
        local userShown = ArchiTotem_Options[threeLetter].shown
        if #tempList > 0 then
			ArchiTotem_Options[threeLetter].shown = math.max(1, math.min(userShown, #tempList))
		else
			ArchiTotem_Options[threeLetter].shown = 0
		end
	end
end

-- =====================================================
--  ONLOAD / ONEVENT
-- =====================================================

function ArchiTotem_OnLoad()
    if class == "SHAMAN" then
        this:SetScript("OnDragStart", ArchiTotem_OnDragStart)
        this:SetScript("OnDragStop", ArchiTotem_OnDragStop)

        this:RegisterForDrag("RightButton")
        for _, popout in ipairs(ArchiTotemPopout) do
            _G[popout]:SetScript("OnDragStart", ArchiTotem_Noop)
            _G[popout]:SetScript("OnDragStop", ArchiTotem_Noop)
        end
        this:RegisterEvent("VARIABLES_LOADED")
        this:RegisterEvent("SPELLCAST_STOP")
        this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        this:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
        SLASH_ARCHITOTEM1 = "/architotem"
        SLASH_ARCHITOTEM2 = "/at"
        SlashCmdList["ARCHITOTEM"] = ArchiTotem_Command
        DEFAULT_CHAT_FRAME:AddMessage("|cff20b2aaArchiTotem|r " .. author .. " " .. L["ver."] .. " " .. version .. " " .. L["loaded"] .. ".")
    else
        this:UnregisterAllEvents()
        ArchiTotemFrame:Hide()
    end
end

function ArchiTotem_OnEvent(event)
    if event == "VARIABLES_LOADED" then
        ArchiTotem_InitDefaults()

        -- Csak a pozíciót állítjuk középre, de a többi beállítást MEGTARTJUK!
        ArchiTotem_Options["Apperance"].position = {
            point = "CENTER",
            relativeTo = UIParent,
            relativePoint = "CENTER",
            xOfs = 0,
            yOfs = 0,
        }

        ArchiTotem_ClearAllCooldowns()
        ArchiTotem_UpdateTextures()
        ArchiTotem_UpdateShown()
        ArchiTotem_SetDirection(ArchiTotem_Options["Apperance"].direction)
        ArchiTotem_SetScale(ArchiTotem_Options["Apperance"].scale)
        ArchiTotem_Order(ArchiTotem_Options["Order"].first, ArchiTotem_Options["Order"].second, ArchiTotem_Options["Order"].third, ArchiTotem_Options["Order"].forth)

        if ArchiTotem_Options["Apperance"].position then
            local pos = ArchiTotem_Options["Apperance"].position
            local relativeTo = pos.relativeTo
            if type(relativeTo) == "string" then
                relativeTo = _G[relativeTo] or UIParent
            end
            ArchiTotemFrame:SetPoint(pos.point, relativeTo, pos.relativePoint, pos.xOfs, pos.yOfs)
        end

        ArchiTotem_InitMinimapButton()

    elseif event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" then
        ArchiTotemCasted = 0

    elseif event == "SPELLCAST_STOP" then
        if ArchiTotemCasted == 1 then
            ArchiTotemActiveTotem[ArchiTotemCastedElement] = ArchiTotemCastedTotem
            ArchiTotemActiveTotem[ArchiTotemCastedElement].casted = GetTime()
            ArchiTotem_TotemData[ArchiTotemCastedButton].cooldownstarted = GetTime()

            ArchiTotem_UpdateAllCooldowns(ArchiTotemCastedButton)

            if ArchiTotem_Options["Apperance"].bottomoncast == true then
                local buttonNumber = tonumber(string.sub(ArchiTotemCastedButton, -1, -1))
                if buttonNumber > 1 then
                    local topbutton, bottombutton
                    for i = buttonNumber, 2, -1 do
                        topbutton = string.sub(ArchiTotemCastedButton, 1, -2) .. i
                        bottombutton = string.sub(ArchiTotemCastedButton, 1, -2) .. (i - 1)
                        ArchiTotem_Switch(topbutton, bottombutton)
                        if ArchiTotem_TotemData[topbutton].cooldownstarted == nil then
                            local duration = 1.5
                            local cooldownObj = _G[topbutton .. "Cooldown"]
                            if cooldownObj then
                                CooldownFrame_SetTimer(cooldownObj, GetTime(), duration, 1)
                            end
                        end
                    end
                    local duration = ArchiTotem_TotemData[bottombutton].cooldown
                    if duration == 0 then duration = 1.5 end
                    local bottomCooldownObj = _G[bottombutton .. "Cooldown"]
                    if bottomCooldownObj then
                        CooldownFrame_SetTimer(bottomCooldownObj, GetTime(), duration, 1)
                    end
                end
            end

            ArchiTotemCasted = nil
            ArchiTotemCastedTotem = nil
            ArchiTotemCastedButton = nil
        end
    end
end

-- =====================================================
--  DRAG HANDLING
-- =====================================================

function ArchiTotem_OnDragStart()
    if IsControlKeyDown() then
        ArchiTotemFrame:StartMoving()
    end
end

function ArchiTotem_OnDragStop()
    ArchiTotemFrame:StopMovingOrSizing()

    local point, relativeTo, relativePoint, xOfs, yOfs = ArchiTotemFrame:GetPoint()
    if not ArchiTotem_Options["Apperance"].position then
        ArchiTotem_Options["Apperance"].position = {}
    end
    ArchiTotem_Options["Apperance"].position.point = point
    ArchiTotem_Options["Apperance"].position.relativeTo = relativeTo
    ArchiTotem_Options["Apperance"].position.relativePoint = relativePoint
    ArchiTotem_Options["Apperance"].position.xOfs = xOfs
    ArchiTotem_Options["Apperance"].position.yOfs = yOfs
end

-- =====================================================
--  MOUSE ENTER / LEAVE / CLICK
-- =====================================================

function ArchiTotem_OnEnter()
    if not ArchiTotem_Options then return end

    if ArchiTotem_Options["Apperance"].allonmouseover == true then
        for _, v in pairs(totemElements) do
            local threeLetterElement = string.sub(v, 1, 3)
            for i = 1, ArchiTotem_Options[threeLetterElement].max do
                _G["ArchiTotemButton_" .. v .. i]:Show()
            end
        end
    else
        local totemElement = string.sub(this:GetName(), 1, -2)
        local maxOfElement = string.sub(this:GetName(), 18, 20)
        if maxOfElement and ArchiTotem_Options[maxOfElement] then
            for i = 2, ArchiTotem_Options[maxOfElement].max do
                local button = _G[totemElement .. i]
                if button then
                    button:Show()
                end
            end
        end
    end

    if ArchiTotem_Options["Apperance"].showtooltips == true then
        local buttonName = this:GetName()
        if ArchiTotem_TotemData and ArchiTotem_TotemData[buttonName] then
            local totemData = ArchiTotem_TotemData[buttonName]
            local tooltipspellID = ArchiTotem_GetSpellId(totemData.name)
            if tooltipspellID > 0 then

                GameTooltip:SetScale(tonumber(ArchiTotem_Options["Apperance"].tooltipScale) or 1.0)

                if ArchiTotem_Options["Apperance"].shortTooltip == true then
                    GameTooltip_SetDefaultAnchor(GameTooltip, this)
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine(totemData.name, 1, 1, 1)
                    GameTooltip:Show()
                else
                    GameTooltip_SetDefaultAnchor(GameTooltip, this)
                    GameTooltip:SetSpell(tooltipspellID, SpellBookFrame.bookType)
                end
            end
        end
    end
end

function ArchiTotem_OnLeave()
    ArchiTotem_UpdateShown()
end

function ArchiTotem_OnClick()
    if IsAltKeyDown() then
        local underTotemNumber = tonumber(string.sub(this:GetName(), -1, -1)) - 1
        local underTotem = string.sub(this:GetName(), 1, -2) .. underTotemNumber
        if underTotemNumber > 0 then
            ArchiTotem_Switch(this:GetName(), underTotem)
        end
    elseif IsControlKeyDown() then
        local overTotemNumber = tonumber(string.sub(this:GetName(), -1, -1)) + 1
        local overTotem = string.sub(this:GetName(), 1, -2) .. overTotemNumber
        local maxOfElement = string.sub(this:GetName(), 18, 20)
        if overTotemNumber < ArchiTotem_Options[maxOfElement].max + 1 then
            ArchiTotem_Switch(this:GetName(), overTotem)
        end
    else
        ArchiTotem_CastTotem()
    end
end

-- =====================================================
--  SPELL CASTING
-- =====================================================

function ArchiTotem_GetSpellId(spell)
    local localizeSpell = L[spell] or spell
    local spellID = 0
    local id = 1
    while true do
        local spellName = GetSpellName(id, 1) -- BOOKTYPE_SPELL
        if not spellName then break end
        if string.lower(spellName) == string.lower(localizeSpell) then
            spellID = id
            break
        end
        id = id + 1
    end
    return spellID
end

function ArchiTotem_CastTotem()
    local buttonName = this:GetName()
    local totemData = ArchiTotem_TotemData[buttonName]
    if not totemData then return end

    local localizeSpell = L[totemData.name] or totemData.name

    if localizeSpell and localizeSpell ~= "" then
        local spellID = ArchiTotem_GetSpellId(localizeSpell)
        if spellID > 0 then
            ArchiTotemCasted = 1
            ArchiTotemCastedTotem = totemData
            ArchiTotemCastedElement = string.sub(buttonName, 18, -2)
            ArchiTotemCastedButton = buttonName

            if ArchiTotemCastedTotem.casted == nil then
                ArchiTotemCastedTotem.casted = GetTime() - ArchiTotemCastedTotem.cooldown
            end

            RunScript("CastSpellByName('" .. localizeSpell .. "')")
        else
            UIErrorsFrame:AddMessage("Spell not found: " .. tostring(localizeSpell), 1.0, 0.1, 0.1)
        end
    else
        UIErrorsFrame:AddMessage("Invalid totem name: " .. tostring(totemData.name), 1.0, 0.1, 0.1)
    end
end

-- =====================================================
--  SWITCH / COOLDOWN / TEXTURE UPDATES
-- =====================================================

function ArchiTotem_Switch(arg1, arg2)
    local temp = ArchiTotem_TotemData[arg1]
    ArchiTotem_TotemData[arg1] = ArchiTotem_TotemData[arg2]
    ArchiTotem_TotemData[arg2] = temp
    _G[arg1 .. "CooldownText"]:Hide()
    _G[arg1 .. "CooldownBg"]:Hide()
    _G[arg2 .. "CooldownText"]:Hide()
    _G[arg2 .. "CooldownBg"]:Hide()

    local cooldown1 = _G[arg1 .. "Cooldown"]
    local cooldown2 = _G[arg2 .. "Cooldown"]

    if ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg1].name) ~= 0 and cooldown1 then
        local _, duration1 = GetSpellCooldown(ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg1].name), BOOKTYPE_SPELL)
        CooldownFrame_SetTimer(cooldown1, ArchiTotem_TotemData[arg1].casted, duration1, 1)
    end
    if ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg2].name) ~= 0 and cooldown2 then
        local _, duration2 = GetSpellCooldown(ArchiTotem_GetSpellId(ArchiTotem_TotemData[arg2].name), BOOKTYPE_SPELL)
        CooldownFrame_SetTimer(cooldown2, ArchiTotem_TotemData[arg2].casted, duration2, 1)
    end
    ArchiTotem_UpdateTextures()

    if ArchiTotem_Options then
        local saveData = {}
        for k, v in pairs(ArchiTotem_TotemData) do
            saveData[k] = {
                icon = v.icon,
                name = v.name,
                duration = v.duration,
                cooldown = v.cooldown,
                cooldownstarted = nil,
                casted = nil,
            }
        end
        ArchiTotem_Options["TotemOrder"] = saveData
    end
end

function ArchiTotem_ClearAllCooldowns()
    if not ArchiTotem_TotemData then return end
    for _, v in pairs(ArchiTotem_TotemData) do
        v.cooldownstarted = nil
    end
end

function ArchiTotem_UpdateCooldown(Buttonname, duration)
    if ArchiTotem_Options["Debug"] then ArchiTotem_Print("+++++" .. Buttonname .. "+++++", "debug") end
    local cooldown = _G[Buttonname .. "Cooldown"]
    if cooldown ~= nil then
        local start = GetTime()
        if duration == 0 then duration = 1.5 end
        local enable = 1
        CooldownFrame_SetTimer(cooldown, start, duration, enable)
        if ArchiTotem_Options["Debug"] then ArchiTotem_Print(start .. "-" .. duration .. "-" .. enable) end
    else
        if ArchiTotem_Options["Debug"] then ArchiTotem_Print("+++++" .. Buttonname .. " NOT FOUND") end
    end
end

function ArchiTotem_UpdateAllCooldowns()
    if not ArchiTotem_TotemData then return end
    for k, v in pairs(ArchiTotem_TotemData) do
        if v.casted == nil then v.casted = GetTime() - v.cooldown end
        local duration = 1.5
        if GetTime() > (v.casted + v.cooldown) then
            if ArchiTotemCastedButton == k then duration = v.cooldown else duration = 1.5 end
            local cooldownObj = _G[k .. "Cooldown"]
            if cooldownObj then
                ArchiTotem_UpdateCooldown(k, duration)
            end
        end
    end
end

function ArchiTotem_UpdateTextures()
    if not ArchiTotem_Options or not ArchiTotem_TotemData then return end
    for _, v in pairs(totemElements) do
        local threeLetterElement = string.sub(v, 1, 3)
        for i = 1, ArchiTotem_Options[threeLetterElement].max do
            local buttonName = "ArchiTotemButton_" .. v .. i
            local texObj = _G[buttonName .. "Texture"]
            if texObj and ArchiTotem_TotemData[buttonName] then
                texObj:SetTexture(ArchiTotem_TotemData[buttonName].icon)
                texObj:Show()
            end
        end
    end
end

function ArchiTotem_UpdateShown()
    if not ArchiTotem_Options then return end
    for _, v in pairs(totemElements) do
        local threeLetterElement = string.sub(v, 1, 3)
        if ArchiTotem_Options["Apperance"].allonmouseover == true then
            for i = 1, ArchiTotem_Options[threeLetterElement].max do
                _G["ArchiTotemButton_" .. v .. i]:Show()
            end
        else
            for i = 1, ArchiTotem_Options[threeLetterElement].max do
                if i <= ArchiTotem_Options[threeLetterElement].shown then
                    _G["ArchiTotemButton_" .. v .. i]:Show()
                else
                    _G["ArchiTotemButton_" .. v .. i]:Hide()
                end
            end
        end
    end
end

-- =====================================================
--  LAYOUT / ORDER / SCALE
-- =====================================================

function ArchiTotem_SetDirection(dir)
    ArchiTotem_Options["Apperance"].direction = dir
    local anchor1, anchor2
    if dir == "down" then
        anchor1 = "TOPLEFT"
        anchor2 = "BOTTOMLEFT"
        EarthDurationText:SetPoint("CENTER", ArchiTotemButton_Earth1, "CENTER", 0, 26)
        FireDurationText:SetPoint("CENTER", ArchiTotemButton_Fire1, "CENTER", 0, 26)
        WaterDurationText:SetPoint("CENTER", ArchiTotemButton_Water1, "CENTER", 0, 26)
        AirDurationText:SetPoint("CENTER", ArchiTotemButton_Air1, "CENTER", 0, 26)
    elseif dir == "up" then
        anchor1 = "BOTTOMLEFT"
        anchor2 = "TOPLEFT"
        EarthDurationText:SetPoint("CENTER", ArchiTotemButton_Earth1, "CENTER", 0, -26)
        FireDurationText:SetPoint("CENTER", ArchiTotemButton_Fire1, "CENTER", 0, -26)
        WaterDurationText:SetPoint("CENTER", ArchiTotemButton_Water1, "CENTER", 0, -26)
        AirDurationText:SetPoint("CENTER", ArchiTotemButton_Air1, "CENTER", 0, -26)
    end
    for _, v in pairs(totemElements) do
        local threeLetterElement = string.sub(v, 1, 3)
        for i = 2, ArchiTotem_Options[threeLetterElement].max do
            local relativeTotem = _G["ArchiTotemButton_" .. v .. (i - 1)]
            _G["ArchiTotemButton_" .. v .. i]:ClearAllPoints()
            _G["ArchiTotemButton_" .. v .. i]:SetPoint(anchor1, relativeTotem, anchor2)
        end
    end
end

function ArchiTotem_Order(first, second, third, forth)
    if first == nil or second == nil or third == nil or forth == nil then
        return ArchiTotem_Print(L["Elements must be written in english!"] .. " <Earth, Fire, Water, Air>", "error")
    end
    local firstButton = "ArchiTotemButton_" .. strupper(string.sub(first, 1, 1)) .. string.sub(first, 2) .. "1"
    local secondButton = "ArchiTotemButton_" .. strupper(string.sub(second, 1, 1)) .. string.sub(second, 2) .. "1"
    local thirdButton = "ArchiTotemButton_" .. strupper(string.sub(third, 1, 1)) .. string.sub(third, 2) .. "1"
    local forthButton = "ArchiTotemButton_" .. strupper(string.sub(forth, 1, 1)) .. string.sub(forth, 2) .. "1"

    ArchiTotem_Options["Order"].first = strupper(string.sub(first, 1, 1)) .. string.sub(first, 2)
    ArchiTotem_Options["Order"].second = strupper(string.sub(second, 1, 1)) .. string.sub(second, 2)
    ArchiTotem_Options["Order"].third = strupper(string.sub(third, 1, 1)) .. string.sub(third, 2)
    ArchiTotem_Options["Order"].forth = strupper(string.sub(forth, 1, 1)) .. string.sub(forth, 2)

    _G[firstButton]:ClearAllPoints()
    _G[firstButton]:SetPoint("CENTER", ArchiTotemFrame, "CENTER")

    _G[secondButton]:ClearAllPoints()
    _G[secondButton]:SetPoint("BOTTOMLEFT", firstButton, "BOTTOMRIGHT")

    _G[thirdButton]:ClearAllPoints()
    _G[thirdButton]:SetPoint("BOTTOMLEFT", secondButton, "BOTTOMRIGHT")

    _G[forthButton]:ClearAllPoints()
    _G[forthButton]:SetPoint("BOTTOMLEFT", thirdButton, "BOTTOMRIGHT")
end

function ArchiTotem_SetScale(scale)
    ArchiTotem_Options["Apperance"].scale = scale
    for _, v in pairs(totemElements) do
        local threeLetterElement = string.sub(v, 1, 3)
        for i = 1, ArchiTotem_Options[threeLetterElement].max do
            _G["ArchiTotemButton_" .. v .. i]:SetScale(tonumber(scale))
        end
    end
end

function ArchiTotem_ResetData()
    ArchiTotem_TotemData = nil
    ArchiTotem_Options = nil

    ArchiTotem_InitDefaults()

    ArchiTotem_ClearAllCooldowns()
    ArchiTotem_UpdateTextures()
    ArchiTotem_UpdateShown()
    ArchiTotem_SetDirection(ArchiTotem_Options["Apperance"].direction)
    ArchiTotem_SetScale(ArchiTotem_Options["Apperance"].scale)
    ArchiTotem_Order(ArchiTotem_Options["Order"].first, ArchiTotem_Options["Order"].second, ArchiTotem_Options["Order"].third, ArchiTotem_Options["Order"].forth)

    if ArchiTotemConfigFrame and ArchiTotemConfigFrame:IsShown() then
        ArchiTotem_UpdateConfigDisplay()
    end

    ArchiTotem_Print("Data reset complete.", "error")
end

-- =====================================================
--  ONUPDATE
-- =====================================================

function ArchiTotem_OnUpdate(arg1)
    this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + arg1

    if this.TimeSinceLastUpdate > CLOCK_UPDATE_RATE then
        -- Active totem durations
        if ArchiTotemActiveTotem then
            for k, v in pairs(ArchiTotemActiveTotem) do
                if GetTime() > (v.casted + v.duration) then
                    v = nil
                    _G[k .. "DurationText"]:Hide()
                else
                    local seconds = string.format("%.0f", (v.duration + (v.casted - GetTime())))
                    local minutes = string.format("0%.0f", ((seconds - mod(seconds, 60)) / 60))
                    local seconds = mod(seconds, 60)
                    _G[k .. "DurationText"]:Show()
                    if seconds < 10 then seconds = string.format("0%.0f", seconds) else seconds = string.format("%.0f", seconds) end
                    _G[k .. "DurationText"]:SetText(minutes .. ":" .. seconds)
                end
            end
        end

        -- Cooldown timers
        if ArchiTotem_TotemData then
            for k, v in pairs(ArchiTotem_TotemData) do
                if ArchiTotem_Options["Apperance"].shownumericcooldowns == true then
                    if v.cooldownstarted == nil then
                        -- nothing
                    else
                        if GetTime() > (v.cooldownstarted + v.cooldown) then
                            _G[k .. "CooldownText"]:Hide()
                            _G[k .. "CooldownBg"]:Hide()
                            v.cooldownstarted = nil
                        else
                            _G[k .. "CooldownBg"]:Show()
                            _G[k .. "CooldownText"]:Show()
                            local seconds = string.format("%.0f", (v.cooldown + (v.cooldownstarted - GetTime())))
                            local minutes = string.format("%.0f", ((seconds - mod(seconds, 60)) / 60))
                            local seconds = mod(seconds, 60)
                            if minutes ~= "0" then
                                _G[k .. "CooldownText"]:SetText(minutes .. ":" .. seconds)
                            else
                                _G[k .. "CooldownText"]:SetText(seconds)
                            end
                        end
                    end
                end
            end
        end

        this.TimeSinceLastUpdate = 0
    end
end

-- =====================================================
--  SLASH COMMANDS
-- =====================================================

function ArchiTotem_Command(cmd)
    local command = string.lower(cmd)
    local arg = {}
    for token in string.gfind(command, "%w+") do
        table.insert(arg, token)
    end

    if arg[1] == "set" then
        if arg[2] == "earth" then
            if tonumber(arg[3]) > 0 and tonumber(arg[3]) <= 5 then
                ArchiTotem_Options["Ear"].shown = tonumber(arg[3])
                ArchiTotem_UpdateShown()
                ArchiTotem_Print(L["Earth totems shown: "] .. arg[3])
            end
        elseif arg[2] == "fire" then
            if tonumber(arg[3]) > 0 and tonumber(arg[3]) <= 5 then
                ArchiTotem_Options["Fir"].shown = tonumber(arg[3])
                ArchiTotem_UpdateShown()
                ArchiTotem_Print(L["Fire totems shown: "] .. arg[3])
            end
        elseif arg[2] == "water" then
            if tonumber(arg[3]) > 0 and tonumber(arg[3]) <= 6 then
                ArchiTotem_Options["Wat"].shown = tonumber(arg[3])
                ArchiTotem_UpdateShown()
                ArchiTotem_Print(L["Water totems shown: "] .. arg[3])
            end
        elseif arg[2] == "air" then
            if tonumber(arg[3]) > 0 and tonumber(arg[3]) <= 7 then
                ArchiTotem_Options["Air"].shown = tonumber(arg[3])
                ArchiTotem_UpdateShown()
                ArchiTotem_Print(L["Air totems shown: "] .. arg[3])
            end
        else
            ArchiTotem_Print(L["Elements must be written in english!"] .. " <Earth, Fire, Water, Air>", "error")
        end
    elseif arg[1] == "direction" then
        if arg[2] == "down" then
            ArchiTotem_SetDirection("down")
            ArchiTotem_Print(L["Direction set to: Down"])
        elseif arg[2] == "up" then
            ArchiTotem_SetDirection("up")
            ArchiTotem_Print(L["Direction set to: Up"])
        else
            ArchiTotem_Print(L["Direction must be down or up!"], "error")
        end
    elseif arg[1] == "order" then
        ArchiTotem_Order(arg[2], arg[3], arg[4], arg[5])
        if arg[2] and arg[3] and arg[4] and arg[5] then
            ArchiTotem_Print(L["Order set to: "] .. arg[2] .. ", " .. arg[3] .. ", " .. arg[4] .. ", " .. arg[5])
        end
    elseif arg[1] == "scale" then
        if not arg[2] then
            return ArchiTotem_Print(L["Specify scale"], "error")
        elseif type(tonumber(arg[2])) ~= "number" then
            return ArchiTotem_Print(L["Scale must be a number!"], "error")
        end
        if arg[3] then
            ArchiTotem_SetScale(arg[2] .. "." .. arg[3])
            ArchiTotem_Print(L["Scale set to: "] .. arg[2] .. "." .. arg[3])
        else
            ArchiTotem_SetScale(arg[2])
            ArchiTotem_Print(L["Scale set to: "] .. arg[2])
        end
    elseif arg[1] == "showall" then
        ArchiTotem_Options["Apperance"].allonmouseover = not ArchiTotem_Options["Apperance"].allonmouseover
        ArchiTotem_Print(ArchiTotem_Options["Apperance"].allonmouseover and L["Showing all totems on mouseover"] or L["Showing only one element on mouseover"])
    elseif arg[1] == "bottomcast" then
        ArchiTotem_Options["Apperance"].bottomoncast = not ArchiTotem_Options["Apperance"].bottomoncast
        ArchiTotem_Print(ArchiTotem_Options["Apperance"].bottomoncast and L["Totems will move the the bottom line when cast"] or L["Totems will stay where they are when cast"])
    elseif arg[1] == "timers" then
        ArchiTotem_Options["Apperance"].shownumericcooldowns = not ArchiTotem_Options["Apperance"].shownumericcooldowns
        if not ArchiTotem_Options["Apperance"].shownumericcooldowns then
            for k, v in pairs(ArchiTotem_TotemData) do
                _G[k .. "CooldownText"]:Hide()
                _G[k .. "CooldownBg"]:Hide()
                v.cooldownstarted = nil
            end
            for k, v in pairs(ArchiTotemActiveTotem) do
                _G[k .. "DurationText"]:Hide()
            end
        end
        ArchiTotem_Print(ArchiTotem_Options["Apperance"].shownumericcooldowns and L["Timers are now turned on"] or L["Timers are now turned off"])
    elseif arg[1] == "tooltip" then
        ArchiTotem_Options["Apperance"].showtooltips = not ArchiTotem_Options["Apperance"].showtooltips
        ArchiTotem_Print(ArchiTotem_Options["Apperance"].showtooltips and L["Tooltips are now turned on"] or L["Tooltips are now turned off"])
    elseif arg[1] == "debug" then
        ArchiTotem_Options["Debug"] = not ArchiTotem_Options["Debug"]
        ArchiTotem_Print(ArchiTotem_Options["Debug"] and L["Debuging are now turned on"] or L["Debuging are now turned off"])
    elseif arg[1] == nil then
        ArchiTotem_Print(L["Available commands:"])
        ArchiTotem_Print(L["/at set <earth/fire/water/air> # - Sets the totems shown of that element to #."])
        ArchiTotem_Print(L["/at direction <up/down> - Set the direction totems pop up."])
        ArchiTotem_Print(L["/at order <element 1, element 2, element 3, element 4> - Sets the order of the totems, from left to right."])
        ArchiTotem_Print(L["/at scale # - Sets the scale of ArchiTotem, default is 1."])
        ArchiTotem_Print(L["/at showall - Toggles show all mode, displaying all totems on mouseover."])
        ArchiTotem_Print(L["/at bottomcast - Toggles moving totems to the bottom line when cast"])
        ArchiTotem_Print(L["/at timers - Toggles showing timers"])
        ArchiTotem_Print(L["/at tooltip - Toggles showing tooltips"])
        ArchiTotem_Print(L["/at debug - Toggles debuging"])
        DEFAULT_CHAT_FRAME:AddMessage("\n")
        ArchiTotem_Print(L["Moving the bar:"])
        ArchiTotem_Print(L["Ctrl-RightClick and Drag any of the main buttons"])
        ArchiTotem_Print(L["Ordering totems of same element:"])
        ArchiTotem_Print(L["Ctrl-LeftClick any of the buttons"])
    else
        ArchiTotem_Print(L["Unavailable command. Type /at for help."], "error")
    end
end

-- =====================================================
--  MINIMAP ICON & CONFIG PANEL
-- =====================================================

local ArchiTotemMinimapButton = nil
local ArchiTotemConfigFrame = nil
local configWidgets = {}

function ArchiTotem_CreateMinimapButton()
    if ArchiTotemMinimapButton then return end

    ArchiTotemMinimapButton = CreateFrame("Button", "ArchiTotemMinimapButton", Minimap)
    ArchiTotemMinimapButton:SetWidth(30)
    ArchiTotemMinimapButton:SetHeight(30)
    ArchiTotemMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -20, -50)
    ArchiTotemMinimapButton:SetNormalTexture("Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02")
    ArchiTotemMinimapButton:SetScript("OnClick", function()
        if ArchiTotemConfigFrame and ArchiTotemConfigFrame:IsShown() then
            ArchiTotemConfigFrame:Hide()
        else
            ArchiTotem_ShowConfigPanel()
        end
    end)
    ArchiTotemMinimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(ArchiTotemMinimapButton, "ANCHOR_LEFT")
        GameTooltip:SetText("ArchiTotem Settings")
        GameTooltip:Show()
    end)
    ArchiTotemMinimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function ArchiTotem_ShowConfigPanel()
    if not ArchiTotemConfigFrame then
        ArchiTotem_CreateConfigPanel()
    end
    ArchiTotem_UpdateConfigDisplay()
    ArchiTotemConfigFrame:Show()
end

function ArchiTotem_CreateConfigPanel()
    if ArchiTotemConfigFrame then return end

    local frame = CreateFrame("Frame", "ArchiTotemConfigFrame", UIParent)
    frame:SetWidth(300)
    frame:SetHeight(470)
    frame:SetPoint("CENTER")
    
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    frame:SetBackdropBorderColor(1, 0.82, 0, 1)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    frame:Hide()
    ArchiTotemConfigFrame = frame

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText(L["ArchiTotem - Settings"])
    title:SetTextColor(1, 0.82, 0)

    local function CreateRow(yOffset, labelText)
        local row = CreateFrame("Frame", nil, frame)
        row:SetWidth(260)
        row:SetHeight(24)
        row:SetPoint("TOP", 0, yOffset)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", 10, 0)
        label:SetText(labelText)
        label:SetWidth(100)
        label:SetTextColor(1, 0.82, 0)
        label:SetJustifyH("LEFT")

        local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueText:SetPoint("RIGHT", row, "RIGHT", -30, 0) 
        valueText:SetText("")
        valueText:SetTextColor(1, 1, 1)

        local btnMinus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnMinus:SetWidth(25)
        btnMinus:SetHeight(22)
        btnMinus:SetPoint("RIGHT", valueText, "LEFT", -5, 0)
        btnMinus:SetText("-")

        local btnPlus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnPlus:SetWidth(25)
        btnPlus:SetHeight(22)
        btnPlus:SetPoint("LEFT", valueText, "RIGHT", 5, 0)
        btnPlus:SetText("+")

        return { row = row, label = label, value = valueText, minus = btnMinus, plus = btnPlus }
    end

    local function CreateToggleRow(yOffset, labelText, onClickFunc)
        local row = CreateFrame("Frame", nil, frame)
        row:SetWidth(260)
        row:SetHeight(24)
        row:SetPoint("TOP", 0, yOffset)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", 35, 0)
        label:SetText(labelText)
        label:SetWidth(180)
        label:SetTextColor(1, 0.82, 0)
        label:SetJustifyH("LEFT")

        local btn = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        btn:SetWidth(24)
        btn:SetHeight(24)
        btn:SetPoint("LEFT", 5, 0)
        btn:SetScript("OnClick", onClickFunc)

        return { row = row, label = label, button = btn }
    end

    local yPos = -35

    -- Earth
    local earthRow = CreateRow(yPos, "Earth")
    earthRow.minus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Ear", -1) end)
    earthRow.plus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Ear", 1) end)
    configWidgets.earth = earthRow
    yPos = yPos - 30

    -- Fire
    local fireRow = CreateRow(yPos, "Fire")
    fireRow.minus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Fir", -1) end)
    fireRow.plus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Fir", 1) end)
    configWidgets.fire = fireRow
    yPos = yPos - 30

    -- Water
    local waterRow = CreateRow(yPos, "Water")
    waterRow.minus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Wat", -1) end)
    waterRow.plus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Wat", 1) end)
    configWidgets.water = waterRow
    yPos = yPos - 30

    -- Air
    local airRow = CreateRow(yPos, "Air")
    airRow.minus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Air", -1) end)
    airRow.plus:SetScript("OnClick", function() ArchiTotem_ChangeCount("Air", 1) end)
    configWidgets.air = airRow
    yPos = yPos - 30

    -- Direction
    local dirRow = CreateFrame("Frame", nil, frame)
    dirRow:SetWidth(260)
    dirRow:SetHeight(24)
    dirRow:SetPoint("TOP", 0, yPos)

    local dirLabel = dirRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dirLabel:SetPoint("LEFT", 10, 0)
    dirLabel:SetText(L["Popout direction"])
    dirLabel:SetWidth(180)
    dirLabel:SetTextColor(1, 0.82, 0)
    dirLabel:SetJustifyH("LEFT")

    local dirBtn = CreateFrame("Button", nil, dirRow, "UIPanelButtonTemplate")
    dirBtn:SetWidth(60)
    dirBtn:SetHeight(22)
    dirBtn:SetPoint("RIGHT", -10, 0)
    dirBtn:SetText("UP")
    dirBtn:SetScript("OnClick", function()
        if ArchiTotem_Options["Apperance"].direction == "up" then
            ArchiTotem_SetDirection("down")
        else
            ArchiTotem_SetDirection("up")
        end
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.dir = { row = dirRow, label = dirLabel, button = dirBtn }
    yPos = yPos - 30

    -- Show all on hover
    local showAllRow = CreateToggleRow(yPos, L["Show all totems on hover"], function()
        ArchiTotem_Options["Apperance"].allonmouseover = not ArchiTotem_Options["Apperance"].allonmouseover
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.showAll = showAllRow
    yPos = yPos - 30

    -- Bottom on cast
    local bottomRow = CreateToggleRow(yPos, L["Move to bottom on cast"], function()
        ArchiTotem_Options["Apperance"].bottomoncast = not ArchiTotem_Options["Apperance"].bottomoncast
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.bottom = bottomRow
    yPos = yPos - 30

    -- Numeric cooldowns
    local timerRow = CreateToggleRow(yPos, L["Show numeric cooldowns"], function()
        ArchiTotem_Options["Apperance"].shownumericcooldowns = not ArchiTotem_Options["Apperance"].shownumericcooldowns
        ArchiTotem_UpdateConfigDisplay()
        if not ArchiTotem_Options["Apperance"].shownumericcooldowns then
            for k, v in pairs(ArchiTotem_TotemData) do
                _G[k .. "CooldownText"]:Hide()
                _G[k .. "CooldownBg"]:Hide()
                v.cooldownstarted = nil
            end
            for k, v in pairs(ArchiTotemActiveTotem) do
                _G[k .. "DurationText"]:Hide()
            end
        end
    end)
    configWidgets.timer = timerRow
    yPos = yPos - 30

    -- Icons Scale
    local scaleRow = CreateRow(yPos, L["Icons Scale"])
    scaleRow.minus:SetScript("OnClick", function()
        local newScale = tonumber(ArchiTotem_Options["Apperance"].scale) - 0.1
        if newScale < 0.5 then newScale = 0.5 end
        ArchiTotem_SetScale(string.format("%.1f", newScale))
        ArchiTotem_UpdateConfigDisplay()
    end)
    scaleRow.plus:SetScript("OnClick", function()
        local newScale = tonumber(ArchiTotem_Options["Apperance"].scale) + 0.1
        if newScale > 1.5 then newScale = 1.5 end
        ArchiTotem_SetScale(string.format("%.1f", newScale))
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.scale = scaleRow
    yPos = yPos - 30

    -- Show tooltips
    local tooltipRow = CreateToggleRow(yPos, L["Show tooltips"], function()
        ArchiTotem_Options["Apperance"].showtooltips = not ArchiTotem_Options["Apperance"].showtooltips
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.tooltip = tooltipRow
    yPos = yPos - 30

    -- >>> Short tooltip (közvetlenül a "Show tooltips" sor alá rögzítve) <<<
    ArchiTotemShortTipCheck = CreateFrame("CheckButton", "ArchiTotemShortTipCheck", frame, "UICheckButtonTemplate")
    ArchiTotemShortTipCheck:SetWidth(24)
    ArchiTotemShortTipCheck:SetHeight(24)
    ArchiTotemShortTipCheck:SetPoint("TOPLEFT", tooltipRow.row, "BOTTOMLEFT", 5, -5)
    ArchiTotemShortTipCheck:SetScript("OnClick", function()
        ArchiTotem_Options["Apperance"].shortTooltip = ArchiTotemShortTipCheck:GetChecked()
        ArchiTotem_UpdateConfigDisplay()
    end)

    local shortTipLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    shortTipLabel:SetPoint("LEFT", ArchiTotemShortTipCheck, "RIGHT", 8, 0)
    shortTipLabel:SetText(L["Short tooltip (only name)"] or "Short tooltip (only name)")
    shortTipLabel:SetTextColor(1, 0.82, 0)
    shortTipLabel:SetJustifyH("LEFT")

    -- Tooltip scale
    local tooltipScaleRow = CreateRow(yPos, L["Tooltip scale"])
    tooltipScaleRow.row:ClearAllPoints()
    tooltipScaleRow.row:SetPoint("TOPLEFT", ArchiTotemShortTipCheck, "BOTTOMLEFT", 0, -10)
    tooltipScaleRow.minus:SetScript("OnClick", function()
        local current = tonumber(ArchiTotem_Options["Apperance"].tooltipScale or 1.0)
        local newScale = current - 0.1
        if newScale < 0.2 then newScale = 0.2 end
        ArchiTotem_Options["Apperance"].tooltipScale = newScale
        ArchiTotem_UpdateConfigDisplay()
    end)
    tooltipScaleRow.plus:SetScript("OnClick", function()
        local current = tonumber(ArchiTotem_Options["Apperance"].tooltipScale or 1.0)
        local newScale = current + 0.1
        if newScale > 1.5 then newScale = 1.5 end
        ArchiTotem_Options["Apperance"].tooltipScale = newScale
        ArchiTotem_UpdateConfigDisplay()
    end)
    configWidgets.tooltipScale = tooltipScaleRow

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetBtn:SetWidth(120)
    resetBtn:SetHeight(24)
    resetBtn:SetPoint("BOTTOM", 0, 50)
    resetBtn:SetText(L["Reset Data"])
    resetBtn:SetScript("OnClick", function()
        ArchiTotem_ResetData()
        ArchiTotemConfigFrame:Hide()
    end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(24)
    closeBtn:SetPoint("BOTTOM", 0, 15)
    closeBtn:SetText(L["Close"])
    closeBtn:SetScript("OnClick", function()
        ArchiTotemConfigFrame:Hide()
    end)

    local info = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    info:SetPoint("BOTTOM", 0, 40)
    info:SetText(L["Settings are saved automatically"])
    info:SetTextColor(0.8, 0.8, 0.8)

    ArchiTotemTipScaleValue = tooltipScaleRow.value
end

function ArchiTotem_ChangeCount(element, delta)
    local maxMap = { Ear = 5, Fir = 5, Wat = 6, Air = 7 }
    local current = ArchiTotem_Options[element].shown
    local newVal = current + delta
    if newVal < 1 then newVal = 1 end
    if newVal > maxMap[element] then newVal = maxMap[element] end
    if newVal ~= current then
        ArchiTotem_Options[element].shown = newVal
        ArchiTotem_UpdateShown()
        ArchiTotem_UpdateConfigDisplay()
    end
end

function ArchiTotem_UpdateConfigDisplay()
    if not ArchiTotemConfigFrame then return end

    configWidgets.earth.value:SetText(ArchiTotem_Options["Ear"].shown)
    configWidgets.fire.value:SetText(ArchiTotem_Options["Fir"].shown)
    configWidgets.water.value:SetText(ArchiTotem_Options["Wat"].shown)
    configWidgets.air.value:SetText(ArchiTotem_Options["Air"].shown)

    local dir = ArchiTotem_Options["Apperance"].direction
    configWidgets.dir.button:SetText(dir == "up" and "UP" or "DOWN")

    local function setToggle(row, value)
        row.button:SetChecked(value)
    end
    setToggle(configWidgets.showAll, ArchiTotem_Options["Apperance"].allonmouseover)
    setToggle(configWidgets.bottom, ArchiTotem_Options["Apperance"].bottomoncast)
    setToggle(configWidgets.timer, ArchiTotem_Options["Apperance"].shownumericcooldowns)
    setToggle(configWidgets.tooltip, ArchiTotem_Options["Apperance"].showtooltips)

    configWidgets.scale.value:SetText(string.format("%.1f", tonumber(ArchiTotem_Options["Apperance"].scale)))

    if ArchiTotemShortTipCheck then
        ArchiTotemShortTipCheck:SetChecked(ArchiTotem_Options["Apperance"].shortTooltip or false)
    end
    if ArchiTotemTipScaleValue then
        ArchiTotemTipScaleValue:SetText(string.format("%.1f", tonumber(ArchiTotem_Options["Apperance"].tooltipScale) or 1.0))
    end
end

function ArchiTotem_InitMinimapButton()
    ArchiTotem_CreateMinimapButton()
end
