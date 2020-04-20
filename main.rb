include Math

STDOUT.sync = true # DO NOT REMOVE
# Grab Snaffles and try to throw them through the opponent's goal!
# Move towards a Snaffle to grab it and use your team id to determine towards where you need to throw it.
# Use the Wingardium spell to move things around at your leisure, the more magic you put it, the further they'll move.


my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
turncount = 0

if (my_team_id == 0)
    goalx = 16000
    goaly = 3750
else
    goalx = 0
    goaly = 3750
end

module Peermath
    def self.distance(ax, ay, bx, by)
        Math.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
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
    def self.keeper(array, id) #my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left
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
    
    def self.dotproduct(vec1, vec2)
        vec1[0] * vec2[0] + vec1[1] * vec2[1]
    end
    
    def self.getdirection(position, target, teammate, enemy, bludgers)
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
        while i < 2 #its static: only 2 bludgers and 2 oppponents

            STDERR.puts "bludger is at [#{bludgers[i][2]}, #{bludgers[i][3]}] with v = [#{bludgers[i][4]}, #{bludgers[i][5]}]"
            lvec = [bludgers[i][2] - position[2], bludgers[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - bludgers[i][2], res[1] - bludgers[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 500 && dist < 4000 && d > 0)
                STDERR.puts "bludger[#{i}] is in the way"
                possible = 0
            end

            STDERR.puts "opp wizard is at [#{enemy[i][2]}, #{enemy[i][3]}] with v = [#{enemy[i][4]}, #{enemy[i][5]}]"
            lvec = [enemy[i][2] - position[2], enemy[i][3] - position[3]]
            dist = Math.sqrt(lvec[0] * lvec[0] + lvec[1] * lvec[1])
            d = Peermath.dotproduct(lvec, direction)
            res = [position[2] + direction[0] * d, position[3] + direction[1] * d]
            t = [res[0] - enemy[i][2], res[1] - enemy[i][3]]
            tlen = Math.sqrt(t[0] * t[0] + t[1] * t[1])
            STDERR.puts "d=#{d}, res=[#{res[0]}, #{res[1]}], t = [#{t[0]}, #{t[1]}], tlen = #{tlen}, dist to enemy=#{dist}"
            if (tlen < 500 && dist < 4000 && d > 0)
                STDERR.puts "opponent-wizard[#{i}] is in the way"
                possible = 0
            end

            i += 1
        end
        return possible
    end
end

        
# game loop
loop do
    my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
    opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
    STDERR.puts "my_magic = #{my_magic} and their magic = #{opponent_magic}"
    entities = gets.to_i # number of entities still in game   
    turncount += 1
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

#    abc =  Peermath.distance(my_wizards[0][2], my_wizards[0][3], 50, 50)
#    STDERR.puts abc.to_i
    i = 0
#    snaffles.each do |count|
    while i < snaffles.length
#        dist = Peermath.distance(my_wizards[0][2], my_wizards[0][3], snaffles[i][2], snaffles[i][3])
        dist = Peermath.distance(my_wizards[0][2], my_wizards[0][3], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        # I add the snaffle velocity to the position to try get my wizard to not keep chasing 1 snaffle to the opp goal
        wiz0distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my first wizard"
        dist = Peermath.distance(my_wizards[1][2], my_wizards[1][3], snaffles[i][2] + snaffles[i][4], snaffles[i][3] + snaffles[i][5])
        wiz1distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my second wizard"
        dist = Peermath.distance(opponent_wizards[0][2], opponent_wizards[0][3], snaffles[i][2], snaffles[i][3])
        wiz2distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my opponents first wizard"
        dist = Peermath.distance(opponent_wizards[1][2], opponent_wizards[1][3], snaffles[i][2], snaffles[i][3])
        wiz3distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my opponents second wizard"
        i += 1
    end
    
    target1 = Peermath.closest(wiz0distances)
#    target2 = Peermath.keeper(snaffles, my_team_id)
    target2 = Peermath.closest(wiz1distances)
    closesttogoal = Peermath.keeper(snaffles, my_team_id)
    
#    STDERR.puts "target1 (closest to wiz0) = #{target1}"
#    STDERR.puts "target2 (closest to goal) = #{target2}"
    

    if (target1 == target2 && snaffles.length > 1)
        wiz0distances[target1] += 10000
        tmp = target1
        target1 = Peermath.closest(wiz0distances)
        wiz0distances[tmp] -= 10000
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
    STDERR.puts "closestxy=[#{closestxy[0]}, #{closestxy[1]}]"
    STDERR.puts "x=#{snaffles[closesttogoal][2]}, vx=#{snaffles[closesttogoal][4]}"
    STDERR.puts "speed = #{Math.sqrt(snaffles[closesttogoal][4] * snaffles[closesttogoal][4] + snaffles[closesttogoal][5] * snaffles[closesttogoal][5])}"
#STDERR.puts "clos to goal: xy=[#{snaffles[closesttogoal][2]}, #{snaffles[closesttogoal][3]}] & velocity=[#{snaffles[closesttogoal][4]}, #{snaffles[closesttogoal][5]}] & pos+vel = [#{snaffles[closesttogoal][2] + snaffles[closesttogoal][4]}, #{snaffles[closesttogoal][3] + snaffles[closesttogoal][5]}] & teamid=#{my_team_id}, state=#{snaffles[closesttogoal][6]}"
#    if (snaffles[closesttogoal][2] < 1500 && snaffles[closesttogoal][4] < -150 && my_team_id == 0 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] > 1750 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] < 5750 && snaffles[closesttogoal][6] == 0)
#    elsif (snaffles[closesttogoal][2] > 15000 && snaffles[closesttogoal][4] > 150 && my_team_id == 1 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] > 1750 && snaffles[closesttogoal][3] + snaffles[closesttogoal][5] < 5750 && snaffles[closesttogoal][6] == 0)

#    STDERR.puts "between?=#{closestxy[1].between?(1825, 5675)} & x+vx=#{snaffles[closesttogoal][2] + snaffles[closesttogoal][4]} <= 0 & state=#{snaffles[closesttogoal][6]} & my_team_id=#{my_team_id}"
    if (my_team_id == 0 && closestxy[1].between?(1825, 5675) && snaffles[closesttogoal][2] + snaffles[closesttogoal][4] <= 1000 && snaffles[closesttogoal][6] == 0)
        lastditch = 1
        STDERR.puts "lastditch = 1, id=0"
    elsif (my_team_id == 1 && closestxy[1].between?(1825, 5675) && snaffles[closesttogoal][2] + snaffles[closesttogoal][4] >= 15000 && snaffles[closesttogoal][6] == 0)
        lastditch = 1
        STDERR.puts "lastditch = 1, id=1"
    else
        lastditch = 0
    end
    
    targetpos = [goalx, goaly]
    targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(goalx - 4000), 0], [Peermath.abs(goalx - 4000), 7500]]

    power = 0
    ezscore = Peermath.ezscore(snaffles, goalx)


#    if (wiz0distances[target1] <= 1.0)
    STDERR.puts "wiz1 distance to closest: #{wiz1distances[closesttogoal]} & wiz0: #{wiz0distances[closesttogoal]}"
    if (my_magic >= 10 && lastditch == 1 && (wiz1distances[closesttogoal] > 1000 && wiz0distances[closesttogoal] > 1000))
        STDERR.puts "magic time, last ditch effort to save"

        t = 0
#        STDERR.puts "t = 0"
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[closesttogoal], targets[t], my_wizards[0], opponent_wizards, bludgers) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        power = Peermath.abs(snaffles[closesttogoal][4] / 25) + 10
        STDERR.puts "power = #{power}"
        if (power > my_magic)
            power = my_magic
        end
        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], targets[t][0], targets[t][1], power)
    elsif (my_magic >= 10 && ezscore >= 0 && snaffles[ezscore][3].between?(1900, 5600) && snaffles[ezscore][4] == 0 && snaffles[ezscore][6] == 0)
        STDERR.puts "magic time, ezscore=#{ezscore}"
        STDERR.puts "ezscore pos=[#{snaffles[ezscore][2]}, #{snaffles[ezscore][3]}]"
        
        printf("WINGARDIUM %d %d %d %d\n", snaffles[ezscore][0], goalx, snaffles[ezscore][3], 10)
    elsif (my_wizards[0][6] == 1)

