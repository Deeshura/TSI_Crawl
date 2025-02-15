require 'origin.common'
GeneralFunctions = {}

--[[These are functions/procedures that are useful in a multitude of different maps or situations. Things such as
reseting daily flags, a function to have the pokemon look in a random number of randections, etc.

List of custom variables attached to pokemon:
Importance: used mainly to mark the Hero and the Partner. is equal to 'Hero' if hero and 'Partner' if partner.
nil otherwise, but may be used in future to flag other party members/npcs as being important in someway.

AddBack: Marks the character to be added back when the party is reset,value is the slot to add them back at.
If it's nil then don't add them back. Set it to nil after adding them back
]]--

--Most of these are taken from Palika's generalfunctions from Halcyon. Thank you so much for all of these useful functions!

--given the line to travel between two points, how many frames must the camera move for to get the desired speed?
--2 is standard walking speed... This will mostly be useful for diagonal lines
--will round the result up, so for consistency try to keep the answer as a whole number...
function GeneralFunctions.CalculateCameraFrames(startX, startY, endX, endY, speed)
	local distX = startX - endX
	local distY = startY - endY
	
	local distance = math.sqrt((distX * distX) + (distY * distY))
	
	return math.floor(distance / speed)
	
end 

--assigns a number value to each direction, useful for figuring out how many turn a direction is from another
function GeneralFunctions.DirToNum(dir)
	--up is 0, upright is 1, ... up left is 7
	local num = -1
	if dir == Direction.Up then
		num = 0
	elseif dir == Direction.UpRight then
		num = 1
	elseif dir == Direction.Right then
		num = 2
	elseif dir == Direction.DownRight then
		num = 3
	elseif dir == Direction.Down then
		num = 4
	elseif dir == Direction.DownLeft then
		num = 5
	elseif dir == Direction.Left then
		num = 6
	elseif dir == Direction.UpLeft then
		num = 7
	end
	
	return num
	
end

function GeneralFunctions.GenderToNum(gender)
	local res = -1
	if gender == Gender.Genderless then
		res = 0
	elseif gender == Gender.Male then
		res = 1
	elseif gender == Gender.Female then
		res = 2
	end
	return res
end

function GeneralFunctions.NumToGender(num)
	local res = Gender.Unknown
	if num == 0 then
		res = Gender.Genderless
	elseif num == 1 then
		res = Gender.Male
	elseif num == 2 then
		res = Gender.Female
	end
	return res
end

--converts a number to a direction
function GeneralFunctions.NumToDir(num)
	local dir = Direction.None
	if num % 8 == 0 then 
		dir = Direction.Up
	elseif num % 8 == 1 then
		dir = Direction.UpRight
	elseif num % 8 == 2 then
		dir = Direction.Right
	elseif num % 8 == 3 then
		dir = Direction.DownRight
	elseif num % 8 == 4 then
		dir = Direction.Down
	elseif num % 8 == 5 then
		dir = Direction.DownLeft
	elseif num % 8 == 6 then
		dir = Direction.Left
	elseif num % 8 == 7 then
		dir = Direction.UpLeft
	end

	return dir
end


function GeneralFunctions.ShakeHead(chara, turnframes, startLeft) --smh my head
	
	if turnframes == nil then turnframes = 4 end
	if startLeft == nil then startLeft = true end 
	
	initDir = chara.Direction
	local leftDir = GeneralFunctions.NumToDir(GeneralFunctions.DirToNum(chara.Direction) - 1)
	local rightDir = GeneralFunctions.NumToDir(GeneralFunctions.DirToNum(chara.Direction) + 1)
	if startLeft then
		GROUND:CharAnimateTurnTo(chara, leftDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, rightDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, leftDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, rightDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, initDir, turnframes)
	else
		GROUND:CharAnimateTurnTo(chara, rightDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, leftDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, rightDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, leftDir, turnframes)
		GROUND:CharAnimateTurnTo(chara, initDir, turnframes)
	end
	
end

