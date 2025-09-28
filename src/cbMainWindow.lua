require("common.extension")

local serial   = require("serial")
local serialex = require("ecluart.serialextension")
local sys      = require("sys")
local ui       = require("ui")

--#region object initalization

local APP      = require("resources.app")
local COM      = nil
local WIN      = require("uiMainWindow")

--#endregion

--#region combobox events

function WIN.ComboboxBaudrate:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.baudrate]
end

function WIN.ComboboxBytesize:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.bytesize]
end

function WIN.ComboboxDTRMode:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.dtrmode]
end

function WIN.ComboboxParity:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.parity]
end

function WIN.ComboboxRTSMode:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.rtsmode]
end

function WIN.ComboboxStopbits:onChange()
  self.selected = self.selected or self.items[serialex.DEFAULTS.stopbits]
end

--#endregion

--#region button events

function WIN.ButtonUpdate:onClick()
  WIN.WM:disable()

  WIN.ComboboxPort.items = {}
  WIN.ComboboxPort.selected = nil
  WIN.EditOutput.text = ""

  local succeeded, result = pcall(serialex.comports)

  if succeeded and result then
    WIN.ComboboxPort.items = result
    WIN.ComboboxPort.selected = WIN.ComboboxPort.items[1]
  else
    ui.error("Failed to retrieve ports.", APP.TITLE.error)
  end

  WIN.WM_STANDARD:enable()
end

function WIN.ButtonStart:onClick()
  WIN.WM_START:disable()
  WIN.WM_STOP:enable()
  WIN.WM_CLEAR:disable()

  local port = WIN.ComboboxPort.selected.text
  local state = {
    baudrate = WIN.ComboboxBaudrate.selected.text,
    bytesize = WIN.ComboboxBytesize.selected.text,
    dtr = WIN.ComboboxDTRMode.selected.text,
    parity = WIN.ComboboxParity.selected.text,
    rts = WIN.ComboboxRTSMode.selected.text,
    stopbits = WIN.ComboboxStopbits.selected.text
  }

  COM = serial.Port(port)

  if COM:open(state) then
    WIN.EditOutput.text = ""

    repeat
      local data = COM:readline():wait()

      if COM then
        if data then
          WIN.EditOutput:append(tostring(data))
        else
          ui.error("Error reading port.", APP.TITLE.error)
          WIN.EditOutput.text = ""
          WIN.ComboboxPort.items = {}
          WIN.ComboboxPort.selected = nil
        end
      end
    until not data
  end

  if COM then COM:close() end
  COM = nil

  WIN.WM_START:enable()
  WIN.WM_STOP:disable()
end

function WIN.ButtonStop:onClick()
  if COM then COM:close() end
  COM = nil

  WIN.WM_START:enable()
  WIN.WM_STOP:disable()
end

function WIN.ButtonClear:onClick()
  WIN.EditOutput.text = ""
end

--#endregion

--#region window events

function WIN:onCreate()
  WIN.EditOutput.text = ""

  WIN.ComboboxBaudrate.selected = WIN.ComboboxBaudrate.items[serialex.DEFAULTS.baudrate]
  WIN.ComboboxBytesize.selected = WIN.ComboboxBytesize.items[serialex.DEFAULTS.bytesize]
  WIN.ComboboxDTRMode.selected = WIN.ComboboxDTRMode.items[serialex.DEFAULTS.dtrmode]
  WIN.ComboboxParity.selected = WIN.ComboboxParity.items[serialex.DEFAULTS.parity]
  WIN.ComboboxRTSMode.selected = WIN.ComboboxRTSMode.items[serialex.DEFAULTS.rtsmode]
  WIN.ComboboxStopbits.selected = WIN.ComboboxStopbits.items[serialex.DEFAULTS.stopbits]

  local succeeded, result = pcall(serialex.comports)

  if succeeded then
    WIN.ComboboxPort.items = result
    WIN.ComboboxPort.selected = WIN.ComboboxPort.items[1]
  else
    ui.error("Failed to retrieve ports.", APP.TITLE.error)
    WIN.ComboboxPort.items = {}
    WIN.ComboboxPort.selected = nil
  end
end

function WIN:onShow()
  WIN.GM_TOP:apply()
  WIN.GM_LEFT:apply()
  WIN.GM_RIGHT1:apply()
  WIN.GM_RIGHT2:apply()

  WIN.WM:disable()
  WIN.WM_STANDARD:enable()
end

function WIN:onResize()
  WIN:checksize()

  WIN.GM_TOP:update()
  WIN.GM_LEFT:update()
  WIN.GM_RIGHT1:update()
  WIN.GM_RIGHT2:update()
end

function WIN:onHide()
  if COM then COM:close() end
  sys.exit()
end

--#endregion

WIN:show()

async(function()
  while WIN.visible do
    sleep()

    if not COM then
      WIN.VM_PORT:apply()
      if WIN.VM_PORT.isvalid then
        WIN.WM_STANDARD:enable()
      else
        WIN.WM_PORT:disable()
      end

      WIN.VM_OUTPUT:apply()
      if WIN.VM_OUTPUT.isvalid then
        WIN.WM_CLEAR:enable()
      else
        WIN.WM_CLEAR:disable()
      end
    end

    ui.update()
  end
end)

ui.task:wait()
