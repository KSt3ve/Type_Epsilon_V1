Include "THlib\\menu\\sc_pr.lua"

local m = lstg.menu
m.spell_practice = {}
local M = m.spell_practice
M.name = "spell_practice"
M.obj_list = {}
local t = lstg.text.menu
local t_ids = {"stage1", "stage2", "stage3"}
M.selected = 1
M.spell_selected = 1
M.spobj_list = {}
M.spells = {}
M.diffcolors = {
    easy = { 128, 255, 128 },
    normal = { 128, 128, 255 },
    hard = { 255, 128, 128 },
    lunatic = { 255, 128, 255},
    extra = { 255, 255, 128}
}
for _, _t in ipairs(t_ids) do
    M.spells[_t] = {}
end
M.bossnames = {
    stage1 = {"UmibiyoMidBoss:Normal", "UmibiyoBoss:Normal"},
    stage2 = {"JunMidboss:Normal", "JunBoss:Normal"},
    stage3 = {"UnkMidboss:Normal", "RachelBoss:Normal"},
    stageex = {"UmiEx", "Housui"}
}
M.diffnames = {"easy","normal","hard","lunatic"}

function M.loadspells()
    M.spells = {}
    for _, _t in ipairs(t_ids) do
        M.spells[_t] = {}
    end
    for _, _t in ipairs(t_ids) do
        for i, s in ipairs(_sc_table) do
            for k, n in ipairs(M.bossnames[_t]) do
                if s[1] == n then
                    if(_t ~= "stageex") then
                        for j, d in ipairs(M.diffnames) do
                            local sp = s
                            local ingame_name = s[2]
                            sp[6] = d
                            sp[7] = j
                            sp[8] = i
                            local _clone = clone_spell(sp)
                            --_clone[2] = ternary(lstg.text.spell[ingame_name], lstg.text.spell[ingame_name][j], ingame_name)
                            table.insert(M.spells[_t], _clone)
                        end
                    else
                        local ingame_name = s[2]
                        local name_id = lstg.text.spell[ingame_name]
                        local name = ingame_name
                        if name_id ~= nil then
                            name = name_id[5]
                        end
                        s[2] = name
                        s[6] = "extra"
                        s[7] = 5
                        s[8] = i
                        table.insert(M.spells[_t], s)
                    end
                end
            end
        end
    end
end
function clone_spell(spell)
    local ret = {}
    for i=1, 8 do
        ret[i] = spell[i]
    end
    return ret
end

