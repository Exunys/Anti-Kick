--// Cache

local getgenv, getnamecallmethod, hookmetamethod, newcclosure, checkcaller = getgenv, getnamecallmethod, hookmetamethod, newcclosure, checkcaller

--// Loaded check

if getgenv().ED_AntiKick then return end

--// Variables

local Players, StarterGui, OldNamecall = game:GetService("Players"), game:GetService("StarterGui")

--// Global Variables

getgenv().ED_AntiKick = {
	SendNotifications = true, -- Set to true if you want to get notified for every event
	CheckCaller = false -- Set to true if you want to disable kicking by other executed scripts
}

--// Main

OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	if (getgenv().ED_AntiKick.CheckCaller and not checkcaller() or true) and getnamecallmethod() == "Kick" then
		if getgenv().ED_AntiKick.SendNotifications then
			StarterGui:SetCore("SendNotification", {
				Title = "Exunys Developer",
				Text = "The script has successfully intercepted an attempted kick.",
				Icon = "rbxassetid://6238540373",
				Duration = 2,
			})
		end

		return nil
	end

	return OldNamecall(...)
end))

if getgenv().ED_AntiKick.SendNotifications then
	StarterGui:SetCore("SendNotification", {
		Title = "Exunys Developer",
		Text = "Anti-Kick script loaded!",
		Icon = "rbxassetid://6238537240",
		Duration = 3,
	})
end