--chara looks around in a rotations amount of directions, turning for turnframes frames, 
--ending facing in enddir direction. if alldirections is true, can look in all directions, otherwise can only face +-2 from original direction
function GeneralFunctions.LookAround(chara, rotations, turnframes, allDirections, sound, startLeft, enddir)


	if allDirections == nil then allDirections = true end 
	if sound == nil then sound = true end 
	if startLeft == nil then startLeft = true end 
	if enddir == nil then enddir = chara.Direction end

	local dir = 0
	
	--play the looking around sfx if we want a sound to be made
	if sound then SOUND:PlaySE("EVT_Emote_Confused_2") end

	--if all directions, look in any of the 8 directions randomly (except the one we are already facing)
	--if not all directions, alternate between looking 90 degrees left and right from current direction
	--at the end, face towards the enddir if specified
	if allDirections then 
		for i = 1, rotations, 1 do
			local currentDir = chara.Direction
			local numDir = GeneralFunctions.DirToNum(currentDir)
			local diff = 0
			local rand = 0
			repeat
				rand = math.random(0, 7)--pick a random direction
				diff = math.abs(numDir - rand)
			until (diff > 1 and diff < 7)--chosen direction must be at least 90 degrees different 
			dir = GeneralFunctions.NumToDir(rand)
			GROUND:CharAnimateTurnTo(chara, dir, turnframes)
			GAME:WaitFrames(20)--pause
		end 
	else--this is much less random 
		local leftDir = GeneralFunctions.NumToDir(GeneralFunctions.DirToNum(chara.Direction) - 2)
		local rightDir = GeneralFunctions.NumToDir(GeneralFunctions.DirToNum(chara.Direction) + 2)
		local originalDir = chara.Direction
		local turnLeft = startLeft --start by looking left if that's what's been specified, otherwise start by looking right
		for i = 1, rotations, 1 do
			if turnLeft then
				GROUND:CharAnimateTurn(chara, leftDir, turnframes, turnLeft)
				GAME:WaitFrames(10)--pause
				turnLeft = false
			else
				GROUND:CharAnimateTurn(chara, rightDir, turnframes, turnLeft)
				GAME:WaitFrames(10)--pause
				turnLeft = true
			end
		end
	end
	if enddir ~= Direction.None and enddir ~= dir then--if a direction to end on was specified and we aren't facing that way, turn there 
		GROUND:CharAnimateTurnTo(chara, enddir, turnframes)
	else GAME:WaitFrames(turnframes * 2)--wait for some time based off how long it could have taken to turn if we dont turn at the end 
	end
	GAME:WaitFrames(6)--Wait a short duration before ending

end
	
--This function makes it easy to keep the camera in sync with a character moving
function GeneralFunctions.MoveCharAndCamera(chara, x, y, run, charSpeed, cameraFrames)
	local startX = chara.Position.X
	local startY = chara.Position.Y
	--characters position starts from their top left corner. 
	local camX = x + 8
	local camY = y + 8
	local default = false
	
	--cameraSpeed should only be given when a custom frame count needs to be used for some reason
	--otherwise, calculate the number of frames needed for smooth transition
	if cameraFrames == nil then cameraFrames = GeneralFunctions.CalculateCameraFrames(startX, startY, x, y, charSpeed) end
	--default run to false 
	if run == nil then run = false end 

	local coro1 = TASK:BranchCoroutine(function() GAME:MoveCamera(camX, camY, cameraFrames, false) end)
	local coro2 = TASK:BranchCoroutine(function() GROUND:MoveToPosition(chara, x, y, run, charSpeed) end)
	TASK:JoinCoroutines({coro1, coro2})


end

--easy speed control on camera movements
function GeneralFunctions.MoveCamera(x, y, speed)
	if speed == nil then speed = 2 end
	
	local cameraFrames = GeneralFunctions.CalculateCameraFrames(GAME:GetCameraCenter().X, GAME:GetCameraCenter().Y, x, y, speed)
	GAME:MoveCamera(x, y, cameraFrames, false)
end

--old movetoposition behavior
--move diagonially, then on one axis to get to the destination (2 movements)
--only moves in 8 directions 
function GeneralFunctions.EightWayMove(chara, x, y, run, speed)

	local diffX = x - chara.Position.X
	local diffY = y - chara.Position.Y
	
	
	local xSign = 1
	local ySign = 1
	
	if diffX < 0 then xSign = -1 end
	if diffY < 0 then ySign = -1 end

	diffX = math.abs(diffX)
	diffY = math.abs(diffY)
	
	
	local diff = 0 
	
	if diffX < diffY then
		diff = diffX
		GROUND:MoveToPosition(chara, chara.Position.X + (diff * xSign), chara.Position.Y + (diff * ySign), run, speed)
	elseif math.abs(diffX) > math.abs(diffY) then
		diff = diffY
		GROUND:MoveToPosition(chara, chara.Position.X + (diff * xSign), chara.Position.Y + (diff * ySign), run, speed)
	end
	
	GROUND:MoveToPosition(chara, x, y, run, speed)
