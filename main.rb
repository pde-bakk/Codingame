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
end

        
# game loop
loop do
    my_score, my_magic = gets.split(" ").collect {|x| x.to_i}
    opponent_score, opponent_magic = gets.split(" ").collect {|x| x.to_i}
    entities = gets.to_i # number of entities still in game
    
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
        dist = Peermath.distance(my_wizards[0][2], my_wizards[0][3], snaffles[i][2], snaffles[i][3])
        wiz0distances.push(dist)
#        STDERR.puts "snaffle[#{i}] is #{dist} units away from my first wizard"
        dist = Peermath.distance(my_wizards[1][2], my_wizards[1][3], snaffles[i][2], snaffles[i][3])
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
    
    closest1st = Peermath.closest(wiz0distances)
    closest2nd = Peermath.closest(wiz1distances)
    if (closest1st == closest2nd)
        STDERR.puts "wiz0dist[#{closest1st}]=#{wiz0distances[closest1st]}"
        STDERR.puts "wiz1dist[#{closest2nd}]=#{wiz1distances[closest2nd]}"
        if (wiz0distances[closest1st] > wiz1distances[closest2nd])
            wiz0distances[closest1st] = 100000
        else
            wiz1distances[closest2nd] = 100000
        end
        closest1st = Peermath.closest(wiz0distances)
        closest2nd = Peermath.closest(wiz1distances)
        STDERR.puts "rework: wiz0dist[#{closest1st}]=#{wiz0distances[closest1st]}"
        STDERR.puts "rework: wiz1dist[#{closest2nd}]=#{wiz1distances[closest2nd]}"

    end
    power = 0
    if (wiz0distances[closest1st] <= 1.0)
        printf("THROW %d %d %d\n", goalx, goaly, 500)
    else
        if (wiz0distances[closest1st] < 150)
            power = wiz0distances[closest1st]
        else
            power = 150
        end
        STDERR.puts "wiz0: distance= #{wiz0distances[closest1st]} & power = #{power}"
        printf("MOVE %d %d %d\n", snaffles[closest1st][2], snaffles[closest1st][3], power)
        STDERR.printf("MOVE %d %d %d\n", snaffles[closest1st][2], snaffles[closest1st][3], power)
    end
    
    power = 0
    if (wiz1distances[closest2nd] <= 1)
        printf("THROW %d %d %d\n", goalx, goaly, 500)
    else
        if (wiz1distances[closest2nd] < 150)
            power = wiz1distances[closest2nd]
        else
            power = 150
        end
        STDERR.puts "wiz1: distance= #{wiz1distances[closest2nd]} & power = #{power}"
        printf("MOVE %d %d %d\n", snaffles[closest2nd][2], snaffles[closest2nd][3], power)
       STDERR.printf("MOVE %d %d %d\n", snaffles[closest2nd][2], snaffles[closest2nd][3], power)
    end

        
#    2.times do
        
            
        # Write an action using puts
        # To debug: STDERR.puts "Debug messages..."
        

        # Edit this line to indicate the action for each wizard (0 ≤ thrust ≤ 150, 0 ≤ power ≤ 500, 0 ≤ magic ≤ 1500)
        # i.e.: "MOVE x y thrust" or "THROW x y power" or "WINGARDIUM id x y magic"
#        printf("MOVE 8000 3750 100\n")

#    end
end
