--// Cache

local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match = getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match

--// Loaded check

if getgenv().ED_AntiKick then
	return
end

--// Variables

local cloneref = cloneref or function(...) 
	return ...
end

local clonefunction = clonefunction or function(...)
	return ...
end

local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

local SetCore = clonefunction(StarterGui.SetCore)
--local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild)

local CompareInstances = (CompareInstances and function(Instance1, Instance2)
		if typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance" then
			return CompareInstances(Instance1, Instance2)
		end
	end)
or
function(Instance1, Instance2)
	return (typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance")-- and GetDebugId(Instance1) == GetDebugId(Instance2)
end

local CanCastToSTDString = function(...)
	return pcall(FindFirstChild, game, ...)
end

--// Global Variables

getgenv().ED_AntiKick = {
	Enabled = true, -- Set to false if you want to disable the Anti-Kick.
	SendNotifications = true, -- Set to true if you want to get notified for every event.
	CheckCaller = true -- Set to true if you want to disable kicking by other user executed scripts.
}

--// Main

local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	local self, message = ...
	local method = getnamecallmethod()
	
	if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and CompareInstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
		if CanCastToSTDString(message) then
			if getgenv().ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", {
					Title = "Exunys Developer - Anti-Kick",
					Text = "Successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2
				})
			end

			return
		end
	end

	return OldNamecall(...)
end))

local OldFunction; OldFunction = hookfunction(LocalPlayer.Kick, function(...)
	local self, Message = ...

	if ((ED_AntiKick.CheckCaller and not checkcaller()) or true) and CompareInstances(self, LocalPlayer) and ED_AntiKick.Enabled then
		if CanCastToSTDString(Message) then
			if ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", {
					Title = "Exunys Developer - Anti-Kick",
					Text = "Successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2
				})
			end

			return
		end
	end
end)

if getgenv().ED_AntiKick.SendNotifications then
	StarterGui:SetCore("SendNotification", {
		Title = "Exunys Developer - Anti-Kick",
		Text = "Anti-Kick script loaded!",
		Icon = "rbxassetid://6238537240",
		Duration = 3
	})
end
