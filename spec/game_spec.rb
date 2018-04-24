require "rspec"
require_relative "../lib/game.rb"

describe Game do
  it "word guessed" do
    game = Game.new("колбаса")
    expect(game.status).to eq :in_progress
    game.next_step("к")
    game.next_step("о")
    game.next_step("л")
    game.next_step("б")
    game.next_step("а")
    game.next_step("1")
    game.next_step("с")

    expect(game.errors).to eq 1
    expect(game.status).to eq :won
  end

  it "user loses the game" do
    game = Game.new("амкар")
    game.next_step("2")
    game.next_step("о")
    game.next_step("л")
    game.next_step("б")
    game.next_step("3")
    game.next_step("с")
    game.next_step("1")
    game.next_step("q")

    expect(game.errors).to eq 7
    expect(game.status).to eq :lost
  end



end
