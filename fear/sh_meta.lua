local PLUGIN = PLUGIN
local meta = FindMetaTable("Player")

function meta:CanHaveFear()
    local faction = ix.faction.indices[self:Team()]

    return !(self.CanFear or faction.CanFear)
end

function meta:IsFearing()
    if !self:GetCharacter() or !self:CanHaveFear() then return false end

    for _, player in pairs(player.GetAll()) do
        if player == self then continue end

        local trace = util.TraceHull({
            start = player:GetShootPos(),
            endpos = player:GetShootPos() + (player:GetAimVector() * 999),
            filter = player,
            mins = Vector(-2, -2, -2),
            maxs = Vector(2, 2, 2),
            mask = MASK_SHOT_HULL,
        })

        if trace.Entity == self and player:IsWepRaised() and !PLUGIN.SafeWeapons[player:GetActiveWeapon():GetClass()] then
            return true
        end
    end

    return false
end