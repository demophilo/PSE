module GameSetup
using JSON3

include("elements.jl")
using .Elements


mutable struct Variant
	name::String
	funktion::String
	parameter::Vector{Any}
	easy_mode::Bool
end

mutable struct Game
	name::String
	variant::Variant
end
variants_path = "variants.json"
function parse_json_to_variants(file_path::String)::Dict{String, Variant}
	json_data = read(file_path, String)
	parsed_data = JSON3.read(json_data, Dict{String, Any})
	variants = Dict{String, Variant}()
	for (key, value) in parsed_data
		variants[key] = Variant(value["name"], value["funktion"], value["parameter"], false)
	end
	return variants
end
game_type = parse_json_to_variants(variants_path)
function input_game_type(dict_game_variants)
	_row = ["$key $(variant.name)" for (key, variant) in (dict_game_variants) if length(key) == 1]
	println.("\t", sort(_row))
	_single_keys = [single for single in keys(dict_game_variants) if length(single) == 1]
	_keys_str = join(sort(collect(_single_keys)), ", ")
	println("\tWelches Spiel möchten Sie spielen: $_keys_str?")

	_chosen_game_letter = ""
	while length(_chosen_game_letter) != 1
		_input_game_letter = readline()
		if _input_game_letter in _single_keys
			_chosen_game_letter *= _input_game_letter
		end
	end

	if dict_game_variants[_chosen_game_letter].mode == "normal"

		println("Wenn Sie das Spiel ohne künstliche Elemente spielen wollen, geben Sie j ein.")
		_input_mode = readline()
		if _input_mode == "j"
			return _chosen_game_letter * "e"
		end

	end

	return _chosen_game_letter
end

function get_elements_to_guess(dict_game_variants, game_type_key::String)
	_elements_to_guess = dict_game_variants[game_type_key].target_elements
	#if length(game_type_key) == 2
	#    _elements_to_guess = get_elements_without_synthetic_elements(_elements_to_guess)
	#end
	return _elements_to_guess
end

for (key, value) in game_type
    println(key, " ", value)
end

end # module
