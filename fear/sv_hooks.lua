local PLUGIN = PLUGIN

function PLUGIN:PlayerTick(ply)
    if ply:IsFearing() and !ply.fearingSounds then
        ply.fearingSounds = true

        ply:EmitSound("player/heartbeat1.wav", 60)
    elseif !ply:IsFearing() and ply.fearingSounds then
        ply.fearingSounds = false

        if (ply:IsValid()) then
            ply:StopSound("player/heartbeat1.wav")
        end
    end
end

function PLUGIN:CanPlayerTakeItem(client, item)
    local itemTable = ix.item.list[item:GetItemID()]

    if client:IsFearing() and (self.ProhibitedBases[itemTable.base] or self.ProhibitedItems[item.uniqueID]) then
        ix.util.NotifyLocalized("notNow", client)
        return false
    end
end

function PLUGIN:CanPlayerEquipItem(client, item)
    if client:IsFearing() and (self.ProhibitedBases[item.base] or self.ProhibitedItems[item.uniqueID]) then
        ix.util.NotifyLocalized("notNow", client)
        return false
    end
end

function PLUGIN:StartCommand(client, ucmd)
    if client:IsFearing() and !client:IsWepRaised() then
        ucmd:RemoveKey(IN_RELOAD)
    end
end