local m = lstg.menu
m.replay = {}
local M = m.replay
M.name = "replay"
M.obj_list = {}
local t = lstg.text.menu
local t_ids = {"easy", "normal", "hard", "lunatic"}
M.selected = 1
M.x = 450
M.y = -175

function M.return_to_menu()
    task.New(stage_init, function() coroutine.yield() M._in() end)
end
function M.update()
    M.replay_obj = New(replay_loader)
    M.replay_obj.exitCallback = function(filename, stageName)
        if not filename then
            task.New(stage_init, function()
                task.New(stage_init, function() menu.FadeOut(M.replay_obj) end)
                --Kill(M.replay_obj)
                stage_init.stack:pop()
                local n = lstg.menu.title_screen
                M._out()
                coroutine.resume(n.coroutine)
                coroutine.resume(n.coroutine)
                coroutine.resume(n.coroutine)
                coroutine.resume(n.coroutine)
                coroutine.resume(n.coroutine)
                coroutine.resume(n.coroutine)
                n._in()
                task.Wait(30)
                n.obj_list[n.selected]:_select()
            end)
        else
            stage.IsReplay = true--判定进入rep播放的flag add by OLC
            stage.Set('load', filename, stageName)
        end
    end
    while(true) do
        coroutine.yield()
    end
end
function M._in()
    if(stage_init.save_replay) then
        M.replay_saver = New(replay_saver, stage_init.save_replay, stage_init.finish)
        M.replay_saver.exitCallback = function()
            task.New(stage_init, function()
                task.New(stage_init, function() menu.FadeOut(M.replay_saver) Kill(M.replay_saver) end)
                stage_init.stack:pop()
                local n = lstg.menu.title_screen
                n._in()
                M._out()
                task.Wait(30)
                n.obj_list[n.selected]:_select()
            end)
        end
        menu.FadeIn2(m.replay.replay_saver)
    else
        task.New(stage_init, function()
            task.Wait(2)
            replay_loader.Refresh(m.replay.replay_obj)
            menu.FadeIn2(m.replay.replay_obj)
        end)
    end
end
function M._out()
    stage_init.save_replay = false
end

------------------------------------------------------------
menu = {}

function menu:FadeIn2()
    self.x = screen.width * 0.5
    task.Clear(self)
    task.New(self, function()
        for i = 0, 30 do
            self.alpha = i / 30
            task.Wait()
        end
        self.alpha = 1
        self.locked = false
    end)
    task.Wait(30)
end
function menu:FadeOut()
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            for i = 29, 0, -1 do
                self.alpha = i / 29
                task.Wait()
            end
            self.alpha = 0
        end)
        task.Wait(30)
    end
end
LoadTTF("replayfnt", 'THlib\\UI\\font\\default_ttf', 30)
LoadImageFromFile('replay_title', 'THlib\\UI\\replay_title.png')
LoadImageFromFile('save_rep_title', 'THlib\\UI\\save_rep_title.png')

local REPLAY_USER_NAME_MAX = 8
local REPLAY_DISPLAY_FORMAT1 = "%02d %s %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"
local REPLAY_DISPLAY_FORMAT2 = "%02d ----/--/-- --:--:-- %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"

local function FetchReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()

    for i = 1, ext.replay.GetSlotCount() do
        local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- 使用第一关的时间作为录像时间
            local date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)

            -- 统计总分数
            local totalScore = 0
            local diff, stage_num = 0, 0
            local tmp
            for i, k in ipairs(slot.stages) do
                totalScore = totalScore + slot.stages[i].score
                diff = string.match(k.stageName, '^.+@(.+)$')
                tmp = string.match(k.stageName, '^(.+)@.+$')
                if string.match(tmp, '%d+') == nil then
                    stage_num = tmp
                else
                    stage_num = 'St' .. string.match(tmp, '%d+')
                end
            end
            if diff == 'Spell Practice' then
                diff = 'SpellCard'
            end
            if tmp == 'Spell Practice' then
                stage_num = 'SC'
            end
            if slot.group_finish == 1 then
                stage_num = 'All'
            end
            text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num }
        else
            text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
        end
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        table.insert(ret, text)
    end
    return ret
end

------------------replay_saver-------------------------
local _keyboard = {}
do
    for i = 65, 90 do
        table.insert(_keyboard, i)
    end
    for i = 97, 122 do
        table.insert(_keyboard, i)
    end
    for i = 48, 57 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
        table.insert(_keyboard, i)
    end
    for i = 35, 38 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 42, 92, 127, 34 }) do
        table.insert(_keyboard, i)
    end
end

replay_loader = Class(object)

