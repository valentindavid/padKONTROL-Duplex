class "PadKontrolMap" (ControlMap)

function PadKontrolMap:__init()
  ControlMap.__init(self)
end

function PadKontrolMap:determine_type(str)
  if str == "XYPAD" then
    return DEVICE_MESSAGE.OSC
  elseif str == "DISPLAY" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1, 4) == "BTN#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1, 4) == "PAD#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1, 5) == "KNOB#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1, 8) == "ENCODER#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1,4) == "MAP#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1,7) == "ENABLE#" then
    return DEVICE_MESSAGE.OSC
  elseif str:sub(1,8) == "CHANNEL#" then
    return DEVICE_MESSAGE.OSC
  elseif str == "MAPX" then
    return DEVICE_MESSAGE.OSC
  elseif str == "MODEX" then
    return DEVICE_MESSAGE.OSC
  elseif str == "CHANNELX" then
    return DEVICE_MESSAGE.OSC
  elseif str == "MAPY" then
    return DEVICE_MESSAGE.OSC
  elseif str == "MODEY" then
    return DEVICE_MESSAGE.OSC
  elseif str == "CHANNELY" then
    return DEVICE_MESSAGE.OSC
  else
    error(("unknown message-type: %s"):format(str or "nil"))
  end
 
end

local buttons = {
   "SCENE",
   "MESSAGE",
   "SETTING",
   "NOTE",
   "MIDICH",
   "SWTYPE",
   "RELVAL",
   "VELO",
   "PORT",
   "FIXEDVEL",
   "PROGCHANGE",
   "X",
   "Y",
   "KNOB1ASSIGN",
   "KNOB2ASSIGN",
   "PEDAL",
   "ROLL",
   "FLAM",
   "HOLD",
}

class "padKONTROL" (MidiDevice)

function padKONTROL:__init(display_name, message_stream, port_in, port_out)
  self.buttons = {}
  for i, v in ipairs(buttons) do
     self.buttons[v] = i
  end

  MidiDevice.__init(self, display_name, message_stream, port_in, port_out)
  self.control_map = PadKontrolMap()
end

local XY_MODE_DISABLE = 0
local XY_MODE_CC = 1
local XY_MODE_PITCHBEND = 2

function padKONTROL:open()
  local input_devices = renoise.Midi.available_input_devices()
  local output_devices = renoise.Midi.available_output_devices()

  if table.find(input_devices, self.port_in) then
    self.midi_in = renoise.Midi.create_input_device(self.port_in,
      {self, padKONTROL.midi_callback},
      {self, padKONTROL.sysex_callback}
    )
  else
    LOG("Notice: Could not create MIDI input device ", self.port_in)
  end

  if table.find(output_devices, self.port_out) then
    self.midi_out = renoise.Midi.create_output_device(self.port_out)
  else
    LOG("Notice: Could not create MIDI output device ", self.port_out)
  end
 


  self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x01)

  self.global_channel = 1
  self.x_mode = XY_MODE_DISABLE
  self.y_mode = XY_MODE_DISABLE
  self.x_channel = 1
  self.y_channel = 1
  self.x_cc = 1
  self.y_cc = 1
  self.pad_mode = {0, 0, 0, 0,
                   0, 0, 0, 0,
                   0, 0, 0, 0,
                   0, 0, 0, 0}
  self.pad_channel = {1, 1, 1, 1,
                      1, 1, 1, 1,
                      1, 1, 1, 1,
                      1, 1, 1, 1}
  self.pad_note = {0, 1, 2, 3,
                   4, 5, 6, 7,
                   8, 9, 10, 11,
                   12, 13, 14, 15}

  self:sync_setup()

  self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x3F, 0x0A, 0x01,
                          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                          0x00, 0x00)

  self:disp("---")
end

