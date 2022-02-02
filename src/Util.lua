local function joinDictionaries(...)
	local out = {}
	for i = 1, select("#", ...) do
		for key, val in pairs(select(i, ...)) do
			out[key] = val
		end
	end
	return out
end

local function ReplaceNewlines(Text)
	return Text and Text:gsub("\n", ",") or ""
end

local function ExtractIDs(Text)
	local IDs = {}

	for ID, _ in Text:gmatch('[^,]+') do
		table.insert(IDs, tonumber(ID))
	end

	return IDs
end

local function Sanitize(Text)
	Text = ReplaceNewlines(Text)
	Text = Text:gsub("[^%d,]+", "")
	return Text
end

return {
	joinDictionaries = joinDictionaries,
	ReplaceNewlines = ReplaceNewlines,
	ExtractIDs = ExtractIDs,
	Sanitize = Sanitize
}