end

--shortcut for doing hero dialogue (i.e., no sfx, no nameplate at the start)
function GeneralFunctions.HeroDialogue(chara, str, emotion)
	UI:SetSpeaker('', false, chara.CurrentForm.Species, chara.CurrentForm.Form, chara.CurrentForm.Skin, chara.CurrentForm.Gender)
	UI:SetSpeakerEmotion(emotion)
	UI:WaitShowDialogue(str)
end

--walking in place to "talk"
function GeneralFunctions.HeroSpeak(chara, duration, anim)
	--anim is the animation we do after walking in place
	if anim == nil then anim = 'None' end 
	GROUND:CharSetAnim(chara, "Walk", true)
	GAME:WaitFrames(duration)
	--GROUND:CharSetAnim(chara, anim, true)
	GROUND:CharEndAnim(chara)
end

--generic emote function with standardized SFX and pause duration. Shouldn't ALWAYS be used to emote, but is useful to cut down on lines...
function GeneralFunctions.EmoteAndPause(chara, emote, sound, repetitions)
	local sfx = 'null'
	local emt = 'null'
	local pause = 0
	
	if repetitions == nil then repetitions = 1 end
	
	if emote == 'Happy' then
		emt = "happy"
		sfx = "EVT_Emote_Startled_2"
		pause = 20--test this one 
	elseif emote == 'Notice' then --this one is the 3 lines
		emt = "notice"
		sfx = 'EVT_Emote_Exclaim'
		pause = 30
	elseif emote == 'Exclaim' then --this one is the !
		emt = "exclaim"
		sfx = 'EVT_Emote_Exclaim_2'
		pause = 20
	elseif emote == 'Glowing' then 
		emt = "glowing"
		sfx = 'EVT_Emote_Startled_2'
		pause = 20--test this one
	elseif emote == 'Sweating' then
		emt = "sweating"
		sfx = 'EVT_Emote_Sweating'
		pause = 40 
	elseif emote == 'Question' then
		emt = "question"
		sfx = 'EVT_Emote_Confused'
		pause = 40
	elseif emote == 'Angry' then
		emt = "angry"
		sfx = 'EVT_Emote_Complain_2'
		pause = 40 --test this one
	elseif emote == 'Shock' then
		emt = "shock"
		sfx = 'EVT_Emote_Shock'
		pause = 40
	else--sweatdrop
		emt = "sweatdrop"
		sfx = 'EVT_Emote_Sweatdrop'
		pause = 40
	end
	
	GROUND:CharSetEmote(chara, emt, repetitions)
	
	if sound and sfx ~= 'null' then 
		SOUND:PlayBattleSE(sfx)
	end	
	GAME:WaitFrames(pause)
end

--generic function to do an animation once then go back to the anim you were doing before (i.e. nod, get up, be surprised) 
--Has standardized wait times
--has some special instances... 
function GeneralFunctions.DoAnimation(chara, anim, sound)
	if sound == nil then sound = false end
	--[[local pause = 0
	--todo: return character to their animation from before. For now just end the anim...
	--local prevAnim = 'None'
	
	if anim == 'Nod' then 
		pause = 20
	elseif anim == 'Wake' then
		pause = 40
	elseif anim == 'Hop' then
		pause = 24
	elseif anim == 'DeepBreath' then
		pause = 80
	end
	]]--
	GROUND:CharWaitAnim(chara, anim)
	GROUND:CharEndAnim(chara)

end

-- Used to get proper pronoun depending on gender of character (gender check command)
-- Form should be given as they, them, their, theirs, themself, or they're.
-- If uppercase is truthy, then the first letter will be capitalized.
function GeneralFunctions.GetPronoun(chara, form, uppercase)
    local gender = chara.CurrentForm.Gender
    local value = ""
    
    if gender == Gender.Female then
        local female_pronouns = {
            ["they"] = "she", -- nominative
            ["them"] = "her", -- objective
            ["their"] = "her", -- possessive
            ["theirs"] = "hers", -- possessive, no following noun
            ["themself"] = "herself", -- reflexive
            ["they're"] = "she's", -- nominative + "be" contraction
            ["are"] = "is", -- "be" present indicative
			["were"] = "was",
			["don't"] = "doesn't"
        }
        value = female_pronouns[form]
    elseif gender == Gender.Male then
        local male_pronouns = {
            ["they"] = "he", -- nominative
            ["them"] = "him", -- objective
            ["their"] = "his", -- possessive
            ["theirs"] = "his", -- possessive, no following noun
            ["themself"] = "himself", -- reflexive
            ["they're"] = "he's", -- nominative + "be" contraction
            ["are"] = "is", -- "be" present indicative
			["were"] = "was",
			["don't"] = "doesn't"
        }
        value = male_pronouns[form]
    else -- if neither male or female, use they/them, so just return the form 
        value = form
    end

    return uppercase and value:gsub("^%l", string.upper) or value
    
