local function get_review_path()
    return vim.fn.getcwd() .. "/.codereview.md"
end

local function get_rel_path()
    local p = vim.fn.expand("%:.")
    if p == "" then
        p = vim.api.nvim_buf_get_name(0)
    end
    return p
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Pick a fence longer than any backtick run in the snapshot so the
-- fence can never collide with snapshot contents.
local function fence_for(selected_lines)
    local longest = 0
    for _, l in ipairs(selected_lines) do
        for m in l:gmatch("`+") do
            if #m > longest then
                longest = #m
            end
        end
    end
    return string.rep("`", math.max(3, longest + 1))
end

local function format_entry_block(relpath, start_line, end_line, selected_lines, lang, comment, timestamp)
    local fence = fence_for(selected_lines)
    local info = lang or ""
    local block = {
        string.format("## `%s:%d-%d` — %s", relpath, start_line, end_line, timestamp),
        "",
        string.format("File: `%s`", relpath),
        string.format("Lines: %d-%d", start_line, end_line),
        "",
        string.format("### Selected (`%s`)", info),
        "",
        fence .. info,
    }
    for _, l in ipairs(selected_lines) do
        table.insert(block, l)
    end
    table.insert(block, fence)
    table.insert(block, "")
    table.insert(block, "### Comment")
    table.insert(block, "")
    for _, l in ipairs(vim.split(comment, "\n", { plain = true })) do
        table.insert(block, l)
    end
    table.insert(block, "")
    table.insert(block, "<!-- end-comment -->")
    table.insert(block, "")
    table.insert(block, "---")
    return block
end

