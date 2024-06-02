--// Cache

local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match
	= getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match;

--// Loaded check

if getgenv().ED_AntiKick then
	return
end

--// Variables

local cloneref = cloneref or function(...) return ... end -- PR NOTE: use for extra protection
local clonefunction = clonefunction or function(...) return ... end
local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

local SetCore = clonefunction(StarterGui.SetCore)
local GetDebugId = clonefunction(game.GetDebugId)
local FindFirstChild = clonefunction(game.FindFirstChild) -- PR NOTE: this will be used to prevent kick baits relating to Unable to cast value to std::string

local compareinstances = (compareinstances and function(ins1, ins2)
		if typeof(ins1) == "Instance" and typeof(ins2) == "Instance" then
			return compareinstances(ins1, ins2);
		end
	end)
or
function(ins1, ins2)
	return (typeof(ins1) == "Instance" and typeof(ins2) == "Instance") and GetDebugId(ins1) == GetDebugId(ins2);
end;

local function CanCastToSTDString(val)
	-- PR NOTE: using FindFirstChild, this will make sure invalid arguments like newproxy() are sent through
	local success, err = pcall(FindFirstChild, game, val);
	return success --and not match(err, "Unable to cast value to std::string");
end

--// Global Variables

getgenv().ED_AntiKick = {
	Enabled = true, -- Set to false if you want to disable the Anti-Kick.
	SendNotifications = true, -- Set to true if you want to get notified for every event
	CheckCaller = false -- Set to true if you want to disable kicking by other executed scripts
}

--// Main

local OldNamecall;
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	local self, message = ...
	local method = getnamecallmethod()
	
	if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
		if CanCastToSTDString(message) then
			if getgenv().ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", { -- PR NOTE: prevent stack overflow :)
					Title = "Exunys Developer",
					Text = "The script has successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2,
				})
			end

			return; -- PR NOTE: calling :Kick() should return 0 args but returning nil will return 1 arg, bad news...
		end
	end

	return OldNamecall(...)
end))

local OldFunction;
OldFunction = hookfunction(LocalPlayer.Kick, function(...)
	local self, message = ...

	if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and compareinstances(self, LocalPlayer) and ED_AntiKick.Enabled then
		if CanCastToSTDString(message) then
			if getgenv().ED_AntiKick.SendNotifications then
				SetCore(StarterGui, "SendNotification", { -- PR NOTE: prevent stack overflow :)
					Title = "Exunys Developer",
					Text = "The script has successfully intercepted an attempted kick.",
					Icon = "rbxassetid://6238540373",
					Duration = 2,
				})
			end

			return;
		end
	end
end)

if getgenv().ED_AntiKick.SendNotifications then
	StarterGui:SetCore("SendNotification", {
		Title = "Exunys Developer",
		Text = "Anti-Kick script loaded!",
		Icon = "rbxassetid://6238537240",
		Duration = 3,
	})
end
