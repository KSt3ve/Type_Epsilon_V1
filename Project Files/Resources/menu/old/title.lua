LoadImageFromFile("menu_overlay", "THlib\\menu\\Assets\\menu_overlay.png")
SetImageCenter("menu_overlay", 425, 425)
SetImageState("menu_overlay", "mul+add", Color(0, 255, 255, 255))
LoadImageFromFile("reimu_overlay", "THlib\\menu\\Assets\\menu_reimu_overlay.png")
SetImageCenter("reimu_overlay", 320, 240)
SetImageState("reimu_overlay", "", Color(0, 255, 255, 255))
LoadImageFromFile("logo_overlay", "THlib\\menu\\Assets\\menu_logo_overlay.png")
SetImageCenter("logo_overlay", 320, 240)
SetImageState("logo_overlay", "", Color(0, 255, 255, 255))
LoadImageFromFile("loading_op", "THlib\\menu\\Assets\\loading_op.png")
SetImageCenter("loading_op", 320, 240)
LoadImageFromFile("gradient", "THlib\\menu\\Assets\\gradient.png")
SetImageCenter("gradient", 320, 240)
LoadImageFromFile('manual','THlib\\menu\\Assets\\manual.png',true,0,0,false,0)
LoadImageFromFile("menu_bg", "THlib\\menu\\Assets\\menu_bg.png")
LoadImageFromFile("menu_bg", "THlib\\menu\\Assets\\menu_bg.png")
LoadImageFromFile("menu_bg2", "THlib\\menu\\Assets\\menu_bg_2.png")

mask_fader2 = Class(object)
function mask_fader2:init(mode)
    self.layer = LAYER_TOP + 999999999
    self.group = GROUP_GHOST
    self.open = (mode == 'open')
end
function mask_fader2:frame()
    if self.timer > 30 then
        Del(self)
    end
end
function mask_fader2:render()
    SetViewMode 'ui'
    if self.open then
        SetImageState('white', '', Color(max(0, min(255, 255 - self.timer * 8.5)), 0, 0, 0))
    else
        SetImageState('white', '', Color(max(0, min(255, self.timer * 8.5)), 0, 0, 0))
    end
    RenderRect('white', 0, screen.width, 0, screen.height)
    SetViewMode 'world'
end

loading_screen = Class(object)
function loading_screen:init()
    self.img = 'loading_op'
    self.x = screen.width / 2
    self.y = screen.height / 2
    self.bound = false
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    ex.SetSignal('loading_end', false)
    task.New(self, function()

        New(tasker, function()

            task.New(self, function()
                task.Wait(60)
                --- load
                ex.SetSignal('loading_end', true)
            end)

            task.New(self, function()
                ex.WaitForSignal('loading_end', true)
                New(mask_fader, close)
                task.Wait(30)
                stage.Set('none', 'menu')
                New(mask_fader, open)
            end)

        end)

    end)
end

function loading_screen:frame()
    task.Do(self)
end

function loading_screen:render()
    SetViewMode'ui'
    self.class.base.render(self)
    SetViewMode'world'
end

menu_overlay_obj = Class(object)
function menu_overlay_obj:init()
    self.img = 'menu_overlay'
    self.x = screen.width / 2
    self.y = screen.height / 2
    self.bound = false
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 5
    self.omiga = 0.1
    task.New(self, function()

        local _beg_alpha = 0 local alpha = _beg_alpha  local _w_alpha = 0 local _end_alpha = 255 local _d_w_alpha = 90 / (90 - 1)
        for _ = 1, 90 do
            SetImgState(self, "mul+add", alpha, 255, 255, 255)
            task._Wait(1)
            _w_alpha = _w_alpha + _d_w_alpha alpha = (_end_alpha - _beg_alpha) * sin(_w_alpha) + (_beg_alpha)
        end

    end)
end

function menu_overlay_obj:frame()
    task.Do(self)
end

