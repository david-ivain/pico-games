pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- global constants and enums
-- enums
-- screen
e_screen_main = 0
e_screen_settings = 1
-- constants
-- settings structure
settings = {
	{
		label = "text speed",
		name = "text_speed",
		options = {
			{
				value = 1,
				label = "normal"
			},
			{
				value = 2,
				label = "fast"
			},
			{
				value = 56,
				label = "instant"
			}
		}
	},
	{
		label = "confirm button",
		name = "confirm_button",
		options = {
			{
				value = 🅾️,
				label = "🅾️"
			},
			{
				value = ❎,
				label = "❎"
			}
		}
	}
}

function _init()
	-- menu navigation
	current_screen = e_screen_main
	hovered_item = 0
	-- dialog box
	dialog = {}
	nb_visible_chars = 0
	-- main menu
	main_menu_items = {
		"continue",
		"new game",
		"settings"
	}
	-- settings
	selected_settings = {
		1,
		1
	}
end

function _update()
	if #dialog > 0 then
		-- if a dialog is opened, it takes precedence over other menus.
		-- show n new characters in the dialog box.
		-- n is determined by text speed.
		nb_visible_chars = min(nb_visible_chars + get_setting("text_speed"), 56)
		if confirm_was_pressed() or cancel_was_pressed() then
			-- if either button was pressed, eitherskip the writing animation
			-- and show all remaining characters, or show dequeue the
			-- currently displayed dialog lines.

			-- count the length of the currently displayed dialog.
			local dialog_length = #dialog[1]
			if #dialog > 1 then
				dialog_length = dialog_length + #dialog[2]
			end

			if nb_visible_chars < dialog_length then
				-- if not all characters are displayed yet, do it.
				nb_visible_chars = 56
			else
				-- else, dequeue the dialog lines.
				nb_visible_chars = 0
				if #dialog > 2 then
					deli(dialog, 1)
					deli(dialog, 1)
				else
					dialog = {}
				end
			end
		end
	elseif current_screen == e_screen_settings then
		-- if the settings are opened
		if confirm_was_pressed() and hovered_item == get_length(settings) then
			-- if "confirm" is selected, back to main menu and save settings
			current_screen = e_screen_main
			hovered_item = 0
		elseif cancel_was_pressed() then
			-- if cancel was pressed, back to main menu
			current_screen = e_screen_main
			hovered_item = 0
		elseif btnp(⬅️) and hovered_item < #settings then
			-- if left was pressed, decrease the currently hovered setting
			selected_settings[hovered_item + 1] = max(1, selected_settings[hovered_item + 1] - 1)
		elseif btnp(➡️) and hovered_item < #settings then
			-- if rifgr was pressed, increase the currently hovered setting
			selected_settings[hovered_item + 1] = min(#settings[hovered_item + 1].options, selected_settings[hovered_item + 1] + 1)
		elseif btnp(⬇️) then
			-- if down was pressed, go to next setting
			hovered_item = (hovered_item + 1) % (#settings + 1)
		elseif btnp(⬆️) then
			-- if up was pressed, go to previous setting
			hovered_item = (hovered_item - 1) % (#settings + 1)
		end
	else
		-- else, the main menu is displayed as default
		if confirm_was_pressed() then
			-- save the selected menu option in ram
			poke(0x4300, hovered_item)
			if hovered_item == 0 then
				-- if continue is selected, load the save and go into the game
				-- TODO
				show_dialog("sorry, you can't continue from save yet.")
			elseif hovered_item == 1 then
				-- if new game is selected, go into the game without loading
				-- TODO
				show_dialog("sorry, you can't start a new game yet.")
			elseif hovered_item == 2 then
				-- if settings is selected, display the settings screen
				current_screen = e_screen_settings
				hovered_item = 0
			end
		elseif btnp(⬇️) then
			-- if down was pressed, go the next menu option
			hovered_item = (hovered_item + 1) % 3
		elseif btnp(⬆️) then
			-- if up was pressed, go the previous menu option
			hovered_item = (hovered_item - 1) % 3
		end
	end
end

function _draw()
	cls(7)
	palt(0, false)
	if current_screen == e_screen_settings then
		draw_options_menu()
	else
		draw_main_menu()
	end
	if #dialog > 0 then
		draw_dialog()
	end
end

function show_dialog(text)
	dialog = split_dialog(text)
	nb_visible_chars = 0
end

function draw_box(x_cols, y_rows, w_cols, h_rows, show_bottom_arrow)
	local offset_x = x_cols * 8
	local offset_y = y_rows * 8
	-- top left
	spr(0, offset_x, offset_y)
	-- top right
	spr(2, (w_cols + 1) * 8 + offset_x, offset_y)
	-- bottom left
	spr(32, offset_x, (h_rows + 1) * 8 + offset_y)
	-- bottom right
	spr(34, (w_cols + 1) * 8 + offset_x, (h_rows + 1) * 8 + offset_y)
	-- top and bottom
	for x = 1, w_cols do
		spr(1, 8 * x + offset_x, offset_y)
		spr(33, 8 * x + offset_x, (h_rows + 1) * 8 + offset_y)
	end
	for y = 1, h_rows do
		-- left and right
		spr(16, offset_x, y * 8 + offset_y)
		spr(18, (w_cols + 1) * 8 + offset_x, y * 8 + offset_y)
		-- middle
		for x = 1, w_cols do
			spr(17, x * 8 + offset_x, y * 8 + offset_y)
		end
	end
	-- bottom arrow (dialog)
	if show_bottom_arrow then
		palt(7, true)
		spr(50, offset_x + (w_cols + 1) * 8 - 1, offset_y + (h_rows + 1) * 8)
		palt(7, false)
	end
end

function draw_main_menu()
	draw_box(0, 0, 4, 3)
	for key, value in pairs(main_menu_items) do
		if key == hovered_item + 1 then
			palt(7, true)
			spr(48, 0, 8 * key)
			palt(7, false)
		end
		print(value, 8, 8 * key, 0)
	end
end

function draw_options_menu()
	for i = 1, #settings do
		local setting = settings[i]
		local y_offset = 32 * (i - 1)
		draw_box(0, 4 * (i - 1), 14, 2)
		print(setting.label, 8, 8 + y_offset, 0)
		for j = 1, #setting.options do
			local option = setting.options[j]
			local x_offset = 32 * (j - 1)
			print(option.label, 8 + x_offset, 16 + y_offset, 0)
			if option.value == get_setting(nil, i) then
				palt(7, true)
				if hovered_item + 1 == i then
					spr(48, x_offset, 16 + y_offset)
				else
					spr(49, x_offset, 16 + y_offset)
				end
				palt(7, false)
			end
		end
	end
	local confirm_y_offset = 16 + 32 * get_length(settings)
	print("confirm", 8, confirm_y_offset, 0)
	if hovered_item == get_length(settings) then
		spr(48, 0, confirm_y_offset)
	end
end

function draw_dialog()
	draw_box(0, 12, 14, 2, true)
	if #dialog > 0 then
		print(sub(dialog[1], 1, nb_visible_chars), 8, 104, 0)
	end
	if #dialog > 1 and nb_visible_chars > 28 then
		print(sub(dialog[2], 1, nb_visible_chars - 28), 8, 112, 0)
	end
end

function split_dialog(text)
	local start_index = 1
	local printed_lines = 0
	local last_blank = 0
	local lines = {}
	for i = 1, #text do
		if text[i] == " " or text[i] == "\n" then
			last_blank = i
		end
		if i - start_index > 28 or text[i] == "\n" then
			add(lines, sub(text, start_index, last_blank))
			start_index = last_blank + 1
			printed_lines = printed_lines + 1
		elseif i == #text then
			add(lines, sub(text, start_index))
			printed_lines = printed_lines + 1
		end
	end
	return lines
end

function get_setting(name, index)
	if index then
		return settings[index].options[selected_settings[index]].value
	end
	for i = 1, #settings do
		if settings[i].name == name then
			return settings[i].options[selected_settings[i]].value
		end
	end
	return nil
end

function confirm_was_pressed()
	return btnp(get_setting("confirm_button"))
end

function cancel_was_pressed()
	return btnp((get_setting("confirm_button") - 3) % 2 + 4)
end

function get_length(table)
	local n = 0
	for k, v in pairs(table) do
		n = n + 1
	end
	return n
end

__gfx__
70000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06007777777777777777006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06077777777777777777706000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06600000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770777777707770000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770077777770777000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770007777777077707777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770077777770777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770777777707777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
