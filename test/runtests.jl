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


