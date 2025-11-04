# Standalone `la_npcs`

This resource demonstrates running the NPC whitelist seeding module by itself.

## Files
```
standalone/la_npcs/
├── fxmanifest.lua
├── config.lua
└── server.lua
```

## Usage
1. Ensure database connection variables are configured in `server.cfg` for `oxmysql`.
2. Copy the main `la_npcs` resource next to this folder (or adjust require path).
3. Import SQL using provided scripts:
   ```bash
   mysql --host=<host> --user=<user> --password=<pass> < sql/create.sql
   mysql --host=<host> --user=<user> --password=<pass> < sql/seed.sql
   ```
4. Start resource:
   ```cfg
   ensure la_core
   ensure ph_shared
   ensure la_npcs
   ensure la_npcs_standalone
   ```
5. Verify console output shows seed completion.
