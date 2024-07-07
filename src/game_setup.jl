include("elements.jl")

mutable struct Variant
    name::String
    target_elements::Array
    mode::String
end

mutable struct Game
    name::String
    variant::Variant
end

dict_game_variants = Dict(
    "a" => Variant("Alle Elemente", get_elements_by_blocks(elements, ["s", "p", "d", "f"]), "normal"),
    "ae" => Variant("Alle Elemente", get_elements_by_blocks(elements, ["s", "p", "d", "f"]), "easy"),
    "b" => Variant("1. Hauptgruppe", get_group_elements(elements, 1), "normal"),
    "be" => Variant("1. Hauptgruppe", get_group_elements(elements, 1), "easy"),
    "c" => Variant("2. Hauptgruppe", get_group_elements(elements, 2), "normal"),
    "ce" => Variant("2. Hauptgruppe", get_group_elements(elements, 2), "easy"),
    "d" => Variant("3. Hauptgruppe", get_group_elements(elements, 13), "normal"),
    "de" => Variant("3. Hauptgruppe", get_group_elements(elements, 13), "easy"),
    "e" => Variant("4. Hauptgruppe", get_group_elements(elements, 14), "normal"),
    "ee" => Variant("4. Hauptgruppe", get_group_elements(elements, 14), "easy"),
    "f" => Variant("5. Hauptgruppe", get_group_elements(elements, 15), "normal"),
    "fe" => Variant("5. Hauptgruppe", get_group_elements(elements, 15), "easy"),
    "g" => Variant("6. Hauptgruppe", get_group_elements(elements, 16), "normal"),
    "ge" => Variant("6. Hauptgruppe", get_group_elements(elements, 16), "easy"),
    "h" => Variant("7. Hauptgruppe", get_group_elements(elements, 17), "normal"),
    "he" => Variant("7. Hauptgruppe", get_group_elements(elements, 17), "easy"),
    "i" => Variant("8. Hauptgruppe", get_group_elements(elements, 18), "normal"),
    "ie" => Variant("8. Hauptgruppe", get_group_elements(elements, 18), "easy"),
    "j" => Variant("Hauptgruppenelemente", get_elements_by_blocks(elements, ["s", "p"]), "normal"),
    "je" => Variant("Hauptgruppenelemente", get_elements_by_blocks(elements, ["s", "p"]), "easy"),
    "k" => Variant("Nebengruppenelemente", get_elements_by_blocks(elements, ["d"]), "normal"),
    "ke" => Variant("Nebengruppenelemente", get_elements_by_blocks(elements, ["d"]), "easy"),
    "l" => Variant("Lanthanide", get_group_elements(elements, "lanthanide"), "na"),
    "m" => Variant("Actinide", get_group_elements(elements, "actinide"), "na"),
    "n" => Variant("Natürliche Elemente", get_nature_elements(elements), "na"),
    "o" => Variant("Künstliche Elemente", get_synthetic_elements(elements), "na"),
    "p" => Variant("Radioaktive Elemente", get_radioactive_elements(elements), "normal"),
    "pe" => Variant("Radioaktive Elemente", get_radioactive_elements(elements), "easy"),
    "q" => Variant("Elemente mit einbuchstabigen Symbolen", get_single_letter_elements(elements), "na"),
    "r" => Variant("Reinelemente", mononuclidic_elements, "na"),
    "s" => Variant("Elemente mit gleichen deutschen und englischen Namen", get_elements_with_same_name(elements), "normal"),
    "se" => Variant("Elemente mit gleichen deutschen und englischen Namen", get_elements_with_same_name(elements), "easy"),
    "t" => Variant("Tom Lehrer Elemente", get_Tom_Lehrer_de_elements(elements, Tom_Lehrer_en_elements), "na")
)

function input_game_type(dict_game_variants)
    _row = ["$key $(variant.name)" for (key, variant) in (dict_game_variants) if length(key) == 1]
    println.("\t", sort(_row))
    _single_keys = [single for single in keys(dict_game_variants) if length(single) == 1]
    _keys_str = join(sort(collect(_single_keys)), ", ")
    println("\tWelches Spiel möchten Sie spielen: $_keys_str?")

    _chosen_game_letter = ""
    while length(_chosen_game_letter) != 1
        _input_game_letter = readline()
        if _input_game_letter in _single_keys
            _chosen_game_letter *= _input_game_letter
        end
    end

    if dict_game_variants[_chosen_game_letter].mode == "normal"
        
        println("Wenn Sie das Spiel ohne künstliche Elemente spielen wollen, geben Sie j ein.")
        _input_mode = readline()
        if _input_mode == "j"
            return _chosen_game_letter*"e"
        end

    end

    return _chosen_game_letter
end

function get_elements_to_guess(dict_game_variants, game_type_key::String)
    _elements_to_guess = dict_game_variants[game_type_key].target_elements
    #if length(game_type_key) == 2
    #    _elements_to_guess = get_elements_without_synthetic_elements(_elements_to_guess)
    #end
    return _elements_to_guess 
end

game_type = input_game_type(dict_game_variants)
println(game_type)
x = get_elements_to_guess(dict_game_variants, game_type)
println(x)