reimu_overlay_obj = Class(object)
function reimu_overlay_obj:init()
    self.img = 'reimu_overlay'
    self.x = screen.width / 2
    self.y = (screen.height / 2) + 120
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 12
    self.bound = false
    SetImageState("reimu_overlay", "", Color(0, 255, 255, 255))
    ex.SetSignal('reimu_title_vanish', false)
    task.New(self, function()

        New(tasker, function()

            task.New(self, function()

                local _beg_alpha = 0 local alpha = _beg_alpha  local _w_alpha = 0 local _end_alpha = 255 local _d_w_alpha = 90 / (30 - 1)
                for _ = 1, 30 do
                    SetImgState(self, "", alpha, 255, 255, 255)
                    task._Wait(1)
                    _w_alpha = _w_alpha + _d_w_alpha alpha = (_end_alpha - _beg_alpha) * sin(_w_alpha) + (_beg_alpha)
                end

            end)

            task.New(self, function()
                task.MoveTo(screen.width / 2, screen.height / 2, 30, MOVE_DECEL)
            end)

        end)

        ex.WaitForSignal('reimu_title_vanish', true)

        New(tasker, function()

            task.New(self, function()

                local _beg_alpha = 255 local alpha = _beg_alpha  local _w_alpha = -90 local _end_alpha = 0 local _d_w_alpha = 90 / (30 - 1)
                for _ = 1, 30 do
                    SetImgState(self, "", alpha, 255, 255, 255)
                    task._Wait(1)
                    _w_alpha = _w_alpha + _d_w_alpha alpha = (_end_alpha - _beg_alpha) * sin(_w_alpha) + (_end_alpha)
                end

            end)

            task.New(self, function()
                task.MoveTo(screen.width / 2, (screen.height / 2) - 120, 30, MOVE_DECEL)
                Del(self)
            end)

        end)
    end)
end

function reimu_overlay_obj:frame()
    task.Do(self)
end

logo_overlay_obj = Class(object)
function logo_overlay_obj:init()
    self.img = 'logo_overlay'
    self.x = screen.width / 2
    self.y = (screen.height / 2) - 120
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 12
    self.bound = false
    SetImageState("logo_overlay", "", Color(0, 255, 255, 255))
    ex.SetSignal('reimu_title_vanish', false)
    task.New(self, function()

        New(tasker, function()

            task.New(self, function()

                local _beg_alpha = 0 local alpha = _beg_alpha  local _w_alpha = 0 local _end_alpha = 255 local _d_w_alpha = 90 / (30 - 1)
                for _ = 1, 30 do
                    SetImgState(self, "", alpha, 255, 255, 255)
                    task._Wait(1)
                    _w_alpha = _w_alpha + _d_w_alpha alpha = (_end_alpha - _beg_alpha) * sin(_w_alpha) + (_beg_alpha)
                end

            end)

            task.New(self, function()
                task.MoveTo(screen.width / 2, screen.height / 2, 30, MOVE_DECEL)
            end)

        end)

        ex.WaitForSignal('reimu_title_vanish', true)

        New(tasker, function()

            task.New(self, function()

                local _beg_alpha = 255 local alpha = _beg_alpha  local _w_alpha = -90 local _end_alpha = 0 local _d_w_alpha = 90 / (30 - 1)
                for _ = 1, 30 do
                    SetImgState(self, "", alpha, 255, 255, 255)
                    task._Wait(1)
                    _w_alpha = _w_alpha + _d_w_alpha alpha = (_end_alpha - _beg_alpha) * sin(_w_alpha) + (_end_alpha)
                end

            end)

            task.New(self, function()
                task.MoveTo(screen.width / 2, (screen.height / 2) + 120, 30, MOVE_DECEL)
                Del(self)
            end)

        end)
    end)
end

function logo_overlay_obj:frame()
    task.Do(self)
end

local setting_item = { 'resx', 'resy', 'windowed', 'vsync', 'sevolume', 'bgmvolume', 'res' }
local Resolution = { { 640, 480 }, { 800, 600 }, { 960, 720 }, { 1024, 768 }, { 1280, 960 } }
local settingfile = "Library\\setting"



function save_setting()
    local f, msg
    f, msg = io.open(settingfile, 'w')
    if false then
        error(msg)
    else
        --f:write(Serialize(cur_setting))--旧方法，但是比较稳定
        f:write(format_json(Serialize(cur_setting)))--新方法by Xrysnow
        f:close()
    end
