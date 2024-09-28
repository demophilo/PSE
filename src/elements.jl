module Elements
using JSON3

include("screen_manipulation.jl")
using .ScreenManipulation

export Element, Variant, Player, read_json_to_element_vector, get_Lehrer_elements, get_group_elements, get_nature_elements, get_elements_by_blocks, get_stable_elements, get_single_letter_elements, get_elements_with_same_name, get_mononuclidic_elements,
	element_compare, sort_elements_chemically, get_PSE_matrix, print_PSE, get_PSE_ready_to_print, get_elements_not_to_guess, remove_synthetic_elements, create_path, read_json_to_variant_vector, get_elements_to_guess, input_game_type, call_function_by_name,
	get_elements_to_guess2, print_title, get_color_dict, colorize_string, clear_sreen, display_screen, read_players, append_Player_to_json_vector, add_player_and_cut_top_n!
struct Element
	name::String # English name of the element
	name_de::String
	symbol::String
	number::Integer
	xpos::Integer # x position in compact PSE
	ypos::Integer # y position in compact PSE
	wxpos::Integer # x position in wide PSE
	wypos::Integer # y position in wide PSE
	group::String # "1"..."18", "lanthanide", "actinide"
	block::String # s, p, d, f
	stable::Bool
	synthetic::Bool
	mononuclidic::Bool
	Lehrer_number::Union{Integer, Nothing}
end

mutable struct Variant
	letter::String
	name::String
	with_easy_mode::Bool
	easy_mode::Bool
end

mutable struct Player
	name::String
	game::String
	total_score::Int
end

"""
	read_chemical_elements(filename::String)

reads the information of the json file and returns a dictionary
"""
function read_json_to_element_vector(filename::String)
	PSE_data = read(filename, String)
	elemente_dict = JSON3.read(PSE_data)
	element_vector = [Element([dict["$field_name"] for field_name in fieldnames(Element)]...) for dict in elemente_dict]
	return element_vector
end

# functions to get elements::Vector{Element}


function get_Lehrer_elements(elements::Vector{Element})
	Lehrer_element_vector = [_element for _element in elements if !isnothing(_element.Lehrer_number)]
	sort!(Lehrer_element_vector, by = x -> x.Lehrer_number)
	return Lehrer_element_vector
end

function get_group_elements(elements::Vector{Element}, group_name::String)::Vector{Element}
	return [_element for _element in elements if _element.group == group_name]
end

function get_nature_elements(elements::Vector{Element}, synthetic::Bool = false)
	if synthetic
		return [_element for _element in elements if _element.synthetic]
	else
		return [_element for _element in elements if !_element.synthetic]
	end
end

function get_elements_by_blocks(elements::Vector{Element}, blockletters::Vector{String})
	return [element for element in elements for _block in blockletters if element.block == _block]
end

function get_stable_elements(elements::Vector{Element}, stable::Bool = true)
	if stable
		return [_element for _element in elements if _element.stable]
	else
		return [_element for _element in elements if !_element.stable]
	end
end

function get_single_letter_elements(elements::Vector{Element})
	return [_element for _element in elements if length(_element.symbol) == 1]
end

function get_elements_with_same_name(elements::Vector{Element})
	return [element for element in elements if element.name == element.name_de]
end

function get_mononuclidic_elements(elements::Vector{Element})
	return [element for element in elements if element.mononuclidic]
end

function element_compare(element1::Element, element2::Element)
	if element1.group == element2.group
		return element1.number < element2.number
	elseif element1.group == "lanthanide" && element2.group == "actinide"
		return true
	elseif element1.group == "actinide" && element2.group == "lanthanide"
		return false
	elseif (element1.group == "actinide" || element1.group == "lanthanide") && (element2.group != "actinide" && element2.group != "lanthanide")
		return false
	elseif (element1.group != "actinide" && element1.group != "lanthanide") && (element2.group == "actinide" || element2.group == "lanthanide")
		return true
	elseif element1.group != "actinide" && element1.group != "lanthanide" && element2.group != "actinide" && element2.group != "lanthanide"
		group1 = parse(Int, element1.group)
		group2 = parse(Int, element2.group)
		return group1 < group2
	end
