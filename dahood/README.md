# Da Hood-style Roblox Game (Starter)

Minimal foundation for a Da Hood-inspired combat/economy game in Roblox.

## What's included

- **Leaderboard:** Cash + Kills (auto-syncs to top-right player list)
- **HUD:** HP bar + Cash counter (bottom-left)
- **Combat:** M1 (left click) punches nearest player in front, server-validated
- **Economy:** Kill = +$50 / +1 Kill. Die = lose 25% of cash.

## Setup in Roblox Studio

1. Open Roblox Studio and create/open a place.
2. In the **Explorer** panel, find these services and paste each script:

   | File | Goes into |
   |------|-----------|
   | `GameServer.server.lua` | `ServerScriptService` (as a `Script`) |
   | `Client.client.lua` | `StarterPlayer` > `StarterPlayerScripts` (as a `LocalScript`) |

3. Hit **Play**. Punch with left click.

## Tuning

Edit the constants at the top of `GameServer.server.lua`:

```lua
local PUNCH_DAMAGE = 12
local PUNCH_RANGE = 6
local PUNCH_COOLDOWN = 0.4
local KILL_REWARD = 50
local DEATH_CASH_LOSS = 0.25
local STARTING_CASH = 100
```

## Next steps to build out

- Guns (raycast hitscan + ammo)
- Stamina + sprint
- Block / dodge mechanics
- Money pickups around the map
- Robbing system (shops, ATMs)
- Cars
- Safe zone vs PvP zone
- Inventory + shop GUI

Tell Kiro which one to add next.
