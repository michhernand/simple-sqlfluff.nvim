local sett = require("simple-sqlfluff.settings")

local M = {}

M.VERSION = "0.1.0"

local function extract_violations(output)
	local output_objs = vim.json.decode(output)
	if #output_objs == 0 then
		return {}
	end

	local first_output_obj = output_objs[1]
	local violations = first_output_obj["violations"]

	if violations == nil then
		return {}
	end

	if #violations == 0 then
		return {}
	end
	return violations
end

local function prepare_one_violation(violation)
	local sev
	if violation["warning"] then
		sev = vim.diagnostic.severity.WARN
	else
		sev = vim.diagnostic.severity.ERROR
	end

	if violation["code"] == nil or violation["code"] == "" then
		return
	end

	if violation["description"] == nil or violation["description"] == "" then
		return
	end

	local msg = violation["code"] .. " :: " .. violation["description"]

	return {
		lnum = violation["start_line_no"]-1,
		col = violation["start_line_pos"],
		end_col = violation["end_line_pos"],
		severity = sev,
		message =  msg,
	}
end

local function render(violations)
	local prepared_violations = {}
	for _, violation in pairs(violations) do
		table.insert(prepared_violations, prepare_one_violation(violation))
	end
	vim.diagnostic.set(
		vim.api.nvim_create_namespace("sqlfluff"),
		0, prepared_violations
	)
end

local function lint()
	if not sett.autocommand_toggle then
		return
	end
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local sql_content = table.concat(lines, "\n")

	local cmd = "sqlfluff lint --format=json -"

	local output = vim.fn.system(cmd, sql_content)
	local violations = extract_violations(output)

	render(violations)
end

local alint = vim.loop.new_async(vim.schedule_wrap(lint))

local function toggle_autocommand()
	sett.autocommand_toggle = not sett.autocommand_toggle
end

local function format()
	local fn = vim.fn.expand('%:p')
	local cmd = "sqlfluff format " .. fn
	vim.fn.system(cmd)

	local formatted_content = vim.fn.readfile(fn)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_content)
end


function M.setup(opts)
	sett.resolve_opts(opts)

	local augroup = vim.api.nvim_create_augroup("simple-sqlfluff", { clear = true })
	local ev_ok = #sett.options.autocommands.events > 0
	local ex_ok = #sett.options.autocommands.extensions > 0
	local en = sett.options.autocommands.enabled

	if ev_ok and ex_ok and en then
		vim.api.nvim_create_autocmd(sett.options.autocommands.events, {
			group = augroup,
			pattern = sett.options.autocommands.extensions,
			callback = function() alint:send() end,
		})
	end

	vim.api.nvim_create_user_command(
		"SQLFluffToggle",
		toggle_autocommand,
		{ nargs = 0 }
	)

	vim.api.nvim_create_user_command(
		"SQLFluffEnable",
		function() sett.autocommand_toggle = true end,
		{ nargs = 0 }
	)

	vim.api.nvim_create_user_command(
		"SQLFluffDisable",
		function() sett.autocommand_toggle = false end,
		{ nargs = 0 }
	)

	vim.api.nvim_create_user_command(
		"SQLFluffFormat",
		format,
		{ nargs = 0 }
	)

end

return M
