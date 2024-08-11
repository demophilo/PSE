using Test
include("../src/elements.jl")
using .Elements
include("../src/screen_manipulation.jl")
using .ScreenManipulation


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
	mononuclidic_elements = [element.name_de for element in mononuclidic_elements]
	@test length(mononuclidic_elements) == 22
	@test mononuclidic_elements == [
		"Beryllium",
		"Fluor",
		"Natrium",
		"Aluminium",
		"Phosphor",
		"Scandium",
		"Mangan",
		"Cobalt",
		"Arsen",
		"Yttrium",
		"Niob",
		"Rhodium",
		"Iod",
		"Caesium",
		"Praseodym",
		"Terbium",
		"Holmium",
		"Thulium",
		"Gold",
		"Bismut",
		"Thorium",
		"Plutonium"
	]
end
@testset "natural elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	natural_elements = get_nature_elements(elements)
	natural_elements = [element.name_de for element in natural_elements]
	@test length(natural_elements) == 94
	@test natural_elements == [
		"Wasserstoff",
		"Helium",
		"Lithium",
		"Beryllium",
		"Bor",
		"Kohlenstoff",
		"Stickstoff",
		"Sauerstoff",
		"Fluor",
		"Neon",
		"Natrium",
		"Magnesium",
		"Aluminium",
		"Silicium",
		"Phosphor",
		"Schwefel",
		"Chlor",
		"Argon",
		"Kalium",
		"Calcium",
		"Scandium",
		"Titan",
		"Vanadium",
		"Chrom",
		"Mangan",
		"Eisen",
		"Cobalt",
		"Nickel",
		"Kupfer",
		"Zink",
		"Gallium",
		"Germanium",
		"Arsen",
		"Selen",
		"Brom",
		"Krypton",
		"Rubidium",
		"Strontium",
		"Yttrium",
		"Zirconium",
		"Niob",
		"Molybdän",
		"Technetium",
		"Ruthenium",
		"Rhodium",
		"Palladium",
		"Silber",
		"Cadmium",
		"Indium",
		"Zinn",
		"Antimon",
		"Tellur",
		"Iod",
		"Xenon",
		"Caesium",
		"Barium",
		"Lanthan",
		"Cer",
		"Praseodym",
		"Neodym",
		"Promethium",
		"Samarium",
		"Europium",
		"Gadolinium",
		"Terbium",
		"Dysprosium",
		"Holmium",
		"Erbium",
		"Thulium",
		"Ytterbium",
		"Lutetium",
		"Hafnium",
		"Tantal",
		"Wolfram",
		"Rhenium",
		"Osmium",
		"Iridium",
		"Platin",
		"Gold",
		"Quecksilber",
		"Thallium",
		"Blei",
		"Bismut",
		"Polonium",
		"Astat",
		"Radon",
		"Francium",
		"Radium",
		"Actinium",
		"Thorium",
		"Protactinium",
		"Uran",
		"Neptunium",
		"Plutonium"
	]
end

@testset "get_radioactive_elements" begin
	elements = read_chemical_elements("../src/PeriodicTable.json")
	radioactive_elements = get_radioactive_elements(elements, false)
	radioactive_elements = [element.name_de for element in radioactive_elements]
	@test length(radioactive_elements) == 38
	@test radioactive_elements == [
		"Technetium",
		"Promethium",
		"Bismut",
		"Polonium",
		"Astat",
		"Radon",
		"Francium",
		"Radium",
		"Actinium",
		"Thorium",
		"Protactinium",
		"Uran",
		"Neptunium",
		"Plutonium",
		"Americium",
		"Curium",
		"Berkelium",
		"Californium",
		"Einsteinium",
		"Fermium",
		"Mendelevium",
		"Nobelium",
		"Lawrencium",
		"Rutherfordium",
		"Dubnium",
		"Seaborgium",
		"Bohrium",
		"Hassium",
		"Meitnerium",
		"Darmstadtium",
		"Roentgenium",
		"Copernicium",
		"Nihonium",
		"Flerovium",
		"Moscovium",
		"Livermorium",
		"Tenness",
		"Oganesson"
	]
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
	single_letter_elements = [element.name_de for element in single_letter_elements]
	@test length(single_letter_elements) == 14
	@test "Yttrium" ∈ single_letter_elements
	@test "Zink" ∉ single_letter_elements
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
	PSE_matrix = get_PSE_matrix(elements,false)
	PSE_matrix_wide = get_PSE_matrix(elements,true)
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