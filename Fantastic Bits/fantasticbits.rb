STDOUT.sync = true # DO NOT REMOVE
include Math
vec2 = Struct.new(:x, :y)
entitystruct = Struct.new(:id, :type, :x, :y, :vx, :vy, :state) do
	def puredistance(struct2)
		Math.sqrt( (struct2[:x] - x) ** 2 + (struct2[:y] - y) ** 2)
	end
	def distance(struct2)
		Math.sqrt( (struct2[:x] + struct2[:vx]- x - vx) ** 2 + (struct2[:y] + struct2[:vy]- y - vy) ** 2)
	end

	def dotproduct(vec1, vec2)
		vec1[0] * vec2[0] + vec1[1] * vec2[1]
	end

	def normalvec(snaffle)
		distance = self.distance(snaffle)
		res = [ (snaffle.x + snaffle.vx - x - vx) / distance, (snaffle.y + snaffle.vy - y - vy) / distance ]
		return res
	end
	
	def	obstaclecheck(target, opponent, bludger, refdist)
			if target == nil || target[0] == nil || target[1] == nil
				return 0
			end
	#		STDERR.puts "position = [#{x}, #{y}]"
	#        STDERR.puts "position=[#{x}, #{y}], target=[#{target[0]}, #{target[1]}]"
			direction = [target[0] - x, target[1] - y]
	#        STDERR.puts "direction = [#{direction[0]}, #{direction[1]}]"
			length = Math.sqrt(direction[0] ** 2 + direction[1] ** 2)
	#        STDERR.puts "length = #{length}"
			direction = [direction[0] / length, direction[1] / length]
	#        STDERR.puts "normalized direction = #{direction[0]}, #{direction[1]}"
			
			possible = 1
			#if length < 1500
			#	possible = 0
			#elsif (teamid == 0 && position[2] < 4000 && (position[3] < 1750 || position[3] > 5750) && target[1] < 4000)
			#	possible = 0
			#elsif (teamid == 1 && position[2] > 12000 && (position[3] < 1750 || position[3] > 5750) && target[1] > 12000)
			#	possible = 0
			#end
			2.times do |i|	#its static: only 2 bludgers and 2 oppponents

		#		if bludger != nil
		##            STDERR.puts "bludger is at [#{bludger[i].x}, #{bludger[i].y}] with v = [#{bludger[i].vx}, #{bludger[i].vy}]"
		#			lvec = [bludger[i].x - x, bludger[i].y - y]
		#			dist = Math.sqrt(lvec[0] ** 2 + lvec[1] ** 2)
		#			d = dotproduct(lvec, direction)
		#			res = [x + direction[0] * d, y + direction[1] * d]
		#			t = [res[0] - bludger[i].x, res[1] - bludger[i].y]
		#			tlen = Math.sqrt(t[0] ** 2 + t[1] ** 2)
		#		#	STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to bludger=#{dist}"
		#			if (tlen < 500 && dist < 4000 && d > 0 && possible == 1) #radius=200 snaffle=150
		#				STDERR.puts "bludger[#{i}] is in the way"
		#				possible = 0
		#			end
	
		#			movexy = [bludger[i].vx, bludger[i].vy]
		#			if (bludger[i].x + bludger[i].vx - x <= 800)
		#				movexy[0] = 0
		#			end
		#			if (bludger[i].y + bludger[i].vy - y <= 800)
		#				movexy[1] = 0
		#			end
		#			#STDERR.puts "bludger will be at [#{bludger[i].x + movexy[0]}, #{bludger[i].y + movexy[1]}] with v = [#{bludger[i].vx}, #{bludger[i].vy}]"
		#			lvec = [bludger[i].x + movexy[0] - x, bludger[i].y + movexy[1] - y]
		#			dist = Math.sqrt(lvec[0] ** 2 + lvec[1] ** 2)
		#			d = dotproduct(lvec, direction)
		#			res = [x + direction[0] * d, y + direction[1] * d]
		#			t = [res[0] - bludger[i].x, res[1] - bludger[i].y]
		#			tlen = Math.sqrt(t[0] ** 2 + t[1] ** 2)
		#			#STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to bludger=#{dist}"
		#			if (tlen < 500 && dist < 4000 && d > 0 && possible == 1) #radius=200 snaffle=150
		#				STDERR.puts "bludger[#{i}] is going to be in the way"
		#				possible = 0
		#			end
		#		end
	
	#            STDERR.puts "opp wizard is at [#{opponent[i].x}, #{opponent[i].y}] with v = [#{opponent[i].vx}, #{opponent[i].vy}]"
				lvec = [opponent[i].x - x, opponent[i].y - y]
				dist = Math.sqrt(lvec[0] ** 2 + lvec[1] ** 2)
