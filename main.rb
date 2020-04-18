include Math

STDOUT.sync = true # DO NOT REMOVE
# Grab Snaffles and try to throw them through the opponent's goal!
# Move towards a Snaffle to grab it and use your team id to determine towards where you need to throw it.
# Use the Wingardium spell to move things around at your leisure, the more magic you put it, the further they'll move.


my_team_id = gets.to_i # if 0 you need to score on the right of the map, if 1 you need to score on the left

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
            if id == 0 && array[index][2] < keep
                saveindex = index
                keep = array[index][2]
            elsif id == 1 && array[index][2] > keep
                saveindex = index
                keep = array[index][2]
            end
            index += 1
        end
        return saveindex
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

end

        
# game loop
loop do
    my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
    opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
    entities = gets.to_i # number of entities still in game
    STDERR.puts "entities: #{entities}"
    
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
            STDERR.puts "Bludger: id=#{entity_id}, pos=[#{x}, #{y}], vel=[#{vx}, #{vy}], state=#{state}"
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
    target2 = Peermath.keeper(snaffles, my_team_id)
    
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
    targetpos = [nil, nil]
    power = 0
#    if (wiz0distances[target1] <= 1.0)
    if (my_wizards[0][6] == 1)
#        goaltargety = Peermath.findgoaly(goalx, my_wizards[0])
        goaltargety = goaly
        printf("THROW %d %d %d\n", goalx, goaltargety, 500)
    else
        if (wiz0distances[target1] < 150)
            power = wiz0distances[target1]
        else
            power = 150
        end
        targetpos[0] = snaffles[target1][2] + snaffles[target1][4] - my_wizards[0][4]
        targetpos[1] = snaffles[target1][3] + snaffles[target1][5] - my_wizards[0][5]
        #targetpos = sn pole has a raffle.x + snaffle.vx - wizard.vx
        
        STDERR.puts "wiz0: distance= #{wiz0distances[target1]} & power = #{power}"
        STDERR.puts "wiz0: position= [#{my_wizards[0][2]}, #{my_wizards[0][3]}]"
        printf("MOVE %d %d %d\n", targetpos[0], targetpos[1], power)
        STDERR.printf("MOVE %d %d %d\n", snaffles[target1][2], snaffles[target1][3], power)
    end
    
    power = 0
    STDERR.puts "myscore=#{my_score}, opp_score=#{opponent_score}, remaining entities=#{entities}"
    STDERR.puts "math: #{my_score + 1} =?= #{entities - 6}"
    if (my_magic >= 50 && (my_score + 1 == entities - 6 || opponent_score + 1 == entities - 6))
        STDERR.puts "magic time"
        if (snaffles[target2][2] <= 100 && (snaffles[target2][3] < 1600 || snaffles[target2][3] > 5800))
            printf("WINGARDIUM %d %d %d\n", snaffles[target2][0], goalx - 1, snaffles[target2][3], 10)
        elsif (snaffles[target2]  >= 15900 && (snaffles[target2][3] < 1600 || snaffles[target2][3] > 5800))
            printf("WINGARDIUM %d %d %d\n", snaffles[target2][0], goalx + 1, snaffles[target2][3], 10)
        else
            printf("WINGARDIUM %d %d %d %d\n", snaffles[target2][0], goalx, goaly, my_magic)
        end
#    elsif (wiz1distances[target2] <= 1)
    elsif (my_wizards[1][6] == 1)
#        goaltargety = Peermath.findgoaly(goalx, my_wizards[0])
        goaltargety = goaly
        STDERR.puts "wiz1distance to target2 = #{wiz1distances[target2]}"
        printf("THROW %d %d %d\n", goalx, goaltargety, 500)
    else
        if (wiz1distances[target2] < 150)
            power = wiz1distances[target2]
        else
            power = 150
        end
        targetpos[0] = snaffles[target2][2] + snaffles[target2][4] - my_wizards[1][4]
        targetpos[1] = snaffles[target2][3] + snaffles[target2][5] - my_wizards[1][5]
        #targetpos = snaffle.x + snaffle.vx - wizard.vx

        STDERR.puts "wiz1: distance= #{wiz1distances[target2]} & power = #{power}"
        STDERR.puts "wiz1: position= [#{my_wizards[1][2]}, #{my_wizards[1][3]}]"
        printf("MOVE %d %d %d\n", snaffles[target2][2], snaffles[target2][3], power)
       STDERR.printf("MOVE %d %d %d\n", snaffles[target2][2], snaffles[target2][3], power)
    end

        
#    2.times do
        
            
        # Write an action using puts
        # To debug: STDERR.puts "Debug messages..."
        

        # Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500, 0 ≤ magic ≤ 1500)
        # i.e.: "MOVE x y thrust" or "THROW x y power" or "WINGARDIUM id x y magic"
#        printf("MOVE 8000 3750 100\n")

#    end

end