end
function format_json(str)
    local ret = ''
    local indent = '    '
    local level = 0
    local in_string = false
    for i = 1, #str do
        local s = string.sub(str, i, i)
        if s == '{' and (not in_string) then
            level = level + 1
            ret = ret .. '{\n' .. string.rep(indent, level)
        elseif s == '}' and (not in_string) then
            level = level - 1
            ret = string.format(
                    '%s\n%s}', ret, string.rep(indent, level))
        elseif s == '"' then
            in_string = not in_string
            ret = ret .. '"'
        elseif s == ':' and (not in_string) then
            ret = ret .. ': '
        elseif s == ',' and (not in_string) then
            ret = ret .. ',\n'
            ret = ret .. string.rep(indent, level)
        elseif s == '[' and (not in_string) then
            level = level + 1
            ret = ret .. '[\n' .. string.rep(indent, level)
        elseif s == ']' and (not in_string) then
            level = level - 1
            ret = string.format(
                    '%s\n%s]', ret, string.rep(indent, level))
        else
            ret = ret .. s
        end
    end
    return ret
end
function setting_keys_default()
    cur_setting.keys.up = default_setting.keys.up
    cur_setting.keys.down = default_setting.keys.down
    cur_setting.keys.left = default_setting.keys.left
    cur_setting.keys.right = default_setting.keys.right
    cur_setting.keys.slow = default_setting.keys.slow
    cur_setting.keys.shoot = default_setting.keys.shoot
    cur_setting.keys.special = default_setting.keys.special
    cur_setting.keys.spell = default_setting.keys.spell
    cur_setting.keys2.up = default_setting.keys2.up
    cur_setting.keys2.down = default_setting.keys2.down
    cur_setting.keys2.left = default_setting.keys2.left
    cur_setting.keys2.right = default_setting.keys2.right
    cur_setting.keys2.slow = default_setting.keys2.slow
    cur_setting.keys2.shoot = default_setting.keys2.shoot
    cur_setting.keys2.special = default_setting.keys2.special
    cur_setting.keys2.spell = default_setting.keys2.spell
    cur_setting.keysys.repfast = default_setting.keysys.repfast
    cur_setting.keysys.repslow = default_setting.keysys.repslow
    cur_setting.keysys.menu = default_setting.keysys.menu
    cur_setting.keysys.snapshot = default_setting.keysys.snapshot
    cur_setting.keysys.retry = default_setting.keysys.retry
end

_GetLastKey = GetLastKey
local _key_code_to_name = KeyCodeToName()

local key_func = { 'up', 'down', 'left', 'right', 'slow', 'shoot', 'spell', 'special', 'repfast', 'repslow', 'menu', 'snapshot' }

key_setting_menu = Class(simple_menu)

function key_setting_menu:init(title, content)
    simple_menu.init(self, title, content)
    self.w = 20
end

function key_setting_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    local last_key = _GetLastKey()
    if last_key ~= KEY.NULL then
        local item = setting_item[self.pos]
        self.pos_changed = ui.menu.shake_time
        if self.pos <= 12 then
            if self.edit then
                _GetLastKey()
                if self.pos <= 8 then
                    --cur_setting.keys[key_func[self.pos]]=last_key
                    self.key[key_func[self.pos]] = last_key
                elseif self.pos <= 12 then
                    cur_setting.keysys[key_func[self.pos]] = last_key
                end
                self.edit = false
                save_setting()
                return
            end
        end
        --        self.pos=self.pos+1
        --        if self.pos==13 then
        --            self.pos=12
        --            menu.FlyIn(menu_title,'left')
        --            menu.FlyOut(menu_key,'right')
    end

    if not self.edit then
        simple_menu.frame(self)
    end
end

