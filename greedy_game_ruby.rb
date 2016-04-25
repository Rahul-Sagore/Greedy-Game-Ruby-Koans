#GREEDY GAME CODE IN RUBY
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
		@name = name.upcase
		@player = {
			name: @name,
			remaining_turn: 5,
			final_score: 0, 
			temp_score: 0 #temporary storing accumulating score for multiple turn
		}
		@player
	end

	def start_roll(times)  #Function for rolling DICE for the player
	  roll = DiceSet.new()
		rolled_dices = roll.roll(times)
		puts "\nYour rolled dice numbers are: #{rolled_dices}"
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

	  	if @player[:temp_score] == 0  && score >= 300
	  			showScoreInfo(score)
	  	elsif @player[:temp_score] != 0
	  		showScoreInfo(score)
	  	else
		  	@player[:remaining_turn] = 5 # Resetting the number turn
		  	puts "OOPS! Your score is #{score}. Minimum score required to participate is 300. \n"
	  	end
	end

	def showScoreInfo(score) #Display score info
		@player[:temp_score] += score
	  puts "Your current score is: #{score}, \nTemporary Total score: #{@player[:temp_score]}"
	  puts "Previously saved Score: #{@player[:final_score]}" if @player[:final_score] > 0
	  score
	end
end

class Game
	def initialize()
		@players = [] # Array of Hashes of Players info
		@last_game = {} # Status of lst game
		@last_player = 0 # Set 1, if last player is winning
	end

	def start_game #Asking user to enter player's name
		puts "\nPlease Enter Players name separating each one with space :"
		user_input = gets.chomp
		users_array = user_input.split(" ")
		users_array.each { |player|
			@players.push Player.new(player)
		}
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

			puts "\nCurrent player is #{player_info[:name]}:"
			puts "\e[31mRemaining turn: #{player_info[:remaining_turn]}. Wants to Roll the dice? (y/n) :\e[0m" 
			choice = gets.chomp

			if choice == "y" #IF user want to roll the dice 
				score = player_obj.start_roll(player_info[:remaining_turn]) # Get Score

				if score != 0 # If user scored something
					if player_info[:temp_score] > 0
						player_info[:remaining_turn] = 5 if player_info[:remaining_turn] == 0 # Reset turn if All dice are scoring
					  	start_playing(player_index) #Rolling dice again
					else
					  	start_playing(player_index.next) # Next Player's turn
					end
				else # Resetting player info if failed to score something
					player_info[:remaining_turn] = 5
					player_info[:temp_score] = 0 # Resetting Accumulated score
					start_playing(player_index.next) #Next player's turn
				end
			else # IF user chose to quit the turn
				player_info[:final_score] += player_info[:temp_score] #Saving Final Score
				player_info[:temp_score] = 0 # Resetting Accumulated score
				player_info[:remaining_turn] = 5

				if player_info[:final_score] >= 3000 && !@last_game[:status]
					puts "----Give your all! This is the last turn----".upcase
					@last_game = { status: true, is_last_player: player_index.next == @players.size}
				end
				start_playing(player_index.next)
			end
		else
			if !@last_game[:status] || @last_game[:is_last_player] # Condition if "last player" crosses winning threshhold
				start_playing(0) #Start last game from first player if last player is winning.
			else
				winner = @players.max_by do |player|
				 	player.player[:final_score]
				end
				puts "\nHurray! Most Greedy person is : #{winner.player[:name]} with score of #{winner.player[:final_score]} \n".upcase
			end
		end
	end # End of "start_playing" Function
end

new_game = Game.new
new_game.start_game
