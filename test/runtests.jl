using Test
using JSON3

include("../src/elements.jl")
using .Elements

include("../src/module_IO_func.jl")
using .IO_func



#################################################
# Tests module Elements
#################################################

@testset "Element Struct Tests" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")

	@test elements[2].name == "Helium"
	@test elements[2].name_de == "Helium"
	@test elements[2].symbol == "He"
	@test elements[2].number == 2
	@test elements[2].xpos == 18
	@test elements[2].ypos == 1
	@test elements[2].wxpos == 32
	@test elements[2].wypos == 1
	@test elements[2].group == "18"
end

@testset "get_group_Elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	group_elements = get_group_elements(elements::Vector{Element}, "1")
	group_elements2 = get_group_elements(elements::Vector{Element}, "17")
	group_elements_actinide = get_group_elements(elements::Vector{Element}, "actinide")
	group_elements_lanthanide = get_group_elements(elements::Vector{Element}, "lanthanide")

	@test length(group_elements) == 7
	@test length(group_elements2) == 6
	@test length(group_elements_actinide) == 15
	@test length(group_elements_lanthanide) == 15
	@test group_elements[1].name_de == "Wasserstoff"
	@test group_elements[2].name_de == "Lithium"
	@test group_elements2[end].name_de == "Tenness"
	@test group_elements_actinide[1].name_de == "Actinium"
	@test group_elements_lanthanide[1].name_de == "Lanthan"
	@test group_elements_lanthanide[end].name_de == "Lutetium"
	@test group_elements_actinide[end].name_de == "Lawrencium"
end

@testset "get_mononuclidic_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	mononuclidic_elements = get_mononuclidic_elements(elements)

	@test length(mononuclidic_elements) == 22
	for element in mononuclidic_elements
		@test element.mononuclidic
	end
end
@testset "get_natural_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	natural_elements = get_nature_elements(elements)

	@test length(natural_elements) == 94
	for element in natural_elements
		@test !element.synthetic
	end
end

@testset "get_stable_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	radioactive_elements = get_stable_elements(elements, false)
	stable_elements = get_stable_elements(elements, true)

	@test length(radioactive_elements) == 38
	for element in radioactive_elements
		@test !element.stable
	end
end
@testset "get_elements_by_blocks" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	block_elements = get_elements_by_blocks(elements, ["s"])
	block_elements2 = get_elements_by_blocks(elements, ["f"])

	@test length(block_elements) == 14
	@test block_elements[end].name_de == "Radium"
	@test length(block_elements2) == 28
	@test block_elements2[end].name_de == "Nobelium"
end

@testset "sort_elements_chemically" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	sorted_elements = sort_elements_chemically(elements)

	@test sorted_elements[1].name_de == "Wasserstoff"
	@test sorted_elements[2].name_de == "Lithium"
	@test sorted_elements[89].name_de == "Lanthan"
	@test sorted_elements[104].name_de == "Actinium"
	@test sorted_elements[118].name_de == "Lawrencium"
end

@testset "get_single_letter_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	single_letter_elements = get_single_letter_elements(elements)

	@test length(single_letter_elements) == 14
	for element in single_letter_elements
		@test length(element.symbol) == 1
	end
end

@testset "get_elements_with_same_name" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	elements_with_same_name = get_elements_with_same_name(elements)
	elements_with_same_name = [element.name_de for element in elements_with_same_name]

	@test length(elements_with_same_name) == 77
	@test "Aluminium" ∈ elements_with_same_name
	@test "Silicium" ∉ elements_with_same_name
	@test "Bismut" ∉ elements_with_same_name
	@test "Nihonium" ∈ elements_with_same_name
end

@testset "remove_synthetic_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	elements = remove_synthetic_elements(elements)

	@test length(elements) == 94
	for element in elements
		@test !element.synthetic
	end
end

@testset "get_PSE_matrix" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	PSE_matrix = get_PSE_matrix(elements, false)
	PSE_matrix_wide = get_PSE_matrix(elements, true)

	@test PSE_matrix[1, 1] == "H"
	@test PSE_matrix[1, 18] == "He"
	@test PSE_matrix_wide[2, 1] == "Li"
	@test PSE_matrix_wide[7, 32] == "Og"
end

@testset "get_Lehrer_elements" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	Lehrer_element_vector = get_Lehrer_elements(elements)

	for (index, element) in enumerate(Lehrer_element_vector)
		@test element.Lehrer_number == index
	end
end