function key_setting_menu:render()
    SetFontState('title_font', '', Color(self.alpha * 255, unpack(ui.menu.title_color)))
    RenderText('title_font', self.title, self.x, self.y + ui.menu.line_height * 6.5, ui.menu.font_size, 'centerpoint')
    ui.DrawMenu2('', self.text, self.pos, self.x - 115, self.y - ui.menu.line_height, self.alpha, self.timer, self.pos_changed, 'left')
    local key_name = {}
    if self.edit then
        if self.timer % 30 < 15 then
            RenderText('title_font', '___', self.x + 128, self.y + ui.menu.line_height * (7 - self.pos), ui.menu.font_size, 'right')
        end
    end
    for i = 1, 8 do
        --table.insert(key_name,_key_code_to_name[cur_setting.keys[key_func[i]]])
        table.insert(key_name, _key_code_to_name[self.key[key_func[i]]])
    end
    for i = 9, 12 do
        table.insert(key_name, _key_code_to_name[cur_setting.keysys[key_func[i]]])
    end
    table.insert(key_name, '')
    table.insert(key_name, '')
    ui.DrawMenu2('', key_name, self.pos, self.x + 115, self.y - ui.menu.line_height, self.alpha, self.timer, self.pos_changed, 'right')
end

other_setting_menu = Class(simple_menu)

function other_setting_menu:init(title, content)
    simple_menu.init(self, title, content)
    self.w = 24
    self.posx = cur_setting.res --cur_setting.res
end

function other_setting_menu:frame()
    task.Do(self)
     if self.locked then
         return
     end
     local last_key = GetLastKey()
     if last_key ~= KEY.NULL then
         local item = setting_item[self.pos]
         if self.pos >= 5 and self.pos <= 6 then
             if last_key == setting.keys.left then
                 cur_setting[item] = max(0, cur_setting[item] - 1)
                 PlaySound('select00', 0.003 * cur_setting[item])
             elseif last_key == setting.keys.right then
                 cur_setting[item] = min(100, cur_setting[item] + 1)
                 PlaySound('select00', 0.003 * cur_setting[item])
             end
         elseif self.pos <= 2 then
             if self.edit then
                 if last_key == setting.keys.down then
                     self.posx = self.posx - 1
                     PlaySound('select00', 0.3)
                 elseif last_key == setting.keys.up then
                     self.posx = self.posx + 1
                     PlaySound('select00', 0.3)
                 elseif last_key == setting.keys.shoot then
                     self.edit = false
                     PlaySound('select00', 0.3)
                 elseif last_key == setting.keys.spell then
                     self.edit = false
                     cur_setting.res = menu_other.setting_backup
                     cur_setting.resx = Resolution[cur_setting.res][1]
                     cur_setting.resy = Resolution[cur_setting.res][2]
                     PlaySound('cancel00', 0.3)
                 end
                 self.posx = max(1, min(self.posx, 5))
                 cur_setting.res = self.posx
                 cur_setting.resx = Resolution[cur_setting.res][1]
                 cur_setting.resy = Resolution[cur_setting.res][2]

             end

                      elseif self.pos<=2 then
                        local step=10^(self.posx-1)
                        if self.edit then
                            if last_key==setting.keys.down then cur_setting[item]=cur_setting[item]-step PlaySound('select00',0.3)
                            elseif last_key==setting.keys.up then cur_setting[item]=cur_setting[item]+step PlaySound('select00',0.3)
                            elseif last_key==setting.keys.left then self.posx=self.posx+1 PlaySound('select00',0.3)
                            elseif last_key==setting.keys.right then self.posx=self.posx-1 PlaySound('select00',0.3)
                            elseif last_key==setting.keys.shoot then self.edit=false PlaySound('select00',0.3)
                            elseif last_key==setting.keys.spell then self.edit=false cur_setting[item]=menu_other.setting_backup PlaySound('cancel00',0.3)
                            end
                            self.posx=max(1,min(self.posx,4))
                            cur_setting[item]=max(1,min(cur_setting[item],9999))
                            return
                        end
         elseif self.pos > 2 and self.pos < 5 then
             if last_key == setting.keys.left or last_key == setting.keys.right then
                 cur_setting[item] = not cur_setting[item]
                 PlaySound('select00', 0.3)
             end
         end
     end
         if not cur_setting[setting_item[3]] then
              cur_setting.res=1
            self.posx=1
            cur_setting.resx=Resolution[1][1]
            cur_setting.resy=Resolution[1][2]
        end
     if not self.edit then
         simple_menu.frame(self)
     end
