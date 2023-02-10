local PlayerData = {}
local isOffDuty = ''
local ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(fetchedObject) ESX = fetchedObject end)
        Citizen.Wait(0)
    end
    
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

    ESX.TriggerServerCallback('esx_t_offduty:isOffDuty', function(offDuty)
        isOffDuty = offDuty
    end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    if Config.OffDutyPositions[job.name] then
        isOffDuty = ''
    end
end)

RegisterNetEvent('esx_t_offduty:offduty')
AddEventHandler('esx_t_offduty:offduty', function(job)
    isOffDuty = job
end)

function Text3D(pos, text)
    local onScreen,_x,_y=World3dToScreen2d(pos.x, pos.y, pos.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.38, 0.38)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.024+ factor, 0.03, 21, 21, 21, 110)
end

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        local curSleep  = 700

        for cJob, cPos in pairs(Config.OffDutyPositions) do
            if (PlayerData.job ~= nil and PlayerData.job.name == cJob) or (isOffDuty == cJob) then
                local distance = #(playerPos - cPos)
                if distance <= Config.DrawDistance then
                    curSleep = 3
                    DrawMarker(Config.Marker.Type, cPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.Size, Config.Marker.Size, Config.Marker.Size, Config.Marker.Color.r, Config.Marker.Color.g, Config.Marker.Color.b, Config.Marker.Color.a, false, false, 2, true, nil, nil, false)
                    if distance <= Config.Marker.Size then
                        if isOffDuty == '' then
                            Text3D(playerPos, "~g~[E] ~w~- Poistu ~b~vuorosta")
                        else
                            Text3D(playerPos, "~g~[E] ~w~- Palaa ~b~vuoroon")
                        end
                        if IsControlJustReleased(0, 51) then
                            TriggerServerEvent('esx_t_offduty:onOffDuty', isOffDuty)
                        end
                    end
                end
            end
        end
        Citizen.Wait(curSleep)
    end
end)