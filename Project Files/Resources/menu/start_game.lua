local m = lstg.menu
m.start_game = {}
local M = m.start_game
M.name = "start_game"
M.obj_list = {}
local t = lstg.text.menu
local t_ids = {"easy", "normal", "hard", "lunatic"}
M.selected = 1
M.x = 450
M.y = -175

function M.update()
    for id, text in ipairs(t_ids) do
        M.obj_list[id] = New(M.option,text,id)
    end
    M._in()
    while(true)do
        if(m.key.up or m.key.left) then
            PlaySound('select00')
            M.wrap_menu(-1)
        elseif(m.key.down or m.key.right) then
            PlaySound('select00')
            M.wrap_menu(1)
        end
        if(KeyIsPressed('shoot')) then
            menu_is_ex = false
            PlaySound('ok00')
            difficulty = M.selected
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
    if IsValid(M.header) then
        Del(M.header)
    end
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
    task.New(stage_init,function()
        local pp = stage_init.bg.amp
        local ep = 5
        for i=0, 1, 1/60 do
            stage_init.bg.amp = Interpolate(pp, ep, EaseOutCubic(i))
            task.Wait(1)
        end
    end)
end

M.option = Class(object)
function M.option:init(t_id,id)
    self.prex = self.x
    self._x = (id-1) * 300 - 450
    self._y = (4-id) * 100 - 125
    self.x = M.x + self._x + 320
    self.y = M.y + self._y + 240
    self.bound = false
    self.t_id = t_id
    self.id = id
    self._in = M.option._in
    self._out = M.option._out
    self._a = 0
    self.font = "start_" .. t_id
end
function M.option:frame()
    self.x = M.x + self._x + 320
    self.y = M.y + self._y + 240
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
    local pp = stage_init.bg.amp
    local ep = _id * 10 + 5
    for i=0, 1, 1/60 do
        M.x = Interpolate(px, ex, EaseOutCubic(i))
        M.y = Interpolate(py, ey, EaseOutCubic(i))
        stage_init.bg.amp = Interpolate(pp, ep, EaseOutCubic(i))
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