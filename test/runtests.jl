using Test
include("../src/elements.jl") # Pfad zur Datei, die das Modul `Elements` enthält
import .Elements as E
p
#=
@testset "Element Struct Tests" begin
	# Test der Instanziierung

	elements = E.read_chemical_elements("C:/Users/sheng/git_projects/PSE/src/PeriodicTable.json")

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
=#
