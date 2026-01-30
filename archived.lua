--== Obsidian Patcher v8 (labels supported) ======================
getgenv().UIPATCH = getgenv().UIPATCH or {}
local P = getgenv().UIPATCH

-- Tab/Control rules
P.skipTabs     = P.skipTabs     or {}
P.renameTabs   = P.renameTabs   or {}
P.hideByIdx    = P.hideByIdx    or {}
P.hideByText   = P.hideByText   or {}
P.renameByIdx  = P.renameByIdx  or {}
P.renameByText = P.renameByText or {}

-- Window overrides
P.windowTitleOverride  = P.windowTitleOverride  or nil
P.windowFooterOverride = P.windowFooterOverride or nil
P.windowIconOverride   = P.windowIconOverride   or nil

-- Icons
P.tabIcons       = P.tabIcons       or {}
P.groupboxIcons  = P.groupboxIcons  or {}

-- Groupboxes + tooltips
P.hideGroupboxes        = P.hideGroupboxes        or {}
P.renameGroupboxes      = P.renameGroupboxes      or {}
P.tooltipByIdx          = P.tooltipByIdx          or {}
P.tooltipByText         = P.tooltipByText         or {}
P.disabledTooltipByIdx  = P.disabledTooltipByIdx  or {}
P.disabledTooltipByText = P.disabledTooltipByText or {}

-- Theme/Save folder overrides
P.themeFolderOverride   = P.themeFolderOverride   or nil
P.saveFolderOverride    = P.saveFolderOverride    or nil
P.saveSubFolderOverride = P.saveSubFolderOverride or nil

-- Helpers
function P.HideTab(name) P.skipTabs[name]=true end
function P.RenameTab(old,new) P.renameTabs[old]=new end
function P.Hide(idOrText) P.hideByIdx[idOrText]=true end
function P.HideText(text) P.hideByText[text]=true end
function P.Rename(id,newText) P.renameByIdx[id]=newText end
function P.RenameText(old,newText) P.renameByText[old]=newText end
function P.SetTitle(s) P.windowTitleOverride=s end
function P.SetFooter(s) P.windowFooterOverride=s end
function P.SetIcon(n) P.windowIconOverride=n end
function P.SetTabIcon(tabName, icon) P.tabIcons[tabName]=icon end
function P.SetGroupboxIcon(title, icon) P.groupboxIcons[title]=icon end
function P.HideGroupbox(title) P.hideGroupboxes[title]=true end
function P.RenameGroupbox(old,new) P.renameGroupboxes[old]=new end
function P.Tooltip(idOrText, tip)
    if P.tooltipByIdx[idOrText] ~= nil or P.hideByIdx[idOrText] ~= nil then P.tooltipByIdx[idOrText] = tip
    else P.tooltipByText[idOrText] = tip end
end
function P.DisabledTooltip(idOrText, tip)
    if P.disabledTooltipByIdx[idOrText] ~= nil or P.hideByIdx[idOrText] ~= nil then P.disabledTooltipByIdx[idOrText] = tip
    else P.disabledTooltipByText[idOrText] = tip end
end
function P.SetThemeFolder(s)   P.themeFolderOverride = s end
function P.SetSaveFolder(s)    P.saveFolderOverride  = s end
function P.SetSaveSubFolder(s) P.saveSubFolderOverride = s end

-- internals
local __PATCH_OPTIONS, __PATCH_TOGGLES
local function safeDefault(opts) return (type(opts)=="table") and opts.Default or nil end
local function dummyOption(default)
    local o={Value=default,Transparency=0}
    function o:SetValue(v) self.Value=v end
    function o:SetValueRGB(v) self.Value=v end
    function o:GetState() return self.Value end
    function o:OnChanged(cb) self._cb=cb end
    function o:OnClick(cb) self._clk=cb end
    return o
end
local function dummyToggle(default) return dummyOption(default or false) end

