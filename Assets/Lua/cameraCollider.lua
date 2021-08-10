local cameraCollider =
{
	Properties = 
	{
	}
}

function cameraCollider:OnActivate()
	self.tickBusHandler = TickBus.Connect(self)
	
	self.collisionCount = 0
	self.initCamX = TransformBus.Event.GetLocalX(self.entityId)
	self.moveCam = false
	
	self.triggerEnterBusId = SimulatedBody.GetOnTriggerEnterEvent(self.entityId);
	self.triggerEnterBus = self.triggerEnterBusId:Connect(
		function(x, y)
			self.body1 = TriggerEvent.GetOtherEntityId(y)
			if GameEntityContextRequestBus.Broadcast.GetEntityName(self.body1) == "PlayerCharacter" then
				Debug.Log(".")
			else 
				self.collisionCount = self.collisionCount + 1
			end
--			log("Entered Trigger " .. tostring(self.collisionCount) .. " | " .. tostring(self.collider))
		
		end)
		
	self.triggerExitBusId = SimulatedBody.GetOnTriggerExitEvent(self.entityId);
	self.triggerExitBus = self.triggerExitBusId:Connect(
		function(x,y)
			self.body1 = TriggerEvent.GetOtherEntityId(y)
			if GameEntityContextRequestBus.Broadcast.GetEntityName(self.body1) == "PlayerCharacter" then
				Debug.Log(".")
			else 
				self.collisionCount = self.collisionCount - 1
			end
--			log("Exited Trigger " .. tostring(self.collisionCount))
		end)
end

function cameraCollider:OnDeactivate()
	self.tickBusHandler:Disconnect()
end

function cameraCollider:OnTick(dt, stp)
	if self.collisionCount > 0 then
		TransformBus.Event.SetLocalX(self.entityId, TransformBus.Event.GetLocalX(self.entityId)+2*dt)
	else
		if TransformBus.Event.GetLocalX(self.entityId) > self.initCamX then
			TransformBus.Event.SetLocalX(self.entityId, TransformBus.Event.GetLocalX(self.entityId)-5*dt)	
		end
	end
end

return cameraCollider