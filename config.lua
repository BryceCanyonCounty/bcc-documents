Config = {
    -- Default Settings
    devMode = false,
    PlayYear = "1900",
    -- Language settings
    defaultlang = "en_lang",    -- Set Your Language (Current Languages: "en_lang" English, "ro_lang" Romanian)
    -- Command Settings
    AdminJob = "admin",         -- allow Admin-Jobs to give unbuyable licenses
    NeedItem = true,            -- Set true or false, if you want to need an item zu execute the commands
    NeedItemName = "paper",    -- define the item-name set in db
    -- NPC and Blip settings
    DocumentBlips = true,
    DocumentNPC = true,
    DocumentLocations = {
        {
            coords = vector3(-175.29, 631.92, 114.09),
            NpcHeading = 326.82,
        },
        {
            coords = vector3(-798.53, -1194.58, 43.95),
            NpcHeading = 190.82,
        },
        {
            coords = vector3(1230.19, -1298.7, 76.9),
            NpcHeading = 230.74,
        },
        {
            coords = vector3(2747.9, -1396.45, 46.18),
            NpcHeading = 31.65,
        },
        {
            coords = vector3(2933.1, 1282.69, 44.65),
            NpcHeading = 74.53,
        },
    },
    -- Document types with associated details
    DocumentTypes = {
        idcard = {
            displayName = "Identity Card",
            price = 15,
            reissuePrice = 20,
            changePhotoPrice = 10,
            extendPrice = 10,
            expiryDays = 0,  -- Set expiry duration by default
            defaultPicture = '',
            sellNpc = true, 
            givenCommand = false,
            allowJob = "",
        },
        huntinglicence = {
            displayName = "Hunting Licence",
            price = 10,
            reissuePrice = 30,
            changePhotoPrice = 10,
            extendPrice = 10,
            expiryDays = 1,  -- Set expiry duration by default
            defaultPicture ='',
            sellNpc = true, 
            givenCommand = false,
            allowJob = "",
        },
        mininglicence = {
            displayName = "Mining Licence",
            price = 20,
            reissuePrice = 25,
            changePhotoPrice = 10,
            extendPrice = 10,
            expiryDays = 1,  -- Set expiry duration by default
            defaultPicture = '',
            sellNpc = true, 
            givenCommand = false,
            allowJob = "",
        },
        lumberlicence = {
            displayName = "Lumber Licence",
            price = 15,
            reissuePrice = 20,
            changePhotoPrice = 10,
            extendPrice = 10,
            expiryDays = 1,  -- Set expiry duration by default
            defaultPicture = '',
            sellNpc = true, 
            givenCommand = false,
            allowJob = "",
        },
        goldpanninglicence = {
            displayName = "Gold Panning Licence",
            price = 10,
            reissuePrice = 15,
            changePhotoPrice = 10,
            extendPrice = 10,
            expiryDays = 1,  -- Set expiry duration by default
            defaultPicture = '',
            sellNpc = true, 
            givenCommand = false,
            allowJob = "",
        },
        weaponlicense = {
            displayName = "Weaponlicense",
            price = 0,
            reissuePrice = 0,
            changePhotoPrice = 0,
            extendPrice = 0,
            expiryDays = 0,  -- Set expiry duration by default
            defaultPicture = '',
            sellNpc = false, 
            givenCommand = "giveweaponlicense",
            allowJob = "doj",
        }
    },
    
    Textures = {
        ['cross'] = { "scoretimer_textures", "scoretimer_generic_cross" },
        ['locked'] = { "menu_textures", "stamp_locked_rank" },
        ['tick'] = { "scoretimer_textures", "scoretimer_generic_tick" },
        ['money'] = { "inventory_items", "money_moneystack" },
        ['alert'] = { "menu_textures", "menu_icon_alert" },
    }
}
