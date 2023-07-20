local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")

function meta:CanHaveFear()
    local character = self:GetCharacter()

    local faction = ix.faction.indices[character:GetFaction()]
    local class = ix.class.list[character:GetClass()]

    return (character.CanFear or (istable(class) and class.CanFear) or faction.CanFear) or false
end

function meta:IsFearing()
    local character = self:GetCharacter()

    if character == nil or !character:CanHaveFear() then return false end

    for _, ply in pairs(player.GetAll()) do
        if ply == self then continue end

        local trace = util.TraceHull({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + (ply:GetAimVector() * 999),
            filter = ply,
            mins = Vector(-2, -2, -2),
            maxs = Vector(2, 2, 2),
            mask = MASK_SHOT_HULL,
        })

        if trace.Entity == self and ply:IsWepRaised() and !PLUGIN.SafeWeapons[ply:GetActiveWeapon():GetClass()] then
            return true
        end
    end

    return false
end

local CHAR = ix.meta.character

function CHAR:CanHaveFear()
    local faction = ix.faction.indices[self:GetFaction()]
    local class = ix.class.list[self:GetClass()]

    return (self.CanFear or (istable(class) and class.CanFear) or faction.CanFear) or false
end

function CHAR:IsFearing()
    if !self:CanHaveFear() then return false end

    for _, ply in pairs(player.GetAll()) do
        if ply == self:GetPlayer() then continue end

        local trace = util.TraceHull({
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + (ply:GetAimVector() * 999),
            filter = ply,
            mins = Vector(-2, -2, -2),
            maxs = Vector(2, 2, 2),
            mask = MASK_SHOT_HULL,
        })

        if trace.Entity == self:GetPlayer() and ply:IsWepRaised() and !PLUGIN.SafeWeapons[ply:GetActiveWeapon():GetClass()] then
            return true
        end
    end

    return false
end
