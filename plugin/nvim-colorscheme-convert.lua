local function paste(data)
	vim.api.nvim_paste(data, true, -1)
end

local utils = {}

utils.buildColorsMap = function(format)
	return {
		bg = format(vim.g.terminal_color_0),
		fg = format(vim.g.terminal_color_15),
		black = format(vim.g.terminal_color_0),
		red = format(vim.g.terminal_color_1),
		green = format(vim.g.terminal_color_2),
		yellow = format(vim.g.terminal_color_3),
		blue = format(vim.g.terminal_color_4),
		magenta = format(vim.g.terminal_color_5),
		cyan = format(vim.g.terminal_color_6),
		white = format(vim.g.terminal_color_15),
		bright_black = format(vim.g.terminal_color_8),
		bright_red = format(vim.g.terminal_color_9),
		bright_green = format(vim.g.terminal_color_10),
		bright_yellow = format(vim.g.terminal_color_11),
		bright_blue = format(vim.g.terminal_color_12),
		bright_magenta = format(vim.g.terminal_color_13),
		bright_cyan = format(vim.g.terminal_color_14),
		bright_white = format(vim.g.terminal_color_15),
	}
end

utils.interpolate = function(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

local templates = {}

templates.alacritty = [[
colors:
  # Default colors
  primary:
    background: '0x${bg}'
    foreground: '0x${fg}'

  # Colors the cursor will use if `custom_cursor_colors` is true
  cursor:
    text: '0x${bg}'
    cursor: '0x${fg}'

  # Normal colors
  normal:
    black:   '0x${black}'
    red:     '0x${red}'
    green:   '0x${green}'
    yellow:  '0x${yellow}'
    blue:    '0x${blue}'
    magenta: '0x${magenta}'
    cyan:    '0x${cyan}'
    white:   '0x${white}'

  # Bright colors
  bright:
    black:   '0x${bright_black}'
    red:     '0x${bright_red}'
    green:   '0x${bright_green}'
    yellow:  '0x${bright_yellow}'
    blue:    '0x${bright_blue}'
    magenta: '0x${bright_magenta}'
    cyan:    '0x${bright_cyan}'
    white:   '0x${bright_white}'
]]

templates.kitty = [[
background ${bg}
foreground ${fg}
cursor ${fg}
cursor_text_color ${bg} 

color0 ${black}
color1 ${red}
color2 ${green}
color3 ${yellow}
color4 ${blue}
color5 ${magenta}
color6 ${cyan}
color7 ${white}
color8  ${bright_black}   
color9  ${bright_red}     
color10 ${bright_green}   
color11 ${bright_yellow}  
color12 ${bright_blue}    
color13 ${bright_magenta} 
color14 ${bright_cyan}    
color15 ${bright_white}   

selection_foreground ${bg}
selection_background ${fg}
]]

local colors = {}

colors.alacritty = function()
	local function formatter(s)
		return s:sub(2, #s)
	end

	local template = templates.alacritty
	local input = utils.buildColorsMap(formatter)
	return utils.interpolate(template, input)
end

colors.kitty = function()
	local function formatter(s)
		return s
	end

	local template = templates.kitty
	local input = utils.buildColorsMap(formatter)
	return utils.interpolate(template, input)
end

vim.api.nvim_create_user_command("ColorschemeDump", function(cmd)
	paste(colors[cmd.args]())
end, {
	bang = true,
	desc = "Paste colors in format $1",
	nargs = 1,
	bar = true,
	complete = function(lead, _, _)
		return vim.tbl_filter(function(x)
			return x:find(lead, 1, true) == 1
		end, vim.tbl_keys(colors))
	end,
})