end

function sort_elements_chemically(elements::Vector{Element})
	_elements = sort(elements, lt = (x, y) -> element_compare(x, y))
	return _elements
end

"""
	get_PSE_matrix(is_wide = true)

generates the PSE matrix, fills it with empty strings and fills the right positions with the element symbols
if is_wide is true, a wide matrix will be generated
"""
function get_PSE_matrix(elements::Vector{Element}, is_wide = false)::Matrix{String}
	if is_wide
		_periodic_table_matrix = fill("", 8, 32)
		for element in elements
			_periodic_table_matrix[element.wypos, element.wxpos] = element.symbol
		end
	else
		_periodic_table_matrix = fill("", 10, 18)
		for element in elements
			_periodic_table_matrix[element.ypos, element.xpos] = element.symbol
		end
	end
	return _periodic_table_matrix
end

"""
	print_PSE(PSE_matrix)

prints the PSE matrix
"""
function print_PSE(PSE_matrix)
	_max_row, _max_column = size(PSE_matrix)
	for row in 1:_max_row
		for column in 1:_max_column
			print(PSE_matrix[row, column])
		end
		print("\n")
	end
end


"""
	filter_periodic_table(PSE_matrix, symbols_to_show, element_sympols_to_guess)

hides the false elements, colors the right elements and the positions to guess
"""
function get_PSE_ready_to_print(PSE_matrix::Matrix{String}, elements_to_show, elements_symbols_to_guess, elements_not_to_guess)
	_filtered_matrix = copy(PSE_matrix)
	_max_rows, _max_columns = size(_filtered_matrix)
	_elements_not_yet_guessed = setdiff(elements_symbols_to_guess, elements_to_show)

	for row in 1:_max_rows
		for column in 1:_max_columns

			if _filtered_matrix[row, column] in elements_to_show
				_cell = rpad(_filtered_matrix[row, column], 3, " ")
				_filtered_matrix[row, column] = "\e[32m$_cell\e[0m"
			end

			if _filtered_matrix[row, column] in _elements_not_yet_guessed
				_filtered_matrix[row, column] = "\e[31m__ \e[0m"
			end

			if _filtered_matrix[row, column] in elements_not_to_guess
				_filtered_matrix[row, column] = "__ "
			end

			if _filtered_matrix[row, column] == ""
				_filtered_matrix[row, column] = "   "
			end


		end
	end

	return _filtered_matrix
end

function get_elements_not_to_guess(elements::Vector{Element}, elements_to_guess::Vector{Element})::Vector{Element}
	return [_element for _element in elements if !(_element in elements_to_guess)]
end

function remove_synthetic_elements(elements::Vector{Element})
	return [element for element in elements if !element.synthetic]
end

function create_path(directories::Vector{String}, filename::String)::String
	return joinpath(directories..., filename)
end

function read_json_to_variant_vector(file_path::String)::Vector{Variant}
	json_data = JSON3.read(file_path)
	variants = Vector{Variant}()
	for item in json_data
		variant = Variant(
			item["letter"],
			item["name"],
			item["with_easy_mode"],
			item["easy_mode"]
		)
		push!(variants, variant)
	end

	return variants
end

function get_elements_to_guess(elements_vector::Vector{Element}, variant::Variant)::Vector{Element}
	if variant.letter == "a"
		return elements_vector
	end

	if variant.letter == "b"
		return get_group_elements(elements_vector, "1")
	end

	if variant.letter == "c"
		return get_group_elements(elements_vector, "2")
	end

	if variant.letter == "d"
		return get_group_elements(elements_vector, "13")
	end

	if variant.letter == "e"
		return get_group_elements(elements_vector, "14")
	end

	if variant.letter == "f"
		return get_group_elements(elements_vector, "15")
	end

	if variant.letter == "g"
		return get_group_elements(elements_vector, "16")
	end

	if variant.letter == "h"
		return get_group_elements(elements_vector, "17")
	end

	if variant.letter == "i"
		return get_group_elements(elements_vector, "18")
	end

	if variant.letter == "j"
		return get_group_elements(elements_vector, "lanthanide")
	end

	if variant.letter == "k"
		return get_group_elements(elements_vector, "actinide")
	end

	if variant.letter == "l"
		return get_mononuclidic_elements(elements_vector)
	end

	if variant.letter == "m"
		return get_stable_elements(elements_vector, false)
	end

	if variant.letter == "n"
		return get_elements_by_blocks(elements_vector, ["s", "p"])
	end

	if variant.letter == "o"
		return get_elements_by_blocks(elements_vector, ["d"])
	end

	if variant.letter == "p"
		return get_elements_with_same_name(elements_vector)
	end

	if variant.letter == "q"
		return get_single_letter_elements(elements_vector)
	end

	if variant.letter == "r"
		return get_Lehrer_elements(elements_vector)
	end
