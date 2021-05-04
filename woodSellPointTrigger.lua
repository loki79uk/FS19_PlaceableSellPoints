-- ============================================================= --
-- DEFINITION FOR WOOD SELL POINT TRIGGER PLACEABLE TYPE
-- ============================================================= --
woodSellPointTrigger = {}
local woodSellPointTrigger_mt = Class(woodSellPointTrigger, WoodSellStationPlaceable)

InitObjectClass(woodSellPointTrigger, "woodSellPointTrigger")

function woodSellPointTrigger:new(isServer, isClient, customMt)
	local self = WoodSellStationPlaceable:new(isServer, isClient, customMt or woodSellPointTrigger_mt)
	registerObjectClassName(self, "woodSellPointTrigger")
	return self
end

function woodSellPointTrigger:delete()
	unregisterObjectClassName(self)
	woodSellPointTrigger:superClass().delete(self)
end

function woodSellPointTrigger:finalizePlacement()
	woodSellPointTrigger:superClass().finalizePlacement(self)
end

function woodSellPointTrigger:readStream(streamId, connection)
	--print("readStream")
	woodSellPointTrigger:superClass().readStream(self, streamId, connection)

	if connection:getIsServer() then
	end
end

function woodSellPointTrigger:writeStream(streamId, connection)
	--print("writeStream")
	woodSellPointTrigger:superClass().writeStream(self, streamId, connection)

	if not connection:getIsServer() then
	end
end

function woodSellPointTrigger:readUpdateStream(streamId, timestamp, connection)
	--print("readUpdateStream")
	woodSellPointTrigger:superClass().readUpdateStream(self, streamId, timestamp, connection)

	if connection:getIsServer() then
	end
end

function woodSellPointTrigger:writeUpdateStream(streamId, connection, dirtyMask)
	--print("writeUpdateStream")
	woodSellPointTrigger:superClass().writeUpdateStream(self, streamId, connection, dirtyMask)

	if not connection:getIsServer() then
	end
end

function woodSellPointTrigger:setOwnerFarmId(farmId, noEventSend)
	farmId = 0
	woodSellPointTrigger:superClass().setOwnerFarmId(self, farmId, noEventSend)
end

function woodSellPointTrigger:createDeformationObject(terrainRootNode, forBlockingOnly, isBlocking)
	if not forBlockingOnly then
		isBlocking = false
	end

	local deform = TerrainDeformation:new(terrainRootNode)

	if forBlockingOnly and not isBlocking then
		for _, rampArea in pairs(self.rampAreas) do
			local layer = -1
			Placeable.addPlaceableRampArea(deform, rampArea, layer, rampArea.maxSlope, terrainRootNode)
		end
	end

	for _, levelArea in pairs(self.levelAreas) do
		local layer = -1
		if levelArea.groundType ~= nil then
			layer = g_groundTypeManager:getTerrainLayerByType(levelArea.groundType)
		end
		Placeable.addPlaceableLevelingArea(deform, levelArea, layer, true)
	end

	if g_densityMapHeightManager.placementCollisionMap ~= nil then
		--deform:setBlockedAreaMap(g_densityMapHeightManager.placementCollisionMap, 0)
	end

	if self.smoothingGroundType ~= nil then
		deform:setOutsideAreaBrush(g_groundTypeManager:getTerrainLayerByType(self.smoothingGroundType))
	end

	deform:setOutsideAreaConstraints(self.maxSmoothDistance, self.maxSlope, self.maxEdgeAngle)
	deform:setBlockedAreaMaxDisplacement(0.001)
	deform:setDynamicObjectCollisionMask(0) --(1048543)
	deform:setDynamicObjectMaxDisplacement(0.03)

	return deform
end
-- ============================================================= --
