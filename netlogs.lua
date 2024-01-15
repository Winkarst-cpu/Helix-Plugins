local PLUGIN = PLUGIN

PLUGIN.name = "Net Logs"
PLUGIN.author = "winkarst"

if (SERVER) then
    ix.log.AddType("net", function(client, messageName)
        return string.format("[Net Log] Player %s (%s) sent net message %s.", client:GetName(), client:SteamID(), messageName)
    end)

    ix.log.AddType("invalidNet", function(client)
        return string.format("[Net Log] Player %s (%s) tried to send invalid net message!", client:GetName(), client:SteamID())
    end)

    function net.Incoming(length, client)
        local i = net.ReadHeader()
        local strName = util.NetworkIDToString(i)

        if (!strName) then
            ix.log.Add(client, "invalidNet")

            return
        end

        local func = net.Receivers[strName:lower()]
        if (!func) then
            ix.log.Add(client, "invalidNet")

            return
        end

        ix.log.Add(client, "net", strName)

        length = length - 16

        func(length, client)
    end
end