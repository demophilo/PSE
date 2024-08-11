module PlayerManipulation

using JSON3

export Player, read_players, append_Player_to_json_array
struct Player
    name::String
    game::String
    total_score::Int
end

function read_players(filename::String)
    _players_data = read(filename, String)
    _players_dict = JSON3.read(_players_data)
    _players = [Player([dict["$field_name"] for field_name in fieldnames(Player)]...) for dict in _players_dict]
    return _players
end

function append_Player_to_json_array(new_player::Player, filename::String)
	_new_item_dict = Dict("name" => new_player.name, "game" => new_player.game, "total_score" => new_player.total_score)
	open(filename, "r+") do file
		_existing_data = JSON3.read(file)
		push!(_existing_data, _new_item_dict)
		seekstart(file)
		JSON3.write(file, _existing_data)
	end
end


end
