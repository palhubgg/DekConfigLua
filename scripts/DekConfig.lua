local lunajson = require 'lunajson'

-- get the root "\Mods" directory we were loaded from
local ModDir = string.gsub(debug.getinfo(1).source, "^@(.+[/\\]Mods[/\\]).+", "%1")
local PathSep = ModDir:sub(-1, -1) -- get path separator in use on this platform
local DebugLogging = true

local function DebugLog(msg)
    if not DebugLogging then return end
    print(string.format("[%s] DEBUG: %s\n", "DekConfig", msg))
end

local ErrorMessage = {
    ConfigNotFound = function(modId)
        return "Config not found for mod " .. modId .. ""
    end
}

local function ModConfigPath(modId, isTest)
    return ModDir .. modId .. PathSep .. modId .. (isTest and ".testconfig.json" or ".modconfig.json")
end

--- @param modId string
--- @param isTest boolean
--- @param mode? openmode
--- @return file*?
local function OpenModConfigFile(modId, isTest, mode)
    local file --- @type file*?
    if isTest then
        DebugLog("OpenModConfigFile - trying " .. ModConfigPath(modId, isTest))
        file = io.open(ModConfigPath(modId, isTest), mode)
        if file then return file end
    end
    DebugLog("OpenModConfigFile - trying " .. ModConfigPath(modId, false))
    return io.open(ModConfigPath(modId, false), mode)
end

--- @generic T table
--- @class DekConfig
--- @field ModID string
--- @field ModVersion string
--- @field IsTest boolean
--- @field ConfigPath string
DekConfig = {}
DekConfig.__index = DekConfig

DekConfig.Name = "DekConfig"
DekConfig.Version = "1.0"

--- Inform that this mod is used by another mod
--- @param ModID string
--- @param ModVersion string
--- @param IsTest boolean?
--- @return DekConfig::Type
function DekConfig.Use(ModID, ModVersion, IsTest)
    if IsTest == nil then IsTest = false end
    print(string.format("%s [v%s] is used by %s [v%s]", DekConfig.Name, DekConfig.Version, ModID, ModVersion))
    local result = {}
    result.ModID = ModID
    result.ModVersion = ModVersion
    result.IsTest = IsTest
    setmetatable(result, DekConfig)
    return result;
end

--- Gets a value from the config by path
--- @param path string  '.'-delimited path to the setting
---@return unknown|nil
function DekConfig:GetSetting(path)
    if not self.Data then
        self:Reload()
    end
    local currentNode = self.Data
    local first = true
    for part in string.gmatch(path, "([^\\.]+)") do
        if currentNode == nil then return DebugLog("GetSetting(" .. path .. "): Path not found") end
        if not first then
            currentNode = currentNode.data
            if currentNode == nil then return DebugLog("GetSetting(" .. path .. "): Path not found") end
        end
        first = false
        currentNode = currentNode[part]
    end
    if currentNode == nil then return DebugLog("GetSetting(" .. path .. "): Path not found") end
    local value = currentNode.live
    if value == nil then return DebugLog("GetSetting(" .. path .. "): Path not found") end
    DebugLog("GetSetting(" .. path .. "): " .. tostring(value))
    return value;
end

--- Sets a value from the config by path
--- @param path string  '.'-delimited path to the setting
--- @param value unknown
---@return unknown|nil
function DekConfig:SetSetting(path, value)
    DebugLog("SetSetting(" .. path .. ", " .. tostring(value) .. ")")
    if not self.Data then
        self:Reload()
    end
    local currentNode = self.Data
    local first = true
    for part in string.gmatch(path, "([^\\.]+)") do
        if currentNode == nil then return DebugLog("SetSetting(" .. path .. "): Path not found") end
        if not first then
            currentNode = currentNode.data
            if currentNode == nil then return DebugLog("SetSetting(" .. path .. "): Path not found") end
        end
        first = false
        currentNode = currentNode[part]
    end
    if currentNode == nil then return DebugLog("SetSetting(" .. path .. "): Path not found") end
    currentNode.live = value
    self:Save()
end

--- Reloads the config from disk
function DekConfig:Reload()
    DebugLog("Reload(self=" .. self.ModID .. ")")
    local file = OpenModConfigFile(self.ModID, self.IsTest, "r")
    if not file then error(ErrorMessage.ConfigNotFound(self.ModID)) end

    local content = file:read("*a")
    file:close()

    self.Data = lunajson.decode(content)
    -- only override passed value if the config has a test value
    if self.Data.test == true then
        if self.IsTest ~= true then
            -- if the config has a test value, and we are not in test mode, then we should reload the config in test mode
            self.IsTest = true
            self:Reload()
        end
        self.IsTest = true
    end
end

function DekConfig:Save()
    DebugLog("Save()")
    local file = io.open(ModConfigPath(self.ModID, self.IsTest), "w")
    if not file then error(ErrorMessage.ConfigNotFound(self.ModID)) end

    file:write(lunajson.encode(self.Data))
    file:close()
end

return DekConfig
