-- Provides various extension serial functions.
local serialextension     = {}

-- Default values for serial communication settings.
serialextension.DEFAULTS  = {
  baudrate = 6,
  bytesize = 4,
  parity = "none",
  stopbits = "one",
  dtrmode = "disabled",
  rtsmode = "off"
}

-- List of supported baud rates for serial communication.
serialextension.baudrates = {
  9600,
  14400,
  19200,
  38400,
  57600,
  115200
}
-- List of supported byte sizes for serial communication.
serialextension.bytesize  = {
  5,
  6,
  7,
  8,
  9
}

-- List of supported parity settings for serial communication.
serialextension.parity    = {
  "none",
  "odd",
  "even",
  "mark",
  "space"
}

-- List of supported stop bits settings for serial communication.
serialextension.stopbits  = {
  "one",
  "one5",
  "two"
}

-- List of supported DTR (Data Terminal Ready) modes.
serialextension.dtrmode   = {
  "enabled",
  "disabled",
  "handshake"
}

-- List of supported RTS (Request to Send) modes.
serialextension.rtsmode   = {
  "on",
  "off",
  "handshake",
  "toggle"
}

-- Get a list of all current available com ports.
function serialextension.comports()
  local ports = {}

  for i = 1, 255 do
    local port = string.format("COM%d", i)
    local file = io.open(port, "r")

    if file then
      table.insert(ports, port)
      file:close()
    end
  end

  return ports
end

--#endregion

return serialextension
