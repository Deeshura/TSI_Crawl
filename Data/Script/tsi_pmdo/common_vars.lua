--[[
    common_vars.lua
    Save vars
]]--

function COMMON.UpdateDayEndVars()

end

function COMMON.UpdateCheckpointStatus(checkpoint, limit)
  checkpoint.DaysSinceCheckpoint = checkpoint.DaysSinceCheckpoint + 1
	if checkpoint.DaysSinceCheckpoint >= limit then
      checkpoint.Status = checkpoint.Status + 1
	  checkpoint.DaysSinceCheckpoint = 0
	  checkpoint.SpokenTo = false
	end
end

function COMMON.CreateMission(key, mission)
  SV.missions.Missions[key] = mission

end



function COMMON.ExitDungeonMissionCheckEx(result, rescue, zoneId, segmentID)

end
