#GREEDY GAME CODE IN RUBY, From Ruby Koans
class DiceSet #Getting random value for DICE ROLL
  attr_reader :values
  def roll(number)
    @values = (1..number).map{ rand(6) + 1 }
    @values
  end
end

class Player # Class for maintaining information of Player's game 
	attr_accessor :player
	def initialize(name)
		@player = {
			name: name,
			remaining_turn: 5,
			final_score: 0, 
			temp_score: 0 #temporary storing accumulating score for multiple turn
		}
		@player
	end

	def start_roll(player)  #Function for rolling DICE for the player
	  roll = DiceSet.new()
		rolled_dices = roll.roll(player[:remaining_turn])
		puts "Player #{player[:name] + 1} rolls : #{rolled_dices.join(", ")}"
		get_score(rolled_dices) #Get calculated score based on DICE ROLLED
	end

	def get_score(dice) # Caculate scores based on number of dice rolled
		score = 0
		points = Hash.new(0)
		points[1] = 100
		points[5] = 50
		scored_dice = 0 # DICES that has been scored, maintaining it in order to remove it.
	  
	 	counts = Hash.new(0)
	  	dice.each { |number| counts[number] += 1 } # Storing each number's count in a HASH
	  	
	  	counts.each do |number, count|
		    if count >= 3
		      if number == 1
		        score += 1000
		      else
		        score += (number * 100)
		      end
		      count = count - 3
		      @player[:remaining_turn] -= 3
		    end
		    @player[:remaining_turn] -= count if points[number] != 0 #Reducing number of turn
		    
		    score += points[number] * count
	  	end
	  	@player[:remaining_turn] = 5 if @player[:remaining_turn] == 0 #Reset to 5, if all the dice scored
	  	score
	end
end

class Game
	def initialize()
		@players = [] # Array of Hashes of Players info
		@last_game = {} # Status of lst game
		@last_player = 0 # Set 1, if last player is winning
		@rounds = 1 # Numbers of round/turn completed
	end

	def process_result(score, player) #Display score info
		player_index = player[:name].next
		puts "Score in this round: #{score}"
		puts "Total score: #{player[:final_score]}"
		puts "" if score == 0
		if (player[:temp_score] == 0  && score >= 0) || player[:temp_score] != 0
			if score != 0
				player[:temp_score] += score
			  	puts "\e[36mDo you want to roll the non-scoring #{player[:remaining_turn]} dices?(y/n):\e[0m"
				user_choice = gets.chomp

				if user_choice == "y"
					if player[:temp_score] > 0
					  	player_index = player[:name] # Next Player's turn
					end
				else
					puts "\n"
					if player[:temp_score] >= 300 || player[:final_score] >= 300
						player[:final_score] += player[:temp_score] #Saving Final Score
					end

					if player[:final_score] >= 3000 && !@last_game[:status]
						puts "----Give your all! This is the last turn----".upcase
						@last_game = { status: true, is_last_player: player_index == @players.size}
					end
				end
			end
		end
		reset_player_turn(player) if player_index == player[:name].next
		start_playing(player_index)
	end

	def reset_player_turn(player)
		player[:remaining_turn] = 5 # Resetting the number turn
		player[:temp_score] = 0 # Resetting Accumulated score
	end

	def start_game #Asking user to enter player's name
		puts "\nEnter Number of players :"
		user_input = gets.chomp
		n_players = user_input.to_i
		n_players.times { |player|
			@players.push Player.new(player)
		}
		puts "\nTurn 1: \n ------"
		start_playing(0) #Start the game with First player
	end

	def start_playing(player_index)
		if @last_game[:is_last_player] && player_index == @players.size #Condition for last game
			player_index = 0 #Start last game with first player
			@last_player = 1 # Dont inculde last player
			@last_game[:is_last_player] = false if @last_game[:status]
		end
		if player_index < @players.size - @last_player
			player_obj =  @players[player_index] # Varibale Caching
			player_info = player_obj.player

			score = player_obj.start_roll(player_info) # Get Score

			process_result(score, player_info)
		else
			@rounds += 1
			puts "Turn #{@rounds}: \n ------" if !@last_game[:status]
			if !@last_game[:status] || @last_game[:is_last_player] # Condition if "last player" crosses winning threshhold
				start_playing(0) #Start last game from first player if last player is winning.
			else
				winner = @players.max_by do |player|
				 	player.player[:final_score]
				end
				puts "\n$$$ Hurray! Most Greedy person is : Player #{winner.player[:name] + 1} with score of #{winner.player[:final_score]} Points $$$ \n\n".upcase
			end
		end
	end # End of "start_playing" Function
end

new_game = Game.new
new_game.start_game