end

--used to conjugate certain verbs appropriately, to be used with the above function typically
--this will need to be updated to be more sophisticated as the use cases arrive. For now, KISS.
function GeneralFunctions.Conjugate(chara, verb)
    local gender = chara.CurrentForm.Gender
    local value = verb
    
    if gender ~= Gender.Genderless then 
		if string.sub(verb, -1) == 's' then 
			value = value .. 'es'
		else
			value = value .. 's'
		end
    end

	return value
    
end


function GeneralFunctions.NameStutter(chara)
	--used to get a stutter on a character's name with proper coloring
	local name = chara.Nickname
	local prefix = "[color=#00FFFF]" .. string.sub(name, 1, 1) .. "[color]-"
	
	return prefix .. chara:GetDisplayName()

end

--centers the camera on the given characters. Moves at a rate of speed.
--give no speed for instant speed 
function GeneralFunctions.CenterCamera(charList, startX, startY, speed)
	local totalX = 0
	local totalY = 0
	local length = 0
	local frameDur = 0
	DEBUG.EnableDbgCoro()

	for key, value in pairs(charList) do
		totalX = totalX + value.Position.X + 8--offset char's pos by 8 to get camera on their center
		totalY = totalY + value.Position.Y + 8
		length = length + 1
		--print(value:GetDisplayName() .. "'s position: " .. value.Position.X .. " " .. value.Position.Y)
	end
	
	local avgX = math.floor(totalX / length)
	local avgY = math.floor(totalY / length)
	
	if speed == nil or startX == nil or startY == nil then
		frameDur = 1
	else
		frameDur = GeneralFunctions.CalculateCameraFrames(startX, startY, avgX, avgY, speed)
	end
	
	--print('CenterCamera: X = ' .. avgX .. '    Y = ' .. avgY)
	GAME:MoveCamera(avgX, avgY, frameDur, false)
	
end

--pan the camera back towards the target location, horizontally first then vertically
--give no parameters to center on player
function GeneralFunctions.PanCamera(startX, startY, toPlayer, speed, endX, endY)
	endX = endX or CH('PLAYER').Position.X + 8
	endY = endY or CH('PLAYER').Position.Y + 8
	speed = speed or 1
	startX = startX or GAME:GetCameraCenter().X
	startY = startY or GAME:GetCameraCenter().Y
	toPlayer = toPlayer or true
	local difference = 0
	local duration = 0
	
	if endX ~= startX then
		difference = math.abs(endX - startX)
		duration = math.ceil(difference / speed)
		GAME:MoveCamera(endX, startY, duration, false)
	end
	
	if endY ~= startY then
		difference = math.abs(endY - startY)
		duration = math.ceil(difference / speed)
		GAME:MoveCamera(endX, endY, duration, false)
	end
	
	if toPlayer then GAME:MoveCamera(0, 0, 1, true) end
	
	
end

--useful for having characters face constantly towards someone who's moving
--offset is if you want the characters to look at 
function GeneralFunctions.FaceMovingCharacter(chara, target, turnFrames, breakDirection)
	local currentLocX = -999
	local currentLocY = -999
	turnFrames = turnFrames or 4

	breakDirection = breakDirection or Direction.None
	
	GAME:WaitFrames(1)--gives the pokemon a chance to start moving
	while not (currentLocX == target.Position.X and currentLocY == target.Position.Y) do
		if chara.Direction == breakDirection then break end
		GROUND:CharTurnToCharAnimated(chara, target, turnFrames)
		currentLocX = target.Position.X
		currentLocY = target.Position.Y
		GAME:WaitFrames(1)
	end
end