@testset "get_elements_not_to_guess" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	elements_to_guess = get_group_elements(elements, "1")
	elements_not_to_guess = get_elements_not_to_guess(elements, elements_to_guess)

	@test length(elements_not_to_guess) == 111
	@test elements[2] ∈ elements_not_to_guess
	@test elements[1] ∉ elements_not_to_guess
	@test elements[3] ∉ elements_not_to_guess
end

@testset "get_PSE_ready_to_print" begin
	elements = read_json_to_element_vector("../src/PeriodicTable.json")
	PSE_matrix = get_PSE_matrix(elements, false)
	elements_to_guess = get_group_elements(elements, "1")
	element_symbols_to_guess = [element.symbol for element in elements_to_guess]
	elements_not_to_guess = get_elements_not_to_guess(elements, elements_to_guess)
	element_symbols_not_to_guess = [element.symbol for element in elements_not_to_guess]
	right_element_symbols = ["H", "Fr"]
	show_matrix = get_PSE_ready_to_print(PSE_matrix, right_element_symbols, element_symbols_to_guess, element_symbols_not_to_guess)

	@test show_matrix[1, 1] == "\e[32mH  \e[0m" # green
	@test show_matrix[2, 2] == "__ " # nobody asked for it
	@test show_matrix[1, 2] == "   " # not part of the PSE, just empty space
	@test show_matrix[3, 1] == "\e[31m__ \e[0m" # red
	@test show_matrix[7, 1] == "\e[32mFr \e[0m" # green again
end

#################################################
# Tests module ScreenManipulation
#################################################

@testset "get_color_dict" begin
	color_dict = get_color_dict()

	@test color_dict["red"] == "\e[31m"
	@test color_dict["green"] == "\e[32m"
	@test color_dict["yellow"] == "\e[33m"
	@test color_dict["blue"] == "\e[34m"
	@test color_dict["purple"] == "\e[35m"
	@test color_dict["lightblue"] == "\e[36m"
	@test color_dict["white"] == "\e[37m"
	@test color_dict["lightred"] == "\e[91m"
	@test color_dict["green2"] == "\e[92m"
	@test color_dict["lightyellow"] == "\e[93m"
	@test color_dict["lightpurple"] == "\e[95m"
	@test color_dict["cyan"] == "\e[96m"
end

@testset "colorize_string" begin
	color_dict = get_color_dict()
	colored_string = colorize_string("Hello World!", color_dict, "red")

	@test colored_string == "\e[31mHello World!\e[0m"
end

#################################################
# Tests module IO_func
#################################################

@testset "Test input_element" begin
	# Simulierte Eingabe
	simulated_input = "Helium\n"
	io = IOBuffer(simulated_input)

	# Funktion, die die Eingabe liest
	function read_input()
		trial_element = IO_func.input_element()
		@test trial_element == "Helium"
	end

	# Pipe erstellen und Daten schreiben
	rd, wr = redirect_stdin()
	write(wr, simulated_input)
	close(wr)

	# Umleiten der Standard-Eingabe
	redirect_stdin(rd) do
		read_input()
	end
end

#################################################
# Tests module game_variants
#################################################

@testset "Test create_path" begin
	directories = ["src"]
	filename = "variants.json"
	variants_path = create_path(directories, filename)
	expected_path = Sys.iswindows() ? "src\\variants.json" : "src/variants.json"
	@test variants_path == expected_path
end

@testset "Test read_json_to_variants" begin
	directories = ["..", "src"]
	filename = "variants.json"
	variants_path = create_path(directories, filename)
	game_variant_vector = read_json_to_variant_vector(variants_path)
	sort!(game_variant_vector, by = x -> x.letter)

	@test game_variant_vector[1].letter == "a"
end

@testset "Test input_game_type" begin
	directories = ["..", "src"]
	filename = "variants.json"
	variants_path = create_path(directories, filename)
	game_variant_vector = read_json_to_variant_vector(variants_path)
	# Simulierte Eingabe
	simulated_input = "c\n"
	io = IOBuffer(simulated_input)

	# Funktion, die die Eingabe liest
	function read_input()
		game_type = input_game_type(game_variant_vector)

		@test typeof(game_type) == Variant
		@test game_type in game_variant_vector
	end

	# Pipe erstellen und Daten schreiben
	rd, wr = redirect_stdin()
	write(wr, simulated_input)
	close(wr)

	# Umleiten der Standard-Eingabe
	redirect_stdin(rd) do
		read_input()
	end
end

