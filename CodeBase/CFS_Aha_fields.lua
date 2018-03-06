local luaLog = get_log("lua")
local config = get_config()

local output_date_format = "YYYY-MM-DD HH:NN:SS"

function handler(document)

	goodDRETitle(document, "DRETITLE", "**No Title**")
	goodDREDate(document, "DREDATE", output_date_format, "1970-01-01 00:00:00")
	changeDREFIELDName(document,"MEDICAL_CONDITIONS/value","CONDITIONS")
	--goodFILEACCESSEDTIME(document, "FILEACCESSEDTIME",output_date_format, "1970-01-01 00:00:00")
	
	changeDateFormat(document, "1970-01-01 00:00:00")
	
	return true
end

function goodDRETitle(document, dest_fieldname, nil_value)
	local dretitle = document:getFieldValue("Title")
	if (dretitle ~= nil) then
		document:setFieldValue(dest_fieldname, dretitle)
	else
		dretitle = document:getFieldValue("Subject")
		if( dretitle ~= nil) then
			document:setFieldValue(dest_fieldname, dretitle)
		else
			local filepath = document:getFieldValue("DREREFERENCE")
			if (filepath ~= nil) then
				local lastslash = string.find(filepath, "\\[^\\]*$")
				local lastdotpos = string.find(string.reverse(filepath),"%.")
				local pathlen =  string.len(filepath)
				dretitle = string.sub(filepath, lastslash+1, pathlen-lastdotpos)
			
				document:setFieldValue(dest_fieldname, dretitle)
			else
				luaLog:write_line(log_level_error(), "DREREFERENCE" .. " source field is nil. " .. document:getReference())
				document:setFieldValue(dest_fieldname, nil_value)
			end
		end
	end
end

function goodDREDate(document, dest_fieldname, output_date_format, nil_value)
	-- MHT - #DREFIELD FileModifiedTime="1500367421"
	local dredate = nil
	dredate = document:getFieldValue("FileModifiedTime")
	if (dredate ~= nil) then
	-- convert to standard format
		local input_date_format = "EPOCHSECONDS"
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

function changeDateFormat(document, nil_value)
	-- MHT - #DREFIELD FileModifiedTime="1500367421"
	local modifieddate = nil
	local accessdate = nil
	local createdate = nil
	local importdate = nil
	local output_format = "LONGMONTH DD YYYY"
	local input_date_format = "EPOCHSECONDS"
	
	modifieddate = document:getFieldValue("FileModifiedTime")
	accessdate = document:getFieldValue("FileAccessedTime")
	createdate = document:getFieldValue("FileCreatedTime")
	importdate = document:getFieldValue("FileImportedTime")
	
	if (modifieddate ~= nil) then		
		-- deal with the comma in source value.  Remove it to make convert_date_time() happy.
		modifieddate = string.gsub(modifieddate, ",", "")
		modifieddate = convert_date_time(modifieddate, input_date_format, output_format)
		if (modifieddate ~= nil) then
			document:setFieldValue("FileModifiedTime", modifieddate)
		else
			luaLog:write_line(log_level_error(), "convert_date_time() failed. " .. document:getReference())
		end
	else
		luaLog:write_line(log_level_error(), "FileModifiedTime source field is nil. " .. document:getReference())

		document:setFieldValue("FileModifiedTime", nil_value)
	end	
	
	if (accessdate ~= nil) then		
		-- deal with the comma in source value.  Remove it to make convert_date_time() happy.
		accessdate = string.gsub(accessdate, ",", "")
		accessdate = convert_date_time(accessdate, input_date_format, output_format)
		if (accessdate ~= nil) then
			document:setFieldValue("FileAccessedTime", accessdate)
		else
			luaLog:write_line(log_level_error(), "convert_date_time() failed. " .. document:getReference())
		end
	else
		luaLog:write_line(log_level_error(), "FileAccessedTime source field is nil. " .. document:getReference())

		document:setFieldValue("FileAccessedTime", nil_value)
	end	
	
	if (createdate ~= nil) then		
		-- deal with the comma in source value.  Remove it to make convert_date_time() happy.
		createdate = string.gsub(createdate, ",", "")
		createdate = convert_date_time(createdate, input_date_format, output_format)
		if (createdate ~= nil) then
			document:setFieldValue("FileCreatedTime", createdate)
		else
			luaLog:write_line(log_level_error(), "convert_date_time() failed. " .. document:getReference())
		end
	else
		luaLog:write_line(log_level_error(), "FileCreatedTime source field is nil. " .. document:getReference())

		document:setFieldValue("FileCreatedTime", nil_value)
	end
	
	if (importdate ~= nil) then		
		-- deal with the comma in source value.  Remove it to make convert_date_time() happy.
		importdate = string.gsub(importdate, ",", "")
		importdate = convert_date_time(importdate, input_date_format, output_format)
		if (importdate ~= nil) then
			document:setFieldValue("FileImportedTime", importdate)
		else
			luaLog:write_line(log_level_error(), "convert_date_time() failed. " .. document:getReference())
		end
	else
		luaLog:write_line(log_level_error(), "FileImportedTime source field is nil. " .. document:getReference())

		document:setFieldValue("FileImportedTime", nil_value)
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
