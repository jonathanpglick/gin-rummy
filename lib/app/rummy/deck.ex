defmodule App.Rummy.Deck do

  @moduledoc """
  Utilities to represent a deck of cards.

  H(earts), D(iamonds), S(pades), C(lubs)
  02-10 as value
  11 = Jack
  12 = Queen
  13 = King
  14 = Ace
  """
  @suits ["H", "D", "S", "C"]
  @cards ["02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14"]

  def get_shuffled_deck() do
    Enum.shuffle(get_deck())
  end

  def get_deck() do
    List.flatten(
      Enum.map(@suits, fn suit ->
        Enum.map(@cards, fn card ->
          suit <> card
        end)
      end)
    )
  end
end
