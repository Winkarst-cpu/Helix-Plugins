local PLUGIN = PLUGIN

PLUGIN.name = "Persistent Decals"
PLUGIN.description = "Adds persistent decals."
PLUGIN.author = "Winkarst#6698"
PLUGIN.persistentDecals = PLUGIN.persistentDecals or {}

ix.command.Add("AddDecal", {
	description = "Adds decal on map.",
	superAdminOnly = true,
	arguments = {
		bit.bor(ix.type.string, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
		bit.bor(ix.type.number, ix.type.optional),
	},
	OnRun = function(self, client, material, sizeX, sizeY, scale)
		if (!material) then
			material = "entities/combineelite.png"
		end

		if (!sizeX) then
			sizeX = 100
		end

		if (!sizeY) then
			sizeY = 100
		end

		if (!scale) then
			scale = .5
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 100000
			data.filter = client
		local trace = util.TraceLine(data)
		local position = trace.HitPos + trace.HitNormal * .1
		local angle = (trace.HitNormal):Angle()
		local info = {}

		info.position = position
		info.angle = Angle(angle.r , angle.y + 90, angle.p + 90)
		info.material = material
		info.scale = scale
		info.size = {x = sizeX, y = sizeY}
		netstream.Start(nil, "ixAddDecal", info)

		table.insert(PLUGIN.persistentDecals, info)
	end
})

ix.command.Add("RemoveDecal", {
	description = "Removes decal on map.",
	adminOnly = true,
	arguments = {
		bit.bor(ix.type.number, ix.type.optional),
	},
	OnRun = function(self, client, range)
		if (!range) then
			range = 10
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 100000
			data.filter = client
		local trace = util.TraceLine(data)

		for k, v in pairs(PLUGIN.persistentDecals) do
			if v.position:Distance(trace.HitPos) < range then
				PLUGIN.persistentDecals[k] = nil
			end
		end

		netstream.Start(nil, "ixDeleteDecal", {trace.HitPos, range})
	end
})

if SERVER then
	function PLUGIN:PlayerInitialSpawn()
		netstream.Start(client, "ixAddDecalsOnTheMap", PLUGIN.persistentDecals)
	end

	function PLUGIN:SaveData()
		self:SaveDecals()
	end

	function PLUGIN:LoadData()
		self.persistentDecals = self:LoadDecals()
	end

	function PLUGIN:SaveDecals()
		ix.data.Set("persistentDecals", self.persistentDecals)
	end

	function PLUGIN:LoadDecals()
		return ix.data.Get("persistentDecals") or {}
	end
end

if CLIENT then
	function PLUGIN:PostDrawTranslucentRenderables()
		for k, v in pairs(self.persistentDecals) do
			if !(v.material or v.position or v.angle or v.scale or v.size) then continue end
			if v.position:Distance(LocalPlayer():GetPos()) > 1255 then continue end

			local material = Material(v.material)

			cam.Start3D2D(v.position, v.angle, v.scale)
				surface.SetMaterial(material)
				surface.SetDrawColor(255, 255, 255, math.Clamp(1255 - v.position:Distance(LocalPlayer():GetPos()), 0, 255))
				surface.DrawTexturedRect(-v.size.x / 2, -v.size.y / 2, v.size.x, v.size.y)
			cam.End3D2D()
		end
	end

	netstream.Hook("ixAddDecalsOnTheMap", function(data)
		PLUGIN.persistentDecals = data
	end)

	netstream.Hook("ixDeleteDecal", function(data)
		local vec = data[1]
		local range = data[2]

		for k, v in pairs(PLUGIN.persistentDecals) do
			if v.position:Distance(vec) < range then
				PLUGIN.persistentDecals[k] = nil
			end
		end
	end)
	netstream.Hook("ixAddDecal", function(data)
		table.insert(PLUGIN.persistentDecals, data)
	end)
end