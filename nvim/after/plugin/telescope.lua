require('telescope').setup {
    defaults = {
        cache_picker = {
            num_pickers = 10
        }
    },
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

local telescope_stack = {}
-- Make a telescope window resumable
function telescope_make_resumeable(id, func, args)
    args = args or {}
    -- Helper function, get the index of value in array
    function indexOf(array, value)
        for i, v in ipairs(array) do
            if v == value then
                return i
            end
        end
        return -1
    end

    return function()
        -- Check if it's been used.
        local i = indexOf(telescope_stack, id)
        if i >= 0 then
            -- Shift it the the top of the stack.
            table.remove(telescope_stack, i)
            table.insert(telescope_stack, 1, id)
            if vim.fn.mode() == "n" then
                builtin.resume({cache_index=i})
                return
            end
        else
            table.insert(telescope_stack, 1, id)
        end
        -- Call the supplied function.
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
        search="",
        only_sort_text=true,
        word_match="-w",
        shorten_path = true
    }
    for k,v in pairs(args) do t[k] = v end
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
    pl      = {desc="grep", func=builtin.live_grep},
    pf      = {desc="fuzzy titles", func=builtin.find_files},
    ff      = {desc="fuzzy contents", func=fuzzy_contents},
}

local nouns = {
    {key="ju", desc="config", path="./usr"},
    {key="js", desc="core", path="./sys"},
    {key="jut", desc="tests", path="./usr/behave/features"},
    {key="juts", desc="config behave steps", path="./usr/behave/steps"},
    {key="jsts", desc="core behave steps", path="./sys/lib/python/behavesteps"}
}

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

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

local menu_lines = {}
for i, d in ipairs(nouns) do
    table.insert(menu_lines, Menu.item(d.desc, {key=d.key, path=d.path}))
end

local selected_verb = ""
local was_visual = false

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
    local verb = selected_verb
    local d = verbs[verb]

    local args = {prompt_title=d.desc.." "..item.text, search_dirs={item.path}} 
    if was_visual then
        vim.cmd("normal gv")
    end
    telescope_make_resumeable(verb..item.key, d.func, args)()
  end,
})

for verb, d in pairs(verbs) do
    -- Register the default path
    vim.keymap.set({'n', 'v'}, '<leader>'..verb, telescope_make_resumeable(
      verb, 
      d.func,
      {prompt_title=d.desc}
    ))
    -- Register menu for paths
    vim.keymap.set({'n', 'v'}, '<leader>x'..verb, function()
        selected_verb = verb
        if vim.fn.mode() == "V" or vim.fn.mode() == "v" then
            was_visual = true
        else
            was_visual = false
        end
        menu:mount()

    end)
end

