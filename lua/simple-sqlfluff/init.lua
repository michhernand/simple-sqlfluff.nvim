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
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local sql_content = table.concat(lines, "\n")

	local cmd = "sqlfluff lint --format=json -"

	local output = vim.fn.system(cmd, sql_content)
	local violations = extract_violations(output)

	render(violations)
end

local alint = vim.loop.new_async(vim.schedule_wrap(lint))

function M.setup(opts)
	sett.resolve_opts(opts)

	local augroup = vim.api.nvim_create_augroup("simple-sqlfluff", { clear = true })

	if (#sett.options.autocommands.events > 0) and (#sett.options.autocommands.extensions > 0) and sett.options.autocommands.enabled then
		vim.api.nvim_create_autocmd(sett.options.autocommands.events, {
			group = augroup,
			pattern = sett.options.autocommands.extensions,
			callback = function() alint:send() end,
		})
	end
end

return M