local function nullControl(kind)
    local self={}
    local function ensureOpt(idx,def) if idx and __PATCH_OPTIONS then __PATCH_OPTIONS[idx]=__PATCH_OPTIONS[idx] or dummyOption(def) end end
    local function ensureTog(idx,def) if idx and __PATCH_TOGGLES then __PATCH_TOGGLES[idx]=__PATCH_TOGGLES[idx] or dummyToggle(def) end end
    function self:AddColorPicker(idx,opts) ensureOpt(idx,safeDefault(opts)); return self end
    function self:AddKeyPicker(idx,opts)   ensureOpt(idx,false); return self end
    function self:AddToggle(idx,opts)      ensureTog(idx,safeDefault(opts)); return self end
    self.AddCheckbox=self.AddToggle
    function self:AddSlider(idx,opts)      ensureOpt(idx,safeDefault(opts)); return self end
    function self:AddInput(idx,opts)       ensureOpt(idx,safeDefault(opts)); return self end
    function self:AddDropdown(idx,opts)    ensureOpt(idx,safeDefault(opts)); return self end
    function self:AddLabel(...)            return self end
    function self:AddButton(...)           return self end
    function self:AddDivider()             end
    return setmetatable(self,{__tostring=function() return "<Hidden:"..(kind or "Control")..">" end,
        __index=function(_,_) return function() return self end end})
end

-- fake groupbox used on hidden tabs
local function makeFakeGroupbox(Options,Toggles)
    local GB={}
    local function hidden(kind,idx,opts)
        local def=safeDefault(opts)
        if idx then
            if (kind=="Toggle" or kind=="Checkbox") and Toggles then Toggles[idx]=Toggles[idx] or dummyToggle(def)
            elseif Options then Options[idx]=Options[idx] or dummyOption(def) end
        end
        return nullControl(kind)
    end
    local function make(addName,kind)
        GB[addName]=function(_,a,b)
            local idx,opts=a,b
            if addName=="AddLabel" then
                -- Signatures: AddLabel(text, [wrapBool]) OR AddLabel(idx, {Text=...})
                if type(a)=="string" and (b==nil or type(b)=="boolean") then
                    -- plain text label: don't create bogus Options entry
                    return hidden("Label", nil, nil)
                end
                if type(idx)=="table" then opts=idx idx=nil end
                return hidden("Label", idx, opts)
            else
                if type(idx)=="table" then opts=idx idx=nil end
                return hidden(kind, idx, opts)
            end
        end
    end
    make("AddToggle","Toggle"); make("AddCheckbox","Checkbox"); make("AddButton","Button")
    -- special AddLabel handling done above in make()
    make("AddLabel","Label"); GB.AddDivider=function() end
    make("AddSlider","Slider"); make("AddInput","Input"); make("AddDropdown","Dropdown")
    make("AddColorPicker","ColorPicker"); make("AddKeyPicker","KeyPicker")
    return GB
end

-- wrap real groupboxes for per-control hide/rename/tooltip (with label overloads)
local function wrapGroupbox(gb,Options,Toggles)
    local function wrapAdd(addName,kind,isToggle)
        if addName=="AddLabel" then return end -- handled separately
        if type(gb[addName])~="function" then return end
        local _a=gb[addName]
        gb[addName]=function(gbo,idx_or_opts,maybe_opts)
            local idx,opts=idx_or_opts,maybe_opts; local text
            if type(idx)=="table" then opts=idx idx=nil end
            if type(opts)=="table" then
                text=opts.Text or opts.Title
                if idx and P.renameByIdx[idx] then
                    if opts.Text then opts.Text=P.renameByIdx[idx] elseif opts.Title then opts.Title=P.renameByIdx[idx] end
                elseif text and P.renameByText[text] then
                    local nt=P.renameByText[text]; if opts.Text then opts.Text=nt elseif opts.Title then opts.Title=nt end
                end
                if idx and P.tooltipByIdx[idx] then opts.Tooltip = P.tooltipByIdx[idx] end
                if text and P.tooltipByText[text] then opts.Tooltip = P.tooltipByText[text] end
                if idx and P.disabledTooltipByIdx[idx] then opts.DisabledTooltip = P.disabledTooltipByIdx[idx] end
                if text and P.disabledTooltipByText[text] then opts.DisabledTooltip = P.disabledTooltipByText[text] end
            end
            if (idx and P.hideByIdx[idx]) or (text and P.hideByText[text]) then
                local def=safeDefault(opts)
                if isToggle and idx then if Toggles then Toggles[idx]=Toggles[idx] or dummyToggle(def) end
                elseif idx then if Options then Options[idx]=Options[idx] or dummyOption(def) end end
                return nullControl(kind)
            end
            return _a(gbo,idx,opts)
        end
    end

    -- Special wrapper for AddLabel to support both overloads
    if type(gb.AddLabel)=="function" then
        local _L = gb.AddLabel
        gb.AddLabel = function(gbo, a, b, c)
            -- Overload 1: AddLabel(text, [wrapBool])
            if type(a)=="string" and (b==nil or type(b)=="boolean") and c==nil then
                local text = a
                if P.hideByText[text] then return nullControl("Label") end
                local newText = P.renameByText[text] or text
                return _L(gbo, newText, b)
            end
            -- Overload 2: AddLabel(idx, { Text=..., DoesWrap=... })
            local idx, opts = a, b
            if type(idx)=="table" then opts=idx idx=nil end
            opts = type(opts)=="table" and opts or {}
            local visible = opts.Text or opts.Title
            if idx and P.renameByIdx[idx] then
                if opts.Text then opts.Text=P.renameByIdx[idx] elseif opts.Title then opts.Title=P.renameByIdx[idx] end
                visible = opts.Text or opts.Title
            end
            if visible and P.renameByText[visible] then
                local nt=P.renameByText[visible]; if opts.Text then opts.Text=nt elseif opts.Title then opts.Title=nt end
                visible = nt
            end
            if (idx and P.hideByIdx[idx]) or (visible and P.hideByText[visible]) then
                if idx and Options then Options[idx]=Options[idx] or dummyOption(opts.Default) end
                return nullControl("Label")
            end
            -- tooltips (labels rarely use these, but support if provided)
            if idx and P.tooltipByIdx[idx] then opts.Tooltip = P.tooltipByIdx[idx] end
            if visible and P.tooltipByText[visible] then opts.Tooltip = P.tooltipByText[visible] end
            if idx and P.disabledTooltipByIdx[idx] then opts.DisabledTooltip = P.disabledTooltipByIdx[idx] end
            if visible and P.disabledTooltipByText[visible] then opts.DisabledTooltip = P.disabledTooltipByText[visible] end
            return _L(gbo, idx, opts)
        end
    end

    wrapAdd("AddToggle","Toggle",true)
    wrapAdd("AddCheckbox","Checkbox",true)
    wrapAdd("AddButton","Button")
    wrapAdd("AddSlider","Slider")
    wrapAdd("AddInput","Input")
    wrapAdd("AddDropdown","Dropdown")
    wrapAdd("AddColorPicker","ColorPicker")
    wrapAdd("AddKeyPicker","KeyPicker")
    return gb
