local m = lstg.menu
m.music_room = {}
local M = m.music_room
M.name = "music_room"
M.obj_list = {}
local t = lstg.text.menu
local t_ids = {"JamTitle", "JamStage1", "JamBoss1", "JamStage2", "JamBoss2", "JamStage3", "JamBoss3",
               "JamTLB", "JamSEX", "JamBEX", "JamEnd", "JamSpell", "JamCredits", "JamLauncher"}
M.selected = 1

M.selected_list = {0,-1,-2,-3,-4,-5,-6,7,6,5,4,3,2,1}
M.numbered_list = {}

function M.update()
    M.center_list = Vector.new(-30,480-125)
    if not IsValid(M.obj_list[1]) then
        for id, text in ipairs(t_ids) do
            M.obj_list[id] = New(M.option,text,id)
        end
    end
    task.New(stage_init,function()
        local _,bgm=EnumRes('bgm')
        for i=1,30 do
            for _,v in pairs(bgm) do
                if GetMusicState(v)=='playing' then
                    SetBGMVolume(v,1-i/30)
                end
            end
            task.Wait(1)
        end
    end)
    --DEBUG_TEXT = "sex 2 for the nintendo switch"
    --M._in()
    while(true)do
        if(m.key.up) then
            PlaySound('select00')
            M.wrap_menu(-1)
        elseif(m.key.down) then
            PlaySound('select00')
            M.wrap_menu(1)
        end
        if(KeyIsPressed('shoot')) then
            PlaySound('ok00')
            M.desc_obj:transition(255)
            local _,bgm=EnumRes('bgm')
            for i=1,15 do
                for _,v in pairs(bgm) do
                    if GetMusicState(v)=='playing' then
                        SetBGMVolume(v,1-i/15)
                    end
                end
                task.Wait(1)
            end
            _stop_music()
            PlaySong(M.numbered_list[0].t_id)
            local _,bgm=EnumRes('bgm')
            for i=1,15 do
                for _,v in pairs(bgm) do
                    if GetMusicState(v)=='playing' then
                        SetBGMVolume(v,i/15)
                    end
                end
                task.Wait(1)
            end
        end
        if(KeyIsPressed('spell')) then
            PlaySound('cancel00')
            M._out()
            task.Wait(15)
            lstg.menu.title_screen._in()
            stage_init.stack:pop()
        end
        coroutine.yield()
    end
end

function M._in()
    if IsValid(M.header) then Del(M.header) end
    --M.header = New(menu_header,320,480-100, "music")
    if not IsValid(M.desc_obj) then M.desc_obj = New(M.desc) end
    if not IsValid(M.obj_list[1]) then
        for id, text in ipairs(t_ids) do
            M.obj_list[id] = New(M.option,text,id)
        end
    end
    M.desc_obj:transition(255)
    task.New(stage_init, function()
        for _, obj in ipairs(M.obj_list) do
            task.New(stage_init,function()
                if not IsValid(obj) then return end
                obj:_in()
            end)
            --task.Wait(2)
        end
    end)
    task.Wait(30)
    M.wrap_menu(0)
end
function M._out()
    --Kill(M.header)
    M.desc_obj:transition(0)
    if IsValid(M.desc_obj) then Del(M.desc_obj) end
    task.New(stage_init, function()
        for _, obj in ipairs(M.obj_list) do
            task.New(stage_init,function()
                obj:_out()
            end)
            --task.Wait(2)
        end
    end)
end

M.option = Class(object)
function M.option:init(t_id,id)
    self.scale = 0.65
    self._a = 0
    self.x = -300
    self.postx = M.getposition(id,0.75).x
    self.prex = self.x
    self.y = M.getposition(id,0.75).y
    self.bound = false
    self.t_id = t_id
    self.id = id
    self._in = M.option._in
    self._out = M.option._out
    self._select = M.option._select
    self._unselect = M.option._unselect
    self.text = self.id .. ". " .. music_list[self.t_id].name
end
function M.option:render()
    SetColorFont("music_room_name",Color(self._a,255,255,255))
    RenderFont("music_room_name",
            self.text, self.x, self.y, self.scale, 'left', "vcenter")
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
    local pa = self._a
    local ea = 0
    for i=0, 1, 1/60 do
        self.x = Interpolate(px, ex, EaseOutCubic(i))
        self._a = Interpolate(pa,ea,EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.option:_select(old)
    local pv = M.getposition(old[self.id], 0.75)
    local ev = M.getposition(M.selected_list[self.id], 0.75)
    local pa = self._a
    local ea = 255 - clamp(math.abs(M.selected_list[self.id])*100,0,255)
    M.numbered_list[M.selected_list[self.id]] = self
    for i=0, 1, 1/20 do
        self.x, self.y = Vector.lerp(pv,ev,i,EaseOutCubic):unpack()
        self._a = Interpolate(pa,ea,EaseOutCubic(i))
        task.Wait(1)
    end
    self.x, self.y = ev:unpack()
end

M.desc = Class(object)
function M.desc:init()
    self.x = 320
    self.y = 240
    self.bound = false
    self._a = 0
    self.scale = 0.5
    self.transition = M.desc.transition
    self.layer = -1
    self.composer = ""
    self.usage = ""
    self.desc = ""
end
function M.desc:frame()
    task.Do(self)
end
function M.desc:render()
    SetColorFont("music_room_desc",Color(self._a,255,255,255))
    local w, h = 16, 16
    RenderFont("music_room_desc", self.composer, self.x-w, self.y, self.scale, 'right', "bottom")
    RenderFont("music_room_desc", self.usage, self.x+w, self.y, self.scale, 'left', "bottom")
    RenderFont("music_room_desc", self.desc, self.x, self.y-h, self.scale, 'center', "top")
end
function M.desc:transition(end_a)
    self.task = {}
    self.task[1] = task.New(self,function()
        local pa = self._a
        local ma = 0
        local ea = end_a
        for i=0, 1, 1/5 do
            self._a = Interpolate(pa, ma, EaseOutCubic(i))
            task.Wait(1)
        end
        local entry = music_list[t_ids[M.selected]]
        self.composer = string.format("Composer: %s",entry.composer)
        self.usage = string.format("Used as: %s",entry.usage)
        self.desc = string.format("Composer's comment:\n%s",entry.desc)
        for i=0, 1, 1/15 do
            self._a = Interpolate(ma, ea, EaseOutCubic(i))
            task.Wait(1)
        end
    end)
end

function M.getposition(id, scale)
    local ang = 0
    if M.center_list == nil then
        M.center_list = Vector.new(-30,480-125)
    end
    return M.center_list + Vector.fromAngle(ang + (360/14) * id) * 100 * scale
end

function M.wrap_menu(change)
    local _old_list = {}
    for k, v in ipairs(M.selected_list) do
        local value = v
        _old_list[k] = v
        if value + change > 7 then
            value = -6
        elseif value + change < -6 then
            value = 7
        else
            value = value + change
        end
        M.selected_list[k] = value
    end
    if M.selected + change > #t_ids then
        M.selected = 1
    elseif M.selected + change < 1 then
        M.selected = #t_ids
    else
        M.selected = M.selected + change
    end

    for k,v in ipairs(M.obj_list) do
        task.New(stage_init, function()
            v:_select(_old_list)
        end)
    end
end