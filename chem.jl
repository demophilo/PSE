
using JSON

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

function read_chemical_elements(filename::String)
    _PSE_data = read(filename, String)
    _elemente_dict = JSON.parse(_PSE_data)
    return _elemente_dict["chem_elements"]
end

element_dicts = read_chemical_elements("PeriodicTable.json")
elements = [Element([dict["$field_name"] for field_name in fieldnames(Element)]...) for dict in element_dicts]

mononuclidic_element = ["Beryllium", "Fluor", "Natrium", "Aluminium", "Phosphor", "Scandium", "Mangan", "Cobalt", "Arsen", "Yttrium", "Niob", "Rhodium", "Iod", "Caesium", "Praseodym", "Terbium", "Holmium", "Thulium", "Gold", "Bismut", "Thorium", "Plutonium"]

function get_group_elements(group_name)
    return [element.name_de for element in elements if element.group == group_name]
end

function get_nature_elements(is_natural::Bool)
    return [element.name_de for element in elements if element.synthetic != is_natural]
end

function get_elements_by_blocks(blockletters::Vector{String})
    return [element.name_de for element in elements for block in blockletters if element.block == block]
end

function get_stable_elements(is_stable::Bool)
    return [element.name_de for element in elements if (element.stable == is_stable)]
end

function get_single_letter_elements()
    return [element.name_de for element in elements if length(element.symbol) == 1]
end

function get_elements_with_same_name()
    return [element.name_de for element in elements if element.name == element.name_de]
end

struct Variant
    name::String
    target_elements::Array
end

function assign_color()
    farben = Dict(
        'a' => "\e[31m", # red
        'b' => "\e[32m", # green
        'c' => "\e[33m", # yellow
        'd' => "\e[34m", # blue
        'e' => "\e[35m", # lila
        'f' => "\e[36m", # light blue
        'g' => "\e[37m", # white
        'h' => "\e[91m", # light red
        'i' => "\e[92m", # green
        'j' => "\e[93m"  # light yellow
    )
    return farben
end

title ="""\e[34m
     _____                                                                   _____)                         
   (, /   )         ,       /                                   /           /       /                        
     /__ /  _  __     _  __/  _  _  _       _   _/_ _  __    __/  _  __    /__     /  _  __   _  _ _/_  _ 
    /     _(/_/ (__(_(_)(_(__(/_//_/_)_(_/_/_)__/__(/_///   (_(__(/_/ (_  /       /__(/_///__(/_//_/___(/_
 ) /                                  .-/                                (_____)                             
(_/                                  (_/                                                                      \e[0m
"""

dict_game_variants = Dict(
    "a" => Variant("Alle Elemente", get_elements_by_blocks(["s", "p", "d", "f"])),
    "b" => Variant("1. Hauptgruppe", get_group_elements(1)),
    "c" => Variant("2. Hauptgruppe", get_group_elements(2)),
    "d" => Variant("3. Hauptgruppe", get_group_elements(13)),
    "e" => Variant("4. Hauptgruppe", get_group_elements(14)),
    "f" => Variant("5. Hauptgruppe", get_group_elements(15)),
    "g" => Variant("6. Hauptgruppe", get_group_elements(16)),
    "h" => Variant("7. Hauptgruppe", get_group_elements(17)),
    "i" => Variant("8. Hauptgruppe", get_group_elements(18)),
    "j" => Variant("Hauptgruppenelemente", get_elements_by_blocks(["s", "p"])),
    "k" => Variant("Nebengruppenelemente", get_elements_by_blocks(["d"])),
    "l" => Variant("Lanthanide", get_group_elements("lanthanide")),
    "m" => Variant("Actinide", get_group_elements("actinide")),
    "n" => Variant("Natürliche Elemente", get_nature_elements(true)),
    "o" => Variant("Künstliche Elemente", get_nature_elements(false)),
    "p" => Variant("Radioaktive Elemente", get_stable_elements(false)),
    "q" => Variant("Elemente mit einbuchstabigen Symbolen", get_single_letter_elements()),
    "r" => Variant("Reinelemente", mononuclidic_element),
    "s" => Variant("Elemente mit gleichen deutschen und englischen Namen", get_elements_with_same_name())
)

function input_game_type()
    row = ["$key $(variant.name)" for (key, variant) in (dict_game_variants)]
    println.("\t", sort(row))
    _keys_str = join(sort(collect(keys(dict_game_variants))), ", ")
    println("\tWelches Spiel möchten Sie spielen: $_keys_str?")
    
    while true
        _chosen_game_letter = readline()
        if _chosen_game_letter[1] in _keys_str
            return _chosen_game_letter
        end
    end  
end

function get_elements_to_guess(game_type_key::String)
    return dict_game_variants[game_type_key].target_elements 
end

"""
    get_PSE_matrix(is_wide = true)

generates the PSE matrix, fills it with empty strings and fills the right positions with the element symbols
if is_wide is true, a wide matrix will be generated
"""
function get_PSE_matrix(is_wide = true)
    if is_wide == true
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
    filter_periodic_table(PSE_matrix, symbols_to_show, element_sympols_to_guess)

hides the false elements, colors the right elements and the positions to guess
"""
function filter_periodic_table(PSE_matrix, symbols_to_show, element_sympols_to_guess)
    _filtered_matrix = copy(PSE_matrix)
    _max_rows, _max_columns = size(_filtered_matrix)
    for row in 1:_max_rows
        for column in 1:_max_columns
            if !(_filtered_matrix[row,column] in symbols_to_show || _filtered_matrix[row,column] == "")
                if _filtered_matrix[row,column] in element_sympols_to_guess
                    _filtered_matrix[row,column] = "\e[31m__ \e[0m"
                else
                    _filtered_matrix[row, column] = "__ "
                end
                
            end
            if _filtered_matrix[row,column] == ""
                _filtered_matrix[row, column] = "   "
            end
            if _filtered_matrix[row,column] in symbols_to_show
                cell = rpad(_filtered_matrix[row, column],3," ")
                _filtered_matrix[row, column] = "\e[32m$cell\e[0m"
            end
        end
    end

    return _filtered_matrix
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

function input_element()
    print("Gib ein Element ein: ")
    trial_element = readline()
    return trial_element
end

function clear_sreen()
    print("\e[2J")
end

"""
    display_screen(show_matrix, score, time_bonus)

shows the gaming screen with title, PSE and score
"""
function display_screen(show_matrix, score, time_bonus)
    clear_sreen()
    println(title,"\n"^10)
    println("")
    print_PSE(show_matrix)
    println("")
    _total = score + time_bonus
    println("Score: $score    Timebonus: $time_bonus    Total: $_total")
end

# sets up the game
clear_sreen()
println(title,"\n"^10)
game_type = input_game_type()
elements_to_guess = get_elements_to_guess(game_type)
element_sympols_to_guess = [element.symbol for element in elements if element.name_de in elements_to_guess]

# sets up the initial values 
is_wide = false
periodic_table_matrix = get_PSE_matrix(is_wide)
right_element_names = Set([])
right_element_symbols = []
start_time = time()
max_time = length(elements_to_guess)*10
score::Int = 0
time_bonus::Int = max_time*10

# displays the first screen
show_matrix = filter_periodic_table(periodic_table_matrix, right_element_symbols, element_sympols_to_guess)
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

    global score::Int = length(right_element_names)*100
    global time_bonus::Int = (max_time - round(duration)) > 0 ? (max_time - round(duration)) * 10 : 0
    

    global show_matrix = filter_periodic_table(periodic_table_matrix, right_element_symbols, element_sympols_to_guess)
    display_screen(show_matrix, score, time_bonus)
end













