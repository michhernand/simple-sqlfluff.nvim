local M = {}

M.options = {}

M.defaults = {}

function M.resolve_opts(options)
	M.options = vim.tbl_deep_extend(
		"force",
		{}, M.defaults,
		options or {}
	)
end

return M