function M.update()
    if scoredata.ex_unlocked and t_ids[#t_ids] ~= "stageex" then
        table.insert(t_ids, "stageex")
    end
    M.loadspells()
    DEBUG_TEXT = "stfu about sex 2"
    for id, text in ipairs(t_ids) do
        M.obj_list[id] = New(M.option,text,id)
    end
    M._in()
    while(true)do
        if(m.key.up) then
            PlaySound('select00')
            M.wrap_menu(-1)
        elseif(m.key.down) then
            PlaySound('select00')
            M.wrap_menu(1)
        end
        if(KeyIsPressed('shoot') and t_ids[M.selected] ~= 'return') then
            PlaySound('ok00')
            M.select()
        end
        if(KeyIsPressed("spell") or (KeyIsPressed('shoot') and t_ids[M.selected] == 'return')) then
            PlaySound('cancel00')
            M._out()
            stage_init.stack:pop(1)
            task.New(stage_init, function()
                task.Wait(1)
                lstg.menu.title_screen._in()
            end)
        end
        coroutine.yield()
    end
end

function M._in()
    if IsValid(M.player_obj) then
        Del(M.player_obj)
    end
    M.player_obj = New(M.player_select)
    if IsValid(M.header) then
        Del(M.header)
    end
    M.header = New(menu_header,320,480-50, "scpr")
    task.New(stage_init, function()
        for _, obj in ipairs(M.obj_list) do
            task.New(stage_init,function()
                obj:_in()
            end)
            task.Wait(2)
        end
    end)
    task.Wait(30)
    M.obj_list[M.selected]:_select()
end
function M._out()
    Kill(M.player_obj)
    Kill(M.header)
    task.New(stage_init, function()
        for _, obj in ipairs(M.obj_list) do
            task.New(stage_init,function()
                obj:_out()
            end)
            task.Wait(2)
        end
    end)
end
function M.select()
    M.sp_bg_obj = New(M.spell_bg)
    for _, obj in ipairs(M.spobj_list) do
        if IsValid(obj) then
            Kill(obj)
        end
        --task.Wait(2)
    end
    local _t = t_ids[M.selected]
    for id, spell in ipairs(M.spells[_t]) do
        M.spobj_list[id] = New(M.spell_option,spell,id)
        task.Wait(2)
    end
    task.Wait(25)
    M.wrap_spell_menu(0)
    while(true)do
        if(m.key.up) then
            PlaySound('select00')
            M.wrap_spell_menu(-1)
        elseif(m.key.down) then
            PlaySound('select00')
            M.wrap_spell_menu(1)
        end
        if(KeyIsPressed('shoot')) then
            PlaySound('ok00')
            local spell = M.spells[_t][M.spell_selected]
            old_lstg:storeUI()
            lstg.var.scpr_id = spell[#spell]
            lstg.var.rep_player = player_replays[lstg.var.player_name]
            if lstg.var.rep_player == "Marisa" then
                lstg.var.rep_player = ternary(lstg.var.is_missile, "Marisa B", "Marisa A")
            end
            RETURN_TO_MENU = "spell_practice"
            difficulty = spell[7]
            stage.group.Start(stage.groups["Spell Practice"])
        end
        if(KeyIsPressed("spell")) then
            PlaySound('cancel00')
            for _, obj in ipairs(M.spobj_list) do
                if(IsValid(obj)) then Kill(obj) end
                task.Wait(2)
            end
            if M.sp_bg_obj ~= nil then
                Kill(M.sp_bg_obj)
            end
            M.spell_selected = 1
            task.New(stage_init, function()
                task.Wait(60)
                M.y = M.spell_yvariance(1,0.4)
            end)
            task.Wait(30)
            break
        end
        coroutine.yield()
    end
end

M.option = Class(object)
function M.option:init(t_id,id)
    self.scale = 0.65
    self.x = -175
    self.postx = M.getposition(id,0.75).x
    self.prex = self.x
    self.y = M.getposition(id,0.75).y
    self.bound = false
    self.text = t[t_id].text
    self.t_id = t_id
    self.id = id
    self._in = M.option._in
    self._out = M.option._out
    self._select = M.option._select
    self._unselect = M.option._unselect
    self.layer = -2
end
function M.option:render()
    SetFontState("menu","",Color(255,255,255,255))
    RenderText("menu", self.text, self.x, self.y, self.scale, 'left', "vcenter")
end
function M.option:_in()
    local px = self.x
    local ex = self.postx
    for i=0, 1, 1/60 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.option:_out()
    local px = self.postx
    local ex = self.prex
    for i=0, 1, 1/60 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.option:_select()
    local px = self.x
    local ex = self.x + 30
    for i=0, 1, 1/20 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.option:_unselect()
    local px = self.x
    local ex = self.postx
    for i=0, 1, 1/20 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end

M.spell_option = Class(object)
function M.spell_option:init(spell,id)
    self.scale = 0.4
    self.x = 640 + 150
    self.postx = M.get_spellposition(id,self.scale).x
    self.prex = self.x
    self.y = M.get_spellposition(id,self.scale).y
    self.bound = false
    self.spell = spell
    --self.t_id = t_id
    self.id = id
    self._in = M.spell_option._in
    self._out = M.spell_option._out
    self._select = M.spell_option._select
    self._unselect = M.spell_option._unselect
    self._a = 60
    self._sta = self._a
    self.diff = lstg.text.menu[spell[6]].text
    self.color = M.diffcolors[spell[6]]
    task.New(self,function()
        self:_in()
    end)
end
function M.spell_option:frame()
    task.Do(self)
end
function M.spell_option:render()
    local r = self.color[1]/255
    local g = self.color[2]/255
    local b = self.color[3]/255
    SetFontState("menu","",Color(255,self._a * r,self._a * g,self._a * b))
    local scalie = self.scale
    self.scale = self.scale
    RenderText("menu", _editor_class[self.spell[1]].name .. "|" .. self.diff, self.x, self.y + M.y, self.scale, 'left', "vcenter")
    self.scale = scalie + 0.2
    SetFontState("menu","",Color(255,self._a,self._a,self._a))
    --SystemLog(PrintTableUniLine(self.spell))
    local spell_id = lstg.text.spell[self.spell[2]]
    local thing = spell_id ~= nil
    --SystemLog(tostring(not not thing))
    local name
    if thing then
        name = spell_id[self.spell[7]]
    else
        name = self.spell[2]
    end
    --SystemLog(name)
    RenderText("menu", name, self.x + 10, self.y + M.y - 30 * self.scale, self.scale, 'left', "vcenter")
    self.scale = scalie

    SetFontState("menu","",Color(255,255,255,255))
end
function M.spell_option:kill()
    PreserveObject(self)
    task.New(self,function()
        self:_out()
        RawKill(self)
    end)
end
function M.spell_option:_in()
    local px = self.x
    local ex = self.postx
    for i=0, 1, 1/60 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.spell_option:_out()
    local px = self.postx
    local ex = self.prex
    for i=0, 1, 1/60 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.spell_option:_select()
    local px = self.x
    local ex = self.x + 30
    local pa = self._a
    local ea = 255
    for i=0, 1, 1/20 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.spell_option:_unselect()
    local px = self.x
    local ex = self.postx
    local pa = self._a
    local ea = self._sta
    for i=0, 1, 1/20 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.spell_yvariance(id,scale)
    return id * 150 * scale
end
function M.get_spellposition(id, scale)
    return {
        x = 50,
        y = 500 - (150 + M.spell_yvariance(id,scale))
    }
end
M.y = M.spell_yvariance(1,0.4)
function M.getposition(id, scale)
    local ang = ((id - 1) * 9 / (#t_ids-1)) * 20
    return {
        x = 40 * scale,
        y = 500 - (150 + id * 40 * scale)
    }
end
CopyImage("menu_spell_bg", "white")
SetImageState("menu_spell_bg", "", Color(0))
M.spell_bg = Class(object)
function M.spell_bg:init()
    self.img = "menu_spell_bg"
    self.layer = -1.5
    task.New(self,function()
        for i=0, 1, 1/30 do
            SetImageState("menu_spell_bg", "", Color(EaseOutCubic(i) * 230,0,0,0))
            task.Wait(1)
        end
    end)
end
M.spell_bg.frame = task.Do
function M.spell_bg:render()
    RenderRect(self.img,0,640,0,480)
end
function M.spell_bg:kill()
    PreserveObject(self)
    task.New(self,function()
        for i=0, 1, 1/30 do
            SetImageState("menu_spell_bg", "", Color(EaseOutCubic(1-i) * 230,0,0,0))
            task.Wait(1)
        end
        RawDel(self)
    end)
end

function M.wrap_menu(change)
    local obj = M.obj_list[M.selected]
    task.New(stage_init, function()
        obj:_unselect()
    end)

    if(M.selected + change > #t_ids) then
        M.selected = 1
    elseif(M.selected + change < 1) then
        M.selected = #t_ids
    else
        M.selected = M.selected + change
    end

    local obj2 = M.obj_list[M.selected]
    task.New(stage_init, function()
        obj2:_select()
    end)
end

function M.wrap_spell_menu(change)
    local obj = M.spobj_list[M.spell_selected]
    local _t = t_ids[M.selected]
    task.New(stage_init, function()
        obj:_unselect()
    end)

    if(M.spell_selected + change > #M.spells[_t]) then
        M.spell_selected = 1
    elseif(M.spell_selected + change < 1) then
        M.spell_selected = #M.spells[_t]
    else
        M.spell_selected = M.spell_selected + change
    end

    local obj2 = M.spobj_list[M.spell_selected]
    task.New(stage_init,function()
        local py = M.y
        local ey = M.spell_yvariance(M.spell_selected,0.4)
        for i=0, 1, 1/20 do
            M.y = Interpolate(py, ey, EaseOutCubic(i))
            task.Wait(1)
        end
    end)
    task.New(stage_init, function()
        obj2:_select()
    end)
end
SCPR_PLAYER_IMGS = { "reimuA","reimuB","marisaA", "marisaB" }
for k,v in ipairs(SCPR_PLAYER_IMGS) do
    LoadImageFromFile("scpr:" .. v, "THlib\\menu\\assets\\" .. v .. ".png", false, 0,0,false)
end
local players = {"reimuA_player", "reimuB_player", "marisaA_player", "marisaA_player"}
M.player_select = Class(object)
function M.player_select:init()
    self.x = 640
    self.y = 100
    self.id = 1
    self.alpha = 0
    self.layer = -1
    self.bound = false
    task.New(self,function()
        M.player_change(self,0)
        self.alpha = 255
        while(true) do
            if(m.key.right) then
                M.player_change(self,1)
            elseif(m.key.left) then
                M.player_change(self,-1)
            end
            coroutine.yield()
        end
    end)
end
function M.player_select:frame()
    task.Do(self)
end
function M.player_select:render()
    self._img = "scpr:" .. SCPR_PLAYER_IMGS[self.id]
    SetImageState(self._img, "", Color(self.alpha/1.3,255,255,255))
    Render(self._img,self.x,self.y,0,-self.hscale,self.vscale)
end
function M.player_select:kill()
    PreserveObject(self)
    task.Clear(self)
    task.New(self, function()
        for i=0, 1, 1/15 do
            self.alpha = EaseOutCubic(1-i) * 255
        end
        Del(self)
    end)
end
function M.player_change(self,change)
    local pa = self.alpha
    for i=0, 1, 1/15 do
        self.alpha = Interpolate(pa,0,EaseOutCubic(i))
        coroutine.yield()
    end
    local id = self.id
    if id + change > 4 then
        id = 1
    elseif id + change < 1 then
        id = 4
    else
        id = id + change
    end
    self.id = id
    lstg.var.player_name = players[self.id]
    lstg.var.is_missile = self.id == 4
    for i=0, 1, 1/15 do
        self.alpha = Interpolate(pa,255,EaseOutCubic(i))
        coroutine.yield()
    end
    self.alpha = 255
end