local GUI = require('gui')
local paths = require('paths')
local system = require('system')
local event = require('event')
local ser = require('serialization')
local image = require('image')
local fs = require('filesystem')
local OE = require('opengames')
local compressor = require('compressor')
local lc = system.getCurrentScriptLocalization()
local userSettings = system.getUserSettings()
if not userSettings.OpenGames then
		system.saveUserSettings()
end
gamepath = ''
local cr1, cr2,cr3,cr4 = userSettings.cr1 or 0x989898, userSettings.cr2 or 0x505050,userSettings.cr3 or 0x000000,userSettings.cr4 or 0x757575
treemode = 'screen'
game = {scripts = {},window = {abn = userSettings.windowABN or true,type = 'window',width=userSettings.windowWidth or 80,height= userSettings.windowHeight or 40,title = userSettings.windowTitle or 'Title',color = userSettings.windowColor or cr4,titleColor = userSettings.windowTitleColor or cr2},screen = {buffer = {window={}}},storage={}}

wk,win,menu = system.addWindow(GUI.filledWindow(0,0,160,50,0x8E8E8E))
local function changePosition(idk,fromposition,toposition)
		if idk == true then
  		game.screen[fromposition].raw:moveForward()
 	else
  		game.screen[fromposition].raw:moveBackward()
 	end
