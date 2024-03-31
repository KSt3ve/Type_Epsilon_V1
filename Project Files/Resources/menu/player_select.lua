local m = lstg.menu
m.player_select = {}
local M = m.player_select
M.name = "player_select"
local t = lstg.text.menu
local t_ids = {"extra"}
M.selected = 1
M.player_names = {
    [true] = {'marisaA_player'},
    [false] = {'reimuA_player', 'reimuB_player'}
}
M.player_ids = {
    "A", "B"
}
M.stages = {
    'stage1',
    'stage2',
    'stage3'
}

function M.update()
    local is_ex = menu_is_ex
    M._in(is_ex)
    while(true)do
        if(m.key.up or m.key.down or m.key.right or m.key.left) and not menu_is_ex then
            PlaySound('select00')
            task.New(M.obj, function()
                task.Clear(M.obj,true)
                M.obj:select()
            end)
        end
        if(KeyIsPressed('shoot')) then
            PlaySound('ok00')
            local __id = (1 - M.obj.value) + 1
            lstg.var.player_name = wrap_table(M.player_names[is_ex],__id,true)
            lstg.var.rep_player = ternary(is_ex, 'Marisa', 'Reimu ' .. M.player_ids[__id])
            if not practice then
                lstg.var.is_scpr = false
                stage.group.Start(stage.groups[ternary(is_ex, 'Extra', 'Normal')])
            else
                M.practice()
            end
        end
        if(KeyIsPressed("spell")) then
            PlaySound('cancel00')
            task.New(stage_init, function() M.obj:_out() end)
            task.Wait(5)
            Kill(M.header)
            stage_init.stack[-1]._in()
            stage_init.stack:pop()
        end
        coroutine.yield()
    end
end
function M._in(is_ex)
    is_ex = is_ex or stage_init.stack[-1].name == "extra_start"
    if IsValid(M.obj) then
        Del(M.obj)
    end
    M.obj = New(M.option, is_ex)
    if IsValid(M.header) then
        Del(M.header)
    end
    M.header = New(menu_header,320,480-50, "player")
    task.New(stage_init, function() M.obj:_in() end)
end
M.color = {}
M.color[true] = {
    {255,255,0}
}
M.color[false] = {
    {255,0,0},
    {0,0,255}
}
M.option = Class(object)
function M.option:init(is_ex)
    self.prex = self.x
    self.x = 320+64
    self.y = 240-60
    self.bound = false
    self.is_ex = is_ex
    self.value = 1
    self.render_value = self.value
    self._in = M.option._in
    self._out = M.option._out
    self.select = M.select_func
    self._a = 0
    self.scale = 0.6
end
function M.option:frame()
    task.Do(self)
    DEBUG_TEXT = self.render_value ..  "  |  " .. self._a
    if(self.is_ex) then self.value = 0 end
end
LoadImageFromFile('prselect_mari', "THlib\\menu\\assets\\select_mari.png", false, 0,0,false)
LoadImageFromFile('prselect_reimu', "THlib\\menu\\assets\\select_reimu.png", false, 0,0,false)
function M.option:render()
    local bitchimg = ternary(self.is_ex, "prselect_mari", "prselect_reimu")
    SetImageState(bitchimg,'', Color(self._a,255,255,255))
    Render(bitchimg, self.x-250,self.y,0.8,0.8)
    if not self.is_ex then
        local col1 = M.color[false][1]
        local col2 = M.color[false][2]
        local _t = self.render_value/2 + 0.5
        SetImageState('select_rei_bg', '',
                Color(self._a,
                        Interpolate(col1[1], col2[1], _t),
                        Interpolate(col1[2], col2[2], _t),
                        Interpolate(col1[3], col2[3], _t)
                )
        )
        Render('select_rei_bg',self.x,self.y,0,self.scale,self.scale)
        SetImageState('select_rei1','', Color(self._a,255,255,255))
        Render('select_rei1',self.x,self.y,0,clamp(self.render_value,0,1)*self.scale,self.scale)
        SetImageState('select_rei2','', Color(self._a,255,255,255))
        Render('select_rei2',self.x,self.y,0,-clamp(self.render_value,-1,0)*self.scale,self.scale)
    else
        SetImageState('select_mari_bg','', Color(self._a,255,255,255))
        Render('select_mari_bg',self.x,self.y,0,self.scale,self.scale)
        SetImageState('select_mari','', Color(self._a,255,255,255))

        Render('select_mari',self.x,self.y,0,self.scale,self.scale)
    end
end
function M.option:_in()
    local pa = 0
    local ea = 255
    for i=0, 1, 1/30 do
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
    self._a = ea
end
function M.option:_out()
    local pa = 255
    local ea = 0
    for i=0, 1, 1/30 do
        self._a = Interpolate(pa, ea, EaseOutCubic(i))
        task.Wait(1)
    end
    self._a = ea
    Kill(self)
