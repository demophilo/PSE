module IO_func

export input_element, input_player_name

function input_element()::String
	print("Gib den Namen eines Elements ein: ")
	trial_element = readline()
	return trial_element
end

function input_player_name()
	println("Geben Sie ihren Namen ein:")
	_name::String = readline()
	return _name
end

end
