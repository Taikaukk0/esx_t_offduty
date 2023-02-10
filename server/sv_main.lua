ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local offDuty = json.decode(LoadResourceFile(GetCurrentResourceName(), 'server/offduty.json'))

ESX.RegisterServerCallback('esx_t_offduty:isOffDuty', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local hex = xPlayer.identifier
    if offDuty[hex] then
        cb(offDuty[hex].job)
    else
        cb('')
    end
end)

RegisterServerEvent('esx_t_offduty:onOffDuty')
AddEventHandler('esx_t_offduty:onOffDuty', function(isOffDuty)
    local xPlayer = ESX.GetPlayerFromId(source)
	local hex = xPlayer.identifier
    if isOffDuty ~= '' then
        xPlayer.setJob(offDuty[hex].job, offDuty[hex].grade)
        offDuty[hex] = nil
    else
        TriggerClientEvent('esx_t_offduty:offduty', source, xPlayer.job.name)
        offDuty[hex] = {job = xPlayer.job.name, grade = xPlayer.job.grade}
        xPlayer.setJob("unemployed", 0)
    end
    SaveResourceFile(GetCurrentResourceName(), 'server/offduty.json', json.encode(offDuty, {indent = true}), -1)
end)