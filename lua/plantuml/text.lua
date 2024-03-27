local utils = require('plantuml.utils')

local M = {}

M.Renderer = {}

function M.Renderer:new(flag)
    local buf = vim.api.nvim_create_buf(false, true)
    assert(buf ~= 0, string.format('[plantuml.nvim] Failed to create buffer'))
    assert(flag == "txt" or flag == "utxt", string.format('[plantuml.nvim] Invalid text renderer flag'))

    self.__index = self
    return setmetatable({ buf = buf, flag = flag, win = nil }, self)
end

function M.Renderer:render(file)
    utils.Command:new(string.format('plantuml -pipe -t' .. self.flag .. ' < %s', file)):start(function(output)
        self:_write_output(output)
        self:_create_split()
    end)
end

function M.Renderer:_write_output(output)
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, true, output)
end

function M.Renderer:_create_split()
    -- Only create the window if it's not already created.
    if not (self.win and vim.api.nvim_win_is_valid(self.win)) then
        vim.cmd('vsplit')
        self.win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(self.win, self.buf)
    end
end

return M
