include Math

STDOUT.sync = true # DO NOT REMOVE
# Grab Snaffles and try to throw them through the opponent's goal!
# Move towards a Snaffle to grab it and use your team id to determine towards where you need to throw it.
# Use the Wingardium spell to move things around at your leisure, the more magic you put it, the further they'll move.


my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
if my_team_id == 0
    opponent_team_id = 1
else
    opponent_team_id = 0
end
turncount = 0

if (my_team_id == 0)
    goalx = 16000
    goaly = 3750
    my_goalx = 0
else
    goalx = 0
    goaly = 3750
    my_goalx = 16000
end

module Peermath
    def self.distance(ax, ay, bx, by)
        Math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    end

    def self.dist(a, b)
        Math.sqrt((b[0] - a[0]) ** 2 + (b[1] - a[1]) ** 2)
    end

    def self.closest(array)
        dist = 100000
        index = 0
        saveindex = 0
        while index < array.length
            if array[index] < dist
                saveindex = index
                dist = array[index]
            end
            index += 1
        end
        return saveindex
    end
    
    def self.closestnocarry(array, snaffles)
        dist = 100000
        index = 0
        saveindex = 0
        while index < array.length
            if array[index] < dist && snaffles[index][6] == 0
                saveindex = index
                dist = array[index]
            end
            index += 1
        end
        return saveindex
    end
    
    def self.keeperonx(array, id) #my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
        index = 0
        saveindex = 0
        if id == 0
            keep = 16000
        else
            keep = 0
        end
        while index < array.length
            if id == 0 && array[index][2] + 2 * array[index][4] < keep #Xpos + Xveloc < keep
                saveindex = index
                keep = array[index][2] + 2 * array[index][4]
            elsif id == 1 && array[index][2] + 2 * array[index][4] > keep
                saveindex = index
                keep = array[index][2] + 2 * array[index][4]
            end
            index += 1
        end
        return saveindex
    end

    def self.keeper(array, id) #my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
        index = 0
        saveindex = 0
        distance = 10000
        if id == 0
            goal = [0, 3750]
        else
            goal = [16000, 3750]
        end
        STDERR.puts "keeper check"
        while index < array.length
            pos = [ array[index][2], array[index][3] ]
            if Peermath.dist(pos, goal) < distance
                saveindex = index
                distance = Peermath.dist(pos, goal)
            end
            index += 1
        end
        return saveindex
    end
                
    
    def self.spits(array, id) #my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
        index = 0
        saveindex = 0
        if id == 1
            keep = 16000
        else
            keep = 0
        end
        while index < array.length
            if id == 0 && array[index][2] + 2 * array[index][4] < keep #Xpos + Xveloc < keep
                saveindex = index
                keep = array[index][2] + 2 * array[index][4]
            elsif id == 1 && array[index][2] + 2 * array[index][4] > keep
                saveindex = index
                keep = array[index][2] + 2 * array[index][4]
            end
            index += 1
        end
        return saveindex
    end
    
    def self.ezscore(array, goalx)
        i = 0
        savei = -1
        value = 800
        while (i < array.length)
            if (Peermath.abs(goalx - array[i][2]) < value)
                value = Peermath.abs(goalx - array[i][2])
                savei = i
            end
            i += 1
        end
        return savei
    end

    def self.abs(nb)
        if (nb < 0)
            nb *= -1
        end
        return nb
    end        
    
    def self.findgoaly(goalx, wizard)
        if (Peermath.abs(goalx - wizard[2]) < 500 && (wizard[3] < 2000 || wizard[3] > 5600))
            return 3750
        elsif (wizard[3] + wizard[5] < 2000)
            return 2200
        elsif wizard[3] + wizard[5]> 5600
            return 5000
        else
            return wizard[3]
        end
    end
    
    def self.getfuturepos(ent, friction, threshold)
#        STDERR.puts "gfp gets: #{ent[2]}, #{ent[3]}, #{ent[4]}, #{ent[5]}, #{friction}, #{threshold}"
        oldpos = [ent[2], ent[3]]
        vel = [ent[4], ent[5]]
        entpos = [oldpos[0] + vel[0], oldpos[1] + vel[1]]
        while Math.sqrt(((entpos[0] - oldpos[0]) + (entpos[1] - oldpos[1])).abs) > threshold
            vel = [vel[0] * friction, vel[1] * friction]
            oldpos = entpos
            entpos = [entpos[0] + vel[0], entpos[1] + vel[1]]
        end
        return entpos
    end
    
    def self.gettargetpower(ent, friction, target)
        result = [nil, nil, nil]
#        STDERR.puts "ent: [#{ent[2]}x, #{ent[3]}y, v=[#{ent[4]}, #{ent[5]}]]"
        
        future = Peermath.getfuturepos(ent, friction, 5)
#        STDERR.puts "snaffle speed = #{Math.sqrt(ent[4] ** 2 + ent[5] ** 2)}"
#        STDERR.puts "mytarget = [#{target[0]}, #{target[1]}], futurepos target = [#{future[0]}, #{future[1]}], snaf is at [#{ent[2]}, #{ent[3]}] with v = [#{ent[4]}, ent[5]]"
        result[0] = target[0] - future[0] + ent[2]
        result[1] = target[1] - future[1] + ent[3]
        result[2] = Peermath.dist(target, future)
        STDERR.puts "result: [#{result[0]}, #{result[1]} veloc=#{result[2]}]"
        return result
    end
    
    def self.dotproduct(vec1, vec2)
        vec1[0] * vec2[0] + vec1[1] * vec2[1]
    end
    
    def self.crossproduct(vec1, vec2)
       (vec1[0] * vec2[1]) - (vec1[1] * vec2[0])
    end
    
    def self.getdirection(position, target, teammate, enemy, bludgers, refdist, teamid)
#        STDERR.puts " "
#        STDERR.puts "position=[#{position[2]}, #{position[3]}], target=[#{target[0]}, #{target[1]}]"
#        STDERR.puts "target=[#{target[0]}, #{target[1]}]"
        direction = [target[0] - position[2], target[1] - position[3]]
