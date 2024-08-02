module Elements
using JSON
export Element, read_chemical_elements

struct Element
	name::String # English name of the element
	name_de::String
	symbol::String
	number::Integer
	xpos::Integer # x position in compact PSE
	ypos::Integer # y position in compact PSE
	wxpos::Integer # x position in wide PSE
	wypos::Integer # y position in wide PSE
	group::Any # 1...18, "lanthanid", "actinide"
	block::String # s, p, d, f
	stable::Bool
	synthetic::Bool
end

"""
	read_chemical_elements(filename::String)

reads the information of the json file and returns a dictionary
"""
function read_chemical_elements(filename::String)
	_PSE_data = read(filename, String)
	_elemente_dict = JSON.parse(_PSE_data)
	_elements = [Element([dict["$field_name"] for field_name in fieldnames(Element)]...) for dict in _elemente_dict]
	return _elements
end

# functions to get elements::Vector{Element}
mononuclidic_elements = [
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

Tom_Lehrer_en_elements = [
	"Antimony",
	"Arsenic",
	"Aluminium",
	"Selenium",
	"Hydrogen",
	"Oxygen",
	"Nitrogen",
	"Rhenium",
	"Nickel",
	"Neodymium",
	"Neptunium",
	"Germanium",
	"Iron",
	"Americium",
	"Ruthenium",
	"Uranium",
	"Europium",
	"Zirconium",
	"Lutetium",
	"Vanadium",
	"Lanthanum",
	"Osmium",
	"Astatine",
	"Radium",
	"Gold",
	"Protactinium",
	"Indium",
	"Gallium",
	"Iodine",
	"Thorium",
	"Thulium",
	"Thallium",
	"Yttrium",
	"Ytterbium",
	"Actinium",
	"Rubidium",
	"Boron",
	"Gadolinium",
	"Niobium",
	"Iridium",
	"Strontium",
	"Silicon",
	"Silver",
	"Samarium",
	"Bismuth",
	"Bromine",
	"Lithium",
	"Beryllium",
	"Barium",
	"Holmium",
	"Helium",
	"Hafnium",
	"Erbium",
	"Phosphorus",
	"Francium",
	"Fluorine",
	"Terbium",
	"Manganese",
	"Mercury",
	"Molybdenum",
	"Magnesium",
	"Dysprosium",
	"Scandium",
	"Cerium",
	"Cesium",
	"Lead",
	"Praseodymium",
	"Platinum",
	"Plutonium",
	"Palladium",
	"Promethium",
	"Potassium",
	"Polonium",
	"Tantalum",
	"Technetium",
	"Titanium",
	"Tellurium",
	"Cadmium",
	"Calcium",
	"Chromium",
	"Curium",
	"Sulfur",
	"Californium",
	"Fermium",
	"Berkelium",
	"Mendelevium",
	"Einsteinium",
	"Nobelium",
	"Argon",
	"Krypton",
	"Neon",
	"Radon",
	"Xenon",
	"Zinc",
	"Rhodium",
	"Chlorine",
	"Carbon",
	"Cobalt",
	"Copper",
	"Tungsten",
	"Tin",
	"Sodium"
]

function get_group_elements(elements::Vector{Element}, group_name::Any, easy_mode::Bool)
	return [_element for _element in elements if _element.group == group_name && (_element.number <= 94 || _element.number >= 95 && !easy_mode)]
end

function get_nature_elements(elements::Vector{Element})
	return [_element for _element in elements if !_element.synthetic]
end

function get_synthetic_elements(elements::Vector{Element})
	return [_element for _element in elements if _element.synthetic]
end

function get_elements_by_blocks(elements::Vector{Element}, blockletters::Vector{String}, easy_mode::Bool)
	return [_element for _element in elements for _block in blockletters if _element.block == _block && (_element.number <= 94 || (_element.number >= 95 && !easy_mode))]
end

function get_stable_elements(elements::Vector{Element})
	return [_element for _element in elements if _element.stable]
end

function get_radioactive_elements(elements::Vector{Element}, easy_mode::Bool)
	return [_element for _element in elements if !_element.stable && (_element.number <= 94 || _element.number >= 95 && !easy_mode)]
end

function get_single_letter_elements(elements::Vector{Element})
	return [_element for _element in elements if length(_element.symbol) == 1]
end

function get_elements_with_same_name(elements::Vector{Element}, easy_mode::Bool)
	return [_element for _element in elements if _element.name == _element.name_de && (_element.number <= 94 || _element.number >= 95 && !easy_mode)]
end

function get_Tom_Lehrer_de_elements(elements::Vector{Element}, Tom_Lehrer_en_elements)
	return [_element for _element in elements if _element.name in Tom_Lehrer_en_elements]
end

function get_elements_without_synthetic_elements(elements::Vector{Element})
	return [_element for _element in elements if _element.number < 95]
end

function element_compare(element1::Element, element2::Element)
	if element1.group == element2.group
		return element1.number < element2.number
	elseif element1.group == "lanthanide" && element2.group == "actinide"
		return true
	elseif element1.group == "actinide" && element2.group == "lanthanide"
		return false
	elseif (element1.group == "actinide" || element1.group == "lanthanide") && (element2.group != "actinide" && element2.group != "lanthanide")
		return false
	elseif (element1.group != "actinide" && element1.group != "lanthanide") && (element2.group == "actinide" || element2.group == "lanthanide")
		return true
	elseif element1.group != "actinide" && element1.group != "lanthanide" && element2.group != "actinide" && element2.group != "lanthanide"
		return element1.group < element2.group
	else
		println("ein Fall beim Sortieren der Elemente wurde nicht bedacht")
	end
end

function sort_elements_chemically(elements::Vector{Element})
	_elements = sort(elements, lt = (x, y) -> element_compare(x, y))
	return _elements
end

"""
	get_PSE_matrix(is_wide = true)

generates the PSE matrix, fills it with empty strings and fills the right positions with the element symbols
if is_wide is true, a wide matrix will be generated
"""
function get_PSE_matrix(elements::Vector{Element}, is_wide = true)
	if is_wide
		_periodic_table_matrix = fill("", 8, 32)
		for element in elements
			_periodic_table_matrix[element.wypos, element.wxpos] = element.symbol
		end
	else
		_periodic_table_matrix = fill("", 10, 18)
		for element in elements
			_periodic_table_matrix[element.ypos, element.xpos] = element.symbol
		end
	end
	return _periodic_table_matrix
end

"""
	print_PSE(PSE_matrix)

prints the PSE matrix
"""
function print_PSE(PSE_matrix)
	_max_row, _max_column = size(PSE_matrix)
	for row in 1:_max_row
		for column in 1:_max_column
			print(PSE_matrix[row, column])
		end
		print("\n")
	end
end


"""
	filter_periodic_table(PSE_matrix, symbols_to_show, element_sympols_to_guess)

hides the false elements, colors the right elements and the positions to guess
"""
function filter_periodic_table(PSE_matrix, symbols_to_show, element_sympols_to_guess)
	_filtered_matrix = copy(PSE_matrix)
	_max_rows, _max_columns = size(_filtered_matrix)
	_elements_not_yet_guessed = setdiff(element_sympols_to_guess, symbols_to_show)
	for row in 1:_max_rows
		for column in 1:_max_columns

			if _filtered_matrix[row, column] in symbols_to_show
				_cell = rpad(_filtered_matrix[row, column], 3, " ")
				_filtered_matrix[row, column] = "\e[32m$_cell\e[0m"
			end


			if _filtered_matrix[row, column] in _elements_not_yet_guessed
				_filtered_matrix[row, column] = "\e[31m__ \e[0m"
			end



			if !(_filtered_matrix[row, column] in symbols_to_show || _filtered_matrix[row, column] == "")
				if _filtered_matrix[row, column] in element_sympols_to_guess
					_filtered_matrix[row, column] = "\e[31m__ \e[0m"
				else
					_filtered_matrix[row, column] = "__ "
				end

			end

			if _filtered_matrix[row, column] == ""
				_filtered_matrix[row, column] = "   "
			end


		end
	end

	return _filtered_matrix
end
print_PSE(get_PSE_matrix(elements::Vector{Element}, true))

end # module
