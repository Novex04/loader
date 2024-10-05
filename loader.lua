local HttpService = game:GetService("HttpService")


-- Obfuscated GitHub Personal Access Token
local token = "\103\104\112\95\77\82\83\105\117\65\77\83\84\79\102\52\89\65\73\55\101\88\49\105\102\82\108\115\107\88\114\88\97\65\48\118\100\121\101\114\10"

-- GitHub API URLs for the files in your repo
local keyUrl = "https://api.github.com/repos/Novex04/Novex/contents/key.txt?ref=main"
local mainUrl = "https://api.github.com/repos/Novex04/Novex/contents/main.lua?ref=main"

-- Function to reconstruct the obfuscated string (token)
local function reconstructString(obfuscatedStr)
    local reconstructed = obfuscatedStr:gsub("\\(%d+)", function(num)
        return string.char(tonumber(num))
    end)
    return reconstructed
end

-- Base64 decoding function
local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local function Keysys(result)
	local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()
	local Notif = library:InitNotifications()
	library.title = "Keysys"
	Init = library:Init()
	local tab1 = Init:NewTab("Key")
	local Textbox1 = tab1:NewTextbox("Input Key:", "", "1", "all", "small", true, false, function(val)
		if val == result then
			Notif:Notify("Correct Key, Loading MainUi", 5, "success")
			writefile("Novex/Config.cfg", val)
			performHttpGetWithHeaders(mainUrl, Actualtoken)
		else
			Notif:Notify("Wrong Key.", 5, "error")
		end
	end)
end

-- Reconstruct the token and remove any extra spaces
local Actualtoken = reconstructString(token):gsub("%s+", "")

-- Function to perform the HTTP GET request with detailed error logging
local function performHttpGetWithHeaders(url, token)
    local headers = {
        ["Authorization"] = "token " .. token  -- Authorization header with the token
    }

    -- Perform the HTTP request using `request` with headers
    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "GET",
            Headers = headers
        })
    end)

    -- If the request is successful, handle the response
    if success then
        -- Log the entire response for debugging
        print("Response object:\n", response)

        if response and response.StatusCode == 200 then
            print("Status code 200: Success")
            -- Parse the JSON response (file contents are returned in base64)
            local responseData = HttpService:JSONDecode(response.Body)
            if responseData and responseData.content then
                -- Decode the base64 content using the custom decodeBase64 function
                local decodedContent = decodeBase64(responseData.content)
                print("Decoded file content:\n" .. decodedContent)

                -- Attempt to execute the fetched content as Lua code using loadstring
                local chunk, errorMsg = loadstring(decodedContent)
                if chunk then
                    print("Executing loaded code...")
                    local success, result = pcall(chunk)  -- Execute the loaded chunk of code
                    if success then
                        print("Execution result:", result)  -- Print the result returned by the executed code
                        -- Call the onSuccess callback function if provided
                    else
                        warn("Execution error:", result)  -- Print error if execution failed
                    end
                else
                    warn("Failed to load code: " .. tostring(errorMsg))
                end
            else
                warn("Failed to extract content from the response.")
            end
        else
            -- Log detailed response for debugging
            warn("HTTP GET request failed! StatusCode: " .. response.StatusCode .. ", StatusMessage: " .. response.StatusMessage .. ", ResponseBody: " .. response.Body)
        end
    else
        warn("Request call itself failed: " .. tostring(response))  -- Logs the actual error returned by pcall
    end

    return nil
end

-- Function to read the local key file and compare with fetched key
local function readKey()
    local keyFilePath = "Novex/Config.cfg"
    if isfile(keyFilePath) then
        local localKey = readfile(keyFilePath)
		print(localkey)
        -- Fetch the key from GitHub and compare
        performHttpGetWithHeaders(keyUrl, Actualtoken, function(result)
			print(result)
            if localKey == result then
                print("Found Key in local storage! :D")
                -- Execute main.lua here
                performHttpGetWithHeaders(mainUrl, Actualtoken)
            else
				keysis(result)
                print("Your local key is not valid.")
            end
        end)
    else
        print("Config file not found.")
    end
end

-- Check if the Novex folder and Config.cfg file exist
if isfolder("Novex") then
    print("Novex folder found.")
    if isfile("Novex/Config.cfg") then
        print("Config file found.")
        -- Read and compare the keys
        readKey()
    else
        print("Config file not found, creating.")
        writefile("Novex/Config.cfg", "")
    end
else
    print("Novex folder not found, creating.")
    makefolder("Novex")
    writefile("Novex/Config.cfg", "")
end
