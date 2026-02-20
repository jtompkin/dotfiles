-- Must require("wezterm") before loading this file
wezterm.on("update-status", function(window)
	window:set_right_status(wezterm.format({
		{ Text = " Key Table: " .. (window:active_key_table() or "default") .. " " },
	}))
end)
wezterm.on("augment-command-palette", function()
	return {
		{
			brief = "Custom: Toggle tab bar",
			icon = "cod_indent",
			action = wezterm.action_callback(function(window)
				local overrides = window:get_config_overrides() or {}
				if overrides.enable_tab_bar == nil then
					overrides.enable_tab_bar =
						not window:effective_config().enable_tab_bar
				else
					overrides.enable_tab_bar = not overrides.enable_tab_bar
				end
				window:set_config_overrides(overrides)
			end),
		},
		{
			brief = "Custom: Toggle ligatures",
			icon = "cod_export",
			action = wezterm.action_callback(function(window)
				local overrides = window:get_config_overrides() or {}
				if overrides.harfbuzz_features then
					overrides.harfbuzz_features = nil
				else
					overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
				end
				window:set_config_overrides(overrides)
			end),
		},
		{
			brief = "Custom: Toggle audible bell",
			icon = "cod_bell_slash_dot",
			action = wezterm.action_callback(function(window)
				local overrides = window:get_config_overrides() or {}
				local switch = { SystemBeep = "Disabled", Disabled = "SystemBeep" }
				if overrides.audible_bell == nil then
					overrides.audible_bell =
						switch[window:effective_config().audible_bell]
				else
					overrides.audible_bell = switch[overrides.audible_bell]
				end
				window:set_config_overrides(overrides)
			end),
		},
		{
			brief = "Custom: Clear config overrides",
			action = wezterm.action_callback(function(window)
				window:set_config_overrides({})
			end),
		},
	}
end)
