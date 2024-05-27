vim.opt.showmode = false
require('lualine').setup({
    options = {
        theme = 'gruvbox-material',
        component_separators = '|',
        section_separators = { left = '', right = '' },
    },
    sections = {
        lualine_a = { {
            'mode',
            separator = { left = '', right = '' },
        } },
        lualine_c = { {
            'filename',
            file_status = true,
            newfile_status = true,
            path = 1,
        } },
        lualine_z = { {
            'location',
            separator = { left = '', right = '' },
        } },
    }
})