#        if (Peermath.abs(goalx - my_wizards[1][2]) < Peermath.abs(goalx - my_wizards[0][2]))
#            newtar = [my_wizards[1][2], my_wizards[1][3]]
#            targets.unshift(newtar)
#        end
        t = 0
        STDERR.puts "t = 0"
        while (t + 1 < targets.length && Peermath.getdirection(my_wizards[0], targets[t], my_wizards[1], opponent_wizards, bludgers) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
#        STDERR.puts " "
#        STDERR.puts "wizard velocity=[#{my_wizards[0][4]}, #{my_wizards[0][5]}]"
#        STDERR.puts "target=[#{targets[t][0]}, #{targets[t][1]}]"
        STDERR.puts "t=#{t}, target=[#{targets[t][0]}, #{targets[t][1]}], throw to [#{targets[t][0] - my_wizards[0][4]}, #{targets[t][1] - my_wizards[0][5]}]"

        printf("THROW %d %d %d\n", targets[t][0] - my_wizards[0][4], targets[t][1] - my_wizards[0][5], 500)
        
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
    targetpos = [goalx, goaly]
    targets = [[goalx, goaly], [goalx, goaly - 100], [goalx, goaly - 300], [goalx, goaly - 600], [goalx, goaly - 800], [goalx, goaly + 100], [goalx, goaly + 300], [goalx, goaly + 600], [goalx, goaly + 800], [Peermath.abs(goalx - 4000), 0], [Peermath.abs(goalx - 4000), 7500]]
cond = 0
    if (my_magic >= 15 && turncount > 194 && opponent_score >= my_score)
        id = Peermath.spits(snaffles, goalx)
        STDERR.puts "magic time, its turn #{turncount}"
        printf("WINGARDIUM %d %d %d %d\n", snaffles[id][0], goalx, goaly, my_magic)
    elsif (my_magic >= 40 && (2 * (my_score + 1) > my_score + opponent_score + entities - 6 || 2 * (opponent_score + 1) > my_score + opponent_score + entities - 6) && snaffles[closesttogoal][6] == 0 && cond == 1)
#    if (my_magic >= 50 && (my_score + 1 == entities - 5 || opponent_score + 1 == entities - 5))
        STDERR.puts "magic time, gamepoint for either side"
        
        t = 0
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[closesttogoal], targets[t], my_wizards[0], opponent_wizards, bludgers) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end

        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], targets[t][0], targets[t][1], my_magic)
