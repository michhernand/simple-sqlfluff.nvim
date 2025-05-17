local M = {}

M.options = {}

M.autocommand_toggle = true

M.defaults = {
	autocommands = {
		enabled = true,
		events = {
			"BufReadPost",
			"InsertLeave",
		},
		extensions = {
			"*.sql",
		},
	},
}

function M.resolve_opts(options)
	M.options = vim.tbl_deep_extend(
		"force",
		{}, M.defaults,
		options or {}
	)
end

return M

