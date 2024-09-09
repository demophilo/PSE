module VariantSetup
using JSON3

include("elements.jl")
using .Elements

export Variant, create_path, parse_json_to_variants, input_game_type, get_elements_to_guess, call_function_by_name


mutable struct Variant
	name::String
	funktion::String
	parameter::Vector{Any}
	easy_mode::Bool
end


function create_path(directories::Vector{String}, filename::String)::String
	return joinpath(directories..., filename)
end

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

function call_function_by_name(mod::Module, func_name::String, params::AbstractVector)
    func = getfield(mod, Symbol(func_name))
    return func(params...)
end

end # module