end
local title = win:addChild(GUI.text(1,1,cr2,'Editor 1.13'))
local screen = win:addChild(GUI.container(2,3,160,50))
BG = screen:addChild(GUI.panel(1,1,game.window.width,game.window.heigth,game.window.color))
TITLE = screen:addChild(GUI.text(math.floor(game.window.width/2-#game.window.title/2),1,game.window.titleColor,game.window.title))
local params = win:addChild(GUI.filledWindow(102,24,40,23,cr1))
local obj = win:addChild(GUI.filledWindow(102,2,36,20,cr1))
OE.init({editor = true,game = game,container = screen})

function hts(...)
  return ("0x%06X"):format(...)
end
function it(...)
  return params:addChild(GUI.input(...))
end
function bn(...)
  return params:addChild(GUI.button(...))
end
function tt(...)
  return params:addChild(GUI.text(...))
end
function bx(...)
  return params:addChild(GUI.comboBox(...))
end
function del() 
  for i = 1,#game.screen do
    if what == game.screen[i] then
    game.screen[i].raw:remove()
    table.remove(game.screen,i) 
    table.remove(game.screen.buffer,i) 
    break 
    end 
  end 
		draw() 
		drawtree() 
		drawparams(game.screen[1]) 
end
function drawparams(whatt)
  what = whatt
  params:removeChildren()
  if not what then 
    params:addChild(GUI.panel(1,1,40,27,cr1))
    return 
  end
 	if lc.close == 'Закрыть' or lc.close == 'Закрити' then
  		divide = 2
 	else
  		divide = 1
 	end
  params:addChild(GUI.panel(1,1,40,25,cr1))
  tt(3,2,cr2,'Params')
  if what.type == 'text' then
    tt(3,3,cr2,lc.type..' | '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.text)
    tt(3,8,cr2,lc.color)
    tt(3,9,cr2,lc.visible)
    tt(3,10,cr2,lc.delete)
    tt(3,11,cr2,lc.up)
    tt(3,12,cr2,lc.down)
    local tmp = bn(17,11,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,12,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,10,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 9, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
    local xx = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    xx.onInputFinished = function()
    		if xx.text ~= '' then
      		what.x = tonumber(xx.text)
     	 	draw()
     	end
    end
    local yy = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    yy.onInputFinished = function()
    		if yy.text ~= '' then
      what.y = tonumber(yy.text)
      draw()
      end
    end
    local Text = it(17, 7, 20, 1, cr1, cr2, cr3, cr1, cr2, what.text, "T")
    Text.onInputFinished = function()
       what.text = Text.text
       draw()
    end
    local color = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.color), "C")
    color.onInputFinished = function()
    		if color.text ~= '' then
      what.color = tonumber(color.text)
      draw()
      end
    end
    local name = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    name.onInputFinished = function()
      what.name = name.text
      drawtree()
    end
  elseif what.type == 'button' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.heigth)
    tt(3,8,cr2,lc.width)
    tt(3,9,cr2,lc.text)
    tt(3,10,cr2,lc.colorbg)
    tt(3,11,cr2,lc.colorbgp)
    tt(3,12,cr2,lc.colorfg)
    tt(3,13,cr2,lc.colorfgp)
    tt(3,14,cr2,lc.onTouch)
    tt(3,15,cr2,lc.mode)
    tt(3,16,cr2,lc.animated)
    tt(3,17,cr2,lc.switchMode)
    tt(3,18,cr2,lc.disabled)
    tt(3,19,cr2,lc.visible)
    tt(3,20,cr2,lc.delete)
    tt(3,21,cr2,lc.up)
    tt(3,22,cr2,lc.down)
    local tmp = bx(17, 15, 15, 1, cr1, cr2, cr1, cr2)
    if what.mode == 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.mode = 'default'
    		  draw()
    		  drawparams(what)
    		end
    		if what.prevMode == 'framedButton' then
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'framedButton'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'roundedButton'
    		  draw()
    		  drawparams(what)
    		end
    		else
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'roundedButton'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'framedButton'
    		  draw()
    		  drawparams(what)
    		end
    		end
    elseif what.mode == 'framedButton' then
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.mode = 'framedButton'
    		  draw()
    		  drawparams(what)
    		end
    		if what.prevMode == 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'default'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'roundedButton'
    		  draw()
    		  drawparams(what)
    		end
    	else
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'roundedButton'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.default).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'default'
    		  draw()
    		  drawparams(what)
    		end
    		end
    elseif what.mode == 'roundedButton' then
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.mode = 'roundedButton'
    		  draw()
    		  drawparams(what)
    		end
    		if what.prevMode == 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'default'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'framedButton'
    		  draw()
    		  drawparams(what)
    		end
     else
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'framedButton'
    		  draw()
    		  drawparams(what)
    		end
    		tmp:addItem(lc.default).onTouch = function()
    		  what.prevMode = what.mode
    		  what.mode = 'default'
    		  draw()
    		  drawparams(what)
    		end
    		end
    end
    local tmp = bx(17, 16, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.animated == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.animated = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.animated = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.animated = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.animated = true
        draw()
      end
    end
    local tmp = bx(17, 18, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.disabled == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.disabled = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.disabled = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.disabled = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.disabled = true
        draw()
      end
    end
    local tmp = bx(17, 17, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.switchMode == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.switchMode = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.switchMode = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.switchMode = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.switchMode = true
        draw()
      end
    end
    local tmp = bn(17,21,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,22,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,20,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 19, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = it(17, 9, 20, 1, cr1, cr2, cr3, cr1, cr2, what.text, "T")
    tmp.onInputFinished = function()
       what.text = tmp.text
       draw()
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorbg), "BG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorbg = tonumber(tmp.text)
      draw()
      elseif tmp.text == '{tarns}' or tmp.text == '{transparent}' then
        what.colorbg = nil
        draw()
      end
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorbgp), "BGP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorbgp = tonumber(tmp.text)
      draw()
      elseif tmp.text == '{tarns}' or tmp.text == '{transparent}' then
        what.colorbgp = nil
        draw()
      end
    end
    local tmp = it(17, 13, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorfgp), "FGP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorfgp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 12, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorfg), "FG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorfg = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1,cr1, cr2, cr3, cr1, cr2, what.height, "H")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.height = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 14, 20,1, cr1, cr2, cr3, cr1, cr2, string.gsub(what.onTouch,'.lua',''), "oT")
    tmp.onInputFinished = function()
      what.onTouch = tmp.text .. '.lua'
    end
    local tmp = it(17, 4, 20,1,cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
  elseif what.type == 'script' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,lc.path)
    tt(3,6,cr2,lc.autoload)
    tt(3,7,cr2,lc.delete)
    tt(3,8,cr2,lc.up)
    tt(3,9,cr2,lc.down)
    local tmp = bn(17,8,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,9,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,7,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = function() for i = 1,#game.scripts do if what == game.scripts[i] then table.remove(game.scripts,i) break end end draw() drawtree() drawparams(game.scripts[1]) end
    local tmp = bx(17, 6, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.autoload == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.autoload = true
       draw()
     end
     tmp:addItem(lc.falsee).onTouch = function()
        what.autoload = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.autoload = false
        draw()
      end
      tmp:addItem(lc.truee).onTouch = function()
        what.autoload = true
        draw()
      end
    end
    local tmp  = bn(17,5,#what.path,1,cr1,cr2,cr1,cr2,what.path)
    tmp.onTouch = function()
      system.execute(paths.system.applicationMineCodeIDE, what.path)
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local codeView = params:addChild(GUI.codeView(3, 11, 36, 10, 1, 1, 1, {}, {}, GUI.LUA_SYNTAX_PATTERNS, GUI.LUA_SYNTAX_COLOR_SCHEME, true, {}))
local counter = 1
for line in fs.lines(what.path) do
	line = line:gsub("\t", "  "):gsub("\r\n", "\n")
	codeView.maximumLineLength = math.max(codeView.maximumLineLength, unicode.len(line))
	table.insert(codeView.lines, line)
	counter = counter + 1
	if counter > codeView.height then
		break
	end
end
  elseif what.type == 'image' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.image)
    tt(3,8,cr2,lc.visible)
    tt(3,9,cr2,lc.delete)
    tt(3,10,cr2,lc.up)
    tt(3,11,cr2,lc.down)
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.image, "I")
    tmp.onInputFinished = function()
      what.image = tmp.text
      draw()
    end
    local tmp = bn(17,10,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,11,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,9,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 8, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tonumber(tmp.text)
      draw()
      end
    end
  elseif what.type == 'input' then
    tt(3,3,cr2,lc.type..': | '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.heigth)
    tt(3,8,cr2,lc.width)
    tt(3,9,cr2,lc.text)
    tt(3,10,cr2,lc.ph)
    tt(3,11,cr2,lc.colorbg)
    tt(3,12,cr2,lc.colorbgp)
    tt(3,13,cr2,lc.colorfg)
    tt(3,14,cr2,lc.colorfgp)
    tt(3,15,cr2,lc.colorph)
    tt(3,16,cr2,lc.path)
    tt(3,17,cr2,lc.delete)
    tt(3,18,cr2,lc.visible)
    tt(3,19,cr2,lc.up)
    tt(3,20,cr2,lc.down)
    local tmp = bn(17,19,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,20,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,17,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(16, 18, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
    local tmp = it(17, 15, 20, 1, cr1, cr2, cr3, cr1, cr2, hts(what.colorph), "PH")
    tmp.onInputFinished = function()
      what.colorph =tonumber(tmp.text)
      draw()
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = it(17, 9, 20, 1, cr1, cr2, cr3, cr1, cr2, what.text, "T")
    tmp.onInputFinished = function()
       what.text = tmp.text
       draw()
    end
    local tmp = it(17, 10, 20, 1, cr1, cr2, cr3, cr1, cr2, what.textph, "T")
    tmp.onInputFinished = function()
       what.textph = tmp.text
       draw()
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorbg), "BG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorbg = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 12, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorbgp), "BGP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorbgp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 14, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorfgp), "FGP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorfgp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 13, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorfg), "FG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorfg = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.height, "H")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.height = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 16, 20,1, cr1, cr2, cr3, cr1, cr2, string.gsub(what.onInputEnded,'.lua',''), "oT")
    tmp.onInputFinished = function()
      what.onInputEnded = tmp.text .. '.lua'
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
  elseif what.type == 'switch' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.colorp)
    tt(3,9,cr2,lc.colors)
    tt(3,10,cr2,lc.colorpp)
    tt(3,11,cr2,lc.path)
    tt(3,12,cr2,lc.state)
    tt(3,13,cr2,lc.visible)
    tt(3,14,cr2,lc.delete)
    tt(3,15,cr2,lc.up)
    tt(3,16,cr2,lc.down)
    local tmp = bn(17,15,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,16,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 4, 5,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = bn(17,14,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 13, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, string.gsub(what.onStateChanged,'.lua',''), "oSC")
    tmp.onInputFinished = function()
      what.onStateChanged = tmp.text .. '.lua'
      draw()
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorp), "P")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colors), "S")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colors = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2, hts(what.colorpp), "PP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorpp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = bx(17, 12, #lc.falsee/divide+2, 1,cr1, cr2, cr1,cr2)
    if what.state == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.state = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.state = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.state = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.state = true
        draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
  elseif what.type == 'window' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.width)
    tt(3,5,cr2,lc.heigth)
    tt(3,6,cr2,lc.title)
    tt(3,7,cr2,lc.titleColor)
    tt(3,8,cr2,lc.color)
    tt(3,9,cr2,lc.actionbuttons)
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
          drawtree()
          end
    end
    local tmp = it(17, 5, 20,1, cr1, cr2, cr3, cr1, cr2, what.height, "H")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.height = tonumber(tmp.text)
      draw()
          drawtree()
          end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.color), "C")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.color = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.titleColor), "CT")
    tmp.onInputFinished = function()
      what.titleColor = tonumber(tmp.text)
      draw()
    end
    local tmp = it(17, 6, 20,1, cr1, cr2, cr3, cr1, cr2,  what.title, "T")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.title = tmp.text
      draw()
      end
    end
    local tmp = bx(17, 9, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.abn == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.abn = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.abn = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.abn = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.abn = true
        draw()
      end
    end
  elseif what.type == 'colorSelector' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.heigth)
    tt(3,9,cr2,lc.color)
    tt(3,10,cr2,lc.text)
    tt(3,11,cr2,lc.path)
    tt(3,12,cr2,lc.visible)
    tt(3,13,cr2,lc.delete)
    tt(3,14,cr2,lc.up)
    tt(3,15,cr2,lc.down)
    local tmp = bn(17,14,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,15,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, what.path, "P")
    tmp.onInputFinished = function()
      what.path = tmp.text .. '.lua'
      draw()
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2, what.text, "T")
    tmp.onInputFinished = function()
      what.text = tmp.text
      draw()
    end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.color), "C")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.color = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, what.height, "H")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.height = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = bn(17,13,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17,12, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'progressBar' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.colorp)
    tt(3,9,cr2,lc.colors)
    tt(3,10,cr2,lc.colorv)
    tt(3,11,cr2,lc.value)
    tt(3,12,cr2,lc.visible)
    tt(3,13,cr2,lc.delete)
    tt(3,14,cr2,lc.up)
    tt(3,15,cr2,lc.down)
    local tmp = bn(17,14,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,15,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, what.value, "V")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.value = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorp), "P")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colors), "S")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colors = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorv), "V")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorv = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = bn(17,13,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 12, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'comboBox' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.elh)
    tt(3,9,cr2,lc.colorbg)
    tt(3,10,cr2,lc.colort)
    tt(3,11,cr2,lc.colorabg)
    tt(3,12,cr2,lc.colorat)
    tt(3,13,cr2,lc.items)
    tt(3,14,cr2,lc.visible)
    tt(3,15,cr2,lc.delete)
    tt(3,16,cr2,lc.up)
    tt(3,17,cr2,lc.down)
    local tmp = bn(17,16,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,17,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,13, 4,1, cr1, cr2, cr1, cr2, lc.show)
    tmp.onTouch = function()
      choosed = what.items[1]
      local choose = win:addChild(GUI.filledWindow(1,1,45,12,cr1))
      local function update()
      local tmp1 = choose:addChild(GUI.comboBox(2,2,20,3,cr4,cr1,cr4,cr1))
	    	if lc.close == 'Закрыть' or lc.close == 'Закрити' then
	    			divide = 2
	    	else
  		  		divide = 1
	    	end
      local tmp = choose:addChild(GUI.input(2,6, 20,1, cr1, cr2, cr3, cr1, cr2,  choosed.name, "N")) 
      tmp.onInputFinished = function()
        choosed.name = tmp.text
        draw()
      end
      local tmp = choose:addChild(GUI.comboBox(2, 10, #lc.falsee/divide+2, 1,cr4, cr1, cr4, cr1))
     if choosed.active == false then
        tmp:addItem(lc.truee).onTouch = function()
          choosed.active = false
          draw()
        end
        tmp:addItem(lc.falsee).onTouch = function()
          choosed.active = true
          draw()
        end
      else
        tmp:addItem(lc.falsee).onTouch = function()
          choosed.active =true
          draw()
        end
       tmp:addItem(lc.truee).onTouch = function()
          choosed.active = false
          draw()
        end
      end
      local tmp = choose:addChild(GUI.button(30,8,#lc.close/divide,1,cr1,cr2,cr1,cr2,lc.close))
      tmp.onTouch = function()
       choose:remove()
       draw()
      end
      local tmp = choose:addChild(GUI.input(2,8, 20, 1,cr1, cr2, cr3, cr1, cr2,  choosed.path, "P")) 
      tmp.onInputFinished = function()
        choosed.path = tmp.text
      end
        tmp1:addItem(choosed.name).onTouch = function()
         update()
        end
      for i = 1,#what.items do
        if what.items[i] ~= choosed then
        tmp1:addItem(what.items[i].name).onTouch = function()
         choosed = what.items[i]
         update()
        end
        end
      end
      local tmp = choose:addChild(GUI.button(30,2,#lc.add/divide,1,cr1,cr2,cr1,cr2,lc.add))
      tmp.onTouch = function()
        table.insert(what.items,{name='Item',path='',active=false})
        choosed = what.items[#what.items]
        update()
      end
      local tmp = choose:addChild(GUI.button(30,4,#lc.remove/divide,1,cr1,cr2,cr1,cr2,lc.remove))
      tmp.onTouch = function()
        for i = 1,#what.items do 
        if what.items[i] == choosed then
          table.remove(what.items,i)
        end end
        choosed = what.items[#what.items]
        update()
      end
    end  update() end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorbg), "BG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorbg = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colort), "T")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colort = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorabg), "ABG")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorabg = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 12, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorat), "AT")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorat = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, what.elh, "ELH")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.elh = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x =tmp.text
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = bn(17,15,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 14, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'slider' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.colorp)
    tt(3,9,cr2,lc.colorpp)
    tt(3,10,cr2,lc.colorv)
    tt(3,11,cr2,lc.minv)
    tt(3,12,cr2,lc.maxv)
    tt(3,13,cr2,lc.value)
    tt(3,14,cr2,lc.path)
    tt(3,15,cr2,lc.visible)
    tt(3,16,cr2,lc.delete)
    tt(3,17,cr2,lc.up)
    tt(3,18,cr2,lc.down)
    local tmp = bn(17,17,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,18,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 14, 20,1, cr1, cr2, cr3, cr1, cr2, what.path, "P")
    tmp.onInputFinished = function()
      what.path = tmp.text .. '.lua'
      draw()
    end
    local tmp = it(17, 11, 20,1, cr1, cr2, cr3, cr1, cr2, what.minv, "MINV")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.minv = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 12, 20,1, cr1, cr2, cr3, cr1, cr2, what.maxv, "MAXV")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.maxv = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 13, 20,1, cr1, cr2, cr3, cr1, cr2, what.value, "V")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.value = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorp), "P")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorpp), "PP")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorpp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 10, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorv), "V")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorv = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tmp.text
      draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = bn(17,16,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 15, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'progressIndicator' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.colorpa)
    tt(3,8,cr2,lc.colorp)
    tt(3,9,cr2,lc.colors)
    tt(3,10,cr2,lc.visible)
    tt(3,11,cr2,lc.delete)
    tt(3,12,cr2,lc.up)
    tt(3,13,cr2,lc.down)
    local tmp = bn(17,12,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,13,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorpa), "PA")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorpa = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colorp), "P")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colorp = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.colors), "S")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.colors = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = bn(17,11,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 10, #lc.falsee/divide+2, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'panel' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,'X')
    tt(3,6,cr2,'Y')
    tt(3,7,cr2,lc.width)
    tt(3,8,cr2,lc.heigth)
    tt(3,9,cr2,lc.color)
    tt(3,10,cr2,lc.visible)
    tt(3,11,cr2,lc.delete)
    tt(3,12,cr2,lc.up)
    tt(3,13,cr2,lc.down)
    local tmp = it(17, 9, 20,1, cr1, cr2, cr3, cr1, cr2,  hts(what.color), "S")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.color = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 7, 20,1, cr1, cr2, cr3, cr1, cr2, what.width, "W")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.width = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 8, 20,1, cr1, cr2, cr3, cr1, cr2, what.height, "H")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.height = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = bn(17,12,6,1,cr1,cr2,cr1,cr2,lc.up)
    tmp.onTouch = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(true,i,i-1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = bn(17,13,6,1,cr1,cr2,cr1,cr2,lc.down)
    tmp.onTouch  = function()
      for i = 1,#game.screen do
        if game.screen[i] == what then
          changePosition(false,i,i+1)
          draw()
          drawtree()
          break
        end
      end
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
    end
    local tmp = it(17, 5, 5, 1, cr1, cr2, cr3, cr1, cr2, what.x, "X")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.x = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = it(17, 6, 5, 1, cr1, cr2, cr3, cr1, cr2, what.y, "Y")
    tmp.onInputFinished = function()
    		if tmp.text ~= '' then
      what.y = tonumber(tmp.text)
      draw()
      end
    end
    local tmp = bn(17,11,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = del
    local tmp = bx(17, 10, 5, 1,cr1, cr2, cr1, cr2)
    if what.visible == true then
      tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        what.visible = false
        draw()
      end
     tmp:addItem(lc.truee).onTouch = function()
        what.visible = true
        draw()
      end
    end
  elseif what.type == 'file' then
    tt(3,3,cr2,lc.type..': '..what.type)
    tt(3,4,cr2,lc.name)
    tt(3,5,cr2,lc.path)
    tt(3,6,cr2,lc.delete)
    local tmp = params:addChild(GUI.filesystemChooser(17, 5, 20, 1,cr1, cr2, cr1, cr2, nil, lc.open, lc.close, string.gsub(what.path,fs.extension(what.path) or '',''), "/"))
    tmp:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_FILE)
    tmp.onSubmit = function(path)
      what.path = path
      drawtree()
      drawparams(what)
      local tmp = find(game.screen.buffer,what.name)
      if tmp then
      		tmp.buffer.visible = false
      end
      draw()
    end
    local tmp = it(17, 4, 20,1, cr1, cr2, cr3, cr1, cr2, what.name, "N")
    tmp.onInputFinished = function()
      what.name = tmp.text
      drawtree()
      draw()
    end
    if fs.extension(what.path) == '.pic' then
    		local tmp = params:addChild(GUI.container(3,8,36,13))
    		tmp:addChild(GUI.panel(1,1,36,14,0x808080))
    		tmp:addChild(GUI.image(1,1,image.load(what.path)))
    end
    local tmp = bn(17,6,6,1,cr1,cr2,cr1,cr2,lc.delete)
    tmp.onTouch = function () for i = 1,#game.storage do if what == game.storage[i] then table.remove(game.storage,i) break end end draw() drawtree() drawparams(game.storage[1]) end
  else
    tt(1,1,cr2,lc.WYC)
  end
end
function objectmenu()
		if lc.close == 'Закрыть' or lc.close == 'Закрити' then
				divide = 2
		else
				divide = 1
		end
  choose = win:addChild(GUI.filledWindow(55,20,50,20,cr1))
  choose.actionButtons.close.onTouch = function() choose:remove() end
  if treemode == 'screen' then
  local tmp = choose:addChild(GUI.button(6,14,#lc.panel/divide,1,cr1,cr2,cr1,cr2,lc.panel))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.panelVisible or true,type = 'panel',x=userSettings.panelX or 1,y=userSettings.panelY or 1,color=userSettings.color or cr1,width = userSettings.panelWidth or 10,height=  userSettings.panelHeigth or 10,name = userSettings.panelName or 'Panel'})
  end
  local tmp = choose:addChild(GUI.button(6,4,#lc.text/divide,1,cr1,cr2,cr1,cr2,lc.text))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible =userSettings.textVisible or true,type = 'text',x=userSettings.textX or 1,y=userSettings.textY or 1,color=userSettings.textColor or cr2,text=userSettings.textText or 'Text',name = userSettings.textName or 'Text'})
  end
  local tmp = choose:addChild(GUI.button(25,6,#lc.progressBar/divide,1,cr1,cr2,cr1,cr2,lc.progressBar))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.progressBarVisible or true,width=userSettings.progressBarWidth or 20,colorp = userSettings.progressBarColorP or cr1,colors=userSettings.progressBarColorS or cr2,colorv=userSettings.progressBarColorV or cr2,type = 'progressBar',x=userSettings.progessBarX or 1,y=userSettings.progressBarY or 1,color= userSettings.progressBarColor or cr1,value=userSettings.progressBarValue or 50,name = userSettings.progressBarname or 'ProgressBar'})
  end
  local tmp = choose:addChild(GUI.button(25,8,#lc.comboBox/divide,1,cr1,cr2,cr1,cr2,lc.comboBox))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.comboBoxVisible or true,type = 'comboBox',width=userSettings.comboBoxWidth or 20,x=userSettings.comboBoxX or 1,y=userSettings.comboBoxY or 1,elh=userSettings.ComboBoxELH or 3,items={{name=userSettings.comboBoxItemsName or 'Item',active = false,type='itemComboBox',path=''}},colorbg=userSettings.comboBoxColorBG or cr1,colort=userSettings.comboBoxColorT or cr2,colorabg=userSettings.comboBoxColorABG or cr1,colorat=userSettings.comboBoxColorAT or cr2,name = userSettings.comboBoxName or 'ComboBox'})
  end
  local tmp = choose:addChild(GUI.button(7,18,#lc.slider/divide,1,cr1,cr2,cr1,cr2,lc.slider))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.sliderVisible or true,type = 'slider',x=userSettings.sliderX or 1,y=userSettings.sliderY or 1,width=userSettings.sliderWidth or 20,colorp=userSettings.sliderColorP or cr1,colors=userSettings.sliderColorS or cr2,colorpp=userSettings.sliderColorPP or cr1,colorv=userSettings.sliderColorV or cr2,minv=userSettings.sliderMinv or 1,maxv=userSettings.sliderMaxv or 100,value=userSettings.sliderValue or 50,text=userSettings.sliderText or 'Slider',name = userSettings.sliderName or 'Slider'})
  end
  local tmp = choose:addChild(GUI.button(25,4,#lc.progressIndicator/divide,1,cr1,cr2,cr1,cr2,lc.progressIndicator))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.piVisible or true,type = 'progressIndicator',x=userSettings.piX or 1,y=userSettings.piY or 1,active=userSettings.piActive or false,rollStage=userSettings.piRollStage or 1,colorp= userSettings.piColorP or cr1,colors=userSettings.piColorS or cr2,colorpa=userSettings.piColorPA or cr3,name = userSettings.piName or 'pI'})
  end
  local tmp = choose:addChild(GUI.button(7,16,#lc.collorSelector/divide,1,cr1,cr2,cr1,cr2,lc.collorSelector))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.csVisible or true,path='',type = 'colorSelector',color=userSettings.csColor or 0xFF00FF,x=userSettings.csX or 1,y=userSettings.csY or 1,width=userSettings.csWidth or 20,height=userSettings.csHeight or 3,text=userSettings.csText or 'Color Selector',name = userSettings.csName or 'ColorSelector'})
  end
  local tmp = choose:addChild(GUI.button(6,10,#lc.input/divide,1,cr1,cr2,cr1,cr2,lc.input))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.inputVisible or true,onInputEnded = '',width=userSettings.inputWidth or 20,height=userSettings.inputHeight or 3,colorbg = userSettings.inputColorBG or cr1,colorfg = userSettings.inputColorFG or cr2,colorfgp = userSettings.inputColorFGP or cr1,colorbgp = userSettings.inputColorBGP or cr4,colorph=userSettings.inputColorPH or 0x2D2D2D,type = 'input',x=userSettings.inputX or 1,y=userSettings.inputY or 1,name = userSettings.inputName or 'Input',text = userSettings.inputText or 'Input',textph = userSettings.inputTextPH or 'Text'})
  end
  local tmp = choose:addChild(GUI.button(6,12,#lc.switch/divide,1,cr1,cr2,cr1,cr2,lc.switch))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{onStateChanged = userSettings.switchonStateChanged or '', visible =userSettings.switchVisible or true,state=userSettings.switchState or false,type = 'switch',x=userSettings.switchX or 1,y=userSettings.switchY or 1,width=userSettings.switchWidth or 8,colorp= userSettings.switchColorP or cr2, colors=userSettings.switchColorS or cr2,colorpp=userSettings.switchColorPP or cr1,name = userSettings.switchName or 'Switch'})
  end
  local tmp = choose:addChild(GUI.button(6,8,#lc.image/divide,1,cr1,cr2,cr1,cr2,lc.image))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.imageVisible or true, type = 'image',x=userSettings.imageX or 1,y=userSettings.imageY or 1,image=userSettings.imageImage or 'StorageEl',name = userSettings.imageName or 'image',path = userSettings.imagePath or 'Script'})
  end
  local tmp = choose:addChild(GUI.button(6,6,#lc.button/divide,1,cr1,cr2,cr1,cr2,lc.button))
  tmp.onTouch = function()
    choose:remove()
    new(game.screen,{visible = userSettings.buttonVisible or true,onTouch = userSettings.buttonOnTouch or '', height = userSettings.buttonHeight or 3,width = userSettings.buttonWidth or 20, animated = userSettings.buttonAnimated or true, disabled = userSettings.buttonDisabled or false, prevMode = userSettings.buttonsPrevMode or 'roundedButton', switchMode = userSettings.buttonSwitchMode or false, mode = userSettings.buttonMode or 'default', type = 'button',x= userSettings.buttonX or 1,y=userSettings.buttonY or 1,name = userSettings.buttonName or 'button',colorbg= userSettings.buttonColorBG or cr1,colorfg = userSettings.buttonColorFG or cr2,colorbgp = userSettings.buttonColorBGP or cr2,colorfgp= userSettings.buttonColorFGP or cr1,text=userSettings.buttonText or 'Button'})
  end
  elseif treemode == 'script' then
    local tmp = choose:addChild(GUI.button(6,4,#lc.script/divide,1,cr1,cr2,cr1,cr2,lc.script))
    tmp.onTouch = function()
      choose:remove()
      fs.write('/Temporary/'..tostring(#game.scripts+1)..'.lua',lc.DFtS)
      new(game.scripts,{autoload = userSettings.scriptAutoload or false,path = '/Temporary/'..tostring(#game.scripts+1)..'.lua',name = userSettings.scriptName or 'script',type = 'script'})
    end
    local tmp = choose:addChild(GUI.filesystemChooser(5, 6, 10, 1, cr1, cr2, cr1, cr2, nil, lc.open, lc.close, lc.choose, "/"))
    tmp.onSubmit = function(path)
    		if fs.extension(path) == '' or fs.extension(path) == '.lua' then
     		 choose:remove()
       	new(game.scripts,{autoload = userSettings.scriptAutoload or false,path = path,name = userSettings.scriptName or 'Script',type = 'script'})
      end
    end
  elseif treemode == 'storage' then
local tmp = choose:addChild(GUI.filesystemChooser(6, 4, #lc.path/divide+3, 1, cr1, cr2, cr1, cr2, nil, lc.open, lc.close, lc.path, "/"))
tmp:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_FILE)
tmp.onSubmit = function(path)
choose:remove()
    new(game.storage,{path = path,name = userSettings.storageElName or 'StorageEl',type = 'file'})
  draw()
  drawtree()
end
  end
end

function new(where,what)
  table.insert(where,what)
  for i = 1,#where do
    if where[i].name == what.name and where[i].type == what.type and where[i].x == what.x and where[i].y == what.y then
      drawparams(where[i])
    end
  end
  drawtree()
  draw()
end

function drawtree()
  obj:removeChildren()
  obj:addChild(GUI.panel(1,1,36,20,cr1))
		if lc.close == 'Закрыть' or lc.close == 'Закрити' then
				divide = 2
		else
				divide = 1
		end
		local elements = obj:addChild(GUI.container(4,4,33,17))
		local modesButtons = obj:addChild(GUI.container(1,1,36,20))
		local bg = modesButtons:addChild(GUI.panel(1,1,36,3,cr1))
  local screenmode = modesButtons:addChild(GUI.button(3,2,#lc.screen/divide,1,cr1,cr2,cr1,cr2,lc.screen))
  screenmode.onTouch = function()
    treemode = 'screen'
    drawparams(game.screen[1])
    drawtree()
  end
  local storagemode = modesButtons:addChild(GUI.button(5+#lc.screen/divide+#lc.scripts/divide,2,#lc.storage/divide,1,cr1,cr2,cr1,cr2,lc.storage))
  storagemode.onTouch = function()
    treemode = 'storage'
    drawparams(game.storage[1])
    drawtree()
  end
  local scriptmode = modesButtons:addChild(GUI.button(4+#lc.screen/divide,2,#lc.scripts/divide,1,cr1,cr2,cr1,cr2,lc.scripts))
  scriptmode.onTouch = function()
    treemode = 'script'
    drawparams(game.scripts[1])
    drawtree()
  end
  if treemode == 'screen' then
    local tmp = modesButtons:addChild(GUI.button(3,3,#lc.screen/divide,1,cr1,cr2,cr1,cr2,lc.screen))
    tmp.onTouch = function()
       drawparams(game.window)
    end
    local addScreen = modesButtons:addChild(GUI.button(#lc.screen/divide+4,3,1,1,cr1,cr2,cr1,cr2,'+'))
    addScreen.onTouch = function()
      objectmenu()
    end
    y = 1
    for i = 1,#game.screen do
      tmp = elements:addChild(GUI.button(1,y,#game.screen[i].name,1,cr1,cr2,cr1,cr2, game.screen[i].name))
      tmp.onTouch = function()
        drawparams(game.screen[i])
      end
      y = y + 1
    end
  elseif treemode == 'script' then
   modesButtons:addChild(GUI.text(3,3,cr2,lc.scripts))
   local addScreen = modesButtons:addChild(GUI.button(#lc.scripts/divide+4,3,1,1,cr1,cr2,cr1,cr2,'+'))
    addScreen.onTouch = function()
      objectmenu()
    end
    y = 1
    for i = 1,#game.scripts do
      tmp = elements:addChild(GUI.button(1,y,#game.scripts[i].name,1,cr1,cr2,cr1,cr2, game.scripts[i].name))
      tmp.onTouch = function()
        drawparams(game.scripts[i])
      end
      y = y + 1
    end
  elseif treemode == 'storage' then
   modesButtons:addChild(GUI.text(3,3,cr2,lc.storage))
   local addScreen = modesButtons:addChild(GUI.button(#lc.storage/divide+4,3,1,1,cr1,cr2,cr1,cr2,'+'))
    addScreen.onTouch = function()
      objectmenu()
    end
    y = 1
    for i = 1,#game.storage do
      tmp = elements:addChild(GUI.button(1,y,#game.storage[i].name,1,cr1,cr2,cr1,cr2, game.storage[i].name))
      tmp.onTouch = function()
        drawparams(game.storage[i])
      end
      y = y + 1
    end
  end
end
local function save(path)
		gamepath = path
  fs.makeDirectory('/Temporary/ProjectSave')
  local idk = {}
		  local tmpgame = table.copy(game)
		  for i = 1,#tmpgame.screen do
		  		tmpgame.screen[i].raw = nil
		  		tmpgame.screen.buffer[i].raw = nil
		  		tmpgame.screen.buffer[i].visible = false
		  end
    fs.writeTable('/Temporary/ProjectSave/Game.dat',tmpgame)
		  tmpgame = nil
  for i = 1,#game.storage do
  		table.insert(idk,'/Temporary/ProjectSave/' ..fs.name(game.storage[i].path))
    fs.copy(game.storage[i].path,'/Temporary/ProjectSave/' ..fs.name(game.storage[i].path))
  end
  for i = 1,#game.scripts do
  		table.insert(idk,'/Temporary/ProjectSave/' ..fs.name(game.scripts[i].path))
    fs.copy(game.scripts[i].path,'/Temporary/ProjectSave/'..fs.name(game.scripts[i].path))
  end
  compressor.pack(path..'.pkg',idk)
end
local function saveAsWindow ()
		local tmp = GUI.addFilesystemDialog(wk,true,50, 30, lc.save,lc.cancel,lc.name,'/')
	 tmp:setMode(GUI.IO_MODE_SAVE, GUI.IO_MODE_FILE)
		tmp.onSubmit = function(path)
		  if fs.exists(path..'.pkg') then 
		  		local winerr = win:addChild(GUI.container(60,20,60,5))
			  	if lc.close == 'Закрыть' or lc.close == 'Закрити' then
				  		divide = 2
			  	else
				  		divide = 1
			  	end
		  		winerr:addChild(GUI.panel(1,1,#lc.YNEF,5,0xAAAAAA))
		  		winerr:addChild(GUI.text(2,2,cr1,lc.YNEF))
		  		winerr:addChild(GUI.button(2,4,2+#lc.save/divide,1,cr1,cr2,cr1,cr2,lc.save)).onTouch = function()
		 				 save(path)
		 				 winerr:remove()
		    end
		  		winerr:addChild(GUI.button(4+#lc.YNEF/divide-#lc.cancel/divide-3,4,#lc.cancel/divide+3,1,cr1,cr2,cr1,cr2,lc.close)).onTouch = function()
		 				  winerr:remove()
		 				  return 
		 				  end
		  else
		  		save(path)
		  end
		  draw()
		  drawtree()
		end
	tmp:show()
end
local function new()
		treemode = 'screen'
		game = {scripts = {},window = {abn = userSettings.windowABN or true,type = 'window',width=userSettings.windowWidth or 80,heigth= userSettings.windowHeight or 40,title = userSettings.windowTitle or 'Title',color = userSettings.windowColor or cr4,titleColor = userSettings.windowTitleColor or cr2},screen = {},storage={}}
		draw()
		drawtree()
		drawparams()
end
local function saveOrPass(onEnd,arg1)
		 	if lc.close == 'Закрыть' or lc.close == 'Закрити' then
		  		divide = 2
		 	else
		  		divide = 1
		 	end
				local winerr = win:addChild(GUI.container(60,20,#lc.saveToPath/divide+5+4+#lc.close/divide+3+4+#lc.save/divide+2+#lc.withoutSave/divide+4,5))
				winerr:addChild(GUI.panel(1,1,#lc.saveToPath/divide+5+4+#lc.close/divide+3+4+#lc.save/divide+2+#lc.withoutSave/divide+4,5,0xAAAAAA))
				winerr:addChild(GUI.text(2,2,cr1,lc.NF))
				winerr:addChild(GUI.button(2,4,#lc.saveToPath/divide+5,1,cr1,cr2,cr1,cr2,lc.saveToPath)).onTouch = function()
					 saveAsWindow()
					 winerr:remove()
					 onEnd(arg1)
		  end
		  if gamepath ~= '' then
						winerr:addChild(GUI.button(#lc.saveToPath/divide+5+4,4,2+#lc.save/divide,1,cr1,cr2,cr1,cr2,lc.save)).onTouch = function()
							 save(gamepath)
							 winerr:remove()
							 onEnd(arg1)
				  end
		  end
				winerr:addChild(GUI.button(#lc.saveToPath/divide+5+4+#lc.save/divide+4,4,#lc.close/divide+3,1,cr1,cr2,cr1,cr2,lc.close)).onTouch = function()
				  winerr:remove()
		  end
				winerr:addChild(GUI.button(#lc.saveToPath/divide+5+4+#lc.close/divide+3+4+#lc.save/divide+2,4,#lc.withoutSave/divide+5,1,cr1,cr2,cr1,cr2,lc.withoutSave)).onTouch = function()
				  winerr:remove()
				  onEnd(arg1)
		  end
end
local contextMenu = menu:addContextMenuItem(lc.file)
contextMenu:addItem(lc.new,false).onTouch = function()
		if game.screen[1] == nil and game.storage[1] == nil and game.scripts[1] == nil then
				new()
		else
				saveOrPass(new)
		end
end
contextMenu:addSeparator()
contextMenu:addItem(lc.save,false).onTouch = saveAsWindow
local function open(path)
				gamepath = path
		  compressor.unpack(path,'/Temporary/')
		  path = '/Temporary/ProjectSave/'
		  if not fs.exists(path..'/Game.dat') then GUI.alert(lc.UFP) return end
		  game = fs.readTable(path..'/Game.dat')
		  idk = fs.list(path)
		  for i = 1,#idk do
		    for e = 1, #game.storage do
		      if game.storage[e].name == string.gsub(idk[i],fs.extension(idk[i]) or '','') then
		        game.storage[e].path = path..idk[i]
		      end
		    end
		    if fs.extension(idk[i]) == '.lua' then
		      for e = 1, #game.scripts do
		        if game.scripts[e].name == string.gsub(idk[i],'.lua','') then
		          game.scripts[e].path = path..idk[i]
		        end
		      end
		    end
		  end
		  for i = 1, #game.screen do
		  		if game.screen[i].type == 'button' then
		  				if not game.screen[i].animated then game.screen[i].animated = userSettings.buttonAnimated or true end
		  				if not game.screen[i].disable then game.screen[i].disable = userSettings.buttonDisable or false end
		  				if not game.screen[i].switchMode then game.screen[i].switchMode = userSettings.buttonSwitchMode or false end
		  				if not game.screen[i].mode then game.screen[i].mode = userSettings.buttonMode or 'default' end
		  				if not game.screen[i].prevMode then game.screen[i].prevMode = userSettings.buttonPrevMode or 'roundedButton' end
		  		end
		  end
		  OE = nil
		  local OE = require('opengames')
		  for i = 1,#game.screen.buffer do
		  		game.screen.buffer[i].visible = false
		  end
		  OE.init({editor = true,game = game,container = screen})
		  draw()
		  drawtree()
end
contextMenu:addItem(lc.open,false).onTouch = function()
		local tmp = GUI.addFilesystemDialog(wk,true,50, 30, lc.open,lc.cancel,lc.name,'/')
		tmp:setMode(GUI.IO_MODE_OPEN, GUI.IO_MODE_FILE)
		tmp.onSubmit = function(path)
				saveOrPass(open,path)
		end
	tmp:show()
end
contextMenu:addSeparator()
contextMenu:addItem(lc.export,false).onTouch = function()
				local tmp = GUI.addFilesystemDialog(wk,true,50, 30, lc.export,lc.cancel,lc.name,'/')
		tmp:setMode(GUI.IO_MODE_SAVE, GUI.IO_MODE_FILE)
		local function export(path)
		  local towrite = ''
		  towrite = towrite .. 'local image = require("Image")\nlocal fs = require("filesystem")\nlocal event = require("event")\nlocal GUI = require("GUI")\nlocal system = require("System")\nlocal OE = require("opengames")\nlocal gamepath = string.gsub(system.getCurrentScript(),"/Main.lua","")\ngame = fs.readTable(gamepath.."/Game.dat")\ngame.localization=system.getCurrentScriptLocalization()\nlocal wk,win,menu = system.addWindow(GUI.filledWindow(1,1,game.window.width,game.window.height,0x989898))\nwin:removeChildren()\nlocal BG = win:addChild(GUI.panel(1,1,game.window.width,game.window.height,game.window.color)) \nlocal TITLE = win:addChild(GUI.text(math.floor(game.window.width/2-#game.window.title/2),1,game.window.titleColor,game.window.title))\nOE.init({gamePath = gamepath, editor = false,game = game, container = win})\n'
		  fs.makeDirectory(path..'.app/Scripts')
		  fs.makeDirectory(path..'.app/Assets')
		  fs.makeDirectory(path..'.app/Localizations')
		  for i = 1,#game.storage do
		    if fs.extension(game.storage[i].path) == '.lang' then 
		      fs.copy(game.storage[i].path,path..'.app/Localizations/'..fs.name(game.storage[i].path)) 
		    else
		      fs.copy(game.storage[i].path,path..'.app/Assets/'..fs.name(game.storage[i].path))
		    end
		  end
		  for i = 1,#game.scripts do
		    fs.copy(game.scripts[i].path,path..'.app/Scripts/'..game.scripts[i].name..'.lua')
		  end
		  for i = 1, #game.storage do
		    if fs.extension(game.storage[i].path) == '.lang' then 
		   		 game.storage[i].path = path..'.app/Localizations/'..fs.name(game.storage[i].path)
		    else
		   		 game.storage[i].path = path..'.app/Assets/'..fs.name(game.storage[i].path)
		    end
		  end
		  for i = 1, #game.scripts do
		    game.scripts[i].path = path..'.app/Scripts/'..game.scripts[i].name..'.lua'
		  end
		  idk = nil
		  for e = 1,#game.storage do
		    if game.storage[e].name == 'Icon' and fs.extension(game.storage[e].path) == '.pic' then
		      idk = game.storage[e].path
		    end
		  end
		  if idk == nil then idk = '/Icons/Application.pic' end
		  local tmpgame = table.copy(game)
		  for i = 1,#tmpgame.screen do
		  		tmpgame.screen[i].raw = nil
		  		tmpgame.screen.buffer[i].raw = nil
		  		tmpgame.screen.buffer[i].visible = false
		  end
		  towrite = towrite .. 'draw()\n for i = 1,#game.scripts do\n if game.scripts[i].autoload == true then\n system.execute(game.scripts[i].path)\n end\n end\n'
		  fs.write(path..'.app/Main.lua',towrite)
		  fs.writeTable(path..'.app/Game.dat',tmpgame)
		  fs.copy(idk,path..'.app/Icon.pic')
		  tmpgame = nil
		end
		tmp.onSubmit = function(path)
		  if fs.exists(path..'.app') then
		  		local winerr = win:addChild(GUI.container(60,20,50,5))
			  	if lc.close == 'Закрыть' or lc.close == 'Закрити' then
			  			divide = 2
				  else
				  		divide = 1
			  	end
		  		winerr:addChild(GUI.panel(1,1,4+#lc.EF,5,0xAAAAAA))
		  		winerr:addChild(GUI.text(2,2,cr1,lc.EF))
		  		winerr:addChild(GUI.button(2,4,#lc.export/divide+2,1,cr1,cr2,cr1,cr2,lc.export)).onTouch = function()
		 				 export(path)
		 				 winerr:remove()
		    end
		  		winerr:addChild(GUI.button(4+#lc.EF/divide-#lc.cancel/divide-3,4,#lc.cancel/divide+3,1,cr1,cr2,cr1,cr2,lc.close)).onTouch = function()
		 				  winerr:remove()
		 				  return 
		 				  end
		  else
		    fs.makeDirectory(path..'.app')
		  		export(path)
		  end
		end
	tmp:show()
end
local usualParams = menu:addContextMenuItem(lc.sampleParams)
local function sampleParams()
		local tmp = usualParams:addSubMenuItem(lc.overall)
		tmp:addItem(lc.cr1).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.cr1 == nil then userSettings.cr1 = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.cr1 or cr1, hts(userSettings.cr1) or hts(cr1)))
			  tmpp.onColorSelected = function()
			    userSettings.cr1 = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.cr2).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.cr2 == nil then userSettings.cr1 = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.cr2 or cr2, hts(userSettings.cr2) or hts(cr2)))
			  tmpp.onColorSelected = function()
			    userSettings.cr2 = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.cr3).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.cr3 == nil then userSettings.cr1 = cr3 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.cr3 or cr3, hts(userSettings.cr3) or hts(cr3)))
			  tmpp.onColorSelected = function()
			    userSettings.cr3 = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.cr4).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.cr4 == nil then userSettings.cr1 = cr4 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.cr4 or cr4, hts(userSettings.cr4) or hts(cr4)))
			  tmpp.onColorSelected = function()
			    userSettings.cr4 = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowColor).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.windowColor == nil then userSettings.windowColor = cr4 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.windowColor or cr4, hts(userSettings.windowColor) or hts(cr4)))
			  tmpp.onColorSelected = function()
			    userSettings.windowColor = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowTitle).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.windowTitle) or 'Title'))
			  tmpp.onInputFinished = function()
			   userSettings.windowTitle = tmpp.text
						system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowTitleColor).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.windowTitleColor == nil then userSettings.windowTitleColor = cr4 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.windowTitleColor or cr2, hts(userSettings.windowTitleColor) or hts(cr2)))
			  tmpp.onColorSelected = function()
			    userSettings.windowTitleColor = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowWidth).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.windowWidth) or '80'))
			  tmpp.onInputFinished = function()
			   userSettings.windowHeigth = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowHeight).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.windowHeight) or '25'))
			  tmpp.onInputFinished = function()
			   userSettings.windowHeigth = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.windowABN).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(1, 1, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2))
    if userSettings.windowABN == nil then userSettings.windowABN = true end
    if userSettings.windowABN == true then
      tmp:addItem(lc.truee).onTouch = function()
        userSettings.windowABN = true
						system.saveUserSettings()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.windowABN = false
						system.saveUserSettings()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.windowABN = false
						system.saveUserSettings()
      end
     tmp:addItem(lc.truee).onTouch = function()
        userSettings.windowABN = true
						system.saveUserSettings()
      end
    end
		end
		tmp:addItem(lc.reset).onTouch = function()
				userSettings = {}
				system.saveUserSettings()
		end
		local tmp = usualParams:addSubMenuItem(lc.text)
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.textX) or '1'))
			  tmpp.onInputFinished = function()
			   userSettings.textX = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.textY) or '1'))
			  tmpp.onInputFinished = function()
			    userSettings.textY = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.textName) or 'Text'))
			  tmpp.onInputFinished = function()
			    userSettings.textName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.color).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.textColor == nil then userSettings.textColor = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.textColor or cr2, hts(userSettings.textColor) or hts(cr2)))
			  tmpp.onColorSelected = function()
			    userSettings.textColor = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.text).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.textText) or 'Text'))
			  tmpp.onInputFinished = function()
			    userSettings.textText = tmpp.text
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.button)
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.buttonX) or '1'))
			  tmpp.onInputFinished = function()
			   userSettings.buttonX = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.buttonY) or '1'))
			  tmpp.onInputFinished = function()
			    userSettings.buttonY = tonumber(tmpp.text)
						system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.buttonName) or 'Button'))
			  tmpp.onInputFinished = function()
			    userSettings.buttonName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.text).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.buttonText) or 'Text'))
			  tmpp.onInputFinished = function()
			    userSettings.buttonText = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.onTouch).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.buttonOnTouch) or 'Text'))
			  tmpp.onInputFinished = function()
			    userSettings.buttonOnTouch = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorbg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.buttonColorBG == nil then userSettings.buttonColorBG = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.buttonColorBG or cr1, hts(userSettings.buttonColorBG) or hts(cr1)))
			  tmpp.onColorSelected = function()
			    userSettings.buttonColorBG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorfg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.buttonColorFG == nil then userSettings.buttonColorFG = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.buttonColorFG or cr2, hts(userSettings.buttonColorFG) or hts(cr2)))
			  tmpp.onColorSelected = function()
			    userSettings.buttonColorFG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorbgp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.buttonColorBGP == nil then userSettings.buttonColorBGP = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.buttonColorBGP or cr2, hts(userSettings.buttonColorBGP) or hts(cr2)))
			  tmpp.onColorSelected = function()
			    userSettings.buttonColorBGP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorfgp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.buttonColorFGP == nil then userSettings.buttonColorFGP = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.buttonColorFGP or cr1, hts(userSettings.buttonColorFGP) or hts(cr1)))
			  tmpp.onColorSelected = function()
			    userSettings.buttonColorFGP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.animated).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(1, 1, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2))
    if userSettings.buttonAnimated == nil then userSettings.buttonAnimated = true end
    if userSettings.buttonAnimated == true then
      tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonAnimated = true
						system.saveUserSettings()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonAnimated = false
						system.saveUserSettings()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonAnimated = false
						system.saveUserSettings()
      end
     tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonAnimated = true
						system.saveUserSettings()
      end
    end
		end
		tmp:addItem(lc.disabled).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(1, 1, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2))
    if userSettings.buttonDisabled == nil then userSettings.buttonDisabled = true end
    if userSettings.disbuttonDisabledabled == true then
      tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonDisabled = true
						system.saveUserSettings()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonDisabled = false
						system.saveUserSettings()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonDisabled = false
						system.saveUserSettings()
      end
     tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonDisabled = true
						system.saveUserSettings()
      end
    end
		end
		tmp:addItem(lc.switch).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(1, 1, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2))
    if userSettings.buttonSwitchMode == nil then userSettings.buttonSwitchMode = true end
    if userSettings.buttonSwitchMode == true then
      tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonSwitchMode = true
						system.saveUserSettings()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonSwitchMode = false
						system.saveUserSettings()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.buttonSwitchMode = false
						system.saveUserSettings()
      end
     tmp:addItem(lc.truee).onTouch = function()
        userSettings.buttonSwitchMode = true
						system.saveUserSettings()
      end
    end
		end
		tmp:addItem(lc.mode).onTouch = function()
			 local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(17, 15, 15, 1, cr1, cr2, cr1, cr2))
    if userSettings.buttonMode == nil then userSettings.buttonMode = 'default' end
    if userSettings.buttonPrevMode == nil then userSettings.buttonPrevMode = 'roundedButton' end
    what = userSettings
    if what.buttonMode== 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.buttonMode = 'default'
						system.saveUserSettings()
    		end
    		if what.buttonPrevMode == 'framedButton' then
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'framedButton'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'roundedButton'
						system.saveUserSettings()
    		end
    		else
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'roundedButton'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'framedButton'
						system.saveUserSettings()
    		end
    		end
    elseif what.buttonMode == 'framedButton' then
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.buttonMode = 'framedButton'
						system.saveUserSettings()
    		end
    		if what.buttonPrevMode == 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'default'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'roundedButton'
						system.saveUserSettings()
    		end
    	else
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'roundedButton'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.default).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'default'
						system.saveUserSettings()
    		end
    		end
    elseif what.buttonMode == 'roundedButton' then
    		tmp:addItem(lc.roundedButton).onTouch = function()
    		  what.buttonMode = 'roundedButton'
						system.saveUserSettings()
    		end
    		if what.buttonPrevMode == 'default' then
    		tmp:addItem(lc.default).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'default'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'framedButton'
						system.saveUserSettings()
    		end
     else
    		tmp:addItem(lc.framedButton).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'framedButton'
						system.saveUserSettings()
    		end
    		tmp:addItem(lc.default).onTouch = function()
    		  what.buttonPrevMode = what.buttonMode
    		  what.buttonMode = 'default'
						system.saveUserSettings()
    		end
    		end
    end
		end
		local tmp = usualParams:addSubMenuItem(lc.image)
		tmp:addItem(lc.image).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.imageImage)))
			  tmpp.onInputFinished = function()
			    userSettings.imageImage = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.imageName)))
			  tmpp.onInputFinished = function()
			    userSettings.imageName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.imageX)))
			  tmpp.onInputFinished = function()
			    userSettings.imageX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.imageY)))
			  tmpp.onInputFinished = function()
			    userSettings.imageY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.input)
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputX)))
			  tmpp.onInputFinished = function()
			    userSettings.inputX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputY)))
			  tmpp.onInputFinished = function()
			    userSettings.inputY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.inputWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.heigth).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputHeight)))
			  tmpp.onInputFinished = function()
			    userSettings.inputHeight = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorbg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.inputColorBG == nil then userSettings.inputColorBG = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.inputColorBGP or cr2, hts(userSettings.inputColorBG)))
			  tmpp.onColorSelected = function()
			    userSettings.inputColorBG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end end
		tmp:addItem(lc.colorfg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.inputColorFG == nil then userSettings.inputColorFG = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.inputColorFG, hts(userSettings.inputColorFG)))
			  tmpp.onColorSelected = function()
			    userSettings.inputColorFG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorph).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.inputColorPH == nil then userSettings.inputColorPH = 0x2D2D2D end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.inputColorPH, hts(userSettings.inputColorPH)))
			  tmpp.onColorSelected = function()
			    userSettings.inputColorPH = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorbgp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.inputColorBGP == nil then userSettings.inputColorBGP = cr4 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.inputColorBGP, hts(userSettings.inputColorBGP)))
			  tmpp.onColorSelected = function()
			    userSettings.inputColorBGP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorfgp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.inputColorFGP == nil then userSettings.inputColorFGP = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.inputColorFGP, hts(userSettings.inputColorFGP)))
			  tmpp.onColorSelected = function()
			    userSettings.inputColorFGP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputName)))
			  tmpp.onInputFinished = function()
			    userSettings.inputName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.text).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputText)))
			  tmpp.onInputFinished = function()
			    userSettings.inputText = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.textph).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.inputTextPH)))
			  tmpp.onInputFinished = function()
			    userSettings.inputTextPH = tmpp.text
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.switch)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.switchName)))
			  tmpp.onInputFinished = function()
			    userSettings.switchName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.state).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
    local tmp = container.layout:addChild(GUI.comboBox(1, 1, #lc.falsee/divide+2, 1, cr1, cr2, cr1, cr2))
    if userSettings.switchState == nil then userSettings.switchState = true end
    if userSettings.switchState == true then
      tmp:addItem(lc.truee).onTouch = function()
        userSettings.switchState = true
						system.saveUserSettings()
      end
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.switchState = false
						system.saveUserSettings()
      end
    else
      tmp:addItem(lc.falsee).onTouch = function()
        userSettings.switchState = false
						system.saveUserSettings()
      end
     tmp:addItem(lc.truee).onTouch = function()
        userSettings.switchState = true
						system.saveUserSettings()
      end
    end
    end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.switchX)))
			  tmpp.onInputFinished = function()
			    userSettings.switchX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.switchY)))
			  tmpp.onInputFinished = function()
			    userSettings.switchY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.switchWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.switchWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.switchColorP == nil then userSettings.switchColorP = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorP, hts(userSettings.switchColorP)))
			  tmpp.onColorSelected = function()
			    userSettings.switchColorP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colors).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.switchColorS == nil then userSettings.switchColorS = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorS, hts(userSettings.switchColorS)))
			  tmpp.onColorSelected = function()
			    userSettings.switchColorS = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colort).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.switchColorT == nil then userSettings.switchColorT = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorT, hts(userSettings.switchColorT)))
			  tmpp.onColorSelected = function()
			    userSettings.switchColorT = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		local tmp = usualParams:addSubMenuItem(lc.panel)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.panelName)))
			  tmpp.onInputFinished = function()
			    userSettings.panelName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.panelX)))
			  tmpp.onInputFinished = function()
			    userSettings.panelX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.panelY)))
			  tmpp.onInputFinished = function()
			    userSettings.panelY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.panelWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.panelWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.heigth).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.panelHeight)))
			  tmpp.onInputFinished = function()
			    userSettings.panelHeight = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colors).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.panelColor == nil then userSettings.panelColor = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.panelColor, hts(userSettings.panelColor)))
			  tmpp.onColorSelected = function()
			    userSettings.panelColor = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		local tmp = usualParams:addSubMenuItem(lc.collorSelector)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csName)))
			  tmpp.onInputFinished = function()
			    userSettings.csName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csX)))
			  tmpp.onInputFinished = function()
			    userSettings.csX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csY)))
			  tmpp.onInputFinished = function()
			    userSettings.csY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.csWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.heigth).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csHeight)))
			  tmpp.onInputFinished = function()
			    userSettings.csHeight = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.color).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.csColor == nil then userSettings.csColor = 0xFF00FF end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.csColor, hts(userSettings.csColor)))
			  tmpp.onColorSelected = function()
			    userSettings.csColor = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.text).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.csText)))
			  tmpp.onInputFinished = function()
			    userSettings.csText = tmpp.text
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.slider)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderName)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderX)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderY)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.sliderColorP == nil then userSettings.sliderColorP = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.sliderColorP, hts(userSettings.sliderColorP)))
			  tmpp.onColorSelected = function()
			    userSettings.sliderColorP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorpp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.sliderColorPP == nil then userSettings.sliderColorPP = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.sliderColorPP, hts(userSettings.sliderColorPP)))
			  tmpp.onColorSelected = function()
			    userSettings.sliderColorPP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.sliderColorV == nil then userSettings.sliderColorV = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.sliderColorV, hts(userSettings.sliderColorV)))
			  tmpp.onColorSelected = function()
			    userSettings.sliderColorV = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.minv).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderMinv)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderMinv = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.maxv).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderMaxv)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderMaxv = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.value).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.sliderValue)))
			  tmpp.onInputFinished = function()
			    userSettings.sliderValue = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.progressIndicator)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.piName)))
			  tmpp.onInputFinished = function()
			    userSettings.piName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.piX)))
			  tmpp.onInputFinished = function()
			    userSettings.piX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.piY)))
			  tmpp.onInputFinished = function()
			    userSettings.piY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.piColorP == nil then userSettings.piColorP = cr3 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.piColorP, hts(userSettings.piColorP)))
			  tmpp.onColorSelected = function()
			    userSettings.piColorP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorpa).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.piColorPA == nil then userSettings.piColorPA = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.piColorPS, hts(userSettings.piColorPA)))
			  tmpp.onColorSelected = function()
			    userSettings.piColorPA = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorv).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.piColorS == nil then userSettings.piColorV = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.piColorV, hts(userSettings.piColorV)))
			  tmpp.onColorSelected = function()
			    userSettings.piColorV = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		local tmp = usualParams:addSubMenuItem(lc.progressBar)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.progressBarName)))
			  tmpp.onInputFinished = function()
			    userSettings.progressBarName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.progressBarX)))
			  tmpp.onInputFinished = function()
			    userSettings.progressBarX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.progressBarY)))
			  tmpp.onInputFinished = function()
			    userSettings.progressBarY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.progressBarWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.progressBarWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colorp).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.progressBarColorP == nil then userSettings.progressBarColorP = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorP, hts(userSettings.progressBarColorP)))
			  tmpp.onColorSelected = function()
			    userSettings.progressBarColorP = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colors).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.progressBarColorS == nil then userSettings.progressBarColorS = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorS, hts(userSettings.progressBarColorS)))
			  tmpp.onColorSelected = function()
			    userSettings.progressBarColorS = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorv).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.progresBarColorV == nil then userSettings.progressBarColorV = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.switchColorV, hts(userSettings.progressBarColorV)))
			  tmpp.onColorSelected = function()
			    userSettings.progressBarColorV = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.value).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.progressBarValue)))
			  tmpp.onInputFinished = function()
			    userSettings.progressBarValue = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		local tmp = usualParams:addSubMenuItem(lc.comboBox)
		tmp:addItem(lc.name).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.comboBoxName)))
			  tmpp.onInputFinished = function()
			    userSettings.comboBoxName = tmpp.text
							system.saveUserSettings()
			  end
		end
		tmp:addItem('X').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.comboBoxX)))
			  tmpp.onInputFinished = function()
			    userSettings.comboBoxX = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem('Y').onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.comboBoxY)))
			  tmpp.onInputFinished = function()
			    userSettings.comboBoxY = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.width).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.comboBoxWidth)))
			  tmpp.onInputFinished = function()
			    userSettings.comboBoxWidth = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.elh).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  local tmpp = container.layout:addChild(GUI.input(1,1,30,3,cr1,cr2,cr3,cr1,cr2,tostring(userSettings.comboBoxELH)))
			  tmpp.onInputFinished = function()
			    userSettings.comboBoxELH = tonumber(tmpp.text)
							system.saveUserSettings()
			  end
		end
		tmp:addItem(lc.colort).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.comboBoxColorT == nil then userSettings.comboBoxColorT = cr1 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.comboBoxColorT, hts(userSettings.comboBoxColorT)))
			  tmpp.onColorSelected = function()
			    userSettings.comboBoxColorT = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorat).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.comboBoxColorAT == nil then userSettings.comboBoxColorAT = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.comboBoxColorAT, hts(userSettings.comboBoxColorAT)))
			  tmpp.onColorSelected = function()
			    userSettings.comboBoxColorAT = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorabg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.comboBoxColorABG == nil then userSettings.comboBoxColorABG = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.comboBoxColorABG, hts(userSettings.comboBoxColorABG)))
			  tmpp.onColorSelected = function()
			    userSettings.comboBoxColorABG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
		tmp:addItem(lc.colorbg).onTouch = function()
			  local container = GUI.addBackgroundContainer(wk, true, true)
			  if userSettings.comboBoxColorBG == nil then userSettings.comboBoxColorBG = cr2 end
			  local tmpp = container.layout:addChild(GUI.colorSelector(1, 1, 30, 3, userSettings.comboBoxColorBG, hts(userSettings.comboBoxColorBG)))
			  tmpp.onColorSelected = function()
			    userSettings.comboBoxColorBG = tonumber(tmpp.color)
					 	system.saveUserSettings()
			  end
			end
end
sampleParams()
draw()
drawtree()
drawparams()
 
