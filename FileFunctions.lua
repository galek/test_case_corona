--=============FILES=============
-- Это плохо
filesCount = -1

function AddFile(name)
    
    filesCount=filesCount+1
end


function LoadFile(name)
    -- Path for the file to read
    -- Nick: In test-case we will use DocumentsDirectory
    local path = system.pathForFile( name, system.DocumentsDirectory )

    -- Open the file handle
    local file, errorString = io.open( path, "r" )

    if not file then
        -- Error occurred; output the cause
       print( "File error: " .. errorString )
    else
        -- Read data from file
        local contents = file:read( "*a" )
        -- Output the file contents
        print( "Contents of " .. path .. "\n" .. contents )
    -- Close the file handle
    io.close( file )
end

file = nil
end


function SaveFile(name,saveData)

-- Path for the file to write
local path = system.pathForFile( name, system.DocumentsDirectory )

-- Open the file handle
local file, errorString = io.open( path, "w" )

if not file then
    -- Error occurred; output the cause
    print( "File error: " .. errorString )
else
    -- Write data to file
    file:write( saveData )
    -- Close the file handle
    io.close( file )
end

file = nil
end
--=============FILES=============