function replay_loader:init(exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5

    -- 是否可操作
    self.locked = true

    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.alpha = 0
    self.state1Selected = 1
    self.state1Text = {}
    self.state2Selected = 1
    self.state2Text = {}

    replay_loader.Refresh(self)
end

function replay_loader:Refresh()
    self.state1Text = FetchReplaySlots()
end

function replay_loader:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 构造关卡列表
            local slot = ext.replay.GetSlot(self.state1Selected)
            if slot ~= nil then
                self.state = 1
                self.state2Text = {}
                self.state2Selected = 1
                self.shakeValue = ui.menu.shake_time

                for i, v in ipairs(slot.stages) do
                    local stage = string.match(v.stageName, '^(.+)@.+$')
                    local score = string.format("%012d", v.score)
                    table.insert(self.state2Text, { stage, score })
                end
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local slot = ext.replay.GetSlot(self.state1Selected)
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2Selected = max(1, self.state2Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2Selected = min(#slot.stages, self.state2Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 转场
            local slot = ext.replay.GetSlot(self.state1Selected)
            if self.exitCallback then
                self.exitCallback(slot.path, slot.stages[self.state2Selected].stageName)
            end
            PlaySound('ok00', 0.3)
        elseif KeyIsPressed("spell") then
            self.shakeValue = ui.menu.shake_time
            self.state = 0
        end
    end
end

function replay_loader:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "replay_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                self.alpha,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        ui.DrawRepText2(
                "replayfnt",
                "replay_title",
                self.state2Text,
                self.state2Selected,
                self.x,
                self.y + 120,
                self.alpha,
                self.timer,
                self.shakeValue,
                "center")
    end
end
replay_saver = Class(object)

function replay_saver:init(stages, finish, exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5

    self.locked = true
    self.finish = finish or 0
    self.stages = stages
    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = FetchReplaySlots()
    self.state2CursorX = 0
    self.state2CursorY = 0
    self.state2UserName = ""
end

function replay_saver:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 跳转到录像保存状态
            self.state = 1
            --self.state2CursorX = 0
            --self.state2CursorY = 0
            --self.state2UserName = ""
            --由OLC修改，保存rep时菜单用来记录名称的参数
            if scoredata.repsaver == nil then
                scoredata.repsaver = ""
            end
            self.state2UserName = scoredata.repsaver
            if self.state2UserName ~= "" then
                self.state2CursorX = 12
                self.state2CursorY = 6
            else
                self.state2CursorX = 0
                self.state2CursorY = 0
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2CursorY = self.state2CursorY - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2CursorY = self.state2CursorY + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.left then
            self.state2CursorX = self.state2CursorX - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.right then
            self.state2CursorX = self.state2CursorX + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            if self.state2CursorX == 12 and self.state2CursorY == 6 then
                if self.state2UserName == "" then
                    self.state2UserName = "Anonymous"
                else
                    --由OLC添加，保存rep时菜单用来记录名称的参数
                    scoredata.repsaver = self.state2UserName
                end

                -- 保存录像
                ext.replay.SaveReplay(self.stages, self.state1Selected, self.state2UserName, self.finish)

                if self.exitCallback then
                    self.exitCallback()
                end
                PlaySound("extend", 0.5)
            end

            if #self.state2UserName == REPLAY_USER_NAME_MAX then
                self.state2CursorX = 12
                self.state2CursorY = 6
            elseif self.state2CursorX == 11 and self.state2CursorY == 6 then
                if #self.state2UserName == 0 then
                    self.state = 0
                else
                    self.state2UserName = string.sub(self.state2UserName, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            elseif self.state2CursorX == 10 and self.state2CursorY == 6 then
                local char = string.char(0x20)
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            else
                local char = string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1])
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if #self.state2UserName == 0 then
                self.state = 0
            else
                self.state2UserName = string.sub(self.state2UserName, 1, -2)
            end
            --			self.state = 0
            PlaySound('cancel00', 0.3)
        end

        self.state2CursorX = (self.state2CursorX + 13) % 13
        self.state2CursorY = (self.state2CursorY + 7) % 7
    end
end

function replay_saver:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "save_rep_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                self.alpha,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        Render("save_rep_title", self.x, self.y + ui.menu.sc_pr_line_height + 15 * ui.menu.sc_pr_line_height * 0.5)
        RenderFont("title_header_replay","Replay",self.x,self.y,1,'center','vcenter')
        ---- 绘制键盘
        -- 未选中按键
        SetFontState("replay", "", Color(self.alpha*255, unpack(ui.menu.unfocused_color)))
        for x = 0, 12 do
            for y = 0, 6 do
                if x ~= self.state2CursorX or y ~= self.state2CursorY then
                    --[[					RenderText(
                                            "replay",
                                            string.char(0x20 + y * 12 + x),
                                            self.x + (x - 5.5) * ui.menu.char_width,
                                            self.y - (y - 3.5) * ui.menu.line_height,
                                            ui.menu.font_size,
                                            'centerpoint'
                                        )]]
                    RenderText(
                            "replay",
                            string.char(_keyboard[y * 13 + x + 1]),
                            self.x + (x - 5.5) * ui.menu.char_width,
                            self.y - (y - 3.5) * ui.menu.line_height,
                            ui.menu.font_size,
                            'centerpoint'
                    )
                end
            end
        end
        -- 激活按键
        local color = {}
        local k = cos(self.timer * ui.menu.blink_speed) ^ 2
        for i = 1, 3 do
            color[i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
        end
        SetFontState("replay", "", Color(self.alpha*255, unpack(color)))
        RenderText(
                "replay",
                string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1]),
                self.x + (self.state2CursorX - 5.5) * ui.menu.char_width + ui.menu.shake_range * sin(ui.menu.shake_speed * self.shakeValue),
                self.y - (self.state2CursorY - 3.5) * ui.menu.line_height,
                ui.menu.font_size,
                "centerpoint"
        )

        -- 标题
        SetFontState("replay", "", Color(self.alpha*255, unpack(ui.menu.title_color)))
        RenderText("replay", self.state2UserName, self.x, self.y - 5.5 * ui.menu.line_height, ui.menu.font_size, "centerpoint")
    end
end
M.coroutine = coroutine.create(M.update)