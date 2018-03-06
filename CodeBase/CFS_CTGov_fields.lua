local luaLog = get_log("lua")
local config = get_config()

local output_date_format = "YYYY-MM-DD HH:NN:SS"

function handler(document)

	goodDRETitle(document, "DRETITLE", "**No Title**")
	goodDREDate(document, "DREDATE", output_date_format, "1970-01-01 00:00:00")
	changeDREFIELDName(document,"clinical_study/condition","CONDITIONS")
	
	--viewurl(document, "DREREFERENCE", "https://clinicaltrials.gov")
	
	return true
end

function goodDRETitle(document, dest_fieldname, nil_value)
	local dretitle = document:getValueByPath("clinical_study/brief_title")
	if (dretitle ~= nil) then
		document:setFieldValue(dest_fieldname, dretitle)
	else
		luaLog:write_line(log_level_error(), dest_fieldname .. " source field is nil. " .. document:getReference())
		document:setFieldValue(dest_fieldname, nil_value)
	end
end

function goodDREDate(document, dest_fieldname, output_date_format, nil_value)
	-- #DREFIELD clinical_study/last_update_posted="October 27, 2017"
	local dredate = document:getValueByPath("clinical_study/last_update_posted")
	if (dredate ~= nil) then
		-- convert to standard format
		local input_date_format = "LONGMONTH DD YYYY"
		-- deal with the comma in source value.  Remove it to make convert_date_time() happy.
		dredate = string.gsub(dredate, ",", "")
		dredate = convert_date_time(dredate, input_date_format, output_date_format)
		if (dredate ~= nil) then
			document:setFieldValue(dest_fieldname, dredate)
		else
			luaLog:write_line(log_level_error(), "convert_date_time() failed. " .. document:getReference())
		end
	else
		luaLog:write_line(log_level_error(), dest_fieldname .. " source field is nil. " .. document:getReference())

		document:setFieldValue(dest_fieldname, nil_value)
	end
end

function viewurl(document, dest_fieldname, nil_value)
	local viewurl = document:getValueByPath("clinical_study/required_header/url")
	if (viewurl ~= nil) then
		document:setFieldValue(dest_fieldname, viewurl)
	else
		luaLog:write_line(log_level_error(), dest_fieldname .. " source field is nil. " .. document:getReference())

		document:setFieldValue(dest_fieldname, nil_value)
	end
end

function changeDREFIELDName(document, dest_fieldname, new_fieldname)
	local destFieldValues = { document:getValuesByPath(dest_fieldname) }
	if (destFieldValues ~= nil) then
		for ivalue,destFieldValue in ipairs(destFieldValues) do
			document:addField(new_fieldname, destFieldValue)
		end	
	else
		luaLog:write_line(log_level_error(), dest_fieldname .. " source field is nil. " .. document:getReference())
	end
end