#				STDERR.puts "dist = #{dist}, lvec = " + lvec.to_s
#				d = dotpr(lvec[0], lvec[1], direction[0], direction[1])
				d = lvec[0] * direction[0] + lvec[1] * direction[1] #figure out why i cant make a dotproduct method
#				d = dotproduct(lvec, direction)
				res = [x + direction[0] * d, y + direction[1] * d]
				t = [ res[0] - opponent[i].x, res[1] - opponent[i].y ]
				tlen = Math.sqrt(t[0] ** 2 + t[1] ** 2)
	#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to oppo=#{dist}"
				if (tlen < 550 && dist < refdist && d > 0 && possible == 1) #radius=400 snaffle=150
		#			STDERR.puts "opponent-wizard[#{i}] will be in the way"
					possible = 0
				end
	 
				movexy = [opponent[i].vx, opponent[i].vy]
				if (opponent[i].x + opponent[i].vx - x <= 800)
					movexy[0] = 0
				end
				if (opponent[i].y + opponent[i].vy - y <= 800)
					movexy[1] = 0
				end        
	#            STDERR.puts "opp wizard will be at [#{opponent[i].x + movexy[0]}, #{opponent[i].y + movexy[1]}] with v = [#{opponent[i].vx}, #{opponent[i].vy}]"
				lvec = [opponent[i].x + movexy[0] - x, opponent[i].y + movexy[1] - y]
				dist = Math.sqrt(lvec[0] ** 2 + lvec[1] ** 2)
				d = lvec[0] * direction[0] + lvec[1] * direction[1] #figure out why i cant make a dotproduct method
#				d = dotproduct(lvec, direction)
				res = [x + direction[0] * d, y + direction[1] * d]
				t = [res[0] - opponent[i].x - movexy[0], res[1] - opponent[i].y - movexy[1]]
				tlen = Math.sqrt(t[0] ** 2 + t[1] ** 2)
	#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to oppo=#{dist}"
				if (tlen < 550 && dist < refdist && d > 0 && possible == 1) #radius=400 snaffle=150
		#			STDERR.puts "opponent-wizard[#{i}] will be in the way"
					possible = 0
				end
	
				i += 1
			end
		if (possible == 1)
			STDERR.puts "target [#{target[0]}, #{target[1]}] is haalbaar"
		end
		return possible
	end
end

