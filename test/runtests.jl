using Test
include("../src/elements.jl") # Pfad zur Datei, die das Modul `Elements` enthält
using .Elements # Zugriff auf das Modul `Elements`


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