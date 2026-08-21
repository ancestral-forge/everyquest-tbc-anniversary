local roots = {...}
if #roots == 0 then
	roots = {"."}
end

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function collect_lua_files(root)
	local command = "find " .. shell_quote(root) .. " -type f -name '*.lua' | sort"
	local pipe = assert(io.popen(command, "r"))
	local files = {}

	for file in pipe:lines() do
		if file ~= "./tools/check-lua51-compat.lua" and file ~= "tools/check-lua51-compat.lua" then
			files[#files + 1] = file
		end
	end

	local ok, _, status = pipe:close()
	if ok == nil and status ~= 0 then
		error("failed to list Lua files under " .. root)
	end

	return files
end

local function is_identifier_byte(byte)
	return byte and (byte == 95 or byte >= 48 and byte <= 57 or byte >= 65 and byte <= 90 or byte >= 97 and byte <= 122)
end

local function contains_token(line, token)
	local start_at = 1
	while true do
		local first, last = line:find(token, start_at, true)
		if not first then
			return false
		end

		if not is_identifier_byte(line:byte(first - 1)) and not is_identifier_byte(line:byte(last + 1)) then
			return true
		end

		start_at = last + 1
	end
end

local lua52_api_tokens = {
	["table.unpack"] = "use Lua 5.1 global unpack",
	["package.searchers"] = "Lua 5.1 uses package.loaders",
	["rawlen"] = "not available in Lua 5.1",
	["utf8"] = "not available in Lua 5.1",
	["bit32"] = "not available in Lua 5.1",
	["math.type"] = "not available in Lua 5.1",
	["math.maxinteger"] = "not available in Lua 5.1",
	["math.mininteger"] = "not available in Lua 5.1",
	["string.pack"] = "not available in Lua 5.1",
	["string.unpack"] = "not available in Lua 5.1",
	["string.packsize"] = "not available in Lua 5.1",
	["table.move"] = "not available in Lua 5.1",
	["table.pack"] = "not available in Lua 5.1",
	["_ENV"] = "not available in Lua 5.1",
	["__pairs"] = "not available in Lua 5.1",
	["__ipairs"] = "not available in Lua 5.1",
}

local function check_lua52_plus_api_tokens(file)
	local handle = assert(io.open(file, "r"))
	local line_number = 0
	local failed = false

	for line in handle:lines() do
		line_number = line_number + 1
		line = line:gsub("%-%-.*", "")

		for token, replacement in pairs(lua52_api_tokens) do
			if contains_token(line, token) then
				io.stderr:write(("%s:%d: Lua 5.2+ API %s; %s\n"):format(file, line_number, token, replacement))
				failed = true
			end
		end
	end

	handle:close()
	return not failed
end

local files = {}
for _, root in ipairs(roots) do
	for _, file in ipairs(collect_lua_files(root)) do
		files[#files + 1] = file
	end
end

if #files == 0 then
	print("No Lua files found.")
	os.exit(0)
end

print("Checking Lua 5.1 syntax...")
local failed = false
for _, file in ipairs(files) do
	local chunk, err = loadfile(file)
	if not chunk then
		io.stderr:write(file .. ": " .. tostring(err) .. "\n")
		failed = true
	end
end

print("Checking for common Lua 5.2+ standard-library usage...")
for _, file in ipairs(files) do
	if not check_lua52_plus_api_tokens(file) then
		failed = true
	end
end

if failed then
	os.exit(1)
end

print("Lua 5.1 compatibility checks passed.")
