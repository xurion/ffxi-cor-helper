_addon.name = 'CORHelper'
_addon.version = '0.0.1'
_addon.command = 'corhelper'
_addon.author = 'Dean James (Xurion of Bismarck)'

packets = require('packets')
texts = require('texts')
config = require('config')

key_binds = require('binds')
indexed_key_binds = {}

defaults = {}
defaults.text_settings = {}
defaults.text_settings.pos = {}
defaults.text_settings.pos.x = 0
defaults.text_settings.pos.y = 0
defaults.text_settings.text = {}
defaults.text_settings.text.font = 'Consolas'
defaults.text_settings.text.size = 12
defaults.text_settings.bg = {}
defaults.text_settings.bg.alpha = 75
defaults.text_settings.bg.red = 0
defaults.text_settings.bg.green = 0
defaults.text_settings.bg.blue = 0
defaults.text_settings.flags = {}
defaults.text_settings.flags.draggable = true
defaults.text_settings.padding = 7
defaults.party_alerts = false

settings = config.load(defaults)

function concat_strings(s)
    local t = {}
    for k, v in ipairs(s) do
        t[#t + 1] = tostring(v)
    end
    return table.concat(t, "\n")
end

function setup_ui()
  local ui = texts.new(settings.text_settings, settings)
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
    if key_bind.type ~= 'raw' and key_bind.type ~= 'ws' then
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
    indexed_key_binds[key_bind.key] = key_bind
    windower.send_command('bind %' .. key_bind.key .. ' corhelper execute ' .. key_bind.key)
  end
end

function remove_binds()
  for _, key_bind in pairs(key_binds) do
    windower.send_command('unbind %' .. key_bind.key)
  end
end

function execute_bind(key)
  local command = 'input '
  if indexed_key_binds[key].type == 'ja' or indexed_key_binds[key].type == 'roll' then
    command = command .. '/ja "' .. indexed_key_binds[key].name .. '" <me>'
  elseif indexed_key_binds[key].type == 'ws' then
    local target = windower.ffxi.get_mob_by_target('t')
    local target_distance = math.sqrt(target.distance)
    if target_distance > 21.7 then
      windower.play_sound(windower.addon_path .. 'distance.wav')
      windower.add_to_chat(3, '*****Target too far away - cancelling weapon skill*****')
      return false
    end
    command = command .. '/ws "' .. indexed_key_binds[key].name .. '" <t>'
  elseif indexed_key_binds[key].type == 'raw' then
    command = command .. indexed_key_binds[key].command
  end
  if settings.party_alerts and indexed_key_binds[key].party_alert then
    command = 'input /p ' .. indexed_key_binds[key].name .. ' >>> <t>; wait 0.2; ' .. command
  end
  windower.send_command(command)
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

windower.register_event('addon command', function(command, key)
  if command == 'pa' then
    if settings.party_alerts == true then
      windower.add_to_chat(8, 'CORHelper: Party alerts OFF')
      settings.party_alerts = false
    else
      windower.add_to_chat(8, 'CORHelper: Party alerts ON')
      settings.party_alerts = true
    end
    config.save(settings)
  end

  if command == 'execute' then
    execute_bind(key)
  end
end)