def self.distance(a, b)
	Math.sqrt( (b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2 )
end

def self.dist(ax, ay, bx, by)
	Math.sqrt( (bx - ax) ** 2 + (by - ay) ** 2)
end

def self.dotproduct(vec1, vec2)
	vec1[0] * vec2[0] + vec1[1] * vec2[1]
end

def self.closest(array, isnt)
	ref = 16000
	savei = 0
	array.length.times do |i|
		if array[i] < ref && i != isnt && array[i].state.to_i == 0
			savei = i
			ref = array[i]
		end
	end
	return savei
end

def self.crossproduct(vec1, vec2)
   (vec1[0] * vec2[1]) - (vec1[1] * vec2[0])
end

	

#def nearcheck(snaffle)
#	if 
#end

def targetselect(wizard, opponent, snaffle, bludger, snaffledistance, normalvec, goalx)
	w0c = Array.new(2)
	w1c = Array.new(2)
	w0c[0] = closest(snaffledistance[0], -1) #returns the index of the closest
	w1c[0] = closest(snaffledistance[1], -1)
	throwtargets = []
	throwtargets[0] = [(goalx - 1500).abs, 3750]
	y = 3750 - 2000 + 301 + 150 + 500
	while y < 3750 + 2000 - 300 - 150 - 500
		throwtargets.push([goalx, y])
		y += 1
	end
	if w0c[0] == w1c[0]
		w0c[1] = closest(snaffledistance[0], w0c[0])
		w1c[1] = closest(snaffledistance[0], w1c[0])
		if snaffledistance[0][w0c[0]] + snaffledistance[1][w1c[1]] < snaffledistance[0][w0c[1]] + snaffledistance[1][w1c[0]]
			wiztargets = [w0c[0], w1c[1]]
		else
			wiztargets = [w0c[1], w1c[0]]
		end
	elsif snaffledistance[0][w1c[0]] + snaffledistance[1][w0c[0]] < snaffledistance[0][w0c[0]] + snaffledistance[1][w1c[0]]
		wiztargets = [w1c[0], w0c[0]]
	else
		wiztargets = [w0c[0], w1c[0]] #now w0c[0] and w1c[0] are the indexes of the targeted snaffles (before groupcheck)
	end
	output = Array.new(2)
	output[0] = ["MOVE", 8000, 3750, 150]
	output[1] = ["MOVE", 8000, 3750, 150]
	wizard.length.times do |w|
		output[2] = Array.new(4)
		if wizard[w].state == 0
			t = snaffle[wiztargets[w]]
#			STDERR.puts "t = " + t.to_s
			output[w] = ["MOVE", t.x + t.vx, t.y + t.vy, wizard[w].distance(snaffle[wiztargets[w]]).clamp(0, 150) ]
		else
			wizthrowtargets = throwtargets
			if w == 0
				u = 1
			else
				u = 0
			end
			if (wizard[u].x + wizard[u].vx).abs > (wizard[w].x + wizard[w].vx).abs
				wizthrowtargets.push([wizard[u].x + wizard[u].vx, wizard[u].y + wizard[u].vy])
			end
			wizthrowtargets.length.times do |ree|
				wizthrowtargets[ree][2] = dist(wizard[w].x, wizard[w].y, wizthrowtargets[ree][0], wizthrowtargets[ree][1])
				if wizthrowtargets[ree][0] != goalx
					wizthrowtargets[ree][2] += dist(goalx, 3500, wizthrowtargets[ree][0], wizthrowtargets[ree][1])
				end
			end
			wizthrowtargets = wizthrowtargets.sort_by { |ree| ree[2] }
			t = 0
			while t + 1 && wizard[w].obstaclecheck(wizthrowtargets[t], opponent, bludger, 4000) == 0
				t += 1
			end
			if wizard[w].obstaclecheck(wizthrowtargets[t], opponent, bludger, 4000) == 0
				t = snaffle[wiztargets[w]]
				output[w] = ["THROW", t.x + t.vx, t.y + t.vy, wizard[w].distance(snaffle[wiztargets[w]]).clamp(0, 150) ]
			else
				output[w] = ["THROW", wizthrowtargets[t][0] - wizard[w].vx, wizthrowtargets[t][1] - wizard[w].vy, 500]
			end
		end
	end

#	t2 = snaffle[closest(snaffledistance[1], -1)]

#	STDERR.puts "t2 = " + t2.to_s
	if wiztargets[0] == wiztargets[1]
		STDERR.puts "still same dude"
	end
	return output
end


# Grab Snaffles and try to throw them through the opponent's goal!
# Move towards a Snaffle and use your team id to determine where you need to throw it.

my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
if my_team_id == 0
	goalx = 16000
else
	goalx = 0
end
turn = 0

# game loop

loop do
	my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
	opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
	entities = gets.to_i # number of entities still in game


#	wizard = bludger = opponent = snaffle = Array.new
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
		# state: 1 If the wizard is holding a Snaffle, 0 otherwise
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

	snaffledistance = Array.new(wizard.length + opponent.length)
	normalvec = Array.new(wizard.length)
	wizard.length.times do |w|
		snaffledistance[w] = []
		snaffledistance[w + 2] = []
		normalvec[w] = []
		snaffle.length.times do |s|
			snaffledistance[w].push(wizard[w].distance(snaffle[s]))
			snaffledistance[w + 2].push(opponent[w].distance(snaffle[s]))
			normalvec[w].push(wizard[w].normalvec(snaffle[s]))
			#STDERR.puts "wiz#{w}->snaf#{s} = [#{normalvec[w][s][0]}, #{normalvec[w][s][1]}]"
		end
	end

	targets = targetselect(wizard, opponent, snaffle, bludger, snaffledistance, normalvec, goalx)
	STDERR.puts "targets = " + targets.to_s

		

	2.times do |a|

		STDERR.printf("%s %d %d %d\n", targets[a][0], targets[a][1], targets[a][2], targets[a][3])
		printf("%s %d %d %d\n", targets[a][0], targets[a][1], targets[a][2], targets[a][3])
		# Write an action using puts
		# To debug: STDERR.puts "Debug messages..."


		# Edit this line to indicate the action For each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500)
		# i.e.: "MOVE x y thrust" or "THROW x y power"
		#printf("MOVE 8000 3750 100\n")
	end
	turn += 1
end