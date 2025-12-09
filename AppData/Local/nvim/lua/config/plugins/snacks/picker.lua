local picker = {
    prompt = " ",
    sources = {},
    focus = "input",
    layout = {
        cycle = true,
        --- Use the default layout or vertical if the window is too narrow
        preset = function()
            return vim.o.columns >= 120 and "default" or "vertical"
        end,
    },
    ---@class snacks.picker.matcher.Config
    matcher = {
        fuzzy = true,          -- use fuzzy matching
        smartcase = true,      -- use smartcase
        ignorecase = true,     -- use ignorecase
        sort_empty = false,    -- sort results when the search string is empty
        filename_bonus = true, -- give bonus for matching file names (last part of the path)
        file_pos = true,       -- support patterns like `file:line:col` and `file:line`
        -- the bonusses below, possibly require string concatenation and path normalization,
        -- so this can have a performance impact for large lists and increase memory usage
        cwd_bonus = false,     -- give bonus for matching files in the cwd
        frecency = false,      -- frecency bonus
        history_bonus = false, -- give more weight to chronological order
    },
    sort = {
        -- default sort is by score, text length and index
        fields = { "score:desc", "#text", "idx" },
    },
    ui_select = true, -- replace `vim.ui.select` with the snacks picker
    ---@class snacks.picker.formatters.Config
    formatters = {
        text = {
            ft = nil, ---@type string? filetype for highlighting
        },
        file = {
            filename_first = false, -- display filename before the file path
            truncate = 40,          -- truncate the file path to (roughly) this length
            filename_only = false,  -- only show the filename
            icon_width = 2,         -- width of the icon (in characters)
            git_status_hl = true,   -- use the git status highlight group for the filename
        },
        selected = {
            show_always = false, -- only show the selected column when there are multiple selections
            unselected = true,   -- use the unselected icon for unselected items
        },
        severity = {
            icons = true,  -- show severity icons
            level = false, -- show severity level
            ---@type "left"|"right"
            pos = "left",  -- position of the diagnostics
        },
    },
    ---@class snacks.picker.previewers.Config
    previewers = {
        git = {
            native = false, -- use native (terminal) or Neovim for previewing git diffs and commits
            args = {},      -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
        },
        file = {
            max_size = 1024 * 1024, -- 1MB
            max_line_length = 500,  -- max line length
            ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
        },
        man_pager = nil, ---@type string? MANPAGER env to use for `man` preview
    },
    ---@class snacks.picker.jump.Config
    jump = {
        disabled = true,
    },
    toggles = {
        follow = "f",
        hidden = "h",
        ignored = "i",
        modified = "m",
        regex = { icon = "R", value = false },
    },
    win = {
        -- input window
        input = {
            disabled = true,
        },
        -- result list window
        list = {
            disabled = true,
        },
        -- preview window
        preview = {
            keys = {
                ["<Esc>"] = "close",
                ["q"] = "close",
                ["i"] = "focus_input",
                ["<ScrollWheelDown>"] = "list_scroll_wheel_down",
                ["<ScrollWheelUp>"] = "list_scroll_wheel_up",
                ["<a-w>"] = "cycle_win",
            },
        },
    },
    ---@class snacks.picker.icons
    icons = {
        files = {
            enabled = true, -- show file icons
            dir = "󰉋 ",
            dir_open = "󰝰 ",
            file = "󰈔 "
        },
        keymaps = {
            nowait = "󰓅 "
        },
        tree = {
            vertical = "│ ",
            middle   = "├╴",
            last     = "└╴",
        },
        undo = {
            saved = " ",
        },
        ui = {
            live       = "󰐰 ",
            hidden     = "h",
            ignored    = "i",
            follow     = "f",
            selected   = "● ",
            unselected = "○ ",
            -- selected = " ",
        },
        git = {
            enabled   = true, -- show git icons
            commit    = "󰜘 ", -- used by git log
            staged    = "●", -- staged changes. always overrides the type icons
            added     = "",
            deleted   = "",
            ignored   = " ",
            modified  = "○",
            renamed   = "",
            unmerged  = " ",
            untracked = "?",
        },
        diagnostics = {
            Error = " ",
            Warn  = " ",
            Hint  = " ",
            Info  = " ",
        },
        lsp = {
            unavailable = "",
            enabled = " ",
            disabled = " ",
            attached = "󰖩 "
        },
        kinds = {
            Array         = " ",
            Boolean       = "󰨙 ",
            Class         = " ",
            Color         = " ",
            Control       = " ",
            Collapsed     = " ",
            Constant      = "󰏿 ",
            Constructor   = " ",
            Copilot       = " ",
            Enum          = " ",
            EnumMember    = " ",
            Event         = " ",
            Field         = " ",
            File          = " ",
            Folder        = " ",
            Function      = "󰊕 ",
            Interface     = " ",
            Key           = " ",
            Keyword       = " ",
            Method        = "󰊕 ",
            Module        = " ",
            Namespace     = "󰦮 ",
            Null          = " ",
            Number        = "󰎠 ",
            Object        = " ",
            Operator      = " ",
            Package       = " ",
            Property      = " ",
            Reference     = " ",
            Snippet       = "󱄽 ",
            String        = " ",
            Struct        = "󰆼 ",
            Text          = " ",
            TypeParameter = " ",
            Unit          = " ",
            Unknown       = " ",
            Value         = " ",
            Variable      = "󰀫 ",
        },
    },
    ---@class snacks.picker.db.Config
    db = {
        disabled = true,
    },
    ---@class snacks.picker.debug
    debug = {
        disabled = true,
    },
}

return picker