function padKONTROL:sync_setup()
   local packet = {0x42, 0x40, 0x6E, 0x08, 0x3F, 0x2A, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                   0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

   packet[7 + 1] = self.global_channel - 1
   packet[7 + 2] = self.x_mode + self.y_mode * 4
   packet[7 + 3] = self.x_channel - 1
   packet[7 + 4] = self.y_channel - 1
   packet[7 + 5] = self.x_cc
   packet[7 + 6] = self.y_cc
   packet[7 + 7] = 0
   packet[7 + 8] = 0
   packet[7 + 9] = 0
   for i=16, 1, -1 do
      local a = math.floor((i-1)/7)
      packet[7 + 7 + a] = packet[7 + 7 + a] * 2
      packet[7 + 7 + a] = packet[7 + 7 + a] + self.pad_mode[i]
      packet[7 + 9 + i] = self.pad_channel[i]
      packet[7 + 25 + i] = self.pad_note[i]
   end

   self:send_sysex_message(unpack(packet))
end

function padKONTROL:release()
  self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x00, 0x00, 0x00)
  MidiDevice.release(self)
end

function padKONTROL:disp(str)
   local out = {0x42, 0x40, 0x6E, 0x08, 0x22, 0x04, 0x00, 0x29, 0x29, 0x29}
   for i, c in ipairs({str:byte(1, 3)}) do
      if c >= string.byte('a') and c <= string.byte('z') then
         out[7 + i] = c - string.byte('a') + 0x61
      elseif c >= string.byte('A') and c <= string.byte('Z') then
         out[7 + i] = c - string.byte('A') + 0x41
      elseif c >= string.byte('0') and c <= string.byte('9') then
         out[7 + i] = c - string.byte('0') + 0x30
      elseif c == string.byte('-') then
         out[7 + i] = 0x2d
      end
   end
   self:send_sysex_message(unpack(out))
end

function padKONTROL:send_osc_message(key, value)
  if key == "XYPAD" then

  elseif key:sub(1, 4) == "BTN#" then
     local btn = key:sub(5)
     local code = self.buttons[btn]
     if (code == nil) then
        error(("Button not known: '%s'"):format(key))
     end
     local send_value
     if value == 0 then
        send_value = 0
     else
        send_value = 0x20
     end
     self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x01, code + 0x10 - 1, send_value)
  elseif key:sub(1, 4) == "PAD#" then
     local pad = tonumber(key:sub(5))
     if value == 127 then
        self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x01, pad - 1, 0x20)
     else
        self:send_sysex_message(0x42, 0x40, 0x6E, 0x08, 0x01, pad - 1, 0x00)
     end
  elseif key:sub(1, 5) == "KNOB#" then
  elseif key:sub(1, 8) == "ENCODER#" then
  elseif key == "DISPLAY" then
     self:disp(value)
  elseif key:sub(1,4) == "MAP#" then
     self.pad_note[tonumber(key:sub(5))] = tonumber(value)
     self:sync_setup()
  elseif key:sub(1,7) == "ENABLE#" then
     self.pad_mode[tonumber(key:sub(8))] = tonumber(value)
     self:sync_setup()
  elseif key:sub(1,8) == "CHANNEL#" then
     self.pad_mode[tonumber(key:sub(9))] = tonumber(value)
     self:sync_setup()
  elseif key == "MAPX" then
     self.x_cc = tonumber(value)
     self:sync_setup()
  elseif key == "MODEX" then
     self.x_mode = tonumber(value)
     self:sync_setup()
  elseif key == "CHANNELX" then
     self.x_channel = tonumber(value)
     self:sync_setup()
  elseif key == "MAPY" then
     self.x_cc = tonumber(value)
     self:sync_setup()
  elseif key == "MODEY" then
     self.x_mode = tonumber(value)
     self:sync_setup()
  elseif key == "CHANNELY" then
     self.x_channel = tonumber(value)
     self:sync_setup()
  else
     error(("unknown message: %s"):format(str or "nil"))
  end
end

