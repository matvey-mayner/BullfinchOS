local opengames = {Instance={}}
local GUI = require('GUI')
local image = require('Image')
local system = require('System')
local fs = require('filesystem')
local computer = require("computer")
local paths = require('Paths')
local eventObject
function opengames.init(params)
    opengames.isEditor = params.editor or false
    opengames.useImages = params.useImages or true
    if not params.game then
        system.error('Init MUST contain game table.')
    end
    if not params.container then
        system.error('Init MUST contain window or container.')
    end
    if not opengames.isEditor then
        if not params.gamePath then
            system.error('Init MUST contain game path.')
        end
    end
    opengames.gamepath = params.gamePath
    opengames.game = params.game
    opengames.cashe = {scripts={},images={}}
    opengames.editor = {WK = params.wk, BG=params.bg,TITLE=params.title}
    opengames.imageAtlas = params.imageAtlas
    opengames.container = params.container
    -- Init scripts module
    eventObject = opengames.container:addChild(GUI.object(1,1,1,1))
    eventObject.scripts = {} -- [n] = {time_started, prev_call, time_end, interval, callback}
    eventObject.opengames = opengames
    eventObject.eventHandler = function(_,object,...)
      local computer = require('computer')
      for i = 1, #object.scripts do
        if computer.uptime() > object.scripts[i].prev_call+object.scripts[i].interval then
          object.scripts[i].prev_call = computer.uptime()
          object.scripts[i].callback({...},object.opengames,i,object)
        end
        if computer.uptime()-object.scripts[i].time_end < computer.uptime() then
          if object.scripts[i].time_end > 0 then
            object.scripts[i] = nil
          end
        end
      end
    end
end
local function localCopy(a)
  return a
end
function opengames.fixAtlas(object)
  if object.type == 'animation' then
   local image = image.copy(object.atlas.atlas.image)
   local config = table.copy(object.atlas.config)
   object.atlas = require('ImageAtlas').init(1,1)
   object.atlas.atlas.image = image
   object.atlas.config = config
     object.tick = function(anim) 
       anim.stage = anim.stage + 1
       if anim.atlas:getImage(tostring(anim.stage)) then 
         anim.raw.image = anim.atlas:getImage(tostring(anim.stage))
         return true, 'next'
       else 
         anim.stage = 1
         anim.raw.image = anim.atlas:getImage(tostring(anim.stage)) 
         return true, 'new'
       end
     end
     object.checkNext = function(anim)
       if anim.atlas:getImage(tostring(anim.stage + 1)) then
         return 'next'
       else
         return 'new'
       end
  end
  end