end

function other_setting_menu:render()
     SetFontState('title_font', '', Color(self.alpha * 255, unpack(ui.menu.title_color)))
     RenderText('title_font', self.title, self.x, self.y + ui.menu.line_height * 4, 0.625, 'centerpoint')
     if self.pos <= 2 and self.edit then
         if self.timer % 30 < 15 then
             RenderText('title_font', '____', self.x + 128 - (1 - 1) * ui.menu.num_width, self.y + ui.menu.line_height * (3.5 - 1), 0.625, 'right')
             RenderText('title_font', '____', self.x + 128 - (1 - 1) * ui.menu.num_width, self.y + ui.menu.line_height * (3.5 - 2), 0.625, 'right')
         end
     end
     ui.DrawMenu2('', self.text, self.pos, self.x - 115, self.y - ui.menu.line_height, self.alpha, self.timer, self.pos_changed, 'left')
     local setting_text = {}
     for i = 1, 6 do
         setting_text[i] = tostring(cur_setting[setting_item[i]])
     end
     setting_text[7] = ''
     ui.DrawMenu2('', setting_text, self.pos, self.x + 115, self.y - ui.menu.line_height, self.alpha, self.timer, self.pos_changed, 'right')
end

manual_obj = Class(object)
function manual_obj:init(origin)
    self.x, self.y = screen.width * 0.5, (screen.width * 0.5) + 50
    self.img = 'manual'
    self.bound = false
    self.layer = LAYER_TOP
    task.New(self, function()
        task.MoveTo(self.x,self.y-2200,0,MOVE_ACC_DEC)
        task.MoveTo(self.x,self.y+565,45,MOVE_ACC_DEC)
        self._y=self.y
        for _=1,_infinite do
            if KeyIsPressed "up" and self.y > -1200 then
                PlaySound("changeitem",0.1)
                task.MoveTo(self.x,self.y-100,10,MOVE_ACC_DEC)
            end
            if KeyIsPressed "down" and self.y < 400 then
                PlaySound("changeitem",0.1)
                task.MoveTo(self.x,self.y+100,10,MOVE_ACC_DEC)
            end
            if KeyIsPressed "spell" and self.timer >= 60 then
                PlaySound("cancel00",0.1)
                New(reimu_overlay_obj)
                New(logo_overlay_obj)
                menu.FlyIn(origin, 'left')
                task.MoveTo(self.x,self._y-2200,30,MOVE_ACC_DEC)
                Del(self)
            end
            task._Wait(1)
        end
    end)
end

function manual_obj:frame()
    task.Do(self)
end

function manual_obj:render()
    self.class.base.render(self)
    SetViewMode'ui'
    --SetViewMode'world'
end

function InitializeOptionsMenu()
    menu_other = New(other_setting_menu, 'Other Settings', {
        { 'Resolution X', function ()
            menu_other.edit = true
            menu_other.setting_backup = cur_setting.res
        end },
        { 'Resolution Y', function ()
            menu_other.edit = true
            menu_other.setting_backup = cur_setting.res
        end },
        { 'Windowed', function ()
            cur_setting.windowed = not cur_setting.windowed
        end },
        { 'Vsync', function ()
             cur_setting.vsync = not cur_setting.vsync
        end },
        { 'Sound Volume', function ()
        end },
        { 'Music Volume', function ()
        end },
        { 'Return To Title', function ()
            save_setting()
            os.execute('start /b .\\LuaSTGPlus.exe "start_game=true"')
            stage.QuitGame()
        end },
        { 'exit', function ()
            if menu_other.pos ~= 7 then
            menu_other.pos = 7
            else
                save_setting()
                os.execute('start /b .\\LuaSTGPlus.exe "start_game=true"')
                stage.QuitGame()
            end
        end },
    })
end