#    elsif (wiz1distances[target2] <= 1)
    elsif (my_magic >= 99)
        STDERR.puts "99 magic"

        t = 0
        while (t + 1 < targets.length && Peermath.getdirection(snaffles[closesttogoal], targets[t], my_wizards[0], opponent_wizards, bludgers) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        printf("WINGARDIUM %d %d %d %d\n", snaffles[closesttogoal][0], targets[t][0], targets[t][1], 15)
    elsif (my_wizards[1][6] == 1)
    
#        if (Peermath.abs(goalx - my_wizards[0][2]) < Peermath.abs(goalx - my_wizards[1][2]))
#            newtar = [my_wizards[0][2], my_wizards[0][3]]
#            targets.push(newtar)
#        end
        t = 0
        while (t + 1 < targets.length && Peermath.getdirection(my_wizards[1], targets[t], my_wizards[0], opponent_wizards, bludgers) == 0)
#            STDERR.puts "t=#{t}, tmax=#{targets.length}"
            t += 1
        end
        STDERR.puts "t=#{t}, target=[#{targets[t][0]}, #{targets[t][1]}], throw to [#{targets[t][0] - my_wizards[1][4]}, #{targets[t][1] - my_wizards[1][5]}]"

#        STDERR.puts "wiz1distance to target2 = #{wiz1distances[target2]}"
#        STDERR.puts "velocity=[#{my_wizards[1][4]}, #{my_wizards[1][5]}]"
        printf("THROW %d %d %d\n", targets[t][0] - my_wizards[1][4], targets[t][1] - my_wizards[1][5], 500)
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
