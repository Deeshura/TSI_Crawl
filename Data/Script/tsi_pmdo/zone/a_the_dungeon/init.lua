--[[
    init.lua
    Created: 03/01/2025 16:24:52
    Description: Autogenerated script file for the map a_the_dungeon.
]]--
-- Commonly included lua functions and data
require 'origin.common'

-- Package name
local a_the_dungeon = {}

-------------------------------
-- Zone Callbacks
-------------------------------
---a_the_dungeon.Init(zone)
--Engine callback function
function a_the_dungeon.Init(zone)


end

---a_the_dungeon.EnterSegment(zone, rescuing, segmentID, mapID)
--Engine callback function
function a_the_dungeon.EnterSegment(zone, rescuing, segmentID, mapID)


end

---a_the_dungeon.ExitSegment(zone, result, rescue, segmentID, mapID)
--Engine callback function
function a_the_dungeon.ExitSegment(zone, result, rescue, segmentID, mapID)
    DEBUG.EnableDbgCoro() --Enable debugging this coroutine
    PrintInfo("=>> ExitSegment__the_dungeon result "..tostring(result).." segment "..tostring(segmentID))
  
    --first check for rescue flag; if we're in rescue mode then take a different path
    local exited = COMMON.ExitDungeonMissionCheck(result, rescue, zone.ID, segmentID)
    if exited then
    elseif result ~= RogueEssence.Data.GameProgress.ResultType.Cleared then
      SV.dungeon_defeat = true
      COMMON.EndDungeonDay(result, 'a_oran_tavern', -1, 1, 0)
    else
      --dungeon clears
      if segmentID == 0 then --cleared lost mines
        GAME:ContinueDungeon("a_the_dungeon", 1, 0, 0) --continue to jungle
      elseif segmentID == 1 then --cleared buried jungle
        GAME:ContinueDungeon("a_the_dungeon", 2, 0, 0) --continue to glacier
      elseif segmentID == 2 then --cleared glacier tunnel
        GAME:ContinueDungeon("a_the_dungeon", 3, 0, 0) --continue to burning
      elseif segmentID == 3 then --cleared burning
        GAME:EnterZone("a_the_dungeon", -1, 0, 0) --send to the aura shrine
      elseif segmentID == 4 then --cleared aurum
        GAME:EnterZone("a_the_dungeon", -1, 1, 0) --send to the old buesares (sealed)
      --boss clears
      elseif segmentID == 5 then --beat ranefia
          SV.a_the_dungeon.boss_01_defeated = true --false = boss unbeaten, true = boss beaten
          GAME:EnterZone("a_the_dungeon", -1, 0, 0) --send to the aura shrine with outro savevar
      elseif segmentID == 6 then --beat darkrai
            SV.a_the_dungeon.boss_02_defeated = true --false = boss unbeaten, true = boss beaten
          GAME:EnterZone("a_the_dungeon", -1, 2, 0) --send to old buesares (unsealed) with outro savevar
      else --something wrong
        PrintInfo("No exit procedure found!")
        COMMON.EndDungeonDay(result, 'a_oran_tavern', -1, 1, 0)
      end
    end
  end

---a_the_dungeon.Rescued(zone, name, mail)
--Engine callback function
function a_the_dungeon.Rescued(zone, name, mail)


end

return a_the_dungeon

