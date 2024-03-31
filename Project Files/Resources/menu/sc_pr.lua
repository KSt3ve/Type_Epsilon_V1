local housama = {
    ["UmibiyoMidBoss:Normal"] = "JamStage1",
    ["UmibiyoBoss:Normal"] = "JamBoss1",
    ["JunMidboss:Normal"] = "JamStage2",
    ["JunBoss:Normal"] = "JamBoss2",
    ["UnkMidboss:Normal"] = "JamStage3",
    ["RachelBoss:Normal"] = "JamBoss3",
    UmiEx = "JamSEX",
    Housui = "JamBEX"
}
stage.group.New('menu', {}, "Spell Practice", { lifeleft = 0, power = 400, faith = 50000, bomb = 0 }, false)
stage.group.AddStage('Spell Practice', 'Spell Practice@Spell Practice', { lifeleft = 0, power = 400, faith = 50000, bomb = 0 }, false)
stage.group.DefStageFunc('Spell Practice@Spell Practice', 'init', function(self)
    local scpr_spell = _sc_table[lstg.var.scpr_id]
    local _current_boss = _editor_class[scpr_spell[1]]
    lstg.var.is_scpr = true
    if(scpr_spell[1] ~= "Housui" and scpr_spell[1] ~= "UmiEx") then
        _init_item(self)
        New(mask_fader, 'open')
        New(_G[lstg.var.player_name])
        IS_EX = false
    else
        ExInit(self)
    end
    task.New(self, function()
        TransitionToFullScreen(1, 224,240, 384, 448)
        do
            local name = housama[scpr_spell[1]] or "JamSpell"
            if not setting.usebosstheme then
                PlaySong('JamSpell')
            else
                PlaySong(name)
            end
            if _editor_class[scpr_spell[1]]._bg ~= nil then
                New(_current_boss._bg)
            else
                New(temple_background)
            end
        end
        task._Wait(30)
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            if GetMusicState(v) ~= 'stopped' then
                ResumeMusic(v)
            else
                if _current_boss.bgm ~= "" then
                    _play_music(_current_boss.bgm)
                else
                    --_play_music("spellcard")
                end
            end
        end
        local _boss_wait = true
        local _ref
        if scpr_spell[5] then
            _ref = New(_current_boss, { _current_boss.cards[scpr_spell[4] - 1], scpr_spell[3] })
            last = _ref
        else
            _ref = New(_current_boss, { boss.move.New(0, 144, 60, MOVE_DECEL), scpr_spell[3] })
            last = _ref
        end
        if _boss_wait then
            while IsValid(_ref) do
                task.Wait()
            end
        end
        task._Wait(150)
        if ext.replay.IsReplay() then
            ext.pop_pause_menu = true
            ext.rep_over = true
            lstg.tmpvar.pause_menu_text = { 'Replay Again', 'Return to Title', nil }
        else
            ext.pop_pause_menu = true
            lstg.tmpvar.death = false
            lstg.tmpvar.pause_menu_text = { 'Continue', 'Quit and Save Replay', 'Return to Title' }
        end
        task._Wait(60)
    end)
    task.New(self, function()
        while coroutine.status(self.task[1]) ~= 'dead' do
            task.Wait()
        end
        New(mask_fader, 'close')
        _stop_music()
        task.Wait(30)
        stage.group.FinishStage()
    end)
end)
