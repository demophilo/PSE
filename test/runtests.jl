using Test
include("../src/elements.jl")
using .Elements
include("../src/screen_manipulation.jl")
using .ScreenManipulation

include("../src/module_IO_func.jl")
using .IO_func


@testset "Element Struct Tests" begin
	# Test der Instanziierung

	elements = read_chemical_elements("../src/PeriodicTable.json")

	@test elements[2].name == "Helium"
	@test elements[2].name_de == "Helium"
	@test elements[2].symbol == "He"
	@test elements[2].number == 2
	@test elements[2].xpos == 18
	@test elements[2].ypos == 1
	@test elements[2].wxpos == 32
	@test elements[2].wypos == 1
	@test elements[2].group == 18

end

@testset "get group Elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	group_elements = get_group_elements(elements::Vector{Element}, 1, false)
	group_elements2 = get_group_elements(elements::Vector{Element}, "actinide", false)
	group_elements3 = get_group_elements(elements::Vector{Element}, 13, true)
	@test length(group_elements) == 7
	@test group_elements[1].name_de == "Wasserstoff"
	@test group_elements[2].name_de == "Lithium"
	@test group_elements2[1].name_de == "Actinium"
	@test group_elements3[1].name_de == "Bor"
	@test length(group_elements3) == 5
end

@testset "mononuclidic elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	mononuclidic_elements = get_mononuclidic_elements(elements)
	@test length(mononuclidic_elements) == 22
	for element in mononuclidic_elements
		@test element.mononuclidic
	end
	
end
@testset "natural elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	natural_elements = get_nature_elements(elements)
	@test length(natural_elements) == 94
	for element in natural_elements
		@test !element.synthetic
	end
end

@testset "get_radioactive_elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	radioactive_elements = get_radioactive_elements(elements, false)
	@test length(radioactive_elements) == 38
	for element in radioactive_elements
		@test !element.stable
	end
	
end
@testset "get_elements_by_blocks" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	block_elements = get_elements_by_blocks(elements, ["s"], false)
	block_elements2 = get_elements_by_blocks(elements, ["f"], false)
	block_elements3 = get_elements_by_blocks(elements, ["p"], true)
	@test length(block_elements) == 14
	@test block_elements[14].name_de == "Radium"
	@test length(block_elements2) == 28
	@test block_elements2[28].name_de == "Nobelium"
	@test length(block_elements3) == 30
	@test block_elements3[30].name_de == "Radon"
end

@testset "sort_elements_chemically" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	sorted_elements = sort_elements_chemically(elements)
	@test sorted_elements[1].name_de == "Wasserstoff"
	@test sorted_elements[2].name_de == "Lithium"
	@test sorted_elements[89].name_de == "Lanthan"
	@test sorted_elements[104].name_de == "Actinium"
	@test sorted_elements[118].name_de == "Lawrencium"

end

@testset "get_single_letter_elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	single_letter_elements = get_single_letter_elements(elements)
	@test length(single_letter_elements) == 14
	for element in single_letter_elements
		@test length(element.symbol) == 1
	end
end

@testset "get_elements_with_same_name" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	elements_with_same_name = get_elements_with_same_name(elements, false)
	elements_with_same_name_easy = get_elements_with_same_name(elements, true)
	elements_with_same_name = [element.name_de for element in elements_with_same_name]
	@test length(elements_with_same_name) == 76
	@test length(elements_with_same_name_easy) == 53
	@test "Aluminium" ∈ elements_with_same_name
	@test "Silicium" ∉ elements_with_same_name
	@test "Bismut" ∉ elements_with_same_name
	@test "Nihonium" ∈ elements_with_same_name
	@test "Nihonium" ∉ elements_with_same_name_easy

end

@testset "get_PSE_matrix" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	PSE_matrix = get_PSE_matrix(elements, false)
	PSE_matrix_wide = get_PSE_matrix(elements, true)
	@test PSE_matrix[1, 1] == "H"
	@test PSE_matrix[1, 18] == "He"
	@test PSE_matrix_wide[2, 1] == "Li"
	@test PSE_matrix_wide[7, 32] == "Og"

end

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

@testset "get_Lehrer_elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	Lehrer_element_vector = get_Lehrer_elements(elements)
	for (index, element) in enumerate(Lehrer_element_vector)
		@test element.Lehrer_number == index
	end
end

@testset "get_elements_not_to_guess" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	elements_to_guess = get_group_elements(elements, 1, false)
	elements_not_to_guess = get_elements_not_to_guess(elements, elements_to_guess)
	@test length(elements_not_to_guess) == 111
	@test elements[2] ∈ elements_not_to_guess
	@test elements[1] ∉ elements_not_to_guess
	@test elements[3] ∉ elements_not_to_guess
end


@testset "get_PSE_ready_to_print" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	PSE_matrix = get_PSE_matrix(elements, false)
	elements_to_guess = get_group_elements(elements, 1, false)
	element_symbols_to_guess = [element.symbol for element in elements_to_guess]
	elements_not_to_guess = get_elements_not_to_guess(elements, elements_to_guess)
	element_symbols_not_to_guess = [element.symbol for element in elements_not_to_guess]
	right_element_symbols = ["H", "Fr"]
	show_matrix = get_PSE_ready_to_print(PSE_matrix, right_element_symbols, element_symbols_to_guess, element_symbols_not_to_guess)
	@test show_matrix[1, 1] == "\e[32mH  \e[0m"
	@test show_matrix[2, 2] == "__ "
	@test show_matrix[1, 2] == "   "
	@test show_matrix[3, 1] == "\e[31m__ \e[0m"
	@test show_matrix[7, 1] == "\e[32mFr \e[0m"
end


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
