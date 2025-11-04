local Config = {
    Enable = true,
    Debug = false,
    ToggleKey = 'F10',
    ToggleCommand = '+la_admin_toggle',
    AllowedEvents = {
        'la_weather:update',
        'la_masks:refresh'
    },
    logger = nil
}

return Config