end

-- patch managers (ThemeManager/SaveManager) when they are loadstring'd
local function patchManager(obj)
    if type(obj) ~= "table" then return end
    if type(obj.SetFolder)=="function" and type(obj.ApplyToTab)=="function" then
        local _set = obj.SetFolder
        obj.SetFolder = function(self, path, ...) local use = (P.themeFolderOverride ~= nil) and P.themeFolderOverride or path; return _set(self, use, ...) end
        getgenv().__THEME_MANAGER = obj
    end
    if type(obj.SetFolder)=="function" and type(obj.SetSubFolder)=="function" then
        local _sf  = obj.SetFolder
        local _ssf = obj.SetSubFolder
        obj.SetFolder = function(self, path, ...) local use = (P.saveFolderOverride ~= nil) and P.saveFolderOverride or path; return _sf(self, use, ...) end
        obj.SetSubFolder = function(self, sub, ...) local use = (P.saveSubFolderOverride ~= nil) and P.saveSubFolderOverride or sub; return _ssf(self, use, ...) end
        getgenv().__SAVE_MANAGER = obj
    end
end

-- patch the library after it loads
local _orig_loadstring=loadstring
loadstring=function(src)
    local compiled=_orig_loadstring(src)
    if type(compiled)~="function" then return compiled end
    return function(...)
        local lib=compiled(...)
        patchManager(lib)
        if type(lib)~="table" or type(lib.CreateWindow)~="function" then return lib end

        local Options=lib.Options or getgenv().Options or {}
        local Toggles=lib.Toggles or getgenv().Toggles or {}
        __PATCH_OPTIONS,__PATCH_TOGGLES=Options,Toggles

        local function wrapGroupboxMakers(tab)
            local function wrap(sideAdder)
                if type(tab[sideAdder])~="function" then return end
                local orig=tab[sideAdder]
                tab[sideAdder]=function(t, title, icon, ...)
                    local mappedTitle = (type(title)=="string" and (P.renameGroupboxes[title] or title)) or title
                    local hide = (type(title)=="string") and (P.hideGroupboxes[title] or P.hideGroupboxes[mappedTitle] or P.hideByText[title]) or false
                    if hide then return makeFakeGroupbox(Options,Toggles) end
                    local forcedIcon = (type(mappedTitle)=="string") and P.groupboxIcons[mappedTitle]
                    local gb = (forcedIcon ~= nil) and orig(t, mappedTitle, forcedIcon, ...) or orig(t, mappedTitle, icon, ...)
                    return wrapGroupbox(gb, Options, Toggles)
                end
            end
            wrap("AddLeftGroupbox"); wrap("AddRightGroupbox")
            if type(tab.AddTabbox)=="function" then
                local _tb=tab.AddTabbox
                tab.AddTabbox=function(t, ...)
                    local tb=_tb(t, ...)
                    if type(tb.AddTab)=="function" then
                        local _add=tb.AddTab
                        tb.AddTab=function(tbself, subName, ...)
                            local sub=_add(tbself, subName, ...)
                            return wrapGroupbox(sub, Options, Toggles)
                        end
                    end
                    return tb
                end
            end
        end

        local _CreateWindow=lib.CreateWindow
        lib.CreateWindow=function(self,cfg)
            if type(cfg)=="table" then
                if P.windowTitleOverride  ~= nil then cfg.Title  = P.windowTitleOverride  end
                if P.windowFooterOverride ~= nil then cfg.Footer = P.windowFooterOverride end
                if P.windowIconOverride   ~= nil then cfg.Icon   = P.windowIconOverride   end
            end

            local window=_CreateWindow(self,cfg)

            local _AddTab=window.AddTab
            window.AddTab=function(win, name, icon, ...)
                local mapped = P.renameTabs[name] or name
                local hidden = P.skipTabs[name] or P.skipTabs[mapped]
                if hidden then
                    local fake={}
                    function fake:AddLeftGroupbox(...)  return makeFakeGroupbox(Options,Toggles) end
                    function fake:AddRightGroupbox(...) return makeFakeGroupbox(Options,Toggles) end
                    function fake:AddTabbox(...) return { AddTab=function() return makeFakeGroupbox(Options,Toggles) end } end
                    function fake:UpdateWarningBox() end
                    return fake
                end
                local forcedIcon = P.tabIcons[mapped]
                local realTab = (forcedIcon ~= nil) and _AddTab(win, mapped, forcedIcon, ...) or _AddTab(win, mapped, icon, ...)
                wrapGroupboxMakers(realTab)
                return realTab
            end

            if type(window.AddKeyTab)=="function" then
                local _AddKeyTab=window.AddKeyTab
                window.AddKeyTab=function(win, name, icon, ...)
                    local mapped = P.renameTabs[name] or name
                    local hidden = P.skipTabs[name] or P.skipTabs[mapped]
                    if hidden then
                        local fake={}
                        function fake:AddLeftGroupbox(...)  return makeFakeGroupbox(Options,Toggles) end
                        function fake:AddRightGroupbox(...) return makeFakeGroupbox(Options,Toggles) end
                        function fake:AddTabbox(...) return { AddTab=function() return makeFakeGroupbox(Options,Toggles) end } end
                        function fake:UpdateWarningBox() end
                        return fake
                    end
                    local forcedIcon = P.tabIcons[mapped]
                    local realTab = (forcedIcon ~= nil) and _AddKeyTab(win, mapped, forcedIcon, ...) or _AddKeyTab(win, mapped, icon, ...)
                    wrapGroupboxMakers(realTab); return realTab
                end
            end

            return window
        end
        return lib
    end