#        STDERR.puts "direction = [#{direction[0]}, #{direction[1]}]"
        length = Math.sqrt(direction[0] * direction[0] + direction[1] * direction[1])
#        STDERR.puts "length = #{length}"
        direction = [direction[0] / length, direction[1] / length]
#        STDERR.puts "normalized direction = #{direction[0]}, #{direction[1]}"
        
        i = 0
        possible = 1
        if length < 1500
            possible = 0
        elsif (teamid == 0 && position[2] < 4000 && (position[3] < 1750 || position[3] > 5750) && target[1] < 4000)
            possible = 0
        elsif (teamid == 1 && position[2] > 12000 && (position[3] < 1750 || position[3] > 5750) && target[1] > 12000)
            possible = 0
        end
        while i < 2 #its static: only 2 bludgers and 2 oppponents

#            STDERR.puts "bludger is at [#{bludgers[i][2]}, #{bludgers[i][3]}] with v = [#{bludgers[i][4]}, #{bludgers[i][5]}]"
            lvec = [bludgers[i][2] - position[2], bludgers[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - bludgers[i][2], res[1] - bludgers[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 500 && dist < 4000 && d > 0 && possible == 1) #radius=200 snaffle=150
                STDERR.puts "bludger[#{i}] is in the way"
                possible = 0
            end

            movexy = [bludgers[i][4], bludgers[i][5]]
            if (bludgers[i][2] + bludgers[i][4] - position[2] <= 800)
                movexy[0] = 0
            end
            if (bludgers[i][3] + bludgers[i][5] - position[3] <= 800)
                movexy[1] = 0
            end
#            STDERR.puts "bludger will be at [#{bludgers[i][2] + movexy[0]}, #{bludgers[i][3] + movexy[1]}] with v = [#{bludgers[i][4]}, #{bludgers[i][5]}]"
            lvec = [bludgers[i][2] + movexy[0] - position[2], bludgers[i][3] + movexy[1] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - bludgers[i][2], res[1] - bludgers[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 500 && dist < 4000 && d > 0 && possible == 1) #radius=200 snaffle=150
                STDERR.puts "bludger[#{i}] is going to be in the way"
                possible = 0
            end

#            STDERR.puts "opp wizard is at [#{enemy[i][2]}, #{enemy[i][3]}] with v = [#{enemy[i][4]}, #{enemy[i][5]}]"
            lvec = [enemy[i][2] - position[2], enemy[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [ res[0] - enemy[i][2], res[1] - enemy[i][3] ]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 550 && dist < refdist && d > 0 && possible == 1) #radius=400 snaffle=150
                STDERR.puts "opponent-wizard[#{i}] will be in the way"
                possible = 0
            end
 
            movexy = [enemy[i][4], enemy[i][5]]
            if (enemy[i][2] + enemy[i][4] - position[2] <= 800)
                movexy[0] = 0
            end
            if (enemy[i][3] + enemy[i][5] - position[3] <= 800)
                movexy[1] = 0
            end        
#            STDERR.puts "opp wizard will be at [#{enemy[i][2] + movexy[0]}, #{enemy[i][3] + movexy[1]}] with v = [#{enemy[i][4]}, #{enemy[i][5]}]"
            lvec = [enemy[i][2] + movexy[0] - position[2], enemy[i][3] + movexy[1] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - enemy[i][2] - movexy[0], res[1] - enemy[i][3] - movexy[1]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 550 && dist < refdist && d > 0 && possible == 1) #radius=400 snaffle=150
                STDERR.puts "opponent-wizard[#{i}] will be in the way"
                possible = 0
            end

            i += 1
        end
        if (possible == 1)
            STDERR.puts "target [#{target[0]}, #{target[1]}] is haalbaar"
        end
        return possible
    end

    def self.save(position, target, teammate, enemy, bludgers, refdist)
        direction = [target[0] - position[2], target[1] - position[3]]
        STDERR.puts "target pos: [#{target[0]}, #{target[1]}]"
        length = Math.sqrt(direction[0] * direction[0] + direction[1] * direction[1])
        direction = [direction[0] / length, direction[1] / length]#        STDERR.puts "normalized direction = #{direction[0]}, #{direction[1]}"
        
        i = 0
        possible = 1
        if position[2] < 8000
            goalposts = [ [0, 1750], [0, 5750] ]
        else
            goalposts = [ [16000, 1750], [16000, 5750] ]
        end
        while i < 2 #its static: only 2 bludgers and 2 oppponents

#            STDERR.puts "bludger is at [#{bludgers[i][2]}, #{bludgers[i][3]}] with v = [#{bludgers[i][4]}, #{bludgers[i][5]}]"
            lvec = [bludgers[i][2] - position[2], bludgers[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - bludgers[i][2], res[1] - bludgers[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 500 && dist < 4000 && d > 0 && possible == 1) #radius=200 snaffle=150
                STDERR.puts "bludger[#{i}] is in the way"
                possible = 0
            end

#            STDERR.puts "opp wizard is at [#{enemy[i][2]}, #{enemy[i][3]}] with v = [#{enemy[i][4]}, #{enemy[i][5]}]"
            lvec = [enemy[i][2] - position[2], enemy[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - enemy[i][2], res[1] - enemy[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 800 && dist < refdist && d > 0 && possible == 1) #radius=400 snaffle=150
                STDERR.puts "opponent-wizard[#{i}] is in the way"
                possible = 0
            end

#            STDERR.puts "goal post is at [#{goalposts[i][0]}, #{goalposts[i][1]}]"
            lvec = [goalposts[i][0] - position[2], goalposts[i][1] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - goalposts[i][0], res[1] - goalposts[i][1]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
#            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 450 && d > 0 && possible == 1) #radius=300 snaffle=150
                STDERR.puts "goalpost[#{i}] is in the way"
                possible = 0
            end
            i += 1
        end
        if possible == 1
            STDERR.puts "target: [#{target[0]}, #{target[1]}] is haalbaar"
        end
        return possible
    end

end

static = 1
maxsnafflecount = nil
turnrefstat = nil
turnref = 0
snafsaved = -1

# game loop
loop do
    my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
    opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
    STDERR.puts "my_magic = #{my_magic} and their magic = #{opponent_magic}"
    entities = gets.to_i # number of entities still in game   
    turncount += 1
    if (maxsnafflecount == nil)
        maxsnafflecount = entities - 6
    end
    STDERR.puts "maxsnafflecount=#{maxsnafflecount}, entities remaining = #{entities}, turnref=#{turnref}, #{(turncount - turnref).between?(0, 1)}"
    if turncount > 2 && entities == 7 && turnrefstat == nil
        turnref = turncount
    end

#    entitystruct = Struct.new(:entity_id, :entity_type, :x, :y, :vx, :vy, :state)
#    entitystruct.class
#    entity = entitystruct.new

    my_wizards = Array.new
    opponent_wizards = Array.new
    snaffles = Array.new
    bludgers = Array.new
    
  entities.times do
        # entity_id: entity identifier
        # entity_type: "WIZARD", "OPPONENT_WIZARD" or "SNAFFLE" or "BLUDGER"
        # x: position
        # y: position
        # vx: velocity
        # vy: velocity
        # state: 1 if the wizard is holding a Snaffle, 0 otherwise. 1 if the Snaffle is being held, 0 otherwise. id of the last victim of the bludger.
        entity_id, entity_type, x, y, vx, vy, state = gets.split(" ")
        
        entity_id = entity_id.to_i
        x = x.to_i
        y = y.to_i
        vx = vx.to_i
        vy = vy.to_i
        state = state.to_i
        
        entity = [entity_id, entity_type, x, y, vx, vy, state]
    
        if (entity_type == "WIZARD")
            my_wizards.push(entity)
        elsif (entity_type == "OPPONENT_WIZARD")
            opponent_wizards.push(entity)
        elsif (entity_type == "SNAFFLE")
            snaffles.push(entity)
        elsif (entity_type == "BLUDGER")
            bludgers.push(entity)
        end

    end
    
    
    wiz0distances = []
    wiz1distances = []
    wiz2distances = []
    wiz3distances = []
    
    wiz0normalvec = []
    wiz1normalvec = []

#    abc =  Peermath.distance(my_wizards[0][2], my_wizards[0][3], 50, 50)
#    STDERR.puts abc.to_i
    i = 0
#    snaffles.each do |count|
    while i < snaffles.length
#        dist = Peermath.distance(my_wizards[0][2], my_wizards[0][3], snaffles[i][2], snaffles[i][3])
        dist = Peermath.distance(my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        # I add the snaffle velocity to the position to try get my wizard to not keep chasing 1 snaffle to the opp goal
        crossline = Peermath.getfuturepos(snaffles[i], 0.75, 1)
#        STDERR.puts "#{my_team_id == 0} && #{crossline[0]} > 16000)} || #{(my_team_id == 1 && crossline[0] < 0)} && #{crossline[1].between?(1900, 5600)}"
#        STDERR.puts "#{crossline[0] > 16000}"
#        STDERR.puts "checking. teamid=#{my_team_id} #{my_team_id == 0}, crossline[0]=#{crossline[0]}, #{crossline[0] > 16000}, together: #{(my_team_id == 0 && crossline[0] > 16000)}"
        if ((my_team_id == 0 && crossline[0] > 16000) || (my_team_id == 1 && crossline[0] < 0)) && crossline[1].between?(1900, 5600)
            dist += 10000
#            STDERR.puts " snaffle[#{i}] gonna cross the goalline!!!!"
        end
        wiz0distances.push(dist)
#        STDERR.puts "crossline = [#{crossline[0]}, #{crossline[1]}], team=#{my_team_id}, dist=#{dist}"
        normalvec = [snaffles[i][2] + snaffles[i][4] - (my_wizards[0][2] + my_wizards[0][4]), snaffles[i][3] + snaffles[i][5] - (my_wizards[0][3] + my_wizards[0][5])]
        normalvec = [normalvec[0] / dist, normalvec[1] / dist]
        wiz0normalvec.push(normalvec)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my first wizard"
        dist = Peermath.distance(my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        crossline = Peermath.getfuturepos(snaffles[i], 0.75, 1)
        if ((my_team_id == 0 && crossline[0] > 16000) || (my_team_id == 1 && crossline[0] < 0)) && crossline[1].between?(1900, 5600)
            dist += 10000
        end
        wiz1distances.push(dist)
        normalvec = [snaffles[i][2] + snaffles[i][4] - (my_wizards[1][2] + my_wizards[1][4]), snaffles[i][3] + snaffles[i][5] - (my_wizards[1][3] + my_wizards[1][5])]
        normalvec = [normalvec[0] / dist, normalvec[1] / dist]
        wiz1normalvec.push(normalvec)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my second wizard"
        dist = Peermath.distance(opponent_wizards[0][2] + opponent_wizards[0][4], opponent_wizards[0][3] + opponent_wizards[0][5], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        wiz2distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my opponents first wizard"
        dist = Peermath.distance(opponent_wizards[1][2] + opponent_wizards[1][4], opponent_wizards[1][3] + opponent_wizards[1][5], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        wiz3distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my opponents second wizard"
        i += 1
    end
    
        
    normalvecs = [wiz0normalvec, wiz1normalvec]

    2.times do |counter|
#        STDERR.puts "wizard #{counter}:"
        snaffles.length.times do |sn|
#            STDERR.puts "snaffle#{sn}=@[#{snaffles[sn][2]}, #{snaffles[sn][3]}]: d = #{wiz0distances[sn]}, normalvec = [#{normalvecs[counter][sn][0]}, #{normalvecs[counter][sn][1]}]"
            if counter == 0
#                STDERR.puts "snaffle#{sn}=@[#{snaffles[sn][2]}, #{snaffles[sn][3]}]: d = #{wiz0distances[sn]}, normalvec = [#{wiz0normalvec[sn][0]}, #{wiz0normalvec[sn][1]}]"
            else
#                STDERR.puts "snaffle#{sn}}=@[#{snaffles[sn][2]}, #{snaffles[sn][3]}]: d = #{wiz1distances[sn]}, normalvec = [#{wiz1normalvec[sn][0]}, #{wiz1normalvec[sn][1]}]"
            end
            snaffles.length.times do |sn2|
                cross = Peermath.crossproduct(normalvecs[counter][sn], normalvecs[counter][sn2])
#                STDERR.puts "crossproduct(snaf[#{sn}], snaf[#{sn2}])=#{cross}"
            end
        end
    end
    
    target1 = Peermath.closest(wiz0distances)
#    target2 = Peermath.keeper(snaffles, my_team_id)
    target2 = Peermath.closest(wiz1distances)
    closesttogoal = Peermath.keeper(snaffles, my_team_id)
    closestonx = Peermath.keeperonx(snaffles, my_team_id)
    
    if opponent_score <= 1 && (snaffles[target1][6] == 1 || snaffles[target2][6] == 1)
        target1 = Peermath.closestnocarry(wiz0distances, snaffles)
        target2 = Peermath.closestnocarry(wiz1distances, snaffles)
    end
#    STDERR.puts "target1 (closest to wiz0) = #{target1}"
#    STDERR.puts "target2 (closest to goal) = #{target2}"
    

    if (target1 == target2 && snaffles.length > 1)
        STDERR.puts "same target. targetid = [#{snaffles[target1][0]}]"
        if (wiz0distances[target1] > wiz1distances[target2])
            STDERR.puts "wiz0 is closer, so changing wiz1target"
            wiz0distances[target1] += 10000
            tmp = target1
            target1 = Peermath.closest(wiz0distances)
            wiz0distances[tmp] -= 10000
            STDERR.puts "new target1. id=#{snaffles[target1][0]}, pos=[#{snaffles[target1][2]}, #{snaffles[target1][3]}]"
        else
            STDERR.puts "wiz1 is closer, so changing wiz0target"
            wiz1distances[target2] += 10000
            tmp = target2
            target2 = Peermath.closest(wiz1distances)
            wiz1distances[tmp] -= 10000
            STDERR.puts "new target1. id=#{snaffles[target2][0]}, pos=[#{snaffles[target2][2]}, #{snaffles[target2][3]}]"
        end
    end
    
    if (Peermath.distance(snaffles[target1][2], snaffles[target1][3], snaffles[target2][2], snaffles[target2][3]) < 1500 && snaffles.length > 2)
        STDERR.puts "snaffles too close together. t1=[#{snaffles[target1][2]}, #{snaffles[target1][3]}], t2=[#{snaffles[target2][2]}, #{snaffles[target2][3]}]"
        tmp1 = target1
        tmp2 = target2
        wiz0distances[tmp1] += 10000
        wiz0distances[tmp2] += 10000
        target1 = Peermath.closest(wiz0distances)
        wiz0distances[tmp1] -= 10000
        wiz0distances[tmp2] -= 10000
        STDERR.puts "new target1 = [#{snaffles[target1][2]}, #{snaffles[target1][3]}]"
    end
    
    if (wiz0distances[target1] + wiz1distances[target2] > wiz0distances[target2] + wiz1distances[target1])
        target3 = target1
        target1 = target2
        target2 = target3
    end

#        STDERR.puts "velocity of w0: [#{my_wizards[0][4]}, #{my_wizards[0][5]}]"
#        STDERR.puts "velocity of w1: [#{my_wizards[1][4]}, #{my_wizards[1][5]}]"
#        STDERR.puts "velocity of s0: [#{snaffles[target1][4]}, #{snaffles[target1][5]}]"
#        STDERR.puts "velocity of s2: [#{snaffles[target2][4]}, #{snaffles[target2][5]}]"
        
#    if (closest1st == closest2nd)
#        STDERR.puts "wiz0dist[#{target1}]=#{wiz0distances[target1]}"
#        STDERR.puts "wiz1dist[#{target2}]=#{wiz1distances[target2]}"
#        if (wiz0distances[closest1st] > wiz1distances[closest2nd])
#            wiz0distances[closest1st] = 100000
#        else
#            wiz1distances[closest2nd] = 100000
#        end
#        closest1st = Peermath.closest(wiz0distances)
#        closest2nd = Peermath.closest(wiz1distances)
#        STDERR.puts "rework: wiz1dist[#{closest2nd}]=#{wiz1distances[closest2nd]}"
#
#    end
#    STDERR.puts "closesttogoal: x=#{snaffles[closesttogoal][2]}, vx=#{snaffles[closesttogoal][4]} & id=#{my_team_id}"
#    STDERR.puts "closesttogoal: y=#{snaffles[closesttogoal][3]}, vy=#{snaffles[closesttogoal][5]} & id=#{my_team_id}"
    closestxy = [snaffles[closesttogoal][2] + snaffles[closesttogoal][4], snaffles[closesttogoal][3] + snaffles[closesttogoal][5]]
    STDERR.puts "closestxy=[#{closestxy[0]}, #{closestxy[1]}], state=#{snaffles[closesttogoal][6]}"
    STDERR.puts "x=#{snaffles[closesttogoal][2]}, vx=#{snaffles[closesttogoal][4]}"
    futurepos = Peermath.getfuturepos(snaffles[closesttogoal], 0.75, 2)
#    STDERR.puts "speed = #{Math.sqrt(snaffles[closesttogoal][4] * snaffles[closesttogoal][4] + snaffles[closesttogoal][5] * snaffles[closesttogoal][5])}"
    STDERR.puts "future pos: [#{futurepos[0]}, #{futurepos[1]}]"
#STDERR.puts "clos to goal: xy=[#{snaffles[closesttogoal][2]}, #{snaffles[closesttogoal][3]}] & velocity=[#{snaffles[closesttogoal][4]}, #{snaffles[closesttogoal][5]}] & pos+vel = [#{snaffles[closesttogoal][2] + snaffles[closesttogoal][4]}, #{snaffles[closesttogoal][3] + snaffles[closesttogoal][5]}] & teamid=#{my_team_id}, state=#{snaffles[closesttogoal][6]}"
#    if (snaffles[closesttogoal][2] < 1500 && snaffles[closesttogoal][4] < -150 && my_team_id == 0 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] > 1750 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] < 5750 && snaffles[closesttogoal][6] == 0)
#    elsif (snaffles[closesttogoal][2] > 15000 && snaffles[closesttogoal][4] > 150 && my_team_id == 1 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] > 1750 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] < 5750 && snaffles[closesttogoal][6] == 0)

#    STDERR.puts "between?=#{closestxy[1].between?(1825, 5675)} & x+vx=#{snaffles[closesttogoal][2] + snaffles[closesttogoal][4]} <= 0 & state=#{snaffles[closesttogoal][6]} & my_team_id=#{my_team_id}"
    
    border = [my_goalx, Peermath.abs(my_goalx - 2000)]
    goalposts = [1750, 5750]

#good    targets = [ [my_goalx, 7500, 16000], [(my_goalx - 2000).abs, 0, 16000], [(my_goalx - 2000).abs, 7500, 16000], [my_goalx, 6100, 16000], [my_goalx, 6750, 16000], [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [my_goalx, 0, 16000], [my_goalx, 1400, 16000], [my_goalx, 750, 16000]]
#    targets = targets.sort_by {|s| s[2] } #{ |t| targets[t][3] }
#    futsnaf = Peermath.getfuturepos(snaffles[closesttogoal], 0.75, 2)
#    targets[t][2] = Peermath.distance(futsnaf[0], futsnaf[1], targets[t][0], targets[t][1])


        vlen = Math.sqrt(snaffles[closesttogoal][4] ** 2 + snaffles[closesttogoal][5] ** 2)
        line_normal = [ snaffles[closesttogoal][4] / vlen, snaffles[closesttogoal][5] / vlen ]
        findcross = snaffles[closesttogoal][2] * -1 / line_normal[0]
        cross_y = snaffles[closesttogoal][3] + line_normal[1] * findcross
        STDERR.puts "cross_y = #{cross_y}, y=#{findcross}, line_normal = [#{line_normal[0]}, #{line_normal[1]}]"
        
    if cross_y != cross_y || findcross != findcross || line_normal[0] == 0
        cross_y = 0
    end

    lastditch = 0
    mine = [ wiz0distances[closesttogoal], wiz1distances[closesttogoal] ]
    his = [ wiz1distances[closesttogoal], wiz2distances[closesttogoal] ]
    if (turncount > 175 && opponent_score + 1 > maxsnafflecount / 2 && mine.min > his.min && cross_y.between?(1400, 6100))
        lastditch = 1
        STDERR.puts "last ditch effort is on!"
    end
    
    STDERR.puts "revamp: #{closestxy[0].between?(border.min, border.max)} && #{closestxy[1].between?(goalposts.min, goalposts.max)} && #{snaffles[closesttogoal][6] == 0} && #{snafsaved != snaffles[closesttogoal][0]} && #{cross_y.to_i.between?(1400, 6100)}"
    if (lastditch == 1 || closestxy[0].between?(border.min, border.max) || snaffles[closesttogoal][2].between?(border.min, border.max)) && closestxy[1].between?(goalposts.min, goalposts.max) && snaffles[closesttogoal][6] == 0 && snafsaved != snaffles[closesttogoal][0] && cross_y.between?(1400, 6100)
        STDERR.puts "revamped magic time"
        futsnaf = Peermath.getfuturepos(snaffles[closesttogoal], 0.75, 2)
#        palen = [ [my_goalx, 1400], [my_goalx, 6100] ]
        hitpole = [my_goalx, 1400] #Peermath.hitpole(snaffles[closesttogoal], palen[0])
        hitpole2 = [my_goalx, 6100] # Peermath.hitpole(snaffles[closesttogoal], palen[1])
        if (wiz2distances[closesttogoal] < 5000 && wiz3distances[closesttogoal] < 5000)
            targets = [ [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [goalx, 3750, 16000], [goalx, 0, 16000], [goalx, 7500, 16000], [my_goalx, 7500, 16000], [my_goalx, 6100, 16000], [my_goalx, 6750, 16000], [my_goalx, 0, 16000], [my_goalx, 1400, 16000], [my_goalx, 750, 16000], hitpole, hitpole2]
        elsif lastditch == 1
            targets = [ [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [goalx, 3750, 16000], [goalx, 0, 16000], [goalx, 7500, 16000], [my_goalx, 7500, 16000], [my_goalx, 6100, 16000], [my_goalx, 6750, 16000], [my_goalx, 0, 16000], [my_goalx, 1400, 16000], [my_goalx, 750, 16000] ]
        else
            targets = [ [my_goalx, 7500, 16000], [(my_goalx - 2000).abs, 0, 16000], [(my_goalx - 2000).abs, 7500, 16000], [my_goalx, 6100, 16000], [my_goalx, 6750, 16000], [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [my_goalx, 0, 16000], [my_goalx, 1400, 16000], [my_goalx, 750, 16000], hitpole, hitpole2]
        end
        targets.length.times do |t|
#            targets[t][3] = Peermath.distance(closestxy[0], closestxy[1], targets[t][0], targets[t][1])
#            STDERR.puts "#{(my_goalx - snaffles[closesttogoal][2])} / #{snaffles[closesttogoal][4]}"
            if (my_goalx - snaffles[closesttogoal][2]) / snaffles[closesttogoal][4] >= 5 || lastditch == 1
                tempa = [0 , 0]
                tempa[0] = [wiz2distances[closesttogoal]]
                tempa[1] = [wiz3distances[closesttogoal]]
                targets[t][2] = tempa.min
#                STDERR.puts "no rush: [#{targets[t][0]}, #{targets[t][1]}]"
#                STDERR.puts "dist = #{targets[t][2]}"
            else
                targets[t][2] = Peermath.distance(futsnaf[0], futsnaf[1], targets[t][0], targets[t][1])
            end
        end
#        if (wiz2distances[closesttogoal] >= 5000 || wiz3distances[closesttogoal] >= 5000) || lastditch == 1
            targets = targets.sort_by {|s| s[2] } #{ |t| targets[t][3] }
#        end
        t = 0
#        STDERR.puts "sorted i suppose"
        targets.length.times do |t|
#            STDERR.puts "dist=#{targets[t][2]}. target[#{t}] = [#{targets[t][0]}, #{targets[t][1]}]"
        end
        t = 0
#        STDERR.puts "tmax = #{targets.length}"
        while (t + 1 < targets.length && Peermath.save(snaffles[closesttogoal], targets[t], my_wizards[0], opponent_wizards, bludgers, 4000) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        STDERR.puts "selected target t=#{t} = [#{targets[t][0]}, #{targets[t][1]}]"

        #Peermath.getfuturepos(snaffles[closesttogoal], 0.75, 100)
        bigsave = Peermath.gettargetpower(snaffles[closesttogoal], 0.75, targets[t])
        STDERR.puts "bigsave[2] = #{bigsave[2]}, /100 = #{bigsave[2] / 100}"
        if bigsave[2] > 0
            bigsaveposs = bigsave[2] / 100
            if (wiz2distances[closesttogoal] < 5000 && wiz3distances[closesttogoal] < 5000)
                bigsaveposs *= 2
            end
        end
        if bigsaveposs > my_magic
            STDERR.puts "not possible to save, only have #{my_magic} magic and would need #{bigsave[2] / 100}"
            bigsaveposs = 0
        end
        if (lastditch == 1)
            bigsaveposs = my_magic
        end
        snafsaved = snaffles[closesttogoal][0]
    else
        snafsaved = -1
        bigsaveposs = 0
    end
        
    
 
    power = 0
    ezscore = Peermath.ezscore(snaffles, goalx)
    targetpos = [goalx, goaly]


#    if (wiz0distances[target1] <= 1.0)
#    STDERR.puts "wiz1 distance to closest: #{wiz1distances[closesttogoal]} & wiz0: #{wiz0distances[closesttogoal]}, lastditch = #{lastditch}"
#    if (my_magic >= 8 && sneaky == 1)
#        STDERR.puts "sneaky shit"
        
#        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], sneakytar[0], sneakytar[1], 8)
    STDERR.puts "big save: #{closestxy[0].between?(border.min, border.max)} && #{closestxy[1].between?(goalposts.min, goalposts.max)} && #{snaffles[closesttogoal][6] == 0} && #{bigsaveposs > 0}"
    if closestxy[0].between?(border.min, border.max) && closestxy[1].between?(goalposts.min, goalposts.max) && snaffles[closesttogoal][6] == 0 && bigsaveposs > 0
        STDERR.puts "revamped magic time"
 
#        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], bigsave[0], bigsave[1], bigsaveposs)
        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], bigsave[0], bigsave[1], bigsaveposs)
    elsif (my_magic >= 10 && ezscore >= 0 && snaffles[ezscore][3].between?(1900, 5600) && snaffles[ezscore][4] == 0 && snaffles[ezscore][6] == 0)
        STDERR.puts "magic time, ezscore=#{ezscore}"
        STDERR.puts "ezscore pos=[#{snaffles[ezscore][2]}, #{snaffles[ezscore][3]}]"
        
        printf("WINGARDIUM %d %d %d %d\n", snaffles[ezscore][0], goalx, snaffles[ezscore][3], 10)
    elsif (entities == 7 && my_wizards[0][2] + my_wizards[0][4] < my_wizards[1][2] + my_wizards[1][4] && my_wizards[0][2] > Peermath.abs(my_goalx - 3000) && (turncount - turnref).between?(0, 1))
        STDERR.puts "hurry back to goal"
        printf("MOVE %d %d %d\n", my_goalx, goaly, 150)
    elsif (my_wizards[0][6] == 1)

#        if (Peermath.abs(goalx - my_wizards[1][2]) < Peermath.abs(goalx - my_wizards[0][2]))
#            newtar = [my_wizards[1][2], my_wizards[1][3]]
#            targets.unshift(newtar)
#        end
#        targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(goalx - 4000), 0], [Peermath.abs(goalx - 4000), 7500]]
       targets = [ [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [goalx, 3750, 16000], [goalx, 2050, 16000], [goalx, 5450, 16000], [goalx, 2250, 16000], [goalx, 2450, 16000], [goalx, 2650, 16000], [goalx, 2850, 16000], [goalx, 3050, 16000], [goalx, 3250, 16000],  [goalx, 3450, 16000],  [goalx, 3650, 16000],  [goalx, 3850, 16000],  [goalx, 4050, 16000],  [goalx, 4250, 16000],  [goalx, 4450, 16000],  [goalx, 4650, 16000],  [goalx, 4850, 16000],  [goalx, 5050, 16000],  [goalx, 5250, 16000], [(goalx - 2000).abs, 2000, 16000], [(goalx - 2000).abs, 5500, 16000] ]
        targets.length.times do |t|
            targets[t][2] = Peermath.distance(goalx, goaly, targets[t][0], targets[t][1])
            if targets[t][0] == goalx && targets[t][1].between?(1500, 6000)
                targets[t][2] = 0
            end
        end
        targets = targets.sort_by {|s| s[2] } #{ |t| targets[t][3] }

#         targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(goalx - 4000), 0], [Peermath.abs(goalx - 4000), 7500]]
       targets.length.times do |t|
            STDERR.puts "wiz0target[#{t}] = [#{targets[t][0]}, #{targets[t][1]}]"
        end
        t = 0
#        STDERR.puts "t = 0"
        STDERR.puts "wizard0 looking to throw. pos=[#{my_wizards[0][2]}, #{my_wizards[0][3]}]"
        while (t + 1 < targets.length && Peermath.getdirection(my_wizards[0], targets[t], my_wizards[1], opponent_wizards, bludgers, 4000, my_team_id) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
#        STDERR.puts " "
#        STDERR.puts "wizard velocity=[#{my_wizards[0][4]}, #{my_wizards[0][5]}]"
#        STDERR.puts "target=[#{targets[t][0]}, #{targets[t][1]}]"
        if Peermath.getdirection(my_wizards[0], targets[t], my_wizards[1], opponent_wizards, bludgers, 4000, my_team_id) == 0
            STDERR.printf("wiz0 cant throw, so MOVE %d %d %d\n", goalx, my_wizards[0][3] + my_wizards[0][5], 100)
            printf("MOVE %d %d %d\n", goalx, my_wizards[0][3] + my_wizards[0][5], 100)
        else
            STDERR.puts "wiz0 throw:t=#{t}, target=[#{targets[t][0]}, #{targets[t][1]}], throwing to [#{targets[t][0] - my_wizards[0][4]}, #{targets[t][1] - my_wizards[0][5]}]"
            printf("THROW %d %d %d\n", targets[t][0] - my_wizards[0][4], targets[t][1] - my_wizards[0][5], 500)
        end
        
    else
        if (wiz0distances[target1] < 150)
            power = wiz0distances[target1]
        else
            power = 150
        end
        targetpos[0] = snaffles[target1][2] + snaffles[target1][4]# - my_wizards[0][4]
        targetpos[1] = snaffles[target1][3] + snaffles[target1][5]# - my_wizards[0][5]
        #targetpos = sn pole has a raffle.x + snaffle.vx - wizard.vx
        
#        STDERR.puts "wiz0: distance= #{wiz0distances[target1]} & power = #{power}"
#        STDERR.puts "wiz0: position= [#{my_wizards[0][2]}, #{my_wizards[0][3]}]"
        printf("MOVE %d %d %d\n", targetpos[0], targetpos[1], power)
    end
    
    power = 0
    targets = [ [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [my_wizards[1][2] + my_wizards[1][4], my_wizards[1][3] + my_wizards[1][5], 16000], [goalx, 3750, 16000], [goalx, 2800, 16000], [goalx, 4700, 16000], [goalx, 2050, 16000], [goalx, 5450, 16000], [(goalx - 2000).abs, 2000, 16000], [(goalx - 2000).abs, 5500, 16000] ]
    targets.length.times do |t|
        targets[t][2] = Peermath.distance(goalx, goaly, targets[t][0], targets[t][1])
        if targets[t][0] == goalx && targets[t][1].between?(1500, 6000)
            targets[t][2] = 0
        end
    end
    targets = targets.sort_by {|s| s[2] } #{ |t| targets[t][3] }

#    targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(goalx - 4000), 0], [Peermath.abs(goalx - 4000), 7500]]
    cond = 0
    spits = Peermath.keeper(snaffles, opponent_team_id)
    spitsspeed = Math.sqrt(snaffles[spits][4] ** 2 + snaffles[spits][4] ** 2)
    STDERR.puts "spits snaffle is at [#{snaffles[spits][2]}, #{snaffles[spits][3]}], goalx = #{goalx}"
    STDERR.puts "spitspower:#{my_magic >= 15} && #{turncount > 140} && #{opponent_score > my_score} && #{(goalx - snaffles[spits][2]).abs} && #{snaffles[spits][4] > 350}"
    if (my_magic >= 15 && turncount > 140 && opponent_score > my_score && (goalx - snaffles[spits][2]).abs < 8000 && snaffles[spits][4] > 350)
        id = Peermath.keeper(snaffles, opponent_team_id)
        STDERR.puts "magic time, its past turn 140 and we need to score"

        t = 0
        bounce = [goalx, goaly]
        boink = 0
        if (snaffles[id][3] > 3750 && snaffles[id][3] > opponent_wizards[0][3] && snaffles[id][3] > opponent_wizards[1][3])
            bounce = [snaffles[id][2] + (goalx - snaffles[id][2]).abs, 7500]
            boink = 1
        elsif (snaffles[id][3] < 3750 && snaffles[id][3] < opponent_wizards[0][3] && snaffles[id][3] < opponent_wizards[1][3])
            bounce = [snaffles[id][2] + (goalx - snaffles[id][2]).abs, 0]
            boink = 2
        end
        targets = [[goalx, goaly], bounce, [goalx, goaly - 800], [goalx, goaly + 800], [goalx, goaly - 600], [goalx, goaly + 600], [goalx, goaly - 300], [goalx, goaly + 300], [goalx, goaly - 100], [goalx, goaly + 100]]
        STDERR.puts "spits looking to score. pos=[#{my_wizards[0][2]}, #{my_wizards[0][3]}]"
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[id], targets[t], my_wizards[0], opponent_wizards, bludgers, 16000, my_team_id) == 0)
            STDERR.puts "t=#{t}, tmax=#{targets.length}. target=[#{targets[t][0]}, #{targets[t][1]}]"
            t += 1
        end
        if boink > 0
            STDERR.puts "boink = #{boink}, bouncing?"
        end
        spitspower = 10
        if (my_magic > 50)
            spitspower = 20
        end
        if (t == 1 && boink > 0)
            spitspower = my_magic
        end
        printf("WINGARDIUM %d %d %d %d\n", snaffles[id][0], targets[t][0], targets[t][1], spitspower)
    elsif (my_magic >= 15 && turncount > 194 && opponent_score >= my_score)
        id = Peermath.spits(snaffles, goalx)
        STDERR.puts "magic time, its turn #{turncount}"
        
        t = 0
#        targets = [[goalx, goaly], [goalx, goaly - 800], [goalx, goaly + 800], [goalx, goaly - 600], [goalx, goaly + 600], [goalx, goaly - 300], [goalx, goaly + 300], [goalx, goaly - 100], [goalx, goaly + 100]]
        STDERR.puts "turn194+ looking to throw. pos=[#{my_wizards[0][2]}, #{my_wizards[0][3]}]"
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[id], targets[t], my_wizards[0], opponent_wizards, bludgers, 16000, my_team_id) == 0)
            STDERR.puts "t=#{t}, tmax=#{targets.length}. target=[#{targets[t][0]}, #{targets[t][1]}]"
            t += 1
        end
        STDERR.puts "t=#{t}"
        
        printf("WINGARDIUM %d %d %d %d\n", snaffles[id][0], targets[t][0], targets[t][1], my_magic)
    elsif (my_magic >= 40 && (2 * (my_score + 1) > my_score + opponent_score + entities - 6 || 2 * (opponent_score + 1) > my_score + opponent_score + entities - 6) && snaffles[closesttogoal][6] == 0 && cond == 1)
#    if (my_magic >= 50 && (my_score + 1 == entities - 5 || opponent_score + 1 == entities - 5))
        STDERR.puts "magic time, gamepoint for either side"
        
        t = 0
#        targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(my_goalx - 4000), 0], [Peermath.abs(my_goalx - 4000), 7500]]
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[closesttogoal], targets[t], my_wizards[0], opponent_wizards, bludgers, 4000, my_team_id) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end

        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], targets[t][0], targets[t][1], my_magic)
#    elsif (wiz1distances[target2] <= 1)
    elsif (my_magic >= 99)
        STDERR.puts "99 magic"
        id = Peermath.keeper(snaffles, opponent_team_id)

        t = 0
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[id], targets[t], my_wizards[0], opponent_wizards, bludgers, 4000, my_team_id) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        printf("WINGARDIUM %d %d %d %d\n", snaffles[id][0], targets[t][0], targets[t][1], 20)
    elsif (entities == 7 && my_wizards[0][2] + my_wizards[0][4] > my_wizards[1][2] + my_wizards[1][4] && my_wizards[1][2] > Peermath.abs(my_goalx - 3000) && (turncount - turnref).between?(0, 1))
        STDERR.puts "hurry back to goal"
        printf("MOVE %d %d %d\n", my_goalx, goaly, 150)
    elsif (my_wizards[1][6] == 1)
    
#        if (Peermath.abs(goalx - my_wizards[0][2]) < Peermath.abs(goalx - my_wizards[1][2]))
#            newtar = [my_wizards[0][2], my_wizards[0][3]]
#            targets.push(newtar)
#        end
        targets = [ [my_wizards[0][2] + my_wizards[0][4], my_wizards[0][3] + my_wizards[0][5], 16000], [goalx, 3750, 16000], [goalx, 2050, 16000], [goalx, 5450, 16000], [goalx, 2250, 16000], [goalx, 2450, 16000], [goalx, 2650, 16000], [goalx, 2850, 16000], [goalx, 3050, 16000], [goalx, 3250, 16000],  [goalx, 3450, 16000],  [goalx, 3650, 16000],  [goalx, 3850, 16000],  [goalx, 4050, 16000],  [goalx, 4250, 16000],  [goalx, 4450, 16000],  [goalx, 4650, 16000],  [goalx, 4850, 16000],  [goalx, 5050, 16000],  [goalx, 5250, 16000], [(goalx - 2000).abs, 2000, 16000], [(goalx - 2000).abs, 5500, 16000] ]
        targets.length.times do |t|
            targets[t][2] = Peermath.distance(goalx, goaly, targets[t][0], targets[t][1])
            if targets[t][0] == goalx && targets[t][1].between?(1500, 6000)
                targets[t][2] = 0
            end
        end
        targets = targets.sort_by {|s| s[2] } #{ |t| targets[t][3] }

        t = 0
        STDERR.puts "wizard1 looking to throw. pos=[#{my_wizards[1][2]}, #{my_wizards[1][3]}]"
        while (t + 1 < targets.length && Peermath.getdirection(my_wizards[1], targets[t], my_wizards[0], opponent_wizards, bludgers, 4000, my_team_id) == 0)
         STDERR.puts "target[#{t}]=[#{targets[t][0]}, #{targets[t][1]}]"
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        if Peermath.getdirection(my_wizards[1], targets[t], my_wizards[0], opponent_wizards, bludgers, 4000, my_team_id) == 0
            STDERR.printf("wiz0 cant throw, so MOVE %d %d %d\n", goalx, my_wizards[1][3] + my_wizards[1][5], 100)
            printf("MOVE %d %d %d\n", goalx, my_wizards[1][3] + my_wizards[1][5], 100)
        else
            STDERR.puts "wiz1 throw:t=#{t}, target=[#{targets[t][0]}, #{targets[t][1]}], throwing to [#{targets[t][0] - my_wizards[1][4]}, #{targets[t][1] - my_wizards[1][5]}]"
            printf("THROW %d %d %d\n", targets[t][0] - my_wizards[0][4], targets[t][1] - my_wizards[1][5], 500)
        end
    else
        if (wiz1distances[target2] < 150)
            power = wiz1distances[target2]
        else
            power = 150
        end
        targetpos[0] = snaffles[target2][2] + snaffles[target2][4]# - my_wizards[1][4]
        targetpos[1] = snaffles[target2][3] + snaffles[target2][5]# - my_wizards[1][5]
        #targetpos = snaffle.x + snaffle.vx - wizard.vx

#        STDERR.puts "wiz1: distance= #{wiz1distances[target2]} & power = #{power}"
#        STDERR.puts "wiz1: position= [#{my_wizards[1][2]}, #{my_wizards[1][3]}]"
        printf("MOVE %d %d %d\n", snaffles[target2][2], snaffles[target2][3], power)
    end

        
#    2.times do
        
            
        # Write an action using puts
        # To debug: STDERR.puts "Debug messages..."
        

        # Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500, 0 ≤ magic ≤ 1500)
        # i.e.: "MOVE x y thrust" or "THROW x y power" or "WINGARDIUM id x y magic"
#        printf("MOVE 8000 3750 100\n")

#    end

end
