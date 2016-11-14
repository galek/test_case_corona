local widget = require("widget")
local composer = require("composer")
local scene = composer.newScene()


local mFile = require("FileFunctions")

local mEditBox


local function Init()
    local _SelectedFile = composer.getVariable("SelectedFile")
    mEditBox.text = LoadFile(_SelectedFile)
end

local function destroyEditBox()
    if mEditBox then
        mEditBox:removeSelf()
        mEditBox = nil
    end
end

local function goBack(event)
    print("goBack")
    composer.removeScene("frm_2")
    -- composer.gotoScene( "frm_1" )
    composer.gotoScene("frm_1", "crossFade", 1000)

    destroyEditBox()

    return true
end

local function onSave(event)
    -- print("onSave")
    -- print( event.target.id )  -- Reference to button's 'id' parameter

    local filename = GetOpenedFile()

    assert((not((filename == nil) or filename == "")), "INVALID FILENAME")

    print("onSave " .. filename)
    SaveFile(filename, mEditBox.text)

    return true
end

-- Create scene
function scene:create(event)
    local sceneGroup = self.view
    local function textListener(event)

        if (event.phase == "began") then
            -- User begins editing "defaultBox"

        elseif (event.phase == "ended" or event.phase == "submitted") then
            -- Output resulting text from "defaultBox"
            print(event.target.text)

        elseif (event.phase == "editing") then
            print(event.newCharacters)
            print(event.oldText)
            print(event.startPosition)
            print(event.text)
        end
    end

    -- Create text box
    local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
    local width = display.contentWidth + ox + ox
    local height = display.contentHeight + oy + oy - 32

    mEditBox = native.newTextBox(display.contentCenterX, display.contentCenterY, width - 32, height - 100)
    mEditBox.text = "This is line 1.\nAnd this is line2"
    mEditBox.isEditable = true
    mEditBox.font = native.newFont("Helvetica-Bold", 18)
    mEditBox:addEventListener("userInput", textListener)

    sceneGroup:insert(mEditBox)

    Save = widget.newButton(
    {
        top = display.contentHeight - 50,
        width = 32,
        height = 32,
        left = 300 + ox + ox,
        -- HARDCODED SIZE
        id = "button1",
        label = "Save",
        onRelease = onSave
    }
    )
    sceneGroup:insert(Save)

    Back = widget.newButton(
    {
        top = display.contentHeight - 50,
        width = 32,
        height = 32,
        left = 20 + ox + ox,
        -- HARDCODED SIZE
        id = "button2",
        label = "Back",
        onRelease = goBack
    }
    )
    sceneGroup:insert(Back)

    Init()
end

function scene:destroyScene(event)
    local group = self.view

    destroyEditBox()
end

function scene:exitScene(event)
    local group = self.view

    destroyEditBox()
end

scene:addEventListener("destroyScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("create", scene)


return scene