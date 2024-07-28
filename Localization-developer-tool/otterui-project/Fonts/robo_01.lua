require("LuaLib")
require("TutorialLib")

ui.loadcatalog("ComboSystemTutorial")
ui.loadcatalog("MoveNames")

local routine



-- ##########################################
-- Combo GO #################################
-- ##########################################

-- 2LK 2MP 2MK 2HP
-- jLK jMP jHK
-- 5LPx2 5[MP] 5MK 5HP 
-- 236HK 
-- 236PP


local Combo 
Combo = {
  {
    text = "c.{lk} {seqs} c.{mp} {seqs} c.{mk} {seqs} c.{hp}",  -- c.lk, c.mk, c.hp, 
    details = "DoTheCombo_Cmd",
    func = function(helpers)

      if Combo.wantLoadState then
        savedState()
        wait(25)
        Combo.wantLoadState = false
      end

      local p1, p2 = getP1(), getP2()

      local success = false
      local wedidit = false

      local hitwithCWK = false
      local hitwithCMP = false
      local hitwithCMK = false
      local hitwithCHP = false

      while not success do
      
        if not p2:hasTag("Hitstun") then
          hitwithCWK = false
          hitwithCMK = false
          hitwithCHP = false
        end
        
        if p1:hasTag("c.WK") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithCWK = true
        end
        if p1:hasTag("c.MK") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithCMK = true
        end
        if p1:hasTag("c.MP") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithCMP = true
        end
        if p1:hasTag("c.HP") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithCHP = true
        end

        if hitwithCWK and hitwithCMP and hitwithCMK and hitwithCHP then
          success = true
          wedidit = true
          break
        end

        wait()
      end

      if wedidit then
        helpers.success()
      end

    end
  },
  {
    text = "j.{lk} {seqs} j.{mp} {seqs} j.{hk}",  -- j.lk,, j.mp, j.hk
    details = "DoTheCombo_Cmd",
    func = function(helpers)

      local p1, p2 = getP1(), getP2()
      local success = false
      local wedidit = false
      local hitwithJLK = false
      local hitwithJMP = false
      local hitwithJHK = false

      while not success do

        if not p2:hasTag("Hitstun") then
          wedidit = false
          break
        end
        if p1:hasTag("j.LK") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithJLK = true
        end
        if p1:hasTag("j.MP") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithJMP = true
        end
        if p1:hasTag("j.HK") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithJHK = true
        end

        if hitwithJLK and hitwithJMP and hitwithJHK then
          success = true
          wedidit = true
          break
        end

        wait()
      end

      if wedidit then
        helpers.success()
        did2 = true
      else
        helpers.fail()
        did1 = false
        did2 = false
        Combo.wantLoadState = true

      end
    end
  },
  {
    text = "s.{lp}x2 {seqs} s.{mp} {seqs} s.{mk} {seqs} s.{hp}",  -- 5LPx2 5[MP] 5MK 5HP 
    details = "DoTheCombo_Cmd",
    func = function(helpers)

      local p1, p2 = getP1(), getP2()
      local success = false
      local wedidit = false
      local hitwithSWP2 = false
      local hitwithSMP = false
      local hitwithSMK = false
      local hitwithSHP = false

      while not success do
        if not p2:hasTag("Hitstun") then
          wedidit = false
          break
        end

        if p1:hasTag("s.WP2") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithSWP2 = true
        end
        if p1:hasTag("s.MP") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithSMP = true
        end
        if p1:hasTag("s.MK") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithSMK = true
        end
        if p1:hasTag("s.HP") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithSHP = true
        end

        if hitwithSWP2 and hitwithSMP and hitwithSMK and hitwithSHP then
          success = true
          wedidit = true
          break
        end
        wait()
      end

      if wedidit then
        helpers.success()

      else
        helpers.fail()
        Combo.wantLoadState = true
      end
    end
  },
  {
    text = "Robo_Danger_ButtonH",  -- Dipping cat
    details = "DoTheCombo_Cmd",
    func = function(helpers)
      local p1, p2 = getP1(), getP2()
      local success = false
      local wedidit = false
      local hitwithDippingCat = false

      while not success do
        if not p2:hasTag("Hitstun") then
          wedidit = false
          break
        end

        if p1:hasTag("DippingCat") and p1.numhits > 0 and p2:hasTag("Hitstun") then
          hitwithDippingCat = true
        end

        if hitwithDippingCat and did7 then
          success = true
          wedidit = true
          break
        end

        wait()
      end
      if wedidit then
        helpers.success()
      else

        helpers.fail()
        Combo.wantLoadState = true
      end
    end
  },
  {
    text = "Robo_CannonAlpha",  -- Cannon
    details = "DoTheCombo_Cmd",
    func = function(helpers)
      local p1, p2 = getP1(), getP2()
      local success = false
      local wedidit = false
      local hitwithCannon = false

      while not success do
        if not p2:hasTag("Hitstun") then
          wedidit = false
          break
        end

        for _, child in ipairs(p1:getChildren()) do
	          if (child:hasTag("SuperBeam_Hit_Lv1_Actual") or child:hasTag("SuperBeam_Hit_Lv3_Actual") or child:hasTag("SuperBeam_Hit_Lv5_Actual")) and child.numhits > 0 and p2.hitstun > 0 then
	            hitwithCannon = true
	          end
        end

        if hitwithCannon then
          success = true
          wedidit = true
          break
        end
        wait()
      end
      if wedidit then
        helpers.success()
        helpers.fail()
        Combo.wantLoadState = true
      end
    end
  }
}

Combo.init = function()
  local p1, p2 = getP1(), getP2()
  savedState = saveState()
  p1:addForbiddenTag("")
  runAI = false
  p2:blockingAllowed(false)
  routine = coroutine.create(function() walkforthstand(200) end)
end

Combo.deinit = function()
  getP1():clearForbiddenTags()
  routine = coroutine.create(function() while true do wait() end end)
  runAI = false
  standardwait()
end

Combo.reload = false
Combo.type = "multi"



--- Make the tutorial go! ####################################



local tutorialsections = {
  Combo,
}

setInit(function()
  dosections(tutorialsections)

  setTimer(function()
  end, 1)
end)

setUpdate(function()
  if type(routine) == "thread" and coroutine.status(routine) == "suspended" then
    coroutine.resume(routine)
  end
end)
