require("common.extension")

local serial   = require("serial")
local serialex = require("ecluart.serialextension")
local sys      = require("sys")
local ui       = require("ui")

--#region initalization

local APP      = require("resources.app")
local COM      = nil
local WIN      = require("uiMainWindow")

--#endregion

--#region button events

function WIN.ButtonUpdate:onClick()
  WIN.ComboboxPort.selected = nil

  local succeeded, result = pcall(serialex.comports)

  if succeeded and result then
    WIN.ComboboxPort.items = result
    WIN.ComboboxPort.selected = WIN.ComboboxPort.items[1]
  else
    ui.error("Failed to retrieve COM ports.", APP.TITLE.error)
  end
end

function WIN.ButtonStart:onClick()
  WIN.EditOutput.text = ""

  local state = {
    baudrate = WIN.ComboboxBaudrate.selected.text,
    bytesize = WIN.ComboboxBytesize.selected.text,
    dtr = WIN.ComboboxDTRMode.selected.text,
    parity = WIN.ComboboxParity.selected.text,
    rts = WIN.ComboboxRTSMode.selected.text,
    stopbits = WIN.ComboboxStopbits.selected.text
  }

  COM = serial.Port(WIN.ComboboxPort.selected.text)

  if COM:open(state) then
    repeat
      local data = COM:readline():wait()

      if COM then
        if data then
          WIN.EditOutput:append(tostring(data))
        else
          ui.error("Error reading COM1 port.", APP.TITLE.error);
        end
      end
    until not data
  end
end

function WIN.ButtonStop:onClick()
  if COM then
    COM:close()
    COM = nil
  end
end

function WIN.ButtonClear:onClick()
  WIN.EditOutput.text = ""
end

--#endregion

--#region window events

function WIN:onCreate()
  WIN.ComboboxBaudrate.selected = WIN.ComboboxBaudrate.items[serialex.DEFAULTS.baudrate]
  WIN.ComboboxBytesize.selected = WIN.ComboboxBytesize.items[serialex.DEFAULTS.bytesize]
  WIN.ComboboxDTRMode.selected = WIN.ComboboxDTRMode.items[serialex.DEFAULTS.dtrmode]
  WIN.ComboboxParity.selected = WIN.ComboboxParity.items[serialex.DEFAULTS.parity]
  WIN.ComboboxRTSMode.selected = WIN.ComboboxRTSMode.items[serialex.DEFAULTS.rtsmode]
  WIN.ComboboxStopbits.selected = WIN.ComboboxStopbits.items[serialex.DEFAULTS.stopbits]

  local succeeded, result = pcall(serialex.comports)

  if succeeded and result then
    WIN.ComboboxPort.items = result
    WIN.ComboboxPort.selected = WIN.ComboboxPort.items[1]
  end
end

function WIN:onShow()
  WIN.GM_TOP:apply()
  WIN.GM_LEFT:apply()
  WIN.GM_RIGHT1:apply()
  WIN.GM_RIGHT2:apply()
end

function WIN:onResize()
  WIN:checksize()
  WIN.GM_TOP:update()
  WIN.GM_LEFT:update()
  WIN.GM_RIGHT1:update()
  WIN.GM_RIGHT2:update()
end

function WIN:onHide()
  if COM then
    COM:close()
  end

  sys.exit()
end

--#endregion

WIN:show()

async(function()
  while WIN.visible do
--    sleep()

    WIN.VM_PORT:apply()
    if not WIN.VM_PORT.isvalid then
      WIN.WM_PORT:disable()
      goto update
    end

    WIN.WM:enable()

    if COM and COM.isopen then
      WIN.WM_START:disable()
      goto update
    else
      WIN.WM_STOP:disable()
    end

    WIN.VM_OUTPUT:apply()
    if not WIN.VM_OUTPUT.isvalid then
      WIN.WM_CLEAR:disable()
    end

    ::update::
    ui.update()
  end
end)

waitall()