end
function opengames.Instance.new(...)
   local args = {...}
   local game = opengames.game
  if args[1] == 'panel' then
    table.insert(game.screen,{visible = args[8],type = 'panel',x=args[3],y= args[4],color= args[7],width = args[5],height= args[6],name =  args[2]})
  elseif args[1] == 'text' then
    table.insert(game.screen,{visible =args[7],type = 'text',x= args[3],y=args[4],color=args[5],text=args[6],name = args[2]})
  elseif args[1] == 'progressBar' then
    table.insert(game.screen,{visible = args[10],width= args[5],colorp = args[6],colors=args[7],colorv=args[8],type = 'progressBar',x=args[3],y=args[4],color=args[6],value=args[9],name = args[2]})
  elseif args[1] == 'comboBox' then
    table.insert(game.screen,{visible = args[11],type = 'comboBox',width=args[5],x=args[3],y=args[4] or 1,elh=args[6],items=args[12] or {},colorbg=args[7],colort=args[8],colorabg=args[9],colorat=args[10],name=args[2]})
  elseif args[1] == 'slider' then
    table.insert(game.screen,{visible = args[13],type = 'slider',path=args[12],x=args[3],y=args[4],width=args[5],colorp=args[6],colorpp=args[7],colorv=args[8],minv=args[9],maxv=args[10],value=args[11], name = args[2]})
  elseif args[1] == 'progressIndicator' then
    table.insert(game.screen,{visible = args[8],type = 'progressIndicator',x=args[3],y=args[4],active= false,rollStage= 1,colorp= args[6],colors=args[7],colorpa=args[5],name = args[2]})
  elseif args[1] == 'colorSelector' then
    table.insert(game.screen,{visible = args[10],path=args[9],type = 'colorSelector',color=args[7],x=args[3],y=args[4],width=args[5],height=args[6],text=args[8],name = args[2]})
  elseif args[1] == 'input' then
    table.insert(game.screen,{visible = args[15],onInputEnded = args[14],width=args[5],height=args[6],colorbg = args[9],colorfg = args[10],colorfgp = args[12],colorbgp = args[11],colorph=args[13],type = 'input',x=args[3],y=args[4],name = args[2],text = args[7],textph = args[8]})
  elseif args[1] == 'switch' then
    table.insert(game.screen,{onStateChanged = args[9], visible =args[11],state=args[10],type = 'switch',x=args[3],y=args[4],width=args[5],colorp=args[6], colors=args[7],colorpp=args[8],name = args[2]})
  elseif args[1] == 'button' then
    table.insert(game.screen,{visible = args[17],onTouch = args[12], height = args[6],width = args[5], animated = args[14] or true, disabled = args[16] or false, switchMode = args[15] or false, type = 'button',x= args[3],y=args[4],name = args[2],colorbg= args[8],mode=args[13],colorfg = args[9],colorbgp = args[10],colorfgp= args[11],text=args[7]})
  elseif args[1] == 'image' then
    table.insert(game.screen,{visible = args[6], type = 'image',x=args[3],y=args[4],image=args[5],name = args[2]})
  elseif args[1] == 'animation' then
    table.insert(game.screen,{visible = args[7],stage=0,type='animation',x=args[3],y=args[4],name=args[2],atlas=require('imageAtlas').init(args[5],args[6])})
    opengames.fixAtlas(game.screen[#game.screen])
  end
end
function opengames.Instance.remove(thing)
    if type(thing) == 'number' then
      if not opengames.game.screen[thing] then return false end
      opengames.game.screen[thing].raw:remove()
      opengames.game.screen[thing] = nil
      opengames.game.screen.buffer[thing] = nil
    elseif type(thing) == 'string' then
        _,thing = opengames.find(thing)
      if not opengames.game.screen[thing] then return false end
      opengames.game.screen[thing].raw:remove()
      opengames.game.screen[thing] = nil
      opengames.game.screen.buffer[thing] = nil
    elseif type(thing) == 'table' then
      if not thing then return false end
      thing.raw:remove()
      thing = opengames.find(opengames.game.screen,thing)
      opengames.game.screen[thing] = nil
      opengames.game.screen.buffer[thing] = nil
    end
end
function table.copy (originalTable)
 local copyTable = {}
  for k,v in pairs(originalTable) do
    copyTable[k] = v
  end
 return copyTable
end
local function cp(ind,n) -- Changing params, not club penguin
    local game = opengames.game
    game.screen[ind].raw[n] = game.screen[ind][n]
end
local function getS(ind,n)
    local game = opengames.game
    return game.screen[ind][n]
end
local function getB(ind,n)
    local game = opengames.game
    local tmp = game.screen.buffer[ind][n]
    if not tmp then
        return nil
    else
        return tmp
    end
end
local function getR(ind)
    local game = opengames.game
    return game.screen[ind].raw
end
local function getBW(name)
    local game = opengames.game
    return game.window.buffer[name]
end
local function execute(path,...)
  if opengames.cashe.scripts[path] then
    system.call(load(opengames.cashe.scripts[path]), ... ,opengames)
  else
    local gamepath = opengames.gamepath
    if fs.exists(gamepath..'/Scripts/'..path) then
      opengames.cashe.scripts[path] = fs.read(gamepath..'/Scripts/'..path)
    else
      system.error('Hell naw man :skull:, required file does not exists.')
      return false
    end
    system.call(load(opengames.cashe.scripts[path]), ... ,opengames)
  end
end
local function loadImage(path)
  if opengames.cashe.images[path] then
    if opengames.useImages == true then
      return opengames.cashe.images[path]
    else
      return image.load('/Icons/Script.pic')
    end
  else
    local game = opengames.game
    idk = nil
    for e = 1,#game.storage do
      if game.storage[e].name == path and fs.extension(game.storage[e].path) == '.pic' then
        idk = game.storage[e].path
      end
    end
    if idk == nil then return image.load('/Icons/Script.pic') end
    opengames.cashe.images[path] = image.load(idk)
    if opengames.useImages == true then
      return opengames.cashe.images[path]
    else
      return image.load('/Icons/Script.pic')
    end
  end
end
function opengames.draw()
    local game = opengames.game
    local screen = opengames.container
    local gamepath = opengames.gamepath
    local BG = BG or opengames.editor.BG
    local TITLE = TITLE or opengames.editor.TITLE
    if game.window.width ~= getBW('width') then
        BG.width = game.window.width
        TITLE.localX = math.floor(game.window.width/2-string.len(game.window.title)/1.5/2)
    end
    if game.window.height ~= getBW('height') then
        BG.height = game.window.height
    end
    if game.window.color ~= getBW('color') then
        BG.colors.background = game.window.color
    end
    if game.window.title ~= getBW('title') then
        TITLE.text = game.window.title
        TITLE.localX = math.floor(game.window.width/2-string.len(game.window.title)/1.5/2)
    end
    if game.window.titleColor ~= getBW('titleColor') then
        TITLE.color = game.window.titleColor
    end
    if game.window.abn ~= getBW('abn') then
        if game.window.abn == true then
            ABN = screen:addChild(GUI.actionButtons(2,1,false))
            ABN.close.onTouch = function()
                screen:remove()
            end
            ABN.minimize.onTouch = function()
                screen:minimize()
            end
        else
            ABN:remove()
        end
    end
    if not game.localization then
        game.localization = {}
    end
    for i = 1, #game.screen do
          if game.screen.buffer[i] == nil then
              game.screen.buffer[i] = {visible = false}
          end
          if game.screen[i].text then
              local tbl = {}
              for part in string.gmatch(game.screen[i].text,"[^ ]+") do
                table.insert(tbl, part)
              end
              if tbl[1] == '{loc}' or tbl[1] == '{localization}' then
                  text = game.localization[tbl[2]]
              else
                  text = game.screen[i].text
              end
          end
          if game.screen[i].textph then
              local tbl = {}
              for part in string.gmatch(game.screen[i].textph,"[^ ]+") do
                table.insert(tbl, part)
              end
          end

