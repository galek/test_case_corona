local widget = require("widget")
local composer = require("composer")
local scene = composer.newScene()


local mFile = require("FileFunctions")


local mEditBox

-- Create scene
function scene:create(event)
    local sceneGroup = self.view
    local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)

    -- Set color variables depending on theme
    local tableViewColors = {
        rowColor = { default = { 1 }, over = { 30 / 255, 144 / 255, 1 } },
        lineColor = { 220 / 255 },
        catColor = { default = { 150 / 255, 160 / 255, 180 / 255, 200 / 255 }, over = { 150 / 255, 160 / 255, 180 / 255, 200 / 255 } },
        defaultLabelColor = { 0, 0, 0, 0.6 },
        catLabelColor = { 0 }
    }

    tableViewColors.rowColor.default = { 48 / 255 }
    tableViewColors.rowColor.over = { 72 / 255 }
    tableViewColors.lineColor = { 36 / 255 }
    tableViewColors.catColor.default = { 80 / 255, 80 / 255, 80 / 255, 0.9 }
    tableViewColors.catColor.over = { 80 / 255, 80 / 255, 80 / 255, 0.9 }
    tableViewColors.defaultLabelColor = { 1, 1, 1, 0.6 }
    tableViewColors.catLabelColor = { 1 }

    -- Forward reference for the tableView
    local tableView

    -- Text to show which item we selected
    local itemSelected = display.newText("User selected row ", 0, 0, native.systemFont, 16)
    itemSelected:setFillColor(unpack(tableViewColors.catLabelColor))
    itemSelected.x = display.contentWidth + itemSelected.contentWidth
    itemSelected.y = display.contentCenterY
    sceneGroup:insert(itemSelected)

    -- Function to return to the tableView
    local function goBack(event)
        transition.to(tableView, { x = display.contentWidth * 0.5, time = 600, transition = easing.outQuint })
        transition.to(itemSelected, { x = display.contentWidth + itemSelected.contentWidth, time = 600, transition = easing.outQuint })
        transition.to(event.target, { x = display.contentWidth + event.target.contentWidth, time = 480, transition = easing.outQuint })
    end

    -- Back button
    local backButton = widget.newButton {
        width = 128,
        height = 32,
        label = "back",
        onRelease = goBack
    }
    backButton.x = display.contentWidth + backButton.contentWidth
    backButton.y = itemSelected.y + itemSelected.contentHeight + 16
    sceneGroup:insert(backButton)



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

end

local function goBack(event)
    -- transition.to( tableView, { x=display.contentWidth*0.5, time=600, transition=easing.outQuint } )
    -- transition.to( itemSelected, { x=display.contentWidth+itemSelected.contentWidth, time=600, transition=easing.outQuint } )
   -- transition.to(event.target, { x = display.contentWidth + event.target.contentWidth, time = 480, transition = easing.outQuint })
   
   
    local switch = event.target
    print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
   
end

local function onSave(event)
    --print("onSave")
    --print( event.target.id )  -- Reference to button's 'id' parameter
    
    local filename=GetOpenedFile()
    
    assert((not((filename==nil)or filename=="")),"INVALID FILENAME")    
    SaveFile(filename,mEditBox.text)    
end

-- create the actual tabBar widget

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
    
local Save = widget.newButton(
    {
        top = display.contentHeight - 50,
        width = 32,
        height = 32,
        left = 300 + ox + ox, -- HARDCODED SIZE
        id = "button1",
        label = "Save",
        onEvent = onSave
    }
)  
local Back = widget.newButton(
    {
        top = display.contentHeight - 50,
        width = 32,
        height = 32,
        left = 20 + ox + ox, -- HARDCODED SIZE
        id = "button2",
        label = "Back",
        onEvent = goBack
    }
)

scene:addEventListener("create")

return scene