--does a monologue, centering the text, having it appear instantly and turning off the keysound, then turn centering and auto finish off after.
function GeneralFunctions.Monologue(str)
	UI:ResetSpeaker(false)
	UI:SetCenter(true)
	UI:SetAutoFinish(true)
	UI:WaitShowDialogue(str)
	UI:SetAutoFinish(false)
	UI:SetCenter(false)
end 

function GeneralFunctions.Hop(chara, anim, height, duration, pause, sound)
	anim = anim or 'None'
	height = height or 10
	duration = duration or 10
	if pause == nil then pause = true end
	if sound == nil then sound = false end

	local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex(anim)
	GROUND:CharSetAction(chara, RogueEssence.Ground.HopGroundAction(chara.Position, chara.Direction, animId, height, duration))
	
	if sound then
		SOUND:PlayBattleSE("EVT_Emote_Startled")
	end
	
	if pause then 
		GAME:WaitFrames(duration)
	end

end

--do two hops instead of just one
function GeneralFunctions.DoubleHop(chara, anim, height, duration, pause, sound)
	anim = anim or 'None'
	height = height or 10
	duration = duration or 10
	if pause == nil then pause = true end
	
	if sound then
		SOUND:PlayBattleSE("EVT_Emote_Startled_2")
	end
	
	local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex(anim)
	GROUND:CharSetAction(chara, RogueEssence.Ground.HopGroundAction(chara.Position, chara.Direction, animId, height, duration))
	GAME:WaitFrames(duration)--need to pause no matter what here because only one hop will show otherwise
	GROUND:CharSetAction(chara, RogueEssence.Ground.HopGroundAction(chara.Position, chara.Direction, animId, height, duration))

	if pause then --only pause on 2nd hop if pause needed
		GAME:WaitFrames(duration)
	end

end



function GeneralFunctions.Recoil(chara, anim, height, duration, sound, emote)

	anim = anim or 'Hurt'
	height = height or 10
	duration = duration or 10
	if sound == nil then sound = true end
	if emote == nil then emote = true end
	
	if emote then GROUND:CharSetEmote(chara, "shock", 1) end
	if sound then SOUND:PlayBattleSE('EVT_Emote_Startled') end
	local animId = RogueEssence.Content.GraphicsManager.GetAnimIndex(anim)
	GROUND:CharSetAction(chara, RogueEssence.Ground.HopGroundAction(chara.Position, chara.Direction, animId, height, duration))
	GAME:WaitFrames(duration)
	if emote then GROUND:CharSetEmote(chara, "", 0) end
	
end

function GeneralFunctions.PromptSave()
	UI:ResetSpeaker()
	UI:ChoiceMenuYesNo("Would you like to save your game?")
	UI:WaitForChoice()
	local result = UI:ChoiceResult()
	if result then 
		GAME:GroundSave()
		UI:ResetSpeaker()
		UI:WaitShowDialogue("Game saved!")
		GAME:WaitFrames(20)
	end
end

--used for chapter end save and quit prompts. Needs to be its own function as we can't call a map transition after if we choose save and quit.
--this should really only ever be called if the ground you want to enter next is the one you're already on.
--also this is kind of a workaround method due to how map transitions and reset to title works.

function GeneralFunctions.PromptChapterSaveAndQuit(ground, marker, ground_id)
	UI:ResetSpeaker()
	UI:BeginChoiceMenu("What would you like to do?", {"Save and continue.", "Save and quit.", "Cancel"}, 1, 3)
	UI:WaitForChoice()
	local result = UI:ChoiceResult()
	if result == 1 then 
		UI:ResetSpeaker()
		_DATA.Save.NextDest = RogueEssence.Dungeon.ZoneLoc("master_zone", -1, ground_id, 0)--set next destination to whatever map we were going to go to on a continue. Just in case player quits out after selecting this option.
		GAME:GroundSave()
		UI:WaitShowDialogue("Game saved!")
		GAME:EnterGroundMap(ground, marker)
	elseif result == 2 then 
		UI:ResetSpeaker()
		GAME:FadeOut(false, 40)
		_DATA.Save.NextDest = RogueEssence.Dungeon.ZoneLoc("master_zone", -1, ground_id, 0)--set next destination to whatever map we were going to go to on a continue
		GAME:GroundSave()
		UI:WaitShowDialogue("Game saved! Returning to title.")
		GAME:RestartToTitle()
	else
		GAME:EnterGroundMap(ground, marker)
	end
end

