-- ============================================================= --
-- DEFINITION FOR SELL POINT TRIGGER PLACEABLE TYPE
-- ============================================================= --
SellPointTrigger = {}
local SellPointTrigger_mt = Class(SellPointTrigger, SellingStationPlaceable)

InitObjectClass(SellPointTrigger, "SellPointTrigger")

function SellPointTrigger:new(isServer, isClient, customMt)
	local self = SellingStationPlaceable:new(isServer, isClient, customMt or SellPointTrigger_mt)
	registerObjectClassName(self, "SellPointTrigger")
	return self
end

function SellPointTrigger:delete()
	self:unregisterToMission()
	unregisterObjectClassName(self)
	SellPointTrigger:superClass().delete(self)
end

function SellPointTrigger:getCanBePlacedAt(x, y, z, distance, farmId)
	local canBePlaced = SellPointTrigger:superClass().getCanBePlacedAt(self, x, y, z, distance, farmId)
	return canBePlaced and not self:isSellPointTriggerRegistered()
end

function SellPointTrigger:canBuy()
	local canBuy = SellPointTrigger:superClass().canBuy(self)
	return canBuy and not self:isSellPointTriggerRegistered(),
	g_i18n:getText("warning_onlyOne")..self.sellingStation.stationName..g_i18n:getText("warning_allowedPerMap")
end

function SellPointTrigger:finalizePlacement()
	SellPointTrigger:superClass().finalizePlacement(self)
	self:registerToMission()
end

function SellPointTrigger:readStream(streamId, connection)
	--print("readStream")
	SellPointTrigger:superClass().readStream(self, streamId, connection)

	if connection:getIsServer() then
	end
end

function SellPointTrigger:writeStream(streamId, connection)
	--print("writeStream")
	SellPointTrigger:superClass().writeStream(self, streamId, connection)

	if not connection:getIsServer() then
	end
end

function SellPointTrigger:readUpdateStream(streamId, timestamp, connection)
	--print("readUpdateStream")
	SellPointTrigger:superClass().readUpdateStream(self, streamId, timestamp, connection)

	if connection:getIsServer() then
	end
end

function SellPointTrigger:writeUpdateStream(streamId, connection, dirtyMask)
	--print("writeUpdateStream")
	SellPointTrigger:superClass().writeUpdateStream(self, streamId, connection, dirtyMask)

	if not connection:getIsServer() then
	end
end

function SellPointTrigger:setOwnerFarmId(farmId, noEventSend)
	farmId = 0
	SellPointTrigger:superClass().setOwnerFarmId(self, farmId, noEventSend)
end

function SellPointTrigger:createDeformationObject(terrainRootNode, forBlockingOnly, isBlocking)
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
function SellPointTrigger:isSellPointTriggerRegistered()
	if g_currentMission.SellPointTriggers[self.sellingStation.stationName] ~= nil then
		return true
	end
	return false
end
function SellPointTrigger:registerToMission()
	if not self:isSellPointTriggerRegistered() then
		--print("Register To Mission: " .. self.id)
		g_currentMission.SellPointTriggers[self.sellingStation.stationName] = self.id
		return true
	end
	return false
end
function SellPointTrigger:unregisterToMission()
	if self:isSellPointTriggerRegistered() then
		if g_currentMission.SellPointTriggers[self.sellingStation.stationName] == self.id then
			--print("Unregister From Mission: " .. self.id)
			g_currentMission.SellPointTriggers[self.sellingStation.stationName] = nil
			return true
		end
	end
	return false
end
-- ============================================================= --
