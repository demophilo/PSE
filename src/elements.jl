module Elements
using JSON

include("screen_manipulation.jl")
using .ScreenManipulation

export Element, read_chemical_elements, get_group_elements, get_nature_elements, get_synthetic_elements, get_elements_by_blocks, get_stable_elements, get_radioactive_elements, get_single_letter_elements, get_elements_with_same_name,
	get_mononuclidic_elements, element_compare, sort_elements_chemically, get_PSE_matrix, print_PSE, get_PSE_ready_to_print, get_Lehrer_elements, get_elements_not_to_guess

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
	mononuclidic::Bool
	Lehrer_number::Union{Integer, Nothing}
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


function get_Lehrer_elements(elements::Vector{Element})
	Lehrer_element_vector = [_element for _element in elements if !isnothing(_element.Lehrer_number)]
	sort!(Lehrer_element_vector, by = x -> x.Lehrer_number)
	return Lehrer_element_vector
end

function get_group_elements(elements::Vector{Element}, group_name::Any, easy_mode::Bool)
	return [_element for _element in elements if _element.group == group_name && (_element.number <= 94 || _element.number >= 95 && !easy_mode)]
end

function get_nature_elements(elements::Vector{Element})
	return [_element for _element in elements if !_element.synthetic]
end

function get_elements_by_blocks(elements::Vector{Element}, blockletters::Vector{String}, easy_mode::Bool)
	return [_element for _element in elements for _block in blockletters if _element.block == _block && !(_element.synthetic && easy_mode)]
end

function get_stable_elements(elements::Vector{Element})
	return [_element for _element in elements if _element.stable]
end

function get_radioactive_elements(elements::Vector{Element}, easy_mode::Bool)
	return [_element for _element in elements if !_element.stable && !(_element.synthetic && easy_mode)]
end

function get_single_letter_elements(elements::Vector{Element})
	return [_element for _element in elements if length(_element.symbol) == 1]
end

function get_elements_with_same_name(elements::Vector{Element}, easy_mode::Bool)
	return [_element for _element in elements if _element.name == _element.name_de && !(_element.synthetic && easy_mode)]
end

function get_mononuclidic_elements(elements::Vector{Element})
	return [_element for _element in elements if _element.mononuclidic]
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
function get_PSE_ready_to_print(PSE_matrix, elements_to_show, elements_symbols_to_guess, elements_not_to_guess)
	_filtered_matrix = copy(PSE_matrix)
	_max_rows, _max_columns = size(_filtered_matrix)
	_elements_not_yet_guessed = setdiff(elements_symbols_to_guess, elements_to_show)

	for row in 1:_max_rows
		for column in 1:_max_columns

			if _filtered_matrix[row, column] in elements_to_show
				_cell = rpad(_filtered_matrix[row, column], 3, " ")
				_filtered_matrix[row, column] = "\e[32m$_cell\e[0m"
			end

			if _filtered_matrix[row, column] in _elements_not_yet_guessed
				_filtered_matrix[row, column] = "\e[31m__ \e[0m"
			end

			if _filtered_matrix[row, column] in elements_not_to_guess
				_filtered_matrix[row, column] = "__ "
			end

			if _filtered_matrix[row, column] == ""
				_filtered_matrix[row, column] = "   "
			end


		end
	end

	return _filtered_matrix
end

function get_elements_not_to_guess(elements::Vector{Element}, elements_to_guess::Vector{Element})
	return [_element for _element in elements if !(_element in elements_to_guess)]
end


end # module
