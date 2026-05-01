local function getPlayerIdentifier(source)
    if not source or source == 0 then return nil end
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, string.len("license:")) == "license:" then
            return id
        end
    end
    return nil
end

local function getDiscordID(source)
    if not source or source == 0 then return nil end
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, string.len("discord:")) == "discord:" then
            return string.sub(id, 9)
        end
    end
    return nil
end

local function isAdmin(source)
    local discordID = getDiscordID(source)
    if not discordID then return false end
    for _, id in ipairs(Config.Admins) do
        if id == discordID then
            return true
        end
    end
    return false
end

local function sendLog(webhookType, title, message, color)
    local webhook = Config.Webhooks[webhookType]
    if not webhook or webhook == "" then return end

    local embed = {
        {
            ["color"] = color,
            ["title"] = "**" .. title .. "**",
            ["description"] = message,
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Bee Mods Logs", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

lib.callback.register('dex1n-give-ped:isAdmin', function(source)
    return isAdmin(source)
end)

lib.callback.register('dex1n-give-ped:givePed', function(source, targetId, pedModel)
    if not isAdmin(source) then return false, Config.Notifications.no_permission end
    
    if not GetPlayerName(targetId) then return false, Config.Notifications.no_identifier end

    for _, bannedModel in ipairs(Config.BlacklistedPeds) do
        if bannedModel == pedModel then
            return false, Config.Notifications.banned_ped
        end
    end

    local targetIdentifier = getPlayerIdentifier(targetId)
    if not targetIdentifier then return false, Config.Notifications.no_identifier end

    local success = MySQL.insert.await('INSERT INTO ' .. Config.DatabaseTable .. ' (identifier, ped_model) VALUES (?, ?)', {
        targetIdentifier, pedModel
    })

    if success then
        TriggerClientEvent('QBCore:Notify', targetId, string.format(Config.Notifications.target_receive, pedModel), "success")
        
        local adminName = GetPlayerName(source)
        local targetName = GetPlayerName(targetId)
        local logMsg = string.format("**Yönetici:** %s (%s)\n**Hedef:** %s (%s)\n**Verilen Ped:** %s", 
            adminName, getDiscordID(source) or "Bilinmiyor", 
            targetName, targetIdentifier, 
            pedModel)
        sendLog("give", "Ped Verme Logu", logMsg, 3066993) -- Yeşil

        return true, Config.Notifications.give_success
    end

    return false, Config.Notifications.give_fail
end)

lib.callback.register('dex1n-give-ped:getUserPeds', function(source, targetId)
    local identifier
    if targetId then
        if not isAdmin(source) then return {} end
        if not GetPlayerName(targetId) then return {} end
        identifier = getPlayerIdentifier(targetId)
    else
        identifier = getPlayerIdentifier(source)
    end

    if not identifier then return {} end

    local results = MySQL.query.await('SELECT * FROM ' .. Config.DatabaseTable .. ' WHERE identifier = ?', {
        identifier
    })

    return results or {}
end)

lib.callback.register('dex1n-give-ped:deletePed', function(source, pedDbId)
    if not isAdmin(source) then return false, Config.Notifications.no_permission end

    local pedData = MySQL.single.await('SELECT identifier, ped_model FROM ' .. Config.DatabaseTable .. ' WHERE id = ?', {
        pedDbId
    })

    if not pedData then return false, Config.Notifications.delete_fail end

    local success = MySQL.update.await('DELETE FROM ' .. Config.DatabaseTable .. ' WHERE id = ?', {
        pedDbId
    })

    if success > 0 then
        local players = GetPlayers()
        local targetName = "Çevrimdışı"
        local targetIdFound = nil

        for _, playerId in ipairs(players) do
            if getPlayerIdentifier(playerId) == pedData.identifier then
                targetName = GetPlayerName(playerId)
                targetIdFound = playerId
                TriggerClientEvent('dex1n-give-ped:forceRevertIfPed', playerId, pedData.ped_model)
                break
            end
        end

        local adminName = GetPlayerName(source)
        local logMsg = string.format("**Yönetici:** %s (%s)\n**Hedef:** %s (%s)\n**Silinen Ped:** %s", 
            adminName, getDiscordID(source) or "Bilinmiyor", 
            targetName, pedData.identifier, 
            pedData.ped_model)
        sendLog("delete", "Ped Silme Logu", logMsg, 15158332) -- Kırmızı

        return true, Config.Notifications.delete_success
    end

    return false, Config.Notifications.delete_fail
end)

RegisterCommand(Config.Commands.admin, function(source, args, rawCommand)
    if source == 0 then return end
    if isAdmin(source) then
        TriggerClientEvent('dex1n-give-ped:openAdminMenu', source)
    else
        TriggerClientEvent('QBCore:Notify', source, Config.Notifications.no_permission, "error")
    end
end, false)

RegisterCommand(Config.Commands.user, function(source, args, rawCommand)
    if source == 0 then return end
    TriggerClientEvent('dex1n-give-ped:openUserMenu', source)
end, false)