function InitializeInputMenu()
    menu_key = New(key_setting_menu, 'Key Settings', {
        { 'Up', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Down', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Left', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Right', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Slow', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Shoot', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Spell', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Special', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'RepFast', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'RepSlow', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Menu', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'SnapShot', function()
            menu_key.edit = true
            menu_key.setting_backup = cur_setting[setting_item[menu_key.pos]]
        end },
        { 'Default', function()
            setting_keys_default()
        end },
        { 'Return To Title', function()
            save_setting()
            os.execute('start /b .\\LuaSTGPlus.exe "start_game=true"')
            stage.QuitGame()
        end },
        { 'exit', function()
            if menu_other.pos ~= 14 then
                menu_other.pos = 14
            else
                save_setting()
                os.execute('start /b .\\LuaSTGPlus.exe "start_game=true"')
                stage.QuitGame()
            end
        end },
    })
    menu_key.key = cur_setting.keys
end

stage_init = stage.New('init', true, true)
function stage_init:init()
    New(mask_fader, 'open')
    New(loading_screen)
end
function stage_init:frame()
     --if self.timer >= 120 then
        --stage.Set('none', 'menu')
    --end
end
function stage_init:render()
    ui.DrawMenuBG()
end

stage_menu = stage.New('menu', false, true)

