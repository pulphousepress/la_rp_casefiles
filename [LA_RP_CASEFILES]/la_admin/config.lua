Config = {
  Debug = false,
  ToggleKey = 'F10',              -- admin panel toggle
  Command   = 'la_admin',         -- chat fallback for UI toggle
  AllowAnyoneInDev = true,        -- true = no ACE check while building
  AcePrincipal = 'group.admin',   -- production gate
  StatusCommand = 'la_status',
  AddonsCommand = 'la_addons',
}