--used to reward items to the player, sends the item to storage if inv is full
function GeneralFunctions.RewardItem(itemID, money, amount)
	--if money is true, the itemID is instead the amount of money to award
	if money == nil then money = false end 
	
	UI:ResetSpeaker(false)--disable text noise
	UI:SetCenter(true)
	
	
	SOUND:PlayFanfare("Fanfare/Item")
	
	if money then 
		UI:WaitShowDialogue(GAME:GetTeamName() .. " received " .. "[color=#00FFFF]" .. itemID .. "[color]" .. STRINGS:Format("\\uE024") .. ".[pause=40]") 
		GAME:AddToPlayerMoney(itemID)
	else	
		local itemEntry = RogueEssence.Data.DataManager.Instance:GetItem(itemID)
		
		--give at least 1 item
		if amount == nil then amount = math.max(1, itemEntry.MaxStack) end 

		local item = RogueEssence.Dungeon.InvItem(itemID, false, amount)
		
		local article = "a"
		
		local first_letter = string.upper(string.sub(_DATA:GetItem(item.ID).Name:ToLocal(), 1, 1))
		
		if first_letter == "A" or first_letter == 'E' or first_letter == 'I' or first_letter == 'O' or first_letter == 'U' then article = 'an' end

		UI:WaitShowDialogue(GAME:GetTeamName() .. " received " .. article .. " " .. item:GetDisplayName() ..".[pause=40]") 
		
		--bag is full - equipped count is separate from bag and must be included in the calc
		if GAME:GetPlayerBagCount() + GAME:GetPlayerEquippedCount() >= GAME:GetPlayerBagLimit() then
			UI:WaitShowDialogue("The " .. item:GetDisplayName() .. " was sent to storage.")
			GAME:GivePlayerStorageItem(item.ID, amount)
		else
			GAME:GivePlayerItem(item.ID, amount)
		end
	
	end
	UI:SetCenter(false)
	UI:ResetSpeaker()
			
		
end


local function FirstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

--a or an before an item?
function GeneralFunctions.GetItemArticle(item, uppercase)
	if uppercase == nil then uppercase = false end 
	
	local article = 'a'
	local first_letter = string.upper(string.sub(_DATA:GetItem(item.ID).Name:ToLocal(), 1, 1))

	if first_letter == "A" or first_letter == 'E' or first_letter == 'I' or first_letter == 'O' or first_letter == 'U' then article = 'an' end
	
	if uppercase then article = FirstToUpper(article) end
	
	return article
end

--have both player and partner turn towards chara at the same time
--shortcut function
function GeneralFunctions.DuoTurnTowardsChar(chara, heroDelay, turnFrames)
	local player = CH('PLAYER')
	local partner = CH('Partner')
	
	turnFrames = turnFrames or 4
	heroDelay = heroDelay or 4
	
	local coro1 = TASK:BranchCoroutine(function() GAME:WaitFrames(heroDelay) GROUND:CharTurnToCharAnimated(player, chara, 4) end)
	local coro2 = TASK:BranchCoroutine(function() GROUND:CharTurnToCharAnimated(partner, chara, 4) end)
	
	TASK:JoinCoroutines({coro1, coro2})

end 

--set speaker and emotion beforehand!
function GeneralFunctions.DuoTurnTowardsCharWithDialogue(chara, dialogue, heroDelay, turnFrames)
	local player = CH('PLAYER')
	local partner = CH('Partner')
	
	turnFrames = turnFrames or 4
	heroDelay = heroDelay or 4
	
	local coro1 = TASK:BranchCoroutine(function() GAME:WaitFrames(heroDelay) GROUND:CharTurnToCharAnimated(player, chara, 4) end)
	local coro2 = TASK:BranchCoroutine(function() GROUND:CharTurnToCharAnimated(partner, chara, 4) end)
	UI:WaitShowDialogue(dialogue)
	
	TASK:JoinCoroutines({coro1, coro2})

end

--character hops twice and makes angry noise 
function GeneralFunctions.Complain(chara, emote)
	if emote == nil then emote = false end 
	
	SOUND:PlayBattleSE('EVT_Emote_Complain_2')
	GeneralFunctions.Hop(chara)
	GeneralFunctions.Hop(chara)
	if emote then GROUND:CharSetEmote(chara, "angry", 0) end 
	
end

--do a quick shake in place.
function GeneralFunctions.Shake(chara)
  --GROUND:CharSetAction(CH('PLAYER'), RogueEssence.Ground.FrameGroundAction(CH('PLAYER').Position, CH('PLAYER').Direction, animId, 5))
  GROUND:CharSetDrawEffect(chara, DrawEffect.Trembling)
  GAME:WaitFrames(8)
  GROUND:CharEndDrawEffect(chara, DrawEffect.Trembling)
