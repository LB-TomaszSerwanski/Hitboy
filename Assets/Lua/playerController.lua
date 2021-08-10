local playerController =
{
	Properties = 
	{
		Speed = {default = 1.0, description = "Speed multiplayer.", suffix = "*" },
		CamHoriSpeed = {default = 0.1, description = "Horizontal cam speed multiplayer.", suffix = "*" },
		--CamRot = EntityId(),
		--Cam = EntityId(),
	}
}



--________________________________________________________________ ACTIVATE/DEACTIVATE ________________________________________________________________
function playerController:OnActivate()
--_______________________________________________Connecting to EBUSes
	self.tickHandler = TickBus.Connect(self)
	self.inputJumpHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("Jump"))
	self.inputFBHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("FB"))
	self.inputRLHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("RL"))
	self.inputMouseXHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("MouseX"))
--	self.inputMouseYHandler = InputEventNotificationBus.Connect(self, InputEventNotificationId("MouseY"))
	self.consoleHandler = ConsoleNotificationBus.Connect(self)
	self.ScriptEventHandler = GamePlay.Connect(self)
	self.ScriptEventHandlerDmg = HitSE.Connect(self, self.entityId)
--_______________________________________________Setting up vars
	self.t = 0
	self.stp = {showtime = false}
	self.inputFB =0
	self.inputRL=0
	self.isJumping = false
	self.jumpTime = 0.5
	self.playedSound = false
	self.stepTime = 0
	self.fallingTime = 0
	self.isTheGameStarted = false
	self.health = 100
	self.hudEntity = nil
	self.healthTextElement = nil
	self.isTheHudLoaded = false
	self.initialPos = TransformBus.Event.GetWorldTranslation(self.entityId)
	
	--self.CamRot = self.Properties.CamRot
	self.cc = 
	{
		vel = Vector3(0,0,0),
		vel_x = Vector3(0,0,0),
		vel_y = Vector3(0,0,0),
		vel_xy = Vector3(0,0,0),
		vel_h = Vector3(0,0,0)
		--Komentarz tostowy pszenny
	}
	--((komentarz bez laktozy))
	--Dodaje koment - TS
end

function playerController:OnDeactivate()
	self.tickHandler:Disconnect()
	self.inputJumpHandler:Disconnect()
	self.inputFBHandler:Disconnect()
	self.inputRLHandler:Disconnect()
	self.consoleHandler:Disconnect()
	self.inputMouseXHandler:Disconnect()
	self.ScriptEventHandlerDmg:Disconnect()
	self.ScriptEventHandler:Disconnect()
--	self.inputMouseYHandler :Disconnect()
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






--________________________________________________________________ CONSOLE ________________________________________________________________
function playerController:OnConsoleCommandExecuted(com)
	if com == "stp_showtime 1" then
		self.stp.showtime = true
	elseif com == "stp_showtime 0" then
		self.stp.showtime = false
	end
end

function playerController:ShowTime(self, dt)
	self.t = self.t + dt
	if  self.stp.showtime == true then
		--DebugDrawRequestBus.Broadcast.DrawTextOnScreen( 'Time: ' .. self.t, Color(0,0,0,1), 0.001)
	end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








--________________________________________________________________ TICK ________________________________________________________________
function playerController:OnTick(dt)
	if self.isTheGameStarted then
		if not self.isTheHudLoaded then
			self.hudEntity = find_game_entity("Crosshair")
			self.uiCanvas = UiCanvasAssetRefBus.Event.LoadCanvas(self.hudEntity)
			self.healthTextElement = UiCanvasBus.Event.FindElementByName(self.uiCanvas, "HP TEXT")
			self.isTheHudLoaded = true
		end
		self:UpdateHealth(self)
		self:ShowTime(self, dt)
		self:CharacterMovement(self, dt)
		if self.isJumping then
			if not (CharacterGameplayRequestBus.Event.IsOnGround(self.entityId)) or self.jumpTime > 0 then
				if not self.playedSound then
					AudioTriggerComponentRequestBus.Event.Play(self.entityId)
					self.playedSound = true
				end
				self.jumpTime = self.jumpTime - dt;
				--if self.jumpTime < 0.35 then
					CharacterControllerRequestBus.Event.AddVelocity(self.entityId, Vector3(0,0,10));
				--end
			else 
				--Debug.Log("Finished jumping")
				self.playedSound = false;
				self.isJumping = false
				self.jumpTime = 0.5;
			end
		end
	end		
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--________________________________________________________________ SCRIPT EVENTS ________________________________________________________________
function playerController:ReceiveHit(damage ,entityId)
	--Debug.Log("Received "..tostring(damage).." damage")
	self.health = self.health - damage
	AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "Cowboy_hurt_play")
end


function playerController:StartGame()
	--Debug.Log("Starting the game...")
	self.isTheGameStarted = true
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--________________________________________________________________ INPUT ________________________________________________________________
function playerController:OnPressed(value)
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("FB") then
		self.inputFB = Math.Clamp(value, -1, 1);
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("RL") then
		self.inputRL = Math.Clamp(value, -1, 1);
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseX") then
	--	log('MouseX = '..value)
		TransformBus.Event.RotateAroundLocalZ(self.entityId, -value * self.Properties.CamHoriSpeed)
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("Jump") then
		--log('akcja press')
		--Debug.Log("Jump button pressed. Is Entity on the ground? "..tostring(CharacterGameplayRequestBus.Event.IsOnGround(self.entityId)))
		--log('akcja held')
		if CharacterGameplayRequestBus.Event.IsOnGround(self.entityId) then
			--Debug.Log("Jump")
			self.isJumping=true
		end
	end
	
