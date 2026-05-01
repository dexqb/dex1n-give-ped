local QBCore = exports['qb-core']:GetCoreObject()

local function restoreSkin()
    local playerData = QBCore.Functions.GetPlayerData()
    local gender = playerData.charinfo.gender
    local model = (gender == 1) and `mp_f_freemode_01` or `mp_m_freemode_01`

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetModelAsNoLongerNeeded(model)

    Wait(100)

    if Config.SkinScript == 'qb-clothing' then
        TriggerEvent('qb-clothes:client:loadPlayerSkin')
    elseif Config.SkinScript == 'illenium-appearance' then
        TriggerEvent('illenium-appearance:client:reloadSkin')
    else
        TriggerEvent('qb-clothes:client:loadPlayerSkin')
    end
end

local function setPed(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        QBCore.Functions.Notify(Config.Notifications.invalid_model, "error")
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), hash)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetModelAsNoLongerNeeded(hash)

    QBCore.Functions.Notify(Config.Notifications.apply_success, "success")
end

RegisterNetEvent('dex1n-give-ped:forceRevertIfPed', function(pedModel)
    local currentModel = GetEntityModel(PlayerPedId())
    if currentModel == GetHashKey(pedModel) then
        restoreSkin()
        QBCore.Functions.Notify("Kullandığınız ped silindiği için karakterinize dönüldü.", "primary")
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(5000)
    restoreSkin()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    if LocalPlayer.state.isLoggedIn then
        restoreSkin()
    end
end)

local function openGivePedInput()
    local input = lib.inputDialog('Ped Ver', {
        { type = 'number', label = 'Oyuncu ID', required = true, min = 1 },
        { type = 'input', label = 'Ped Kodu', placeholder = 'Örn: u_m_m_partytarget', required = true },
    })

    if not input then return end

    local targetId = input[1]
    local pedModel = input[2]

    local hash = GetHashKey(pedModel)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        QBCore.Functions.Notify(Config.Notifications.invalid_model, "error")
        return
    end

    local success, message = lib.callback.await('dex1n-give-ped:givePed', false, targetId, pedModel)
    
    QBCore.Functions.Notify(message, success and "success" or "error")
end

local function openDeletePedUserSelect()
    local input = lib.inputDialog('Ped Sil', {
        { type = 'number', label = 'Oyuncu ID', required = true, min = 1 },
    })

    if not input then return end
    local targetId = input[1]

    local peds = lib.callback.await('dex1n-give-ped:getUserPeds', false, targetId)

    if #peds == 0 then
        QBCore.Functions.Notify(Config.Notifications.no_ped_found, "error")
        return
    end

    local elements = {}
    for _, ped in ipairs(peds) do
        table.insert(elements, {
            title = ped.ped_model,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Onay',
                    content = ped.ped_model .. ' isimli pedi silmek istediğinize emin misiniz?',
                    centered = true,
                    cancel = true
                })

                if alert == 'confirm' then
                    local success, message = lib.callback.await('dex1n-give-ped:deletePed', false, ped.id)
                    QBCore.Functions.Notify(message, success and "success" or "error")
                end
            end
        })
    end

    lib.registerContext({
        id = 'admin_delete_ped_menu',
        title = 'Oyuncu Pedleri (ID: ' .. targetId .. ')',
        options = elements
    })
    lib.showContext('admin_delete_ped_menu')
end

RegisterNetEvent('dex1n-give-ped:openAdminMenu', function()
    local isAdmin = lib.callback.await('dex1n-give-ped:isAdmin', false)
    if not isAdmin then return end

    lib.registerContext({
        id = 'admin_ped_main_menu',
        title = 'Yönetici Paneli',
        options = {
            {
                title = 'Ped Ver',
                onSelect = function()
                    openGivePedInput()
                end
            },
            {
                title = 'Ped Sil',
                onSelect = function()
                    openDeletePedUserSelect()
                end
            }
        }
    })
    lib.showContext('admin_ped_main_menu')
end)

RegisterNetEvent('dex1n-give-ped:openUserMenu', function()
    local peds = lib.callback.await('dex1n-give-ped:getUserPeds', false)

    local elements = {
        {
            title = 'Normal Karaktere Dön',
            onSelect = function()
                restoreSkin()
                QBCore.Functions.Notify(Config.Notifications.skin_restored, "success")
            end
        }
    }

    if #peds > 0 then
        for _, ped in ipairs(peds) do
            table.insert(elements, {
                title = ped.ped_model,
                onSelect = function()
                    setPed(ped.ped_model)
                end
            })
        end
    end

    lib.registerContext({
        id = 'user_ped_menu',
        title = 'Ped Menüsü',
        options = elements
    })
    lib.showContext('user_ped_menu')
end)
