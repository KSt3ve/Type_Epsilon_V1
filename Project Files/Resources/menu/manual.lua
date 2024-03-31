---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Zino Lath.
--- DateTime: 18/07/2021 01:01
---
local m = lstg.menu

LoadTexture('manual_img', "THlib\\menu\\assets\\manual.png")
CopyImage('manual_bg', "white")
function hey_bestie()
    local manual = New(manual_class)
    while(IsValid(manual)) do
        coroutine.yield()
    end
end

manual_class = Class(object)
function manual_class:init()
    self._dy = 0
    self.alpha = 0
    local white = Color(255,255,255,255)
    local tx,th = GetTextureSize('manual_img')
    local w,h = tx,480
    self.bound = false
    self.vs = {
        {320+w/-2, 240+h/2,  0, 0,  0, white},
        {320+w/2,  240+h/2,  0, tx, 0, white},
        {320+w/2,  240+h/-2, 0, tx, h, white},
        {320+w/-2, 240+h/-2, 0, 0,  h, white}
    }
    task.New(self, function()
        for i=0, 1, 1/30 do
            self.alpha = EaseOutCubic(i)
            coroutine.yield()
        end
    end)
end
function manual_class:frame()
    local way, speed
    if KeyIsDown('up') then
        way = -1
    elseif KeyIsDown('down') then
        way = 1
    else
        way = 0
    end
    if KeyIsDown('special') then
        speed = 20
    elseif KeyIsDown('slow') then
        speed = 5
    else
        speed = 10
    end

    self._dy = way * speed
    if KeyIsPressed('spell') then
        PlaySound("cancel00")
        Kill(self)
    end
    task.Do(self)
end
function manual_class:render()
    SetImageState('manual_bg', "", Color(self.alpha * 150, 0,0,0))
    RenderRect('manual_bg', 0,640,0,480)
    for k, v in ipairs(self.vs) do
        v[5] = v[5] + self._dy
        v[6] = Color(self.alpha * 255, 255,255,255)
    end
    SetTextureSamplerState("address", "wrap", Color(255,255,255,255))
    RenderTexture('manual_img', "", unpack(self.vs))
    SetTextureSamplerState("address", "clamp", Color(255,255,255,255))
end
function manual_class:kill()
    PreserveObject(self)
    task.Clear(self)
    task.New(self,function()
        local pa = self.alpha
        for i=0, 1, 1/30 do
            self.alpha = Interpolate(pa,0,EaseOutCubic(i))
            coroutine.yield()
        end
        Del(self)
    end)
end