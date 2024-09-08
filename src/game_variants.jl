module VariantSetup
using JSON3

include("elements.jl")
using .Elements

export Variant, create_path, parse_json_to_variants, input_game_type, get_elements_to_guess


mutable struct Variant
	name::String
	funktion::String
	parameter::Vector{Any}
	easy_mode::Bool
end


function create_path(directories::Vector{String}, filename::String)::String
	return joinpath(directories..., filename)
end
#=
directories = ["src"]
filename = "variants.json"
variants_path = create_path(directories, filename)
println(variants_path)
=#
function parse_json_to_variants(file_path::String)::Dict{String, Variant}
	json_data = read(file_path, String)
	parsed_data = JSON3.read(json_data, Dict{String, Any})
	variants = Dict{String, Variant}()
	for (key, value) in parsed_data
		variants[key] = Variant(value["name"], value["funktion"], value["parameter"], false)
	end
	return variants
end

function input_game_type(dict_game_variants::Dict{String, Variant})
	sorted_keys = sort(collect(keys(dict_game_variants)))

	for key in sorted_keys
		println("$key => $(dict_game_variants[key].name)")
	end

	_keys_str = join(sorted_keys, ", ")
	println("\tWelches Spiel möchten Sie spielen: $_keys_str?")

	_chosen_game_letter = ""
	while !occursin(_chosen_game_letter, _keys_str)
		_chosen_game_letter = string(readline()[1])
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
#=
for (key, value) in game_type
	println(key, " ", value)
end
=#
end # module
