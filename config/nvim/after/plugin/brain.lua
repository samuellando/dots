local special_tags = {
    " #cron%(.*%)",
    " #snooze%(.*%)"
}

local function format_date(date)
    local timestamp = os.time(date)
    return os.date("%Y-%m-%d", timestamp)
end

local function snooze_matches(line, date)
    date = date or os.date("*t")
    local snooze_date = string.match(line, "#snooze%((%d%d%d%d%-%d%d%-%d%d)%)")
    return format_date(date) == snooze_date
end

local function cron_matches(line, date)
    date = date or os.date("*t")
    local day, month_expr, dow_expr = string.match(line, "#cron%(([^%s]+)%s+([^%s]+)%s+([^%s]+)%)")
    local today_wday = tonumber(os.date("%w", os.time(date)))
    if day then
        -- Convert string day or "*" to number
        local match_day = (day == "*" or tonumber(day) == date.day)
        -- Month logic
        local match_month = false
        if month_expr == "*" then
            match_month = true
        else
            for m in string.gmatch(month_expr, "[^,]+") do
                if tonumber(m) == date.month then
                    match_month = true
                    break
                end
            end
        end
        -- Day-of-week logic (cron: 0=Sunday)
        local match_dow = false
        if dow_expr == "*" then
            match_dow = true
        else
            for w in string.gmatch(dow_expr, "[^,]+") do
                if tonumber(w) == today_wday then
                    match_dow = true
                    break
                end
            end
        end
        if match_day and match_month and match_dow then
            return true
        end
    end
    return false
end

local function remove_special_tags(todos)
    local n = {}
    for _, todo in ipairs(todos) do
        for _, pat in ipairs(special_tags) do
            todo.line = string.gsub(todo.line, pat, "")
        end
        table.insert(n, todo)
    end
    return n
end

local function has_special_tag(todo)
    for _, pat in ipairs(special_tags) do
        if string.find(todo, pat) ~= nil then
            return true
        end
    end
    return false
end

local function is_todo(todo)
    return string.find(todo, "^%- %[ %]") ~= nil
end

local function is_indent(todo)
    return string.find(todo, "^  ") ~= nil
end

local function deduplicate(todos)
    local map = {}
    for _, todo in ipairs(todos) do
        map[todo.line] = todo
    end
    local new = {}
    for _, v in pairs(map) do
        table.insert(new, v)
    end
    return new
end

local function parse_todos(s, e, pred)
    local todos = {}
    local lines = vim.api.nvim_buf_get_lines(0, s, e, false)
    local state = "GAP"
    local todo = nil
    for _, line in ipairs(lines) do
        if is_todo(line) then
            if todo ~= nil and pred(todo.line) then
                table.insert(todos, todo)
            end
            todo = { line = line, subtasks = {} }
            state = "TODO"
        elseif state == "TODO" and is_indent(line) and todo ~= nil then
            table.insert(todo.subtasks, line)
        else
            if state == "TODO" and todo ~= nil and pred(todo.line) then
                table.insert(todos, todo)
            end
            todo = nil
            state = "GAP"
        end
    end
    if state == "TODO" and todo ~= nil and pred(todo.line) then
        table.insert(todos, todo)
    end
    return todos
end

local function get_past_day_todos()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local last_heading = nil

    -- Find most recent past heading
    for i, line in ipairs(lines) do
        local date_heading = line:match("^# (%d%d%d%d%-%d%d%-%d%d)$")
        if date_heading then
            last_heading = { idx = i, date = date_heading }
        end
    end

    if not last_heading then
        return {}
    end

    -- Gather todos under last_heading until next heading or EOF
    return parse_todos(last_heading.idx + 1, -1, function(line)
        return not has_special_tag(line)
    end)
end

local function get_special_todos(date)
    return parse_todos(0, -1, function(line)
        return has_special_tag(line) and (cron_matches(line, date) or snooze_matches(line, date))
    end)
end

local function get_todos(date)
    local todos = get_past_day_todos()
    for _, todo in ipairs(get_special_todos(date)) do
        table.insert(todos, todo)
    end
    todos = remove_special_tags(todos)
    todos = deduplicate(todos)
    table.sort(todos, function(a, b)
        return a.line > b.line
    end)
    return todos
end

local function get_last_heading_date()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local last_date = nil
    for _, line in ipairs(lines) do
        local d = line:match("^# (%d%d%d%d%-%d%d%-%d%d)$")
        if d then last_date = d end
    end
    return last_date
end

local function date_str_to_time(d)
    local y, m, dd = d:match("(%d+)%-(%d+)%-(%d+)")
    return os.time { year = tonumber(y), month = tonumber(m), day = tonumber(dd) }
end

local function time_to_date(t)
    return os.date("*t", t)
end

local function get_missing_days()
    local last = get_last_heading_date()
    local missing = {}
    local t = date_str_to_time(last)
    local today = os.time()
    while true do
        t = t + 86400 -- add a day
        if t > today + 86400 then break end
        local next_date = time_to_date(t)
        table.insert(missing, next_date)
    end
    return missing
end

local function today_todos()
    local missing_days = get_missing_days()
    for _, day in ipairs(missing_days) do
        local todos = get_todos(day)
        local day_title = "# " .. format_date(day)
        vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", day_title, "", "## Todo" })
        for _, todo in ipairs(todos) do
            vim.api.nvim_buf_set_lines(0, -1, -1, false, { todo.line })
            for _, subtask in ipairs(todo.subtasks) do
                vim.api.nvim_buf_set_lines(0, -1, -1, false, { subtask })
            end
        end
    end
end

vim.api.nvim_create_user_command("TodayTodos", today_todos, {})