end
function M:select_func()
    local pid = self.value
    local eid = 1-pid
    self.value = eid
    local pr = self.render_value
    local er = -sign(pr)
    for i=0, 1, 1/30 do
        self.render_value = Interpolate(pr, er, EaseOutCubic(i))
        task.Wait(1)
    end
    self.render_value = er
end

M.selected_prac = 1
function M.practice()
    for k,v in ipairs(M.prac_objs or {}) do
        if IsValid(v) then Del(v) end
    end
    M.prac_objs = {}
    for k,v in ipairs(M.stages) do
        M.prac_objs[k] = New(M.prac_option, v, k)
    end
    local bg = New(M.prac_bg)
    M.wrap_menu(0)
    task.Wait(30)
    while(true) do
        if(m.key.up) then
            M.wrap_menu(-1)
        elseif(m.key.down) then
            M.wrap_menu(1)
        end
        if KeyIsPressed('spell') then
            Kill(bg)
            for k,v in ipairs(M.prac_objs) do
                Kill(v)
            end
            M.prac_objs = {}
            task.Wait(30)
            return
        end
        if KeyIsPressed('shoot') then
            stage.group.PracticeStart(string.format("%d@Normal",M.selected_prac))
        end
        coroutine.yield()
    end
end
function M.get_position(id, scale)
    local ysize = 30 * scale
    local totaly = ysize*3
    return {
        x = 320,
        y = 240 - (ysize * id) + totaly/2
    }
end
do --prac_option
    M.prac_option = Class(object)
    function M.prac_option:init(t_id,id)
        self.scale = 0.65
        self.x = M.get_position(id,0.75).x
        self.y = M.get_position(id,0.75).y
        self.bound = false
        self.text = t[t_id].text
        self.t_id = t_id
        self.id = id
        self._in = M.prac_option._in
        self._out = M.prac_option._out
        self._select = M.prac_option._select
        self._unselect = M.prac_option._unselect
        self.alpha = 0
        self._b = 0
        self.layer = 5
        task.New(self, function()
            self:_in()
        end)
    end
    function M.prac_option:frame()
        task.Do(self)
    end
    function M.prac_option:render()
        local _b = Interpolate(128,255,self._b)
        SetFontState("menu","",Color(self.alpha,_b,_b,_b))
        RenderText("menu", self.text, self.x, self.y, self.scale, 'center', "vcenter")
        SetFontState("menu","",Color(255,255,255,255))
    end
    function M.prac_option:kill()
        PreserveObject(self)
        task.New(self, function()
            self:_out()
            RawDel(self)
        end)
    end
    function M.prac_option:_in()
        local pa = self.alpha
        local ea = 255
        for i=0, 1, 1/30 do
            self.alpha = Interpolate(pa, ea, EaseOutCubic(i))
            task.Wait(1)
        end
        self.alpha = ea
    end
    function M.prac_option:_out()
        local pa = self.alpha
        local ea = 0
        for i=0, 1, 1/30 do
            self.alpha = Interpolate(pa, ea, EaseOutCubic(i))
            task.Wait(1)
        end
        self.alpha = ea
    end
    function M.prac_option:_select()
        local pb = self._b
        local eb = 1
        for i=0, 1, 1/20 do
            self._b = Interpolate(pb, eb, EaseOutCubic(i))
            task.Wait(1)
        end
        self._b = eb
    end
    function M.prac_option:_unselect()
        local pb = self._b
        local eb = 0
        for i=0, 1, 1/20 do
            self._b = Interpolate(pb, eb, EaseOutCubic(i))
            task.Wait(1)
        end
        self._b = eb
    end
    CopyImage("menu_prac_bg", "white")
    SetImageState("menu_prac_bg", "", Color(0))
    M.prac_bg = Class(object)
    function M.prac_bg:init()
        self.img = "menu_prac_bg"
        self.layer = 4
        task.New(self,function()
            for i=0, 1, 1/30 do
                SetImageState("menu_prac_bg", "", Color(EaseOutCubic(i) * 230,0,0,0))
                task.Wait(1)
            end
        end)
    end
    M.prac_bg.frame = task.Do
    function M.prac_bg:render()
        RenderRect(self.img,0,640,0,480)
    end
    function M.prac_bg:kill()
        PreserveObject(self)
        task.New(self,function()
            for i=0, 1, 1/30 do
                SetImageState("menu_prac_bg", "", Color(EaseOutCubic(1-i) * 230,0,0,0))
                task.Wait(1)
            end
            RawDel(self)
        end)
    end

end
function M.wrap_menu(change)
    local obj = M.prac_objs[M.selected_prac]
    task.New(stage_init, function()
        obj:_unselect()
    end)

    if(M.selected_prac + change > #M.stages) then
        M.selected_prac = 1
    elseif(M.selected_prac + change < 1) then
        M.selected_prac = #M.stages
    else
        M.selected_prac = M.selected_prac + change
    end

    local obj2 = M.prac_objs[M.selected_prac]
    task.New(stage_init, function()
        obj2:_select()
    end)
end
M.coroutine = coroutine.create(M.update)