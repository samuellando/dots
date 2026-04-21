require('telescope').setup {
    pickers = {
        find_files = {
            follow = true,
            no_ignore = true,
            hidden = true
        },
        live_grep = {
            additional_args = {
                "-L",
                "--no-ignore",
                "--hidden"
            }
        }
    }
}

local builtin = require('telescope.builtin')

function getVisualSelection()
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg('v')
    vim.fn.setreg('v', {})

    text = string.gsub(text, "\n", "")
    if string.len(text) > 0 then
        return text
    else
        return ''
    end
end

function ts_call(func, inArgs)
    return function()
        local copy = {}
        for k, v in pairs(inArgs) do
            copy[k] = v
        end
        local args = copy or {}
        -- Check if it's been used.
        if vim.fn.mode() ~= "n" then
            args["default_text"] = getVisualSelection()
        end
        func(args)
    end
end

-- Fuzzy find on file contents
function fuzzy_contents(args)
    args = args or {}
    args["default_text"] = args["default_text"] or ""
    local t = {
        search = "",
        only_sort_text = true,
        word_match = "-w",
        shorten_path = true
    }
    for k, v in pairs(args) do t[k] = v end
    t.default_text = t.default_text:gsub("\\d%+", "")
    t.default_text = t.default_text:gsub("%.%*", "")
    builtin.grep_string(t)
end

-- Format: <leader> VERB NOUN --
--
-- verbs:
--      pl : live grep
--      pf : fuzzy seach file names
--      ff : fuzzy find file contents
--

local verbs = {
    pl = { desc = "grep", func = builtin.live_grep },
    pf = { desc = "fuzzy titles", func = builtin.find_files },
    ff = { desc = "fuzzy contents", func = fuzzy_contents },
}

local Menu = require("nui.menu")

local popup_options = {
    position = "50%",
    size = {
        width = 50,
        height = 10,
    },
    border = {
        style = "rounded",
        text = {
            top = "[Where?]",
            top_align = "center",
        },
    },
    win_options = {
        winhighlight = "Normal:Normal",
    }
}

for verb, d in pairs(verbs) do
    -- Register the default path
    vim.keymap.set({ 'n', 'v' }, '<leader>' .. verb, ts_call(
        d.func,
        { prompt_title = d.desc }
    ))
    -- Register menu for paths
    vim.keymap.set({ 'n', 'v' }, '<leader>x' .. verb, function()
        local nouns = {}
        -- Setup in the local project config
        if vim.g.telescope_nouns ~= nil then
            nouns = vim.g.telescope_nouns
        end

        local menu_lines = {
            Menu.item("Current", {
                key = "cur",
                path = function()
                    local relative_path = vim.fn.expand("%:.")
                    return vim.fn.fnamemodify(relative_path, ":h")
                end
            })
        }
        for _, d in ipairs(nouns) do
            table.insert(menu_lines, Menu.item(d.desc, { key = d.key, path = d.path }))
        end

        local selected_verb = verb

        local was_visual = false
        if vim.fn.mode() == "V" or vim.fn.mode() == "v" then
            was_visual = true
        end

        local menu = Menu(popup_options, {
            lines = menu_lines,
            max_width = 50,
            keymap = {
                focus_next = { "j", "<Down>", "<Tab>" },
                focus_prev = { "k", "<Up>", "<S-Tab>" },
                close = { "<Esc>", "<C-c>" },
                submit = { "<CR>", "<Space>" },
            },
            on_submit = function(item)
                local sverb = selected_verb
                local sd = verbs[sverb]

                if type(item.path) == "function" then
                    item.path = item.path()
                end

                local args = { prompt_title = d.desc .. " " .. item.path, search_dirs = { item.path } }
                if was_visual then
                    vim.cmd("normal gv")
                end
                ts_call(sd.func, args)()
            end,
        })

        menu:mount()
    end)
end
