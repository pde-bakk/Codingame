STDOUT.sync = true # DO NOT REMOVE
# Grab Snaffles and try to throw them through the opponent's goal!
# Move towards a Snaffle and use your team id to determine where you need to throw it.

my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
turn = 0

#2.times do |i|
#	wizard[i], bludger[i], opponent[i] = Struct.new(:id, :type, :x, :y, :vx, :vy, :state)
#	bludger[i] = Struct.new(:id, :type, :x, :y, :pos, :vx, :vy, :v, :state)
#	opponent[i] = Struct.new(:id, :type, :x, :y, :pos, :vx, :vy, :v, :state)
#end

# game loop

loop do
	my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
	opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
	entities = gets.to_i # number of entities still in game


	entitystruct = Struct.new(:id, :type, :x, :y, :vx, :vy, :state)
#		wizard, bludger, opponent, snaffle = Array.new
	wizard = Array.new
	bludger = Array.new
	opponent = Array.new
	snaffle = Array.new

	entities.times do
		# entity_id: entity identifier
		# entity_type: "WIZARD", "OPPONENT_WIZARD" or "SNAFFLE" (or "BLUDGER" after first league)
		# x: position
		# y: position
		# vx: velocity
		# vy: velocity
		# state: 1 if the wizard is holding a Snaffle, 0 otherwise
		entity_id, entity_type, x, y, vx, vy, state = gets.split(" ")
		entity_id = entity_id.to_i
		x = x.to_i
		y = y.to_i
		vx = vx.to_i
		vy = vy.to_i
		state = state.to_i
		entity = entitystruct.new(entity_id, entity_type, x, y, vx, vy, state)
		if entity_type == "WIZARD"
			wizard = wizard.push(entity)
		elsif entity_type == "OPPONENT_WIZARD"
			opponent = opponent.push(entity)
		elsif entity_type == "SNAFFLE"
			snaffle = snaffle.push(entity)
		elsif entity_type == "BLUDGER"
			bludger = bludger.push(entity)
		end
	end
	2.times do

		# Write an action using puts
		# To debug: STDERR.puts "Debug messages..."


		# Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500)
		# i.e.: "MOVE x y thrust" or "THROW x y power"
		printf("MOVE 8000 3750 100\n")
	end
	turn += 1
end