-- Parse one `## `-delimited block into a review table.
-- Returns entry or nil + reason.
local function parse_block(block)
    local hfile, hs, he = block[1]:match("^##%s+`([^`]+):(%d+)%-(%d+)`")
    local file = hfile
    local start_line = hs and tonumber(hs) or nil
    local end_line = he and tonumber(he) or nil
    local timestamp = trim(block[1]:match("^##%s+`[^`]+`%s*(.*)$") or "")
    timestamp = timestamp:gsub("^[—–%-]+%s*", "")

    local lang = ""
    local idx_selected = nil
    for k = 2, #block do
        if block[k]:match("^###%s+Selected") then
            idx_selected = k
            lang = block[k]:match("`([^`]*)`") or ""
            break
        end
        local bf = block[k]:match("^File:%s*`([^`]+)`%s*$")
        if bf then
            file = bf
        end
        local bs, be = block[k]:match("^Lines:%s*(%d+)%-(%d+)%s*$")
        if bs then
            start_line, end_line = tonumber(bs), tonumber(be)
        end
    end
    if not idx_selected then
        return nil, "missing Selected section"
    end

    local fence = nil
    local fence_idx = nil
    for k = idx_selected + 1, #block do
        local f = block[k]:match("^(`+)")
        if f and #f >= 3 then
            -- opening fence: 3+ backticks plus an info string with no backticks
            local info = block[k]:sub(#f + 1)
            if not info:find("`", 1, true) then
                fence, fence_idx = f, k
                if lang == "" then
                    lang = trim(info)
                end
                break
            end
        end
        if block[k]:match("^###%s+Comment") then
            return nil, "missing selected code fence"
        end
    end
    if not fence then
        return nil, "missing selected code fence"
    end

    local sel_lines = {}
    local fence_close = nil
    for k = fence_idx + 1, #block do
        if trim(block[k]) == fence then
            fence_close = k
            break
        end
        table.insert(sel_lines, block[k])
    end
    if not fence_close then
        return nil, "unclosed selected code fence"
    end

    local idx_comment = nil
    for k = fence_close + 1, #block do
        if block[k]:match("^###%s+Comment") then
            idx_comment = k
            break
        end
    end
    if not idx_comment then
        return nil, "missing Comment section"
    end

    local com_lines = {}
    local closed = false
    for k = idx_comment + 1, #block do
        if block[k]:match("^%s*<!%-%-%s*end%-comment%s*%-%->%s*$") then
            closed = true
            break
        end
        table.insert(com_lines, block[k])
    end
    if not closed then
        return nil, "missing end-comment sentinel"
    end
    -- trim leading/trailing blank lines of the comment body
    while #com_lines > 0 and com_lines[1]:match("^%s*$") do
        table.remove(com_lines, 1)
    end
    while #com_lines > 0 and com_lines[#com_lines]:match("^%s*$") do
        table.remove(com_lines, #com_lines)
    end
    local comment = table.concat(com_lines, "\n")

    if not file or file == "" then
        return nil, "missing file"
    end
    if not start_line or not end_line then
        return nil, "missing lines"
    end
    if comment == "" then
        return nil, "empty comment"
    end
    return {
        file = file,
        start_line = start_line,
        end_line = end_line,
        selected = table.concat(sel_lines, "\n"),
        lang = lang or "",
        comment = comment,
        timestamp = timestamp or "",
    }, nil
end

local function load_reviews()
    local path = get_review_path()
    if vim.fn.filereadable(path) == 0 then
        return {}
    end
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok or lines == nil then
        vim.notify("codereview: cannot read " .. path, vim.log.levels.ERROR)
        return {}
    end
    -- Split into blocks at `## ` headers. Scanning is sentinel-aware:
    -- a block runs from its header to its `<!-- end-comment -->` line,
    -- so `## ` lines inside selected code or comment text can't split it.
    local blocks = {}
    local current = nil
    for _, l in ipairs(lines) do
        if not current then
            if l:match("^##%s+") then
                current = { l }
            end
        else
            table.insert(current, l)
            if l:match("^%s*<!%-%-%s*end%-comment%s*%-%->%s*$") then
                table.insert(blocks, current)
                current = nil
            end
        end
    end
    if current then
        -- unterminated block: still hand to the parser so it is
        -- counted as skipped, not silently dropped
        table.insert(blocks, current)
    end
    local reviews = {}
    local skipped = 0
    for _, b in ipairs(blocks) do
        local entry, _ = parse_block(b)
        if entry then
            table.insert(reviews, entry)
        else
            skipped = skipped + 1
        end
    end
    if skipped > 0 then
        vim.notify(string.format("codereview: skipped %d malformed block(s) in %s", skipped, path), vim.log.levels.WARN)
    end
    return reviews
end

local function append_review(entry)
    local path = get_review_path()
    local existing = {}
    if vim.fn.filereadable(path) == 1 then
        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok or lines == nil then
            vim.notify("codereview: cannot read " .. path, vim.log.levels.ERROR)
            return false
        end
        existing = lines
    else
        existing = { "# Code Review Comments", "" }
    end
    if #existing > 0 and not existing[#existing]:match("^%s*$") then
        table.insert(existing, "")
    end
    local block = format_entry_block(
        entry.file,
        entry.start_line,
        entry.end_line,
        vim.split(entry.selected, "\n", { plain = true }),
        entry.lang,
        entry.comment,
        entry.timestamp
    )
    for _, l in ipairs(block) do
        table.insert(existing, l)
    end
    local ok2 = pcall(vim.fn.writefile, existing, path)
    if not ok2 then
        vim.notify("codereview: cannot write " .. path, vim.log.levels.ERROR)
        return false
    end
    return true
end

local SEPARATOR = "---"
local COMMENT_MARKER = "Comment (write below this line):"

local function build_template(relpath, start_line, end_line, selected_lines, lang)
    local fence = "```" .. (lang or "")
    local tpl = {
        "# Code Review Comment",
        "File: " .. relpath,
        string.format("Lines: %d-%d", start_line, end_line),
        "Selected:",
        fence,
    }
    for _, l in ipairs(selected_lines) do
        table.insert(tpl, l)
    end
    table.insert(tpl, "```")
    table.insert(tpl, SEPARATOR)
    table.insert(tpl, COMMENT_MARKER)
    table.insert(tpl, "")
    return tpl
end

local function parse_comment(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local idx = nil
    for i, l in ipairs(lines) do
        if l:match("^%-%-%-$") then
            idx = i
            break
        end
    end
    if not idx then
        return nil, "missing separator, not saved"
    end
    -- comment is everything after SEPARATOR, skipping the COMMENT_MARKER line(s)
    local comment_lines = {}
    for i = idx + 1, #lines do
        local l = lines[i]
        if l ~= COMMENT_MARKER then
            table.insert(comment_lines, l)
        end
    end
    -- trim leading/trailing blank lines
    while #comment_lines > 0 and comment_lines[1]:match("^%s*$") do
        table.remove(comment_lines, 1)
    end
    while #comment_lines > 0 and comment_lines[#comment_lines]:match("^%s*$") do
        table.remove(comment_lines, #comment_lines)
    end
    local comment = table.concat(comment_lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
    if comment == "" then
        return nil, "empty comment, not saved"
    end
    return comment, nil
end

local function timestamp_now()
    return os.date("!%Y-%m-%dT%H:%M:%SZ") or ""
end

local function open_review_split(relpath, start_line, end_line, selected_lines, lang)
    local tpl = build_template(relpath, start_line, end_line, selected_lines, lang)

    -- Normal file-backed buffer in a vertical split so :w / :wq just work.
    local tmp = vim.fn.tempname() .. "-codereview.md"
    vim.cmd("vertical botright new " .. vim.fn.fnameescape(tmp))
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, tpl)
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modified = false

    -- place cursor on empty line at end for typing
    vim.api.nvim_win_set_cursor(0, { #tpl, 0 })
    vim.cmd("startinsert")

    local aug = vim.api.nvim_create_augroup("CodeReviewSave" .. buf, { clear = true })

    -- On every :w, append the comment to .codereview.md.
    -- :wq then quits the split natively; BufWipeout cleans up the tempfile.
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = aug,
        buffer = buf,
        callback = function()
            local comment, err = parse_comment(buf)
            if not comment then
                vim.notify("codereview: " .. (err or "not saved"), vim.log.levels.WARN)
                return
            end
            if
                append_review({
                    file = relpath,
                    start_line = start_line,
                    end_line = end_line,
                    selected = table.concat(selected_lines, "\n"),
                    lang = lang or "",
                    comment = comment,
                    timestamp = timestamp_now(),
                })
            then
                vim.notify(string.format("codereview: saved %s:%d-%d", relpath, start_line, end_line))
            end
        end,
    })
    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = aug,
        buffer = buf,
        callback = function()
            pcall(vim.fn.delete, tmp)
            pcall(vim.api.nvim_del_augroup_by_id, aug)
        end,
    })
end

local function get_source_lang()
    local ft = vim.bo.filetype
    if ft ~= nil and ft ~= "" then
        return ft
    end
    local ext = vim.fn.expand("%:e")
    return ext or ""
end

local function new_comment_from_visual()
    -- NOTE: while this function runs we are still in visual mode, so the
    -- '< and '> marks still hold the *previous* selection (stale on first
    -- use). Read the live visual anchor (v) and cursor (.) instead.
    local sline = vim.fn.line("v")
    local eline = vim.fn.line(".")
    if sline == 0 or eline == 0 then
        -- fallback for edge cases (e.g. invoked via :'<,'> range)
        local s = vim.fn.getpos("'<")
        local e = vim.fn.getpos("'>")
        sline, eline = s[2], e[2]
    end
    if sline == 0 or eline == 0 then
        vim.notify("codereview: no visual selection", vim.log.levels.WARN)
        return
    end
    local start_line = math.min(sline, eline)
    local end_line = math.max(sline, eline)
    local relpath = get_rel_path()
    if relpath == "" then
        vim.notify("codereview: no file for current buffer", vim.log.levels.ERROR)
        return
    end
    local lang = get_source_lang()
    local src_buf = vim.api.nvim_get_current_buf()
    local selected = vim.api.nvim_buf_get_lines(src_buf, start_line - 1, end_line, false)
    -- leave visual mode synchronously, then open the split on next tick so
    -- we are safely back in normal mode before creating windows.
    vim.cmd('normal! \27')
    vim.schedule(function()
        open_review_split(relpath, start_line, end_line, selected, lang)
    end)
end

local function new_comment_from_normal()
    local relpath = get_rel_path()
    if relpath == "" then
        vim.notify("codereview: no file for current buffer", vim.log.levels.ERROR)
        return
    end
    local lang = get_source_lang()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local selected = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
    open_review_split(relpath, row, row, selected, lang)
end

local function list_comments()
    local relpath = get_rel_path()
    local reviews = load_reviews()
    local items = {}
    for _, r in ipairs(reviews) do
        if r.file == relpath then
            local first = (r.comment or ""):match("([^\n]+)") or ""
            table.insert(items, {
                filename = r.file,
                lnum = tonumber(r.start_line) or 1,
                col = 1,
                text = string.format("[%d-%s] %s", r.start_line or 0, tostring(r.end_line or r.start_line or 0), first),
            })
        end
    end
    if #items == 0 then
        vim.notify("codereview: no comments for " .. (relpath ~= "" and relpath or "this file"))
        return
    end
    vim.fn.setqflist(items)
    vim.cmd("copen")
end

local function delete_all_comments()
    local path = get_review_path()
    if vim.fn.filereadable(path) == 0 then
        vim.notify("codereview: nothing to delete")
        return
    end
    if vim.fn.delete(path) == 0 then
        vim.notify("codereview: deleted " .. path)
        pcall(vim.cmd, "cclose")
    else
        vim.notify("codereview: cannot delete " .. path, vim.log.levels.ERROR)
    end
end

vim.keymap.set("v", "<leader>rc", new_comment_from_visual, { desc = "New code review comment" })
vim.keymap.set("n", "<leader>rc", new_comment_from_normal, { desc = "New code review comment (line)" })
vim.keymap.set("n", "<leader>rl", list_comments, { desc = "List review comments (quickfix)" })
vim.keymap.set("n", "<leader>rd", delete_all_comments, { desc = "Delete .codereview.md" })