@testset "Test call_function_by_name" begin
	directories_elements = ["..", "src"]
	filename_elements = "PeriodicTable.json"
	Elements_path = create_path(directories_elements, filename_elements)
	elements = call_function_by_name(Elements, "read_json_to_element_vector", [String], [Elements_path])

	@test elements[2].name == "Helium"
end

@testset "Test get_elements_to_guess" begin
	directories_elements = ["..", "src"]
	filename_elements = "PeriodicTable.json"
	Elements_path = create_path(directories_elements, filename_elements)
	elements = read_json_to_element_vector(Elements_path)

	directories = ["..", "src"]
	filename = "variants.json"
	variants_path = create_path(directories, filename)
	game_variant_vector = read_json_to_variant_vector(variants_path)
	sort!(game_variant_vector, by = x -> x.letter)

	variant = game_variant_vector[3]
	elements_to_guess = get_elements_to_guess(elements, variant)

	@test elements_to_guess[1].name_de == "Beryllium"
	@test elements_to_guess[2].name_de == "Magnesium"
	@test elements_to_guess[3].name_de == "Calcium"
	@test elements_to_guess[4].name_de == "Strontium"
	@test elements_to_guess[5].name_de == "Barium"
	@test elements_to_guess[6].name_de == "Radium"
end

#################################################
# Tests module PlayerManipulation
#################################################

@testset "Test read_players" begin
	# Simulieren des Inhalts einer JSON-Datei
	players_json = """
	[
		{"name": "Alice", "game": "Chess", "total_score": 1500},
		{"name": "Bob", "game": "Poker", "total_score": 1200},
		{"name": "Charlie", "game": "Go", "total_score": 1800}
	]
	"""

	# Schreiben des JSON-Inhalts in eine temporäre Datei
	filename = "temp_players.json"
	open(filename, "w") do file
		write(file, players_json)
	end

	# Aufruf der Funktion read_players
	players = read_players(filename)

	# Überprüfen der zurückgegebenen Spieler
	@test length(players) == 3
	@test players[1].name == "Alice"
	@test players[1].game == "Chess"
	@test players[1].total_score == 1500
	@test players[2].name == "Bob"
	@test players[2].game == "Poker"
	@test players[2].total_score == 1200
	@test players[3].name == "Charlie"
	@test players[3].game == "Go"
	@test players[3].total_score == 1800

	# Löschen der temporären Datei
	rm(filename)
end

@testset "Test append_Player_to_json_array" begin
	# Simulieren des Inhalts einer JSON-Datei
	initial_players_json = """
	[
		{"name": "Alice", "game": "Chess", "total_score": 1500},
		{"name": "Bob", "game": "Poker", "total_score": 1200}
	]
	"""

	# Schreiben des initialen JSON-Inhalts in eine temporäre Datei
	filename = "temp_players.json"
	open(filename, "w") do file
		write(file, initial_players_json)
	end

	# Neuer Spieler, der hinzugefügt werden soll
	new_player = Player("Charlie", "Go", 1800)

	# Aufruf der Funktion append_Player_to_json_array
	append_Player_to_json_vector(filename, new_player)

	# Lesen des aktualisierten Inhalts der Datei
	updated_players_data = read(filename, String)
	updated_players_array = JSON3.read(updated_players_data)

	# Überprüfen der aktualisierten Spieler
	@test length(updated_players_array) == 3
	@test updated_players_array[3]["name"] == "Charlie"
	@test updated_players_array[3]["game"] == "Go"
	@test updated_players_array[3]["total_score"] == 1800

	# Löschen der temporären Datei
	rm(filename)
end

@testset "add_player_and_get_top_3" begin
	initial_player_vector::Vector{Player} = [
        Player("Alice", "Chess", 1500),
        Player("Bob", "Poker", 1200),
        Player("Charlie", "Go", 1800)
    ]
	# Neuer Spieler, der hinzugefügt werden soll
	new_player = Player("David", "Chess", 2000)

	# Aufruf der Funktion add_player_and_get_top_3
	top_3 = add_player_and_update_top_3!(initial_player_vector, new_player)

	# Überprüfen der Top 3 Spieler
	@test length(top_3) == 3
	@test top_3[1].name == "David"
	@test top_3[1].game == "Chess"
	@test top_3[1].total_score == 2000
	@test top_3[2].name == "Charlie"
	@test top_3[2].game == "Go"
	@test top_3[2].total_score == 1800
	@test top_3[3].name == "Alice"
	@test top_3[3].game == "Chess"
	@test top_3[3].total_score == 1500

end