--	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseY") then
--	--	log('MouseY = '..value)
--	end
end


function playerController:OnHeld(value)
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("FB") then
		self.inputFB = Math.Clamp(value, -1, 1);
		AnimGraphComponentRequestBus.Event.SetNamedParameterFloat(self.Actor, "Run", self.inputFB);
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("RL") then
		self.inputRL=Math.Clamp(value, -1, 1);
		AnimGraphComponentRequestBus.Event.SetNamedParameterFloat(self.Actor, "Strafe", self.inputRL);
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseX") then
	--	log('MouseX = '..value)
		TransformBus.Event.RotateAroundLocalZ(self.entityId, -value * self.Properties.CamHoriSpeed)
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("Jump") then
		if CharacterGameplayRequestBus.Event.IsOnGround(self.entityId) then
			self.isJumping=true
		end
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("Jump") then
		--Debug.Log("Jump button pressed. Is Entity on the ground? "..tostring(CharacterGameplayRequestBus.Event.IsOnGround(self.entityId)))
		--log('akcja held')
		if CharacterGameplayRequestBus.Event.IsOnGround(self.entityId) then
			--Debug.Log("Jump")
			self.isJumping=true
		end
	end

--	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("MouseY") then
--	--	log('MouseY = '..value)
--	end
end

function playerController:OnReleased(value)
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("FB") then
		self.inputFB =0;
		--log(self.inputMov.x .. ", " .. self.inputMov.y .. " | Input FB: " .. value)
		AnimGraphComponentRequestBus.Event.SetNamedParameterFloat(self.Actor, "Run", self.inputFB);

	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("RL") then
		self.inputRL=0;
		--log(self.inputMov.x .. ", " .. self.inputMov.y .. " | Input RL: " .. value)
		AnimGraphComponentRequestBus.Event.SetNamedParameterFloat(self.Actor, "Strafe", self.inputRL);
	end
	
	if InputEventNotificationBus.GetCurrentBusId()  == InputEventNotificationId("Jump") then
		--log('akcja released')
	end
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--________________________________________________________________ Movement ________________________________________________________________
function playerController:CharacterMovement(self, dt)
	--DebugDrawRequestBus.Broadcast.DrawTextOnScreen(tostring(self.inputFB), Color(100,0,0,1), 0.001)
	--DebugDrawRequestBus.Broadcast.DrawTextOnScreen(tostring(self.inputRL), Color(0,100,0,1), 0.001)
	
	self.Actor = find_game_entity("Cowboy")
	self.Cam = find_game_entity("Camera")
	self.transCam = TransformBus.Event.GetWorldTM(self.Cam)

	self.forward = Vector3(MathTransform_VM.GetForward(self.transCam, 1).x, MathTransform_VM.GetForward(self.transCam, 1).y, 0)
	self.forwardNor = Vector3.GetNormalized(self.forward)

	self.right = Vector3(MathTransform_VM.GetRight(self.transCam, 1).x, MathTransform_VM.GetRight(self.transCam, 1).y, 0)
	self.rightNor = Vector3.GetNormalized(self.right)

	if self.inputFB ~= 0 then
		self.cc.vel_x = self.forwardNor * self.inputFB;
	else 
		self.cc.vel_x = Vector3(0,0,0)
	end
	
	if self.inputRL ~= 0 then
		self.cc.vel_y = self.rightNor * self.inputRL;
	else
		self.cc.vel_y= Vector3(0,0,0)
	end
	
	self.cc.vel_xy = self.cc.vel_x + self.cc.vel_y 
	if self.cc.vel_xy ~= Vector3(0,0,0) then
		self.cc.vel_xy = self.cc.vel_xy:GetNormalized() * self.Properties.Speed *dt
		self.stepTime = self.stepTime - 0.02
		if self.stepTime < 0 and CharacterGameplayRequestBus.Event.IsOnGround(self.entityId) then
			AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "step_play")
			self.stepTime = 0.5
		end
		else
			AudioTriggerComponentRequestBus.Event.ExecuteTrigger(self.entityId, "step_stop")
			self.stepTime = 0
	end
	self.cc.vel = self.cc.vel_xy + self.cc.vel_h
	--DebugDrawRequestBus.Broadcast.DrawTextOnScreen(tostring(self.cc.vel_x), Color(0,100,100,1), 0.001)
	--DebugDrawRequestBus.Broadcast.DrawTextOnScreen(tostring(self.cc.vel_y), Color(0,100,100,1), 0.001)
	--DebugDrawRequestBus.Broadcast.DrawTextOnEntity(self.entityId, tostring(self.cc.vel_xy), Color(0,0,0,1), 0.001)
	CharacterControllerRequestBus.Event.AddVelocity(self.entityId, self.cc.vel)
	
	
--	log(tostring(TransformBus.Event.GetLocalTM(self.Cam):GetBasisX())..' basis x')
--	log(tostring(EntityTransform_VM.GetEntityForward(self.Cam, 1))..' entity vm forward')
--	log(tostring(MathTransform_VM.GetForward(self.transCam, 1))..' math vm forward')
--	log(tostring(EntityTransform_VM.GetEntityRight(self.Cam, 1))..' entity vm right')
--	log(tostring(MathTransform_VM.GetRight(self.transCam, 1))..' math vm right')

end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

--________________________________________________________________ Update Health on UI ________________________________________________________________

function playerController:UpdateHealth(self)
	UiTextBus.Event.SetText(self.healthTextElement, "Health: "..tostring(self.health))
	if self.health <= 0 then 
		TransformBus.Event.SetWorldTranslation(self.entityId, self.initialPos)
		self.health = 100
	end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



return playerController