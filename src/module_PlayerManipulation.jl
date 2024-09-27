module PlayerManipulation

using JSON3

export Player, read_players, append_Player_to_json_vector
struct Player
    name::String
    game::String
    total_score::Int
end

function read_players(filename::String)
    _players_data = read(filename, String)
    _players_json = JSON3.read(_players_data)
    _player_vector = [Player([dict["$field_name"] for field_name in fieldnames(Player)]...) for dict in _players_json]
    
    return _player_vector
end

function append_Player_to_json_array_old(new_player::Player, filename::String)
	_new_item_dict = Dict("name" => new_player.name, "game" => new_player.game, "total_score" => new_player.total_score)
	open(filename, "r+") do file
		_existing_data = JSON3.read(file)
		push!(_existing_data, _new_item_dict)
		seekstart(file)
		JSON3.write(file, _existing_data)
	end
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
	


end
