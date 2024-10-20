local CreatedBlip = {}
local CreatedNpc = {}
local documentMainMenu

local function debugPrint(...)
    if Config.devMode then
        print(...)
    end
end

Citizen.CreateThread(function()
    local DocumentMenuPrompt = BccUtils.Prompts:SetupPromptGroup()
    local documentprompt = DocumentMenuPrompt:RegisterPrompt(_U('PromptName'), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = 'MEDIUM_TIMED_EVENT' })

    if Config.DocumentBlips then
        for _, v in pairs(Config.DocumentLocations) do
            local DocumentBlip = BccUtils.Blips:SetBlip(_U('BlipName'), 'blip_job_board', 3.2, v.coords.x, v.coords.y,
                v.coords.z)
            CreatedBlip[#CreatedBlip + 1] = DocumentBlip
        end
    end

    if Config.DocumentNPC then
        for _, v in pairs(Config.DocumentLocations) do
            local documentped = BccUtils.Ped:Create('MP_POST_RELAY_MALES_01', v.coords.x, v.coords.y, v.coords.z - 1, 0,
                'world', false)
            CreatedNpc[#CreatedNpc + 1] = documentped
            documentped:Freeze()
            documentped:SetHeading(v.NpcHeading)
            documentped:Invincible()
        end
    end

    while true do
        Wait(1)
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, v in pairs(Config.DocumentLocations) do
            local dist = #(playerCoords - v.coords)
            if dist < 2 then
                DocumentMenuPrompt:ShowGroup(_U('Licenses'))
                if documentprompt:HasCompleted() then
                    OpenMenu()
                end
            end
        end
    end
end)

function openMainMenu()
    if documentMainMenu then
        documentMainMenu:RouteTo()
    else
        debugPrint("Error: documentMainMenu is not initialized.")
    end
end

function OpenMenu()
    documentMainMenu = BCCDocumentsMainMenu:RegisterPage("Main:Page")
    documentMainMenu:RegisterElement('header', {
        value = _U('Licenses'),
        slot = 'header',
        style = {}
    })
    documentMainMenu:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for docType, settings in pairs(Config.DocumentTypes) do
        if settings.sellNpc then
            documentMainMenu:RegisterElement('button', {
                label = settings.displayName,
                style = {}
            }, function()
                OpenDocumentSubMenu(docType)
            end)
        end
    end

    documentMainMenu:RegisterElement('bottomline', {
        style = {}
    })
    BCCDocumentsMainMenu:Open({
        startupPage = documentMainMenu
    })
end

function OpenDocumentSubMenu(docType)
    local documentSubMenu = BCCDocumentsMainMenu:RegisterPage("submenu:" .. docType)

    documentSubMenu:RegisterElement('header', {
        value = Config.DocumentTypes[docType].displayName,
        slot = 'header',
        style = {}
    })
    documentSubMenu:RegisterElement('button', {
        label = _U('RegisterDoc') .. " - $" .. Config.DocumentTypes[docType].price,
        style = {}
    }, function()
        TriggerEvent('bcc-documents:client:createDocument', docType)
    end)

    if docType == 'idcard' then
        documentSubMenu:RegisterElement('button', {
            label = _U('ChangePicture') .. " - $" .. Config.DocumentTypes[docType].changePhotoPrice,
            style = {}
        }, function()
            ChangeDocumentPhoto(docType)
        end)
    end

    documentSubMenu:RegisterElement('button', {
        label = _U('DocumentLost') .. " - $" .. Config.DocumentTypes[docType].reissuePrice,
        style = {}
    }, function()
        TriggerEvent('bcc-documents:client:reissueDocument', docType)
    end)

    if docType ~= 'idcard' or docType ~= 'weaponlicense' then
        local docConfig = Config.DocumentTypes[docType]
        documentSubMenu:RegisterElement('button', {
            label = _U('ExtendExpiry') .. " - $" .. docConfig.extendPrice,
            style = {}
        }, function()
            AddExpiryDate(docType)
        end)
    end

    documentSubMenu:RegisterElement('line', {
        value = _U('Licenses'),
        slot = 'footer',
        style = {}
    })

    documentSubMenu:RegisterElement('button', {
        label = _U('BackButton'),
        slot = 'footer',
        style = {}
    }, function()
        openMainMenu()
    end)

    documentSubMenu:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BCCDocumentsMainMenu:Open({
        startupPage = documentSubMenu
    })
end

function ChangeDocumentPhoto(docType)
    local ChangePhotoPage = BCCDocumentsMainMenu:RegisterPage('change:photo')
    local photoLink = nil

    ChangePhotoPage:RegisterElement('header', {
        value = Config.DocumentTypes[docType].displayName,
        slot = 'header',
        style = {}
    })
    ChangePhotoPage:RegisterElement('input', {
        label = _U('InputPhotolink'),
        placeholder = _U('PastePhotoLink'),
        persist = false,
        style = {}
    }, function(data)
        if data.value and data.value ~= "" then
            photoLink = data.value
        else
            debugPrint("Invalid photo URL.")
        end
    end)

    ChangePhotoPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    ChangePhotoPage:RegisterElement('button', {
        label = _U('Submit'),
        slot = 'footer',
        style = {}
    }, function()
        if docType and photoLink then
            TriggerServerEvent('bcc-documents:server:changeDocumentPhoto', docType, photoLink)
            OpenDocumentSubMenu(docType)
        else
            debugPrint("Error: Missing document type or photo URL.")
        end
    end)

    ChangePhotoPage:RegisterElement('button', {
        label = _U('BackButton'),
        slot = 'footer',
        style = {}
    }, function()
        OpenDocumentSubMenu(docType)
    end)

    ChangePhotoPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BCCDocumentsMainMenu:Open({
        startupPage = ChangePhotoPage
    })
end

function AddExpiryDate(docType)
    local inputPage = BCCDocumentsMainMenu:RegisterPage("input:expiry")
    local daysToAdd = nil

    inputPage:RegisterElement('header', {
        value = Config.DocumentTypes[docType].displayName,
        slot = 'header',
        style = {}
    })

    inputPage:RegisterElement('input', {
        label = _U('EnterExpiryDays'),
        placeholder = _U('NumberOfDays'),
        inputType = 'number',
        slot = 'content',
        style = {}
    }, function(data)
        if tonumber(data.value) and tonumber(data.value) > 0 then
            daysToAdd = tonumber(data.value)
        else
            daysToAdd = nil
            debugPrint("Invalid input for days.")
        end
    end)

    inputPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    inputPage:RegisterElement('button', {
        label = _U('Confirm'),
        slot = 'footer',
        style = {}
    }, function()
        if daysToAdd then
            TriggerServerEvent('bcc-documents:server:updateExpiryDate', docType, daysToAdd)
            OpenDocumentSubMenu(docType)
        else
            debugPrint("Error: Number of days not set or invalid.")
        end
    end)

    inputPage:RegisterElement('button', {
        label = _U('BackButton'),
        slot = 'footer',
        style = {}
    }, function()
        OpenDocumentSubMenu(docType)
    end)

    inputPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BCCDocumentsMainMenu:Open({
        startupPage = inputPage
    })
end

function ShowDocument(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    local DocumentPageShow = BCCDocumentsMainMenu:RegisterPage("show:document")

    DocumentPageShow:RegisterElement('header', {
        value = Config.DocumentTypes[docType].displayName,
        slot = 'header'
    })

    DocumentPageShow:RegisterElement('line', {
        slot = 'header'
    })

    DocumentPageShow:RegisterElement("html",
        {
            slot = 'header',
            value = [[<img width="200px" height="200px" style="margin: 0 auto;" src="]] ..
                (picture or 'default_picture_url_here') .. [[" />]]
        })
    if docType == "idcard" or docType == "weaponlicense" then
        DocumentPageShow:RegisterElement("html", {
            value = [[
                <div style="text-align: center; margin-top: 10px;">
                    <p><b>]] .. _U('Firstname') .. [[</b> ]] .. (firstname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Lastname') .. [[</b> ]] .. (lastname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Nickname') .. [[</b> ]] .. (nickname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Job') .. [[</b> ]] .. (job or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Age') .. [[</b> ]] .. (age or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Gender') .. [[</b> ]] .. (gender or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('CreationDate') .. [[</b> ]] .. (date or 'Unknown') .. [[</p>
                </div>
            ]]
        })
    else
        DocumentPageShow:RegisterElement("html", {
            value = [[
                <div style="text-align: center; margin-top: 10px;">
                    <p><b>]] .. _U('Firstname') .. [[</b> ]] .. (firstname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Lastname') .. [[</b> ]] .. (lastname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Nickname') .. [[</b> ]] .. (nickname or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Job') .. [[</b> ]] .. (job or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Age') .. [[</b> ]] .. (age or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('Gender') .. [[</b> ]] .. (gender or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('CreationDate') .. [[</b> ]] .. (date or 'Unknown') .. [[</p>
                    <p><b>]] .. _U('ExpiryDate') .. [[</b> ]] .. (expire_date or 'N/A') .. [[</p>
                </div>
            ]]
        })
    end

    BCCDocumentsMainMenu:Open({
        startupPage = DocumentPageShow
    })
end

function OpenDocument(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    local DocumentPageOpen = BCCDocumentsMainMenu:RegisterPage("open:document")
    DocumentPageOpen:RegisterElement('header', {
        value = Config.DocumentTypes[docType].displayName,
        slot = 'header'
    })
    DocumentPageOpen:RegisterElement('line', {
        slot = 'header'
    })

    DocumentPageOpen:RegisterElement("html", {
        slot = 'header',
        value = [[
                <img width="200px" height="200px" style="margin: 0 auto;" src="]] ..
            (picture or 'default_picture_url_here') .. [[" />
                ]]
    })

    DocumentPageOpen:RegisterElement('line', {
    })

    if docType == "idcard" or docType == "weaponlicense" then
        DocumentPageOpen:RegisterElement("html", {
            value = [[
                    <div style="text-align: center; margin-top: 10px;">
                        <p><b>]] .. _U('Firstname') .. [[</b> ]] .. (firstname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Lastname') .. [[</b> ]] .. (lastname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Nickname') .. [[</b> ]] .. (nickname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Job') .. [[</b> ]] .. (job or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Age') .. [[</b> ]] .. (age or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Gender') .. [[</b> ]] .. (gender or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('CreationDate') .. [[</b> ]] .. (date or 'Unknown') .. [[</p>
                    </div>
                ]]
        })
    else
        DocumentPageOpen:RegisterElement("html", {
            value = [[
                    <div style="text-align: center; margin-top: 10px;">
                        <p><b>]] .. _U('Firstname') .. [[</b> ]] .. (firstname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Lastname') .. [[</b> ]] .. (lastname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Nickname') .. [[</b> ]] .. (nickname or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Job') .. [[</b> ]] .. (job or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Age') .. [[</b> ]] .. (age or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('Gender') .. [[</b> ]] .. (gender or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('CreationDate') .. [[</b> ]] .. (date or 'Unknown') .. [[</p>
                        <p><b>]] .. _U('ExpiryDate') .. [[</b> ]] .. (expire_date or 'N/A') .. [[</p>
                    </div>
                ]]
        })
    end

    DocumentPageOpen:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    DocumentPageOpen:RegisterElement('button', {
        label = _U('ShowDocument'),
        slot = 'footer',
        style = {}
    }, function()
        OpenShowToPlayerMenu(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    end)

    DocumentPageOpen:RegisterElement('button', {
        label = _U('RevokeDocument'),
        slot = 'footer',
        style = {}
    }, function()
        if docType and docType ~= '' then
            TriggerServerEvent('bcc-documents:server:revokeMyDocument', docType)
            Wait(500) -- Small delay to ensure synchronization
            BCCDocumentsMainMenu:Close()
        else
            debugPrint("Error: docType is nil or empty")
        end
    end)

    DocumentPageOpen:RegisterElement('button', {
        label = _U('PutBack'),
        slot = 'footer',
        style = {}
    }, function()
        BCCDocumentsMainMenu:Close()
    end)

    DocumentPageOpen:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BCCDocumentsMainMenu:Open({
        startupPage = DocumentPageOpen
    })
end

function OpenShowToPlayerMenu(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    local players = GetNearbyPlayers()
    local playerMenu = BCCDocumentsMainMenu:RegisterPage("playerMenu")

    playerMenu:RegisterElement('header', {
        value = _U('ChoosePlayer'),
        slot = 'header'
    })

    if #players > 0 then
        for _, player in ipairs(players) do
            debugPrint("Nearby Player:", player.id, GetPlayerName(GetPlayerFromServerId(player.id)))
            playerMenu:RegisterElement('button', {
                label = GetPlayerName(GetPlayerFromServerId(player.id)),
                style = {}
            }, function()
                TriggerServerEvent('bcc-documents:server:showDocumentToPlayer', player.id, docType, firstname,
                    lastname, nickname, job, age, gender, date, picture, expire_date)
                Wait(500) -- Small delay to ensure synchronization
                VORPcore.NotifyObjective(GetPlayerName(GetPlayerFromServerId(player.id)) .. _U('checkingYourDoc'), 4000)
            end)
        end
    else
        TextDisplay = playerMenu:RegisterElement('textdisplay', {
            value = _U('NoNearbyPlayer'),
            style = {
                color = 'red',
                ['text-align'] = 'center',
                ['margin-top'] = '10px'
            }
        })
    end

    playerMenu:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    playerMenu:RegisterElement('button', {
        label = _U('BackButton'),
        slot = 'footer',
        style = {}
    }, function()
        OpenDocument(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    end)

    playerMenu:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BCCDocumentsMainMenu:Open({
        startupPage = playerMenu
    })
end

function GetNearbyPlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyPlayers = {}

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if distance < 3.0 then
                table.insert(nearbyPlayers, { id = GetPlayerServerId(player), distance = distance })
                debugPrint("Found nearby player:", GetPlayerServerId(player))
            end
        end
    end

    return nearbyPlayers
end

RegisterNetEvent('bcc-documents:opensubmenu')
AddEventHandler('bcc-documents:opensubmenu', function(docType)
    OpenDocumentSubMenu(docType)
end)

RegisterNetEvent('bcc-documents:client:opendocument')
AddEventHandler('bcc-documents:client:opendocument',
    function(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
        debugPrint("OpenDocument triggered with docType: " .. docType)
        OpenDocument(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    end)

RegisterNetEvent('bcc-documents:client:addexpiry')
AddEventHandler('bcc-documents:client:addexpiry', function(docType)
    AddExpiryDate(docType)
end)

RegisterNetEvent('bcc-documents:client:showdocument')
AddEventHandler('bcc-documents:client:showdocument',
    function(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
        ShowDocument(docType, firstname, lastname, nickname, job, age, gender, date, picture, expire_date)
    end)

RegisterNetEvent('bcc-documents:client:noDocument')
AddEventHandler('bcc-documents:client:noDocument', function()
    debugPrint("No document found for this type.")
end)

RegisterNetEvent('bcc-documents:client:createDocument')
AddEventHandler('bcc-documents:client:createDocument', function(docType)
    if docType then
        TriggerServerEvent('bcc-documents:server:createDocument', docType)
    else
        debugPrint("Error: docType is missing.")
    end
end)

RegisterNetEvent('bcc-documents:client:reissueDocument')
AddEventHandler('bcc-documents:client:reissueDocument', function(docType)
    if docType then
        TriggerServerEvent('bcc-documents:server:reissueDocument', docType)
    else
        debugPrint("Error: docType is missing.")
    end
end)

RegisterNetEvent('bcc-documents:client:revokeDocument')
AddEventHandler('bcc-documents:client:revokeDocument', function(docType)
    if docType then
        TriggerServerEvent('bcc-documents:server:revokeDocument', docType)
    else
        debugPrint("Error: docType is missing.")
    end
end)

RegisterNetEvent('bcc-documents:client:changephoto')
AddEventHandler('bcc-documents:client:changephoto', function(docType)
    ChangeDocumentPhoto(docType)
end)

RegisterNetEvent('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, npcs in ipairs(CreatedNpc) do
            npcs:Remove()
        end
        for _, blips in ipairs(CreatedBlip) do
            blips:Remove()
        end
    end
end)
