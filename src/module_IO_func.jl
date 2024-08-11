module IO_func

export input_element

function input_element()
	print("Gib den Namen eines Elements ein: ")
	trial_element = readline()
	return trial_element
end

end
