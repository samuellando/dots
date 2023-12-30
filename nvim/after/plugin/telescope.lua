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
	if #text > 0 then
		return text
	else
		return ''
	end
end

local telescope_stack = {}
function telescope_resume(func, id, force)
    function indexOf(array, value)
        for i, v in ipairs(array) do
            if v == value then
                return i
            end
        end
        return -1
    end

    return function()
        local i = indexOf(telescope_stack, id)
        if i >= 0 then
            table.remove(telescope_stack, i)
            table.insert(telescope_stack, 1, id)
            if not force then
                builtin.resume({cache_index=i})
                return
            end
        else
            table.insert(telescope_stack, 1, id)
        end
        func()
    end
end

function telescope_register(key,func)
    vim.keymap.set('n', '<leader>'..key, telescope_resume(func, key))
    vim.keymap.set('v', '<leader>'..key, telescope_resume(function() 
        func({ default_text = getVisualSelection() })
    end, key, true))
end

vim.keymap.set('n', '<C-p>', builtin.git_files, {})

telescope_register("pf", builtin.find_files)
telescope_register("pl", builtin.live_grep)

--- Jeppesen: Live grep but only for core ---
function telescope_sys(args)
    local t = {search_dirs={"./sys"}}
    for k,v in pairs(args) do t[k] = v end
    t.default_text = t.default_text:gsub("\\d%+", ".*")
    builtin.live_grep(t)
end

--- Jeppesen: Search core behave steps with a fuzzy finder ---
function fuzzy_core_test(args)
    args = args or {default_text = ""}
    local t = {
        search_dirs={"./sys/lib/python/behavesteps"}, 
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

function fuzzy_test(args)
    args = args or {}
    local t = {
        search_dirs={"./usr/behave/features"}, 
        search="",
        only_sort_text=true,
        word_match="-w",
        shorten_path = true
    }
    for k,v in pairs(args) do t[k] = v end
    builtin.grep_string(t)
end

--- Jeppesen specific commands ----
telescope_register("ps", telescope_sys)
telescope_register("fs", fuzzy_core_test)
telescope_register("ft", fuzzy_test)
