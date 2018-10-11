_addon.name = 'CORHelper'
_addon.version = '0.0.1'
_addon.author = 'Dean James (Xurion of Bismarck)'

packets = require('packets')
texts = require('texts')
config = require('config')

key_binds = require('binds')

settings = config.load({
  pos = {
    x = 0,
    y = 0
  },
  text = {
    font = 'Consolas',
    size = 12
  },
  bg = {
    alpha = 200,
    red = 0,
    green = 0,
    blue = 0
  },
  flags = {
    draggable = true
  },
  padding = 7
})

-- function wrap_text_in_roll_colour(text, roll_name)
--   local roll_colours = {
--     [''] = '255,0,0'
--   }[roll_name]
--
--   if roll_colour == nil then
--     roll_colour = '255,255,255'
--   end
--
--   return "\\cs(" .. roll_colour .. ")" .. text .. "\\cr"
-- end

function concat_strings(s)
    local t = {}
    for k, v in ipairs(s) do
        t[#t + 1] = tostring(v)
    end
    return table.concat(t, "\n")
end

function setup_ui()
  local ui = texts.new(settings)
  local properties = L{}
  properties:append('${roll_binds}')
  ui:clear()
  ui:append(properties:concat('\n'))

  return ui
end

function get_hud_text()
  local hud_info = {}
  local roll_binds = {}
  local color
  local buffs = windower.ffxi.get_player().buffs
  for _, key_bind in pairs(key_binds) do
    if key_bind.type ~= 'raw' then
      -- color = '255,255,255'
      -- if key_bind.type == 'roll' then
      --   for _, buff_id in pairs(buffs) do
          -- if buff_list[buff_id].en == key_bind.name then
          --   color = '0,255,0'
          -- end
        -- end
      -- end
      --table.insert(roll_binds, '\\cs(255,255,255)' .. key_bind.key .. ' ' .. key_bind.name .. ' [' .. key_bind.help .. ']\\cr')
      --table.insert(roll_binds, '\\cs(' .. color .. ')' .. key_bind.key .. ' ' .. key_bind.name .. ' (' .. key_bind.help .. ')\\cr')
      table.insert(roll_binds, key_bind.key .. ' ' .. key_bind.name .. ' (' .. key_bind.help .. ')')
    end
  end
  hud_info.roll_binds = concat_strings(roll_binds)

  return hud_info
end

function setup_binds()
  for _, key_bind in pairs(key_binds) do
    local command
    if key_bind.type == 'ja' or key_bind.type == 'roll' then
      command = '/ja "' .. key_bind.name .. '" <me>'
    elseif key_bind.type == 'raw' then
      command = key_bind.command
    end
    windower.send_command('bind %' .. key_bind.key .. ' input ' .. command)
  end
end

function remove_binds()
  for _, key_bind in pairs(key_binds) do
    windower.send_command('unbind %' .. key_bind.key)
  end
end

ui = setup_ui()
default_text = get_hud_text()
ui:update(default_text)

windower.register_event('load', 'login', function ()
  setup_binds()
  ui:show()
end)

windower.register_event('logout', function ()
  ui:hide()
end)

windower.register_event('unload', function ()
  remove_binds()
end)
