local widget = require("widget")
local composer = require("composer")
local scene = composer.newScene()


local mFile = require("FileFunctions")

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



    local defaultBox

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

    defaultBox = native.newTextBox(display.contentCenterX, display.contentCenterY, width - 32, height - 100)
    defaultBox.text = "This is line 1.\nAnd this is line2"
    defaultBox.isEditable = true
    defaultBox.font = native.newFont("Helvetica-Bold", 18)
    defaultBox:addEventListener("userInput", textListener)

end

local function goBack(event)
    -- transition.to( tableView, { x=display.contentWidth*0.5, time=600, transition=easing.outQuint } )
    -- transition.to( itemSelected, { x=display.contentWidth+itemSelected.contentWidth, time=600, transition=easing.outQuint } )
    transition.to(event.target, { x = display.contentWidth + event.target.contentWidth, time = 480, transition = easing.outQuint })
end

function onSave()

end

-- table to setup tabBar buttons
local tabButtons =
{
    {
        width = 32,
        height = 32,
        defaultFile = "icon1.png",
        overFile = "icon1-down.png",
        label = "First",
        selected = true,
        onRelease = goBack
    },
    {
        width = 32,
        height = 32,
        defaultFile = "icon2.png",
        overFile = "icon2-down.png",
        label = "Second",
        onRelease = onSave
    },
}

-- create the actual tabBar widget
local tabBar = widget.newTabBar
{
    top = display.contentHeight - 50,
    width = display.contentWidth,
    backgroundFile = "tabbar.png",
    tabSelectedLeftFile = "tabBar_tabSelectedLeft.png",
    tabSelectedMiddleFile = "tabBar_tabSelectedMiddle.png",
    tabSelectedRightFile = "tabBar_tabSelectedRight.png",
    tabSelectedFrameWidth = 20,
    tabSelectedFrameHeight = 52,
    buttons = tabButtons
}

scene:addEventListener("create")

return scene