end


function input_game_type(variant_vector::Vector)
	for variant in variant_vector
		println("$(variant.letter) => $(variant.name)")
	end

	_keys_str = join([variant.letter for variant in variant_vector], ", ")
	println("\tWelches Spiel möchten Sie spielen: $_keys_str?")

	_chosen_game_letter = ""
	while _chosen_game_letter ∉ [variant.letter for variant in variant_vector]
		_chosen_game_letter = string(readline()[1])
	end

	for variant in variant_vector
		if variant.letter == _chosen_game_letter
			return variant
		end
	end

end

function call_function_by_name(mod::Module, func_name::String, param_types::Vector{DataType}, params::AbstractVector)
	func = getfield(mod, Symbol(func_name))
	typed_params = [convert(param_types[i], params[i]) for i in eachindex(param_types)]
	return func(typed_params...)
end

function get_elements_to_guess2(elements::Vector{Element}, variant::Variant)
	# Fügen Sie den `elements`-Vektor zu den Parametern hinzu
	params_with_elements = [elements; variant.parameter]
	param_types_with_elements = [Vector{Element}; variant.param_types]
	elements_to_guess = call_function_by_name(Elements, variant.funktion, param_types_with_elements, params_with_elements)
	return elements_to_guess
end

function print_title()
	title = open("title.txt", "r") do file
		read(file, String)
	end

	println("\e[98m$title")

end

function get_color_dict()
	farben = Dict(
		"red" => "\e[31m",
		"green" => "\e[32m",
		"yellow" => "\e[33m",
		"blue" => "\e[34m",
		"purple" => "\e[35m",
		"lightblue" => "\e[36m",
		"white" => "\e[37m",
		"lightred" => "\e[91m",
		"green2" => "\e[92m",
		"lightyellow" => "\e[93m",
		"lightpurple" => "\e[95m",
		"cyan" => "\e[96m"
	)
	return farben
end

function colorize_string(text::String, color_dict, color::String)::String
	_colored_string = color_dict["$color"] * text * "\e[0m"
	return _colored_string
end

function clear_sreen()
	print("\e[2J")
end

"""
	display_screen(show_matrix, score, time_bonus)

shows the gaming screen with title, PSE and score
"""
function display_screen(show_matrix, score, time_bonus)
	clear_sreen()
	print_title()
	println("")
	print_PSE(show_matrix)
	println("")
	_total = score + time_bonus
	println("Score: $score    Timebonus: $time_bonus    Total: $_total")
end

function read_players(filename::String)
	_players_data = read(filename, String)
	_players_json = JSON3.read(_players_data)
	_player_vector = [Player([dict["$field_name"] for field_name in fieldnames(Player)]...) for dict in _players_json]

	return _player_vector
end

function append_Player_to_json_vector(filename::String, player::Player)
	players_data = read(filename, String)
	players_array = try
		JSON3.read(players_data, Vector{Dict{String, Any}})
	catch e
		println("Fehler beim Lesen der JSON-Daten: ", e)
		return
	end
	push!(players_array, Dict("name" => player.name, "game" => player.game, "total_score" => player.total_score))
	open(filename, "w") do file
		write(file, JSON3.write(players_array))
	end
end

function add_player_and_cut_top_n!(player_history_vector::Vector{Player}, player::Player, n::Int)
	push!(player_history_vector, player)
	sort!(player_history_vector, by = x -> x.total_score, rev = true)
	resize!(player_history_vector, min(n, length(player_history_vector)))
end

end # module