end
--============================== end patch =====================================


-- Example usage (set BEFORE your UI builds)
UIPATCH.HideTab("SUS")
UIPATCH.HideTab("Debug")
UIPATCH.SetTitle("Archived")
UIPATCH.SetFooter("Cerberus | Premium Scripts")
UIPATCH.SetIcon(136497541793809)
UIPATCH.SetTabIcon("Home", "home")                 -- lucide name or asset id
UIPATCH.SetGroupboxIcon("ESP", "scan")
UIPATCH.HideText("Random Stuff")                   -- hide a control by visible text
UIPATCH.HideGroupbox("Main ESP")                   -- remove entire groupbox
UIPATCH.RenameGroupbox("Player ESP", "ESP")       
UIPATCH.SetThemeFolder("Cerberus")
UIPATCH.SetSaveFolder("Cerberus/Archived")
UIPATCH.SetSaveSubFolder("Archived")
UIPATCH.HideText("BOOBS")
UIPATCH.Hide("Remove Clothes")
UIPATCH.HideText("Stop saying it doest work, of course it doesnt there is NO ANIMATIONS YET, you gott make one yourself using the auto parry builder, and I AM NOT GONNA BOTHER MAKING A FULL AUTO PARRY CUZ IT TAKES FUCKING AGES TO DO.")
loadstring(game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/archived.lua"))()
