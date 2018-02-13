defmodule FavoriteCoffees do
  @people {:magnus, :wolf, :jett, :zephyr, :drake, :waldo, :maverick, :king, :scarlett, :isadora,
           :harlow, :lola, :marlowe, :ophelia, :zenobia, :solange, :wolf, :hurricane, :gunner,
           :king, :jax, :striker, :seven, :dagger, :cashel, :lorcan, :isidore, :clancy, :casimir,
           :zebulon, :webb, :barnabas, :franny, :katherina, :jacinta, :sybil, :electra, :pippa,
           :guinivere, :federica}
  @coffees {:caffe_americano, :cafe_cubano, :caffe_crema, :cafe_zorro, :doppio, :espresso_romano,
            :guillermo, :ristretto, :antoccino, :breve, :cafe_au_lait, :ca_phe_sua_da,
            :cafe_bombon, :cappuccino, :cortado, :egg_coffee, :eggnog_latte, :eiskaffee,
            :espressino, :espresso_con_panna, :flat_white, :galao, :caffe_gommosa, :kopi_susu,
            :latte, :latte_macchiato, :macchiato, :wiener_or_viennese_melange, :white_coffee,
            :white_coffee_uk, :vienna_coffee, :coffee_with_espresso, :coffee_with_tea,
            :coffee_with_alcohol, :melya, :caffe_marocchino, :cafe_miel,
            :mocha_or_cafe_mocha_or_mochaccino, :cafe_de_olla, :cafe_rapido_y_sucio,
            :miscellaneous, :mazagran, :palazzo, :ice_shot, :shakerato, :affogato, :botz,
            :caffe_medici, :cafe_touba, :canned_coffee, :coffee_milk, :double_double,
            :indian_filter_coffee, :pocillo}

  def random_tuple do
    {random_person(), random_coffee()}
  end

  def random_person do
    elem(@people, :rand.uniform(tuple_size(@people)) - 1)
  end

  def random_coffee do
    elem(@coffees, :rand.uniform(tuple_size(@coffees)) - 1)
  end
end