function stage_menu:init()
    local f, msg
    f, msg = io.open(settingfile, 'r')
    if f == nil then
        cur_setting = DeSerialize(Serialize(default_setting))
    else
        cur_setting = DeSerialize(f:read('*a'))
        f:close()
    end
    New(tasker, function()
        New(mask_fader2, 'open')
    end)
    New(mask_fader2,'open')
    local menu_title, menu_player_select, menu_difficulty_select, menu_difficulty_select_pr, menu_replay_loader, menu_replay_saver, menu_items, menu_sc_pr
    local menu_list = {}
    local menu_practice = {}
    --New(reimu_overlay_obj)
    New(menu_overlay_obj)
    if _title_flag == nil then
        _title_flag = true
    else
        New(mask_fader, 'open')
    end
    --
    local function ExitGame()
        task.New(stage_menu, function()
            for i = 1, 60 do
                SetBGMVolume('menu', 1 - i / 60)
                task.Wait()
            end
        end)
        task.New(stage_menu, function()
            menu.FlyOut(menu_title, 'right')
            task.Wait(60)
            stage.QuitGame()
        end)
    end
    --
    menu_items = {

        { 'Game Start', function()
        --ex.SetSignal("reimu_title_vanish", true)
        practice = nil
        menu.FlyIn(menu_difficulty_select, 'right')
        menu.FlyOut(menu_title, 'left')
    end }

    }

    table.insert(menu_items, { 'Extra Start', function()
        PlaySound('invalid', 0.5)
        --misc.ShakeScreen(40, 2)
    end })

    if _allow_practice then

        table.insert(menu_items, { 'Stage Practice', function()
            --ex.SetSignal("reimu_title_vanish", true)
            practice = 'stage'
            menu.FlyIn(menu_difficulty_select_pr, 'right')
            menu.FlyOut(menu_title, 'left')
        end })

    end

    if _allow_sc_practice then

        table.insert(menu_items, { 'Spell Practice', function()
            ex.SetSignal("reimu_title_vanish", true)
            practice = 'spell'
            menu.FlyIn2(menu_sc_pr, 'right')
            menu.FlyOut(menu_title, 'left')
        end })

    end

    table.insert(menu_items, { 'Replays', function()

        ex.SetSignal("reimu_title_vanish", true)
        replay_loader.Refresh(menu_replay_loader)
        menu.FadeIn2(menu_replay_loader, 'right')
        menu.FadeOut(menu_title, 'left')

    end })

    table.insert(menu_items, { 'Music Room', function()

        ex.SetSignal("reimu_title_vanish", true)
        InitializeMusicRoom()
        menu.FlyIn2(menu_music_room, 'right')
        menu.FlyOut(menu_title, 'left')

    end })

    table.insert(menu_items, { 'Gallery', function()

        ex.SetSignal("reimu_title_vanish", true)
        InitializeGallery()
        menu.FlyIn2(menu_gallery, 'right')
        menu.FlyOut(menu_title, 'left')

    end })

    table.insert(menu_items, { 'Manual', function()

        New(manual_obj, menu_title)
        ex.SetSignal("reimu_title_vanish", true)
        menu.FlyOut(menu_title, 'left')

    end })
    
    table.insert(menu_items, { 'Key Settings', function()
        InitializeInputMenu()
        menu.FlyIn(menu_key, 'right')
        menu.FlyOut(menu_title, 'left')
        menu_key.pos = 1
        menu_key.title = 'Key Settings'
        menu_key.key = cur_setting.keys
    end })
    
    table.insert(menu_items, { 'Options', function()
        InitializeOptionsMenu()
        menu.FlyIn(menu_other, 'right')
        menu.FlyOut(menu_title, 'left')
        menu_other.pos = 1
    end })

    table.insert(menu_items, { 'Exit Game', ExitGame })

    table.insert(menu_items, { 'exit', function()

        --ex.SetSignal("reimu_title_vanish", true)
        if menu_title.pos == #menu_title.text then
            ExitGame()
        else
            menu_title.pos = #menu_title.text
        end

    end })

    menu_title = New(simple_menu, '', menu_items)
    New(mask_fader, 'open')
    --
    menu_items = {}

    local difficulty_pos = 1

    for _, name in ipairs(stage.groups) do

        if name ~= 'Spell Practice' then

            table.insert(menu_items, { name, function()

                scoredata.difficulty_select = difficulty_pos
                menu.FlyOut(menu_difficulty_select, 'left')
                last_menu = menu_difficulty_select
                last_menu.group_name = name
                menu.FlyIn(menu_player_select, 'right')

            end })

            difficulty_pos = difficulty_pos + 1

        end

    end

    table.insert(menu_items, { 'exit', function()

        menu.FlyIn(menu_title, 'left')
        menu.FlyOut(menu_difficulty_select, 'right')

    end })

    menu_difficulty_select = New(simple_menu, 'Select Difficulty', menu_items)
    menu_difficulty_select.pos = scoredata.difficulty_select or 1
    --
    menu_items = {}

    for i, v in ipairs(player_list) do

        table.insert(menu_items, { player_list[i][1], function()

            scoredata.player_select = i
            menu.FlyOut(menu_player_select, 'left')
            lstg.var.player_name = player_list[i][2]
            lstg.var.rep_player = player_list[i][3]

            task.New(stage_menu, function()

                for i = 1, 60 do
                    SetBGMVolume('menu', 1 - i / 60)
                    task.Wait()
                end

            end)

            task.New(stage_menu, function()

                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)

                if practice == 'stage' then
                    stage.group.PracticeStart(last_menu.stage_name[last_menu.pos])
                elseif practice == 'spell' then
                    stage.IsSCpractice = true--判定进入符卡练习的flag add by OLC
                    stage.group.PracticeStart('Spell Practice@Spell Practice')
                else
                    stage.group.Start(stage.groups[last_menu.group_name])
                end

            end)

        end })

    end

    table.insert(menu_items, { 'exit', function()

        menu.FlyIn(last_menu, 'left')
        menu.FlyOut(menu_player_select, 'right')

    end })

    menu_player_select = New(simple_menu, 'Select Player', menu_items)
    menu_player_select.pos = scoredata.player_select or 1
    --
    menu_items = {}

    local counter = 0

    for i, name in ipairs(stage.groups) do

        if stage.groups[name].allow_practice then

            table.insert(menu_items, { name, function()

                menu.FlyOut(menu_difficulty_select_pr, 'left')
                menu.FlyIn(menu_practice[name], 'right')

            end })

        end

    end

    table.insert(menu_items, { 'exit', function()

        --New(reimu_overlay_obj)
        menu.FlyIn(menu_title, 'left')
        menu.FlyOut(menu_difficulty_select_pr, 'right')

    end })

    menu_difficulty_select_pr = New(simple_menu, 'Select Difficulty', menu_items)
    --
    for _, sg in ipairs(stage.groups) do

        if stage.groups[sg].allow_practice then

            local menu_items = {}

            for _, s in ipairs(stage.groups[sg]) do

                if stage.stages[s].allow_practice then

                    table.insert(menu_items, { string.match(s, "^[%w_][%w_ ]*"), function()

                        menu.FlyOut(menu_practice[sg], 'left')
                        last_menu = menu_practice[sg]
                        menu.FlyIn(menu_player_select, 'right')

                    end })

                end

            end

            table.insert(menu_items, { 'exit', function()

                menu.FlyIn(menu_difficulty_select_pr, 'left')
                menu.FlyOut(menu_practice[sg], 'right')

            end })

            menu_practice[sg] = New(simple_menu, 'Select Stage', menu_items)
            menu_practice[sg].stage_name = {}

            for _, s in ipairs(stage.groups[sg]) do

                if stage.stages[s].allow_practice then
                    table.insert(menu_practice[sg].stage_name, s)
                end

            end

        end

    end
    --
    menu_sc_pr = New(sc_pr_menu, function(index)
        if index then
            last_menu = menu_sc_pr
            lstg.var.sc_index = index
            menu.FlyIn(menu_player_select, 'right')
            menu.FlyOut(menu_sc_pr, 'left')
        else
            menu.FlyIn(menu_title, 'left')
            menu.FlyOut(menu_sc_pr, 'right')
        end
    end)
    --
    menu_replay_loader = New(replay_loader, function(filename, stageName)
        if not filename then
            New(reimu_overlay_obj)
            New(logo_overlay_obj)
            menu.FlyIn(menu_title, 'left')
            menu.FlyOut(menu_replay_loader, 'right')
        else
            task.New(stage_menu, function()
                for i = 1, 60 do
                    SetBGMVolume('menu', 1 - i / 60)
                    task.Wait()
                end
            end)
            task.New(stage_menu, function()
                menu.FlyOut(menu_replay_loader, 'left')
                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)
                Print(filename, stageName)
                stage.IsReplay = true--判定进入rep播放的flag add by OLC
                stage.Set('load', filename, stageName)
            end)
        end
    end)
    local task_menu_init = function()
        New(reimu_overlay_obj)
        New(logo_overlay_obj)
        menu.FlyIn(menu_title, 'right')
    end
    local sc_init = function()
        --by OLC
        menu_sc_pr.pos = lstg.var.sc_index
        menu_sc_pr.page = int(lstg.var.sc_index / ui.menu.sc_pr_line_per_page) + 2
        self.pos_changed = ui.menu.shake_time
    end

    if stage.IsReplay then
        --rep播放后返回rep菜单 add by OLC
        stage.IsReplay = nil
        menu.FlyIn2(menu_replay_loader, 'left')
    elseif stage.IsSCpractice then
        --符卡练习后返回符卡练习菜单 add by OLC
        stage.IsSCpractice = nil
        if self.save_replay then
            menu_replay_saver = New(replay_saver, self.save_replay, self.finish, function()
                menu.FlyOut(menu_replay_saver, 'right')
                menu.FlyIn2(menu_sc_pr, 'left')
                task.New(menu_sc_pr, sc_init)
            end)
            menu.FlyIn2(menu_replay_saver, 'left')
        else
            menu.FlyIn2(menu_sc_pr, 'left')
            task.New(menu_sc_pr, sc_init)
        end
    else
        if self.save_replay then
            menu_replay_saver = New(replay_saver, self.save_replay, self.finish, function()
                menu.FlyOut(menu_replay_saver, 'right')
                task.New(stage_menu, function()
                    task.Wait(30)
                    task.New(stage_menu, task_menu_init)
                end)
            end)
            menu.FlyIn2(menu_replay_saver, 'left')
        else
            task.New(stage_menu, task_menu_init)
        end
    end

    task.New(self, function()
        --延迟几帧加载bgm避免奇怪的黑块问题--然并乱，草死
        task.Wait(1)
        --New(reimu_overlay_obj)
        New(mask_fader2, 'open')
        New(mask_fader, 'open')
        LoadMusic('menu', music_list.menu[1], music_list.menu[2], music_list.menu[3])
        PlayMusic('menu')
    end)

    menu_list = { menu_title, menu_player_select, menu_difficulty_select, menu_replay_loader, menu_replay_saver, menu_items, menu_sc_pr, menu_network, menu_player_select2, menu_player_select1, menu_playercount }--设置菜单对象表
end
function stage_menu:render()
    ui.DrawMenuBG()
end