local header = {0xF0, 0x42, 0x40, 0x6E, 0x08}

function padKONTROL:sysex_callback(message)
  MidiDevice.sysex_callback(self, message)

  if #message <= #header then
     error("Bad SYSEX")
  end
  for i, v in ipairs(header) do
     if message[i] ~= v then
        error("Bad SYSEX")
     end
  end
  if message[#message] ~= 0xF7 then
     error("Bad SYSEX")
  end

  if message[#header+1] == 0x45 then
     if #message ~= (#header + 1 + 3) then
        error("Bad SYSEX")
     end
     local value = message[#header+3]
     local n = message[#header+2]
     if (n >= 0x40) and (n <= 0x4F) then
        local str = ("PAD#%i"):format(n - 0x40 + 1)
        for k, v in ipairs(self.control_map:get_params_by_value(str, nil)) do
           local msg = Message()
           msg.value = value
           msg.is_note_off = false
           msg.context = DEVICE_MESSAGE.MIDI_NOTE
           self:_send_message(msg, v["xarg"])
        end
     elseif (n >= 0x00) and (n <= 0x0F) then
        local str = ("PAD#%i"):format(n + 1)
        for k, v in ipairs(self.control_map:get_params_by_value(str, nil)) do
           local msg = Message()
           msg.value = 0
           msg.is_note_off = true
           msg.context = DEVICE_MESSAGE.MIDI_NOTE

           self:_send_message(msg, v["xarg"])
        end
     else
        error("Bad SYSEX")
     end
  elseif message[#header+1] == 0x48 then
     if #message ~= (#header + 1 + 3) then
        error("Bad SYSEX")
     end
     local on = message[#header+3]
     local n = message[#header+2]
     local str
     if n == 0x20 then
        str = "BTN#XYPAD"
     else
        str = "BTN#" .. buttons[1+n]
     end
     for k, v in ipairs(self.control_map:get_params_by_value(str, nil)) do
        local msg = Message()
        msg.value = 1
        if on then
           msg.is_note_off = false
        else
           msg.is_note_off = true
        end
        self:_send_message(msg, v["xarg"])
     end
  elseif message[#header+1] == 0x4B then
     if #message ~= (#header + 1 + 3) then
        error("Bad SYSEX")
     end
     local x = message[#header+2]
     local y = message[#header+3]
     for k, v in ipairs(self.control_map:get_params_by_value("XYPAD", nil)) do
        local msg = Message()
        msg.value = {x, y}
        self:_send_message(msg, v["xarg"])
     end
  elseif message[#header+1] == 0x49 then
     if #message ~= (#header + 1 + 3) then
        error("Bad SYSEX")
     end
     local knob = message[#header+2]
     local value = message[#header+3]
     local str = ("KNOB#%i"):format(1 + knob)
     for k, v in ipairs(self.control_map:get_params_by_value(str, nil)) do
        local msg = Message()
        msg.value = value
        self:_send_message(msg, v["xarg"])
     end
  elseif message[#header+1] == 0x43 then
     if #message ~= (#header + 1 + 3) then
        error("Bad SYSEX")
     end
     local value = message[#header+3]
     local str
     if value == 1 then
        str = "ENCODER#RIGHT"
     else
        str = "ENCODER#LEFT"
     end
     for k, v in ipairs(self.control_map:get_params_by_value(str, nil)) do
        local msg = Message()
        msg.value = 1
        msg.is_note_off = false
        self:_send_message(msg, v["xarg"])
     end
  else
  end
end

function padKONTROL:midi_callack(message)
end

function padKONTROL:point_to_value(pt, elm, ceiling)
   if type(pt.val) == "table" then
      local value = table.create()
      for k, v in ipairs(pt.val) do
         value:insert((v * (1 / ceiling)) * 1)
      end
      return value
   else
      return MidiDevice.point_to_value(self, pt, elm, ceiling)
   end
end
