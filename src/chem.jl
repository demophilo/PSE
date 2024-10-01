
using JSON3

include("../src/elements.jl")
using .Elements






# sets up the game
clear_sreen()
print_title()
println("\n"^15)
# player section

player_name = input_player_name()
funfact_vector = ["Das Neutron wird von vielen Leuten als Element mit der Ordnungszahl 0 angesehen und Neutronium genannt.", "Das Neutronium geht keine chemsichen Bindungen ein und ist ergo ein Edelgas.", "Die Tochter von Marie Curie, Irene, machte das Experiment zusammen mit ihrem Ehemann, aber interpretierte die Experimente falsch. Sonst hätte sie das Neutron entdeckt.", "Das einzige Atom ohne Neutronen ist das sogenannte Protium - Wasserstoff-1.", "Obwohl es keine Verbindung mit Neutronen gibt, bestehen Neutronensterne nur aus Neutronen.", "Neutronen sabilisieren die Atomkerne. Die einzigen stablien Atomkerne mit mehr Protonen als Neutronen sind H-1 und He-3."]
element_vector::Vector{Element} = read_json_to_element_vector("PeriodicTable.json")
game_variant_vector::Vector{Variant} = read_json_to_variant_vector("variants.json")

is_playing = true
while is_playing
	game_type::Variant = input_game_type(game_variant_vector)
	element_to_guess_vector::Vector{Element} = get_elements_to_guess(element_vector::Vector{Element}, game_type.letter::String)
	element_symbol_to_guess_vector::Vector{String} = [element.symbol for element in element_to_guess_vector]
	element_name_to_guess_vector::Vector{String} = [element.name_de for element in element_to_guess_vector]
	element_not_to_guess_vector::Vector{Element} = setdiff(element_vector, element_to_guess_vector)
	element_symbols_not_to_guess_vector::Vector{String} = [element.symbol for element in element_not_to_guess_vector]
	# sets up the initial values 
	is_wide = false
	periodic_table_matrix::Matrix{String} = get_PSE_matrix(element_vector, is_wide)
	right_element_set::Set{Element} = Set{Element}()  # Initialisiert als Set von Elementen
	right_element_symbols::Vector{String} = []
	start_time = time()
	max_time = length(element_to_guess_vector) * 10
	score = 0
	time_bonus = max_time * 10

	# displays the first screen
	show_matrix::Matrix{String} = get_PSE_ready_to_print(periodic_table_matrix, right_element_symbols, element_symbol_to_guess_vector, element_symbols_not_to_guess_vector)
	display_screen(show_matrix, score, time_bonus)

	# gaming loop
	while length(element_to_guess_vector) > length(right_element_set)
		trial = input_element()

		if trial == "q" # to quit the game
			time_bonus = 0
			break
		end

		if trial == "w" # to toggle from narrow to wide PSE
			is_wide = !is_wide
			periodic_table_matrix = get_PSE_matrix(is_wide)
		end

		if trial in element_name_to_guess_vector
			for element in element_vector
				if trial == element.name_de
					push!(right_element_set, element)
					global chosen_element = element
					if element in right_element_set
						push!(right_element_symbols, element.symbol)
					end
				end
			end
		end
		clear_sreen()
		show_matrix = get_PSE_ready_to_print(periodic_table_matrix, right_element_symbols, element_symbol_to_guess_vector, element_symbols_not_to_guess_vector)
		display_screen(show_matrix, score, time_bonus)
	end # end of gaming loop

	end_time = time()
	duration = end_time - start_time
	score::Int = length(right_element_symbols) * 100
	time_bonus::Int = (max_time - round(duration)) > 0 ? (max_time - round(duration)) * 10 : 0

	show_matrix = get_PSE_ready_to_print(periodic_table_matrix, right_element_symbols, element_symbol_to_guess_vector, element_symbols_not_to_guess_vector)
	display_screen(show_matrix, score, time_bonus)



	player::Player = Player(player_name, "PSE", game_type.name, "hard", score + time_bonus)

	every_player_history_vector = read_players("chem_players_history.json")
	actual_player_history_vector = [person for person in every_player_history_vector if person.name == player.name]
	add_player_and_cut_top_n!(actual_player_history_vector, player, 3)
	append_Player_to_json_vector("chem_players_history.json", player)

	empty_space = " "^8
	for person in actual_player_history_vector
		println("$(person.name)$empty_space$(person.game)$empty_space$(person.game_variant)$(empty_space)$(person.game_mode)$(empty_space)$(person.total_score)")
	end

	println("Wollen Sie noch ein Spiel spielen?")

	play_again = readline()
	if play_again == "n"
		global is_playing = false
	end
end # end of game

