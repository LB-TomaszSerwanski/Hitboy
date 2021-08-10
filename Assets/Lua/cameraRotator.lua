local cameraRotator = 
{
	Properties =
	{
		CamVertSpeed = {default = 0.1, description = "Vertical cam speed multiplayer.", suffix = "*" },
	}
}





function cameraRotator:OnActivate()
	self.inputHandlerY = InputEventNotificationBus.Connect(self, InputEventNotificationId("MouseY"))
end

function cameraRotator:OnDeactivate()
	self.inputHandlerY:Disconnect()
end



function cameraRotator:OnPressed(value)
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseY") then
	--	log('MouseX = '..value)
		self.clampedY = Math.Clamp(TransformBus.Event.GetLocalRotation(self.entityId).y + value * self.Properties.CamVertSpeed, Math.DegToRad(-70), Math.DegToRad(70))
		TransformBus.Event.SetLocalRotation(self.entityId, Vector3(
				TransformBus.Event.GetLocalRotation(self.entityId).x,
				self.clampedY,
				TransformBus.Event.GetLocalRotation(self.entityId).z)
			)
	end
end

function cameraRotator:OnHeld(value)
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseY") then
	--	log('MouseX = '..value)
		self.clampedY = Math.Clamp(TransformBus.Event.GetLocalRotation(self.entityId).y + value * self.Properties.CamVertSpeed, Math.DegToRad(-70), Math.DegToRad(70))
		TransformBus.Event.SetLocalRotation(self.entityId, Vector3(
				TransformBus.Event.GetLocalRotation(self.entityId).x,
				self.clampedY,
				TransformBus.Event.GetLocalRotation(self.entityId).z)
			)	
	end
end





return cameraRotator
