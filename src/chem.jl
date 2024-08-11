
using JSON3

include("elements.jl")
using .Elements




"""
	display_screen(show_matrix, score, time_bonus)

shows the gaming screen with title, PSE and score
"""
function display_screen(show_matrix, score, time_bonus)
	clear_sreen()
	println(title, "\n"^10)
	println("")
	print_PSE(show_matrix)
	println("")
	_total = score + time_bonus
	println("Score: $score    Timebonus: $time_bonus    Total: $_total")
end

# player section




function append_Player_to_json_array(new_player::Player, filename::String)
	_new_item_dict = Dict("name" => new_player.name, "game" => new_player.game, "total_score" => new_player.total_score)
	open(filename, "r+") do file
		_existing_data = JSON3.read(file)
		push!(_existing_data, _new_item_dict)
		seekstart(file)
		JSON3.write(file, _existing_data)
	end
end

function input_player_name()
	println("Geben Sie ihren Namen ein:")
	_name::String = readline()
	return _name
end

global player_name = input_player_name()

# sets up the game
clear_sreen()
println(title, "\n"^10)

while true
	global game_type = input_game_type(dict_game_variants)
	global elements_to_guess = get_elements_to_guess(dict_game_variants, game_type)
	global element_sympols_to_guess = [element.symbol for element in elements if element.name_de in elements_to_guess]

	# sets up the initial values 
	global is_wide = false
	global periodic_table_matrix = get_PSE_matrix(is_wide)
	global right_element_names = Set([])
	global right_element_symbols = []
	global start_time = time()
	global max_time = length(elements_to_guess) * 10
	global score::Int = 0
	global time_bonus::Int = max_time * 10

	# displays the first screen
	global show_matrix = get_PSE_ready_to_print(periodic_table_matrix, right_element_symbols, element_sympols_to_guess)
	display_screen(show_matrix, score, time_bonus)

	# gaming loop
	while length(elements_to_guess) > length(right_element_names)
		trial = input_element()

		if trial == "q" # to quit the game
			time_bonus = 0
			break
		end

		if trial == "w" # to toggle from narrow to wide PSE
			global is_wide = !is_wide
			global periodic_table_matrix = get_PSE_matrix(is_wide)
		end


		if trial in elements_to_guess
			push!(right_element_names, trial)
			for element in elements
				if trial == element.name_de
					push!(right_element_symbols, element.symbol)
				end
			end
		end


		end_time = time()

		duration = end_time - start_time

		global score::Int = length(right_element_names) * 100
		global time_bonus::Int = (max_time - round(duration)) > 0 ? (max_time - round(duration)) * 10 : 0


		global show_matrix = get_PSE_ready_to_print(periodic_table_matrix, right_element_symbols, element_sympols_to_guess)
		display_screen(show_matrix, score, time_bonus)
	end


	player = Player(player_name, dict_game_variants[game_type].name, score + time_bonus)


	players_history = read_Players_json_to_array("chem_players_history.json")
	player_history = [person for person in players_history if person.name == player.name && person.game == dict_game_variants[game_type].name]

	if length(player_history) < 3
		append_Player_to_json_array(player, "chem_players_history.json")
	end

	empty_space = " "^8
	for person in player_history
		println("$(person.name)$empty_space$(person.game)$empty_space$(person.total_score)")
	end

	println("Wollen Sie noch ein Spiel spielen?")

	play_again = readline()
	if play_again == "n"
		break
	end
end