end

--shake in place until told to stop. Change animation to the first frame of walking while doing so.
--if you don't want that first frame of walk, use GROUND:CharSetDrawEffect and GROUND:CharEndDrawEffect
function GeneralFunctions.StartTremble(chara)
  GROUND:CharSetAction(chara, RogueEssence.Ground.FrameGroundAction(chara.Position, chara.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Walk"), 0))
  GROUND:CharSetDrawEffect(chara, DrawEffect.Trembling)

end 

function GeneralFunctions.StopTremble(chara)
  GROUND:CharEndAnim(chara)
  GROUND:CharEndDrawEffect(chara, DrawEffect.Trembling)

end 

--used to turn towards a specified position which is needed if chara's position is dynamic
function GeneralFunctions.TurnTowardsLocation(chara, targetX, targetY, turnduration)

	local x = chara.Position.X + 8
	local y = chara.Position.Y + 8
	turnduration = turnduration or 4


	--In a normal setting, +y is up, but in pmdo +y is down. So I need to flip the sign on the difference in y between char1 and char2
	local y = -1 * (targetY - y)
	local x = targetX - x
	
	local angle = math.atan(y, x)--this is in radians
	local ratio = math.pi / 8 --for readability

	if angle <= (ratio) and angle >= (-1 * ratio) then 
		GROUND:CharAnimateTurnTo(chara, Direction.Right, turnduration)
	elseif angle > (ratio) and angle < (3 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.UpRight, turnduration)
	elseif angle >= (3 * ratio) and angle <= (5 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.Up, turnduration)
	elseif angle > (5 * ratio) and angle < (7 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.UpLeft, turnduration)
	elseif angle >= (7 * ratio) or angle <= (-7 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.Left, turnduration)
	elseif angle > (-7 * ratio) and angle < (-5 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.DownLeft, turnduration)
	elseif angle >= (-5 * ratio) and angle <= (-3 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.Down, turnduration)
	elseif angle > (-3 * ratio) and angle < (-1 * ratio) then
		GROUND:CharAnimateTurnTo(chara, Direction.DownRight, turnduration)
	else
		--i screwed up with the logic somewhere if one of the above cases isn't selected
		--Spin around like a moron if this statement is reached
		--this should be changed to some sort of error, but i dont know how to log errors properly in PMDO
		GROUND:CharSetAnim(chara, 'Spin', true)
	end
end

function GeneralFunctions.RemoveCharEffects(char)
	char.StatusEffects:Clear();
	char.ProxyAtk = -1;
	char.ProxyDef = -1;
	char.ProxyMAtk = -1;
	char.ProxyMDef = -1;
	char.ProxySpeed = -1;
end

--called whenever to warp the party out, including guests
function GeneralFunctions.WarpOut()
	local player_count = GAME:GetPlayerPartyCount()
	local guest_count = GAME:GetPlayerGuestCount()
	for i = 0, player_count - 1, 1 do 
		local player = GAME:GetPlayerPartyMember(i)
		if not player.Dead then
			GAME:WaitFrames(60)
			local anim = RogueEssence.Dungeon.CharAbsentAnim(player.CharLoc, player.CharDir)
			GeneralFunctions.RemoveCharEffects(player)
			TASK:WaitTask(_DUNGEON:ProcessBattleFX(player, player, _DATA.SendHomeFX))
			TASK:WaitTask(player:StartAnim(anim))
		end
	end

	for i = 0, guest_count - 1, 1 do
		local guest = GAME:GetPlayerGuestMember(i)
		if not guest.Dead then
			GAME:WaitFrames(60)
			local anim = RogueEssence.Dungeon.CharAbsentAnim(guest.CharLoc, guest.CharDir)
			GeneralFunctions.RemoveCharEffects(guest)
			TASK:WaitTask(_DUNGEON:ProcessBattleFX(guest, guest, _DATA.SendHomeFX))
			TASK:WaitTask(guest:StartAnim(anim))
		end
	end
end

--does a double flash like in a boss transition
function GeneralFunctions.DoubleFlash(sound)
    local center = GAME:GetCameraCenter()
    local emitter = RogueEssence.Content.FlashEmitter()
    emitter.FadeInTime = 2
    emitter.HoldTime = 2
    emitter.FadeOutTime = 2
    emitter.StartColor = Color(0, 0, 0, 0)
    emitter.Layer = DrawLayer.Top
    emitter.Anim = RogueEssence.Content.BGAnimData("White", 0)
    GROUND:PlayVFX(emitter, center.X, center.Y)
    if sound then SOUND:PlayBattleSE("EVT_Battle_Flash") end
    GAME:WaitFrames(16)
    GROUND:PlayVFX(emitter, center.X, center.Y)
    if sound then SOUND:PlayBattleSE("EVT_Battle_Flash") end
end

function GeneralFunctions.RemoveAllItems()
	local save = _DATA.Save
	local inv_count = save.ActiveTeam:GetInvCount() - 1

  --remove bag items
  for i = inv_count, 0, -1 do
    local entry = _DATA:GetItem(save.ActiveTeam:GetInv(i).ID)
    --if not entry.CannotDrop then
      save.ActiveTeam:RemoveFromInv(i)
    --end
  end
  
  --remove equips
  local player_count = save.ActiveTeam.Players.Count
  for i = 0, player_count - 1, 1 do 
    local player = save.ActiveTeam.Players[i]
    if player.EquippedItem.ID ~= '' and player.EquippedItem.ID ~= nil then 
      local entry = _DATA:GetItem(player.EquippedItem.ID)
      if not entry.CannotDrop then
         player:SilentDequipItem()
      end
    end
  end
end

---FUNCTIONS BELOW NOT BY PALIKA
function GeneralFunctions.GuestPurge()
	local guest_count = GAME:GetPlayerGuestCount()
	for i = 0, guest_count - 1, 1 do
	  GAME:RemovePlayerGuest(0)
	end
end

function GeneralFunctions.DetermineRank()
	local rank = ""
	if SV.score.CurrentScore > 5 then
		rank = "\u{E10C}\u{E10C}\u{E10C}\u{E10C}\u{E10C}"
	elseif SV.score.CurrentScore > 4 then
		rank = "\u{E10C}\u{E10C}\u{E10C}\u{E10C}"
	elseif SV.score.CurrentScore > 3 then
		rank = "\u{E10C}\u{E10C}\u{E10C}"
	elseif SV.score.CurrentScore > 2 then
		rank = "\u{E10C}\u{E10C}"
	elseif SV.score.CurrentScore > 1 then
		rank = "\u{E10C}"
	else
		rank = "NO STARS."
	end
	return rank
end

function GeneralFunctions.DeeshpawnStarterPartner()
	-- SV.test_grounds.Starter.Gender = LUA_ENGINE:EnumToNumeric(Gender.Female)
	local character = RogueEssence.Dungeon.CharData()
	character.BaseForm = RogueEssence.Dungeon.MonsterID(SV.test_grounds.Starter.Species, SV.test_grounds.Starter.Form, SV.test_grounds.Starter.Skin, LUA_ENGINE:LuaCast(SV.test_grounds.Starter.Gender, Gender))
	character.Nickname = SV.test_grounds.Starter.Nickname
	GROUND:SetPlayer(character)
	GROUND:RemoveCharacter("Partner")
	local p = RogueEssence.Dungeon.CharData()
	p.BaseForm = RogueEssence.Dungeon.MonsterID(SV.test_grounds.Partner.Species, SV.test_grounds.Partner.Form, SV.test_grounds.Partner.Skin, LUA_ENGINE:LuaCast(SV.test_grounds.Partner.Gender, Gender))
	p.Nickname = SV.test_grounds.Partner.Nickname
	GROUND:SpawnerSetSpawn("PARTNER_SPAWN", p)
	local chara = GROUND:SpawnerDoSpawn("PARTNER_SPAWN")
end

function GeneralFunctions.Deadge(char)
	GROUND:CharSetAction(char, RogueEssence.Ground.PoseGroundAction(char.Position, char.Direction, RogueEssence.Content.GraphicsManager.GetAnimIndex("Faint")))
end

function GeneralFunctions.DeeshSetPlayer()
	local character = RogueEssence.Dungeon.CharData()
	character.BaseForm = RogueEssence.Dungeon.MonsterID(SV.grisha.Species, SV.grisha.Form, SV.grisha.Skin, LUA_ENGINE:LuaCast(SV.grisha.Gender, Gender))
	character.Nickname = "Grisha"
	GROUND:SetPlayer(character)
end
