local m = lstg.menu
m.extra_start = {}
local M = m.extra_start
M.name = "extra_start"
M.obj_list = {}
local t = lstg.text.menu
local t_ids = {"extra"}
M.selected = 1
M.x = 0
M.y = 0

function M.update()
    for id, text in ipairs(t_ids) do
        M.obj_list[id] = New(M.option,text,id)
    end
    M._in()
    task.Wait(30)
    while(true)do
        if(KeyIsPressed('shoot')) then
            difficulty = 5
            menu_is_ex = true
            PlaySound('ok00')
            stage_init.stack:push(m.player_select)
            M._out()
            m.player_select._in()
        end
        if(KeyIsPressed("spell")) then
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
    M.header = New(menu_header,320,480-50, "difficulty")
    task.New(stage_init, function()
        for _, obj in ipairs(M.obj_list) do
            task.New(stage_init,function()
                obj:_in()
            end)
        end
        M.select_func(M.selected)
    end)
end
function M._out()
    Kill(M.header)
    for _, obj in ipairs(M.obj_list) do
        task.New(stage_init,function()
            obj:_out()
        end)
    end
end

M.option = Class(object)
function M.option:init(t_id,id)
    self.prex = self.x
    self.x = 320
    self.y = 240
    self.bound = false
    self.text = t[t_id].text
    self.t_id = t_id
    self.id = id
    self._in = M.option._in
    self._out = M.option._out
    self._a = 0
    self.font = "start_" .. t_id
end
function M.option:render()
    local a = self._a
    SetColorFont(self.font, Color(a,a,a,a))
    RenderFont(self.font, self.text, self.x, self.y, 1, 'center', 'vcenter')
end
function M.option:_in()
    local pa = 0
    local ea = 256
    for i=0, 1, 1/30 do
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.option:_out()
    local pa = 256
    local ea = 0
    for i=0, 1, 1/30 do
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
end
function M.select_func(id)
    local _id = id - 1
    id = (4 - id) + 1
    local px = M.x
    local py = M.y
    local ex = (id-1) * 300 - 450
    local ey = (4-id) * 100 - 175
    for i=0, 1, 1/60 do
        M.x = Interpolate(px, ex, EaseOutCubic(i))
        M.y = Interpolate(py, ey, EaseOutCubic(i))
        task.Wait(1)
    end
end

function M.wrap_menu(change)
    if(M.selected + change > 4) then
        M.selected = 1
    elseif(M.selected + change < 1) then
        M.selected = 4
    else
        M.selected = M.selected + change
    end

    task.New(stage_init, function()
        M.select_func(M.selected)
    end)
end

M.coroutine = coroutine.create(M.update)