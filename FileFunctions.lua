--=============FILES=============
local lfs = require( "lfs" )

-- List of files
fileList = {};

function AddFile(file)
        table.insert(fileList, file)
end

function GetFileListSize()
    return table.maxn(fileList)
end

function Traverse()
    -- Get raw path to the app documents directory
    local doc_path = system.pathForFile( "", system.DocumentsDirectory )

    for file in lfs.dir( doc_path ) do
        -- We will use only files
        if (file ~= "..") and (file ~= "." )then
        -- "file" is the current file or directory name
        print("found file, "..file)
        AddFile(file)
        end
    end
end


function GetFileNameByIndex(index)       
    -- assert will work if first param = false, else reverted all params,
    -- so we will write as inverted version
        assert(((index<table.maxn(fileList)) or index>1), "INVALID INDEX")
        return fileList[index]
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


function MakeListOfFiles()
    
    AddFile()
end
--=============FILES=============

