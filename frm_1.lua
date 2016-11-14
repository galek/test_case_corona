local widget = require("widget")
local composer = require("composer")
local scene = composer.newScene()
local shared = require("shared")


local mFile = require("FileFunctions")
-- USED FOR LOCALISATION
local LOC_LoadedFilesTitle = "Loaded Files"

-- Create scene
function scene:create(event)
    local sceneGroup = self.view

    local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
    InitHeader(LOC_LoadedFilesTitle, sceneGroup, ox, oy)

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
    -- Listen for tableView events
    local function tableViewListener(event)
        local phase = event.phase
        -- print( "Event.phase is:", event.phase )
    end

    -- Handle row rendering
    local function onRowRender(event)
        local phase = event.phase
        local row = event.row

        local groupContentHeight = row.contentHeight

        local rowTitle = display.newText(row, GetFileNameByIndex(row.index), 0, 0, nil, 14)
        rowTitle.x = 10
        rowTitle.anchorX = 0
        rowTitle.y = groupContentHeight * 0.5

        rowTitle:setFillColor(unpack(row.params.defaultLabelColor))
    end

    -- Handle row updates
    local function onRowUpdate(event)
        local phase = event.phase
        local row = event.row
        -- print( row.index, ": is now onscreen" )
    end

    -- Handle touches on the row
    local function onRowTouch(event)
        local phase = event.phase
        local row = event.target
        if ("release" == phase) then
            composer.setVariable("SelectedFile", GetFileNameByIndex(row.index))
            composer.gotoScene("frm_2")
        end
    end

    -- Create a tableView
    tableView = widget.newTableView
    {
        top = 32 - oy,
        left = - ox,
        width = display.contentWidth + ox + ox,
        height = display.contentHeight + oy + oy - 32,
        hideBackground = true,
        listener = tableViewListener,
        onRowRender = onRowRender,
        onRowUpdate = onRowUpdate,
        onRowTouch = onRowTouch,
    }
    sceneGroup:insert(tableView)

    for i = 1, GetFileListSize() do
        local isCategory = false
        local rowHeight = 32
        local rowColor = {
            default = tableViewColors.rowColor.default,
            over = tableViewColors.rowColor.over,
        }

        -- Insert the row into the tableView
        tableView:insertRow
        {
            isCategory = isCategory,
            rowHeight = rowHeight,
            rowColor = rowColor,
            lineColor = tableViewColors.lineColor,
            params = { defaultLabelColor = tableViewColors.defaultLabelColor, catLabelColor = tableViewColors.catLabelColor }
        }
    end
end

scene:addEventListener("create")

--
Traverse()

return scene