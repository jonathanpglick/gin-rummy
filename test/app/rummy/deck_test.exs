defmodule App.DeckTest do
  use App.DataCase

  describe "deck" do
    alias App.Rummy.Deck

    test "deal cards for two" do
      deck = Deck.get_deck()
      {hands, draw_deck} = Deck.deal(deck, 2)
      assert length(hands) == 2
      assert Enum.fetch!(hands, 0) == Enum.slice(deck, 0, 10)
      assert Enum.fetch!(hands, 1) == Enum.slice(deck, 10, 10)
      assert draw_deck == Enum.slice(deck, 20, 32)
    end

    test "deal cards for three" do
      deck = Deck.get_deck()
      {hands, draw_deck} = Deck.deal(deck, 3)
      assert length(hands) == 3
      assert Enum.fetch!(hands, 0) == Enum.slice(deck, 0, 10)
      assert Enum.fetch!(hands, 1) == Enum.slice(deck, 10, 10)
      assert Enum.fetch!(hands, 2) == Enum.slice(deck, 20, 10)
      assert draw_deck == Enum.slice(deck, 30, 22)
    end

  end
end
