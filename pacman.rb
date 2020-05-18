STDOUT.sync = true # DO NOT REMOVE
include Math
require 'benchmark'
require 'time'

# Grab the pellets as fast as you can!
somebody = ["SOME", "BODY", "ONCE", "TOLD", "ME", "THE", "WORLD", "IS", "GONNA", "ROLL", "ME", "I", "AIN'T", "THE", "SHARPEST", "TOOL", "IN", "THE", "SHED", "SHE", "WAS", "LOOKING", "KIND", "OF", "DUMB", "WITH", "HER", "FINGER", "AND", "HER", "THUMB", "IN", "THE", "SHAPE", "OF", "AN", "L", "ON", "HER", "FOREHEAD", "WELL", "THE", "YEARS", "START", "COMING", "AND", "THEY", "DON'T", "STOP", "COMING", "FED", "TO", "THE", "RULES", "AND", "I", "HIT", "THE", "GROUND", "RUNNING", "DIDN'T", "MAKE", "SENSE", "NOT", "TO", "LIVE", "FOR", "FUN", "YOUR", "BRAIN", "GETS", "SMART", "BUT", "YOUR", "HEAD", "GETS", "DUMB", "SO", "MUCH", "TO", "DO", "SO", "MUCH", "TO", "SEE", "SO", "WHAT'S", "WRONG", "WITH", "TAKING", "THE", "BACK", "STREETS", "YOU'LL", "NEVER", "KNOW", "IF", "YOU", "DON'T", "GO", "YOU'LL", "NEVER", 
"SHINE", "IF", "YOU", "DON'T", "GLOW", "HEY", "NOW", "YOU'RE", "AN", "ALL", "STAR", "GET", "YOUR", "GAME", "ON", "GO", "PLAY", "HEY", "NOW", "YOU'RE", "A", "ROCK", "STAR", "GET", "THE", "SHOW", "ON", "GET", "PAID", "AND", "ALL", "THAT", "GLITTERS", "IS", "GOLD","ONLY", "SHOOTING", "STARS", "BREAK", "THE", "MOLD", "IT'S", "A", "COOL", "PLACE", "AND", "THEY", "SAY", "IT", "GETS", "COLDER", "YOU'RE", "BUNDLED", "UP", "NOW", "WAIT", "TILL", "YOU", "GET", "OLDER", "BUT", "THE", "METEOR", "MEN", "BEG", "TO", "DIFFER", "JUDG-", "ING", "BY", "THE", "HOLE", "IN", "THE", "SA", "TEL", "LITE", "PIC", "TURE", "THE", "ICE", "WE", "SKATE", "IS", "GETTING", "PRETTY", "THIN", "THE", "WATER'S", "GETTING", "WARM", "SO", "YOU", "MIGHT", "AS", "WELL", "SWIM", "MY", "WORLD'S", "ON", "FIRE", "HOW", "ABOUT", "YOURS"]
$timedebug = true
$movedebug = false
$targetdebug = true
$printdebug = false
$conflictdebug = false
$debug = 0
$speed = 0
$turn = 0
$extra = 0
$openside = 0
$totalpellets = 0
$megadebug = 0
$sing = 1
class Super
   attr_accessor :pos, :distance, :pacid, :mine, :reachable, :manhattan
    def initialize(pos: [0, 0], distance: 0, pacid: 0, mine: false, reachable: false, manhattan: 0)
        @pos = pos
        @distance = distance
        @pacid = pacid
        @mine = mine
        @reachable = reachable
        @manhattan = manhattan
    end
    def puts
        STDERR.puts "Super: pos:#{pos}, mine?#{mine}[#{pacid}], reachable=#{reachable}, dist=#{distance}, mh=#{manhattan} "
    end
end
def best(left, right, up, down, x, y, steps)
    arr = Array.new
    arr.push(50)
    if left > 0 then arr.push(left) end
    if right > 0 then arr.push(right) end
    if up > 0 then arr.push(up) end
    if down > 0 then arr.push(down) end
    return arr.min
end
def simpletargetfloodfill(rows, x, y, goal, maxsteps, steps, width)
    if y < 0 || x < 0 || !rows[y][x]
        return 0
    elsif rows[y][x] == "#" || rows[y][x] == "X" || steps > maxsteps
        return 0
    end
    if goal == [x, y]
        return steps
    end
    rows[y][x] = "X"
    if x == 0 then left = simpletargetfloodfill(rows.clone.map(&:clone), width - 1, y, goal, maxsteps, steps + 1, width) else left = simpletargetfloodfill(rows.clone.map(&:clone), x - 1, y, goal, maxsteps, steps + 1, width) end
    if x == width - 1 then right = simpletargetfloodfill(rows.clone.map(&:clone), 0, y, goal, maxsteps, steps + 1, width) else right = simpletargetfloodfill(rows.clone.map(&:clone), x + 1, y, goal, maxsteps, steps + 1, width) end
    up = simpletargetfloodfill(rows.clone.map(&:clone), x, y - 1, goal, maxsteps, steps + 1, width)
    down = simpletargetfloodfill(rows.clone.map(&:clone), x, y + 1, goal, maxsteps, steps + 1, width)
    return best(left, right, up, down, x, y, steps)
end
def getsuperinfo(rows, mypacs, theirpacs, width)
    supers = Array.new
    if width > 33 then maxsteps = 18 else maxsteps = 20 end
    maxsteps -= mypacs.length + 1
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "S"
                distances = Array.new
                mypacs.length.times do |i|
                    manhattan = afstand( [w, h], [mypacs[i].x, mypacs[i].y], width)
                    dist = simpletargetfloodfill(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, [w, h], maxsteps, 0, width)
                    distances.push( Super.new(:pos => [w, h], :distance => dist, :pacid => mypacs[i].pac_id, :mine => mypacs[i].mine, :reachable => false, :manhattan => manhattan) )
                    # distances[-1].puts
                end
                theirpacs.length.times do |n|
                    manhattan = afstand( [w, h], [theirpacs[n].x, theirpacs[n].y], width)
                    dist = simpletargetfloodfill(rows.clone.map(&:clone), theirpacs[n].x, theirpacs[n].y, [w, h], maxsteps, 0, width)
                    distances.push( Super.new(:pos => [w, h], :distance => dist, :pacid => theirpacs[n].pac_id, :mine => theirpacs[n].mine, :reachable => false, :manhattan => manhattan) )
                    # distances[-1].puts
                end
                distances.sort_by! { |t| t.distance}
                distances.each { |t| t.reachable = true if t.distance == distances[0].distance }
                supers.push(distances)
            end
        end
    end
    mysupers = Array.new(mypacs.length) { Array.new() }
    supers.length.times do |a|
        supers[a].length.times do |b|
            if supers[a][b].mine == true
                mysupers[supers[a][b].pacid].push(supers[a][b])
            end
        end
    end
    # supers.length.times do |t|
    #     STDERR.puts "supers[#{t}]: #{supers[t]}"
    # end
    return mysupers
end

def getpelletcount(rows)
    count = 0
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "S" then count += 10 end
            if rows[h][w] == "." || rows[h][w] == "o" then count += 1 end
        end
    end
    $totalpellets = count
end
def isalive(target, mypacs)
    mypacs.length.times do |i|
        if mypacs[i].pac_id == target.pacid
            return 1
        end
    end
    return 0
end
def min(a, b)
    a < b ? a : b
end
def max(a, b)
    a > b ? a : b
end

def matchup(pac1, pac2)
    if pac1.type_id == "DEAD" || pac2.type_id == "DEAD"
        return "dead"
    end
    if pac1.type_id == pac2.type_id
        return "draw"
    elsif (pac1.type_id == "ROCK" && pac2.type_id == "SCISSORS") || (pac1.type_id == "PAPER" && pac2.type_id == "ROCK") || (pac1.type_id == "SCISSORS" && pac2.type_id == "PAPER")
        return "win"
    elsif (pac1.type_id == "ROCK" && pac2.type_id == "PAPER") || (pac1.type_id == "PAPER" && pac2.type_id == "SCISSORS") || (pac1.type_id == "SCISSORS" && pac2.type_id == "ROCK")
        return "lose"
    end
    return "no"
end

def getcounter(pac)
    if pac.type_id == "ROCK"
        return "PAPER"
    elsif pac.type_id == "PAPER"
        return "SCISSORS"
    elsif pac.type_id == "SCISSORS"
        return "ROCK"
    else
        return "DEAD"
    end
end
def getwintype(pac)
    if pac.type_id == "ROCK"
        return "C"
    elsif pac.type_id == "PAPER"
        return "R"
    elsif pac.type_id == "SCISSORS"
        return "P"
    else
        return " "
    end
end
def getdrawtype(pac)
    if pac.type_id == "ROCK"
        return "R"
    elsif pac.type_id == "PAPER"
        return "P"
    elsif pac.type_id == "SCISSORS"
        return "C"
    else
        return "E"
    end
end
def getlosetype(pac)
    if pac.type_id == "ROCK"
        return "P"
    elsif pac.type_id == "PAPER"
        return "C"
    elsif pac.type_id == "SCISSORS"
        return "R"
    else
        return "E"
    end
end
def biggestnonzero(up, down, left, right)
    arr = Array.new()
    arr.push(6)
    if up > 0 then arr.push(up) end
    if down > 0 then arr.push(down) end
    if left > 0 then arr.push(left) end
    if right > 0 then arr.push(right) end
    return arr.min
end
def istrapped(deadends, enemypac, mypacs)
    if deadends[enemypac.y][enemypac.x] == "D" || deadends[enemypac.y][enemypac.x] == "U"
        return 1
    end
    return 0
end

def getrealdistance(rows, x, y, goal, steps, width)
    if x < 0 || y < 0 || !rows[y][x] || steps == 6 || rows[y][x] == "#" || rows[y][x] == "X"
        return 0
    end
    if x == goal[0] && y == goal[1]
        return steps
    end
    rows[y][x] = "X"
    if x == 0 then left = getrealdistance(rows.clone.map(&:clone), width - 1, y, goal, steps + 1, width) else left = getrealdistance(rows.clone.map(&:clone), x - 1, y,  goal, steps + 1, width) end
    if x == width - 1 then right = getrealdistance(rows.clone.map(&:clone), 0, y,  goal, steps + 1, width) else right = getrealdistance(rows.clone.map(&:clone), x + 1, y,  goal, steps + 1, width) end
    up = getrealdistance(rows.clone.map(&:clone), x, y - 1, goal, steps + 1, width)
    down = getrealdistance(rows.clone.map(&:clone), x, y + 1, goal, steps + 1, width)
    return biggestnonzero(up, down, left, right)
end

def rps(mypacs, ptargets, theirpacs, width, oldpositions_array, positions, rows, deadends, oldtargets)
    moveset = Array.new(mypacs.length)
    mypacs.length.times do |i|
        threatened = 0
        if ptargets[i][0].rushpellet == true
            moveset[i] = ["MOVE", mypacs[i].pac_id, ptargets[i][0].x, ptargets[i][0].y]
        else
            moveset[i] = ["MOVE", mypacs[i].pac_id, ptargets[i][0].goto[0], ptargets[i][0].goto[1]]
        end
        if $movedebug then STDERR.puts "i=#{i}, moveset[i] = #{moveset[i]}, targets #{ptargets[i][0].goto}" end
        theirpacs.length.times do |n|
            afstand = getrealdistance(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, [theirpacs[n].x, theirpacs[n].y], 0, width)
            next if (theirpacs[n].lastseen + 3 < $turn || afstand == 0)

            if afstand < 5 && matchup(mypacs[i], theirpacs[n]) == "lose" && theirpacs[n].lastseen + 3 > $turn then threatened = 1 end
            if $movedebug then STDERR.puts "mine=#{mypacs[i].pac_id}&theirs=#{theirpacs[n].pac_id}, afstand = #{afstand}, threatened=#{threatened} myac=#{mypacs[i].ability_cooldown}&theirac=#{theirpacs[n].ability_cooldown}  " end
            if $movedebug then STDERR.puts "switch if #{matchup(mypacs[i], theirpacs[n])}==lose, myls:#{mypacs[i].lastseen}, enls:#{theirpacs[n].lastseen}, threat=#{threatened}. #{afstand} <= #{1 + theirpacs[n].hasspeed}" end
            if mypacs[i].lastseen == 0 && theirpacs[n].lastseen == $turn && matchup(mypacs[i], theirpacs[n]) == "lose" && afstand <= 1 + theirpacs[n].hasspeed && mypacs[i].ability_cooldown == 0
                # He cant see me right now, but he can move to my position and kill me, so I have to switch (or speed away maybe)
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
                if true then STDERR.puts "SWITCH! he cant see me  " end
            elsif mypacs[i].lastseen == 1 && theirpacs[n].lastseen == $turn && (matchup(mypacs[i], theirpacs[n]) == "lose" || (matchup(mypacs[i], theirpacs[n]) == "draw" && stuckfor(positions, oldtargets, i, mypacs) >= 1)) && afstand <= 1 + theirpacs[n].hasspeed && mypacs[i].ability_cooldown == 0
                # We both see each other, on this turn he can move and take my pac
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
                if true then STDERR.puts "SWITCH! he bout to snap me but sikes  " end
            elsif $turn == 0 && afstand <= 2 && matchup(mypacs[i], theirpacs[n]) == "lose"
                # spawned on the other side of my target (superpellet) from my counterenemy
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
                if true then STDERR.puts "too close to a counter, cant risk losing" end
            end
            if theirpacs[n].lastseen + 2 >= $turn && afstand < 5 && matchup(mypacs[i], theirpacs[n]) == "win" && istrapped(deadends, theirpacs[n], mypacs) == 1
                # possible to trap and kill their unit (not if current target is a superpellet)
                if theirpacs[n].ability_cooldown > 0 then moveset[i] = ["MOVE", mypacs[i].pac_id, theirpacs[n].x, theirpacs[n].y] end
                if $movedebug then STDERR.puts "pac[#{mypacs[i].pac_id}] can trap theirpac[#{theirpacs[n].pac_id}]" end
            end
            nextdist = afstand( ptargets[i][0].goto, [theirpacs[n].x, theirpacs[n].y], width )
            # nextdist = getrealdistance(rows.clone.map(&:clone), theirpacs[n].x, theirpacs[n].y, ptargets[i][0].goto, 0, width)
            # halfdist = afstand( ptargets[i][0].gotohalf, [theirpacs[n].x, theirpacs[n].y], width)
            count = 0
            while deadends[mypacs[i].y][mypacs[i].x] != "D" && deadends[mypacs[i].y][mypacs[i].x] != "U" && matchup(mypacs[i], theirpacs[n]) == "lose" && afstand < 5 && nextdist < afstand && mypacs[i].ability_cooldown > 0 && count * 2 < ptargets[i].length
                # cant switch, gotta run to another target
                count += 1
                threatened = 1
                # STDERR.puts "counter=#{count}"
                ptargets[i].insert(-1, ptargets[i].delete_at(0))
            end
            if $movedebug then STDERR.puts "i=#{mypacs[i].pac_id}, after checking enemy[#{theirpacs[n].pac_id}], move = #{moveset[i]}  " end
            counter = 0
            while threatened == 1 && (deadends[ptargets[i][0].goto[1]][ptargets[i][0].goto[0]] == "D" || deadends[ptargets[i][0].goto[1]][ptargets[i][0].goto[0]] == "U") && counter < ptargets[i].length
                ptargets[i].insert(-1, ptargets[i].delete_at(0))
                counter += 1
                if $movedebug then STDERR.puts "pac#{mypacs[i].pac_id} scared so no go into dead-end " end
            end
        end
        if threatened == 0 && mypacs[i].ability_cooldown == 0 && moveset[i][0] == "MOVE"
            moveset[i] = ["SPEED", mypacs[i].pac_id]
            if $movedebug then STDERR.puts "Speed cus I can" end
        end
    end
    # if $movedebug then STDERR.puts "movesets = #{moveset}" end
    return moveset
end
            

def time_diff_milli(start, finish)
    (finish - start) * 1000.0
end

def getrandomtarget(rows, mypacs, i, width)
    t = Target.new
    r = randomtarget(rows)
    t.x = r[0]
    t.y = r[1]
    t.pacid = mypacs[i].pac_id
    t.origin = "randomizer"
    t.goto = r
    t.goalvalue = 0
    t.gotohalf = r
    t.rushpellet = false
    t.distance = afstand(r, [mypacs[i].x, mypacs[i].y], width)
    t.manhattan = t.distance
    return t
end
def conflict(rows, mypacs, ptargets, width)
    conflicts = 1
    counter = 0
    t1 = Time.now
    maxima = ptargets.max_by(&:size).size
    if $conflictdebug then STDERR.puts "maxima = #{maxima}" end
    while conflicts > 0 && counter < maxima
        conflicts = 0
        counter += 1
        # STDERR.puts "conflictcounter = #{counter}"
        mypacs.length.times do |i|
            mypacs.length.times do |n|
                if i != n && ( ptargets[i][0].goto == ptargets[n][0].goto || ptargets[i][0].gotohalf == ptargets[n][0].gotohalf)
                    if ptargets[i][0].value < ptargets[n][0].value || (i > n && ptargets[i][0].value == ptargets[n][0].value)
                        #i's value is lower so seek new target
                        conflicts += 1
                        if counter == maxima && i > n then ptargets[i][0].goto = [mypacs[i].x, mypacs[i].y] else ptargets[i].insert(-1, ptargets[i].delete_at(0)) end
                    end
                end
            end
        end
    end
    if $timedebug then STDERR.puts "conflict runtime = #{time_diff_milli(t1, Time.now)}" end
    if $targetdebug
        ptargets.length.times do |i|
            STDERR.puts "after #{counter - 1} conflict: #{mypacs[i].pac_id}-> #{ptargets[i][0].goto} "
        end
    end
    return ptargets
end
def stuckwithteammate(mypacs, ptargets, i, width)
    # ptargets[i][0].gotohalf
    mypacs.length.times do |t|
        # STDERR.puts "stuckwithteammate if #{i}!=#{t} && #{afstand(ptargets[i][0].gotohalf, [mypacs[t].x, mypacs[t].y], width )} == 1"
        if i != t && afstand(ptargets[i][0].gotohalf, [mypacs[t].x, mypacs[t].y], width ) == 1
            return 1
        end
    end
    return 0
end
def saveenemy(theirpacs, stucktile, typeid, width, rows)
    nsaved = -1
    refdist = 30
    theirpacs.length.times do |n|
        checkdist = afstand(stucktile, [theirpacs[n].x, theirpacs[n].y], width)
        if theirpacs[n].type_id == typeid && theirpacs[n].lastseen != $turn && checkdist < refdist
            refdist = checkdist
            nsaved = n
            STDERR.puts "gotcha bitch nr#{theirpacs[nsaved].pac_id}"
        end
    end
    if nsaved != -1
        theirpacs[nsaved].x = stucktile[0]
        theirpacs[nsaved].y = stucktile[1]
        theirpacs[nsaved].lastseen = $turn
        rows[stucktile[1]][stucktile[0]] = "E"
    end
end
def stuckfor(positions, oldtargets, i, mypacs)
    # STDERR.puts "oldtargets: #{oldtargets.length}, mypacs: #{mypacs.length}, i=#{i} "
    # STDERR.puts "i=#{mypacs[i].pac_id}.stuck if: #{[mypacs[i].x, mypacs[i].y]} != #{oldtargets[i].goto} && #{mypacs[i].ability_cooldown} < 9 "
    if [mypacs[i].x, mypacs[i].y] != oldtargets[i].goto && mypacs[i].ability_cooldown < 9
        # STDERR.puts ", apparently #{positions[i]} is equal to #{oldpositions_array[a][i]}"
        return 1
    end
    return 0
end

def unseenenemycheck(ptargets, mypacs, rows, positions, oldtargets, width, theirpacs)
    count = 0
    mypacs.length.times do |i|
        # STDERR.puts "i=#{mypacs[i].pac_id}.unseen en if: #{stuckfor(positions, oldtargets, i, mypacs)} >= 1 && #{stuckwithteammate(mypacs, ptargets, i, width)} == 0 "
        if stuckfor(positions, oldtargets, i, mypacs) >= 1 && stuckwithteammate(mypacs, ptargets, i, width) == 0
            saveenemy(theirpacs, ptargets[i][0].gotohalf, mypacs[i].type_id, width, rows)
        end
    end

end
def clearmap(rows)
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "S"
                rows[h][w] = " "
            elsif rows[h][w] == "E" || rows[h][w] == "R" || rows[h][w] == "P" || rows[h][w] == "C" || rows[h][w] == "M"
                rows[h][w] = " "
            elsif rows[h][w] == "-"
                rows[h][w] = " "
            elsif rows[h][w] == "o"
                rows[h][w] = "."
            end
        end
    end
    return rows
end
def turnzerofloodfillchecks(rows, x, y, steps, value, width, currentpac, deadends, maxsteps)
    if y < 0 || x < 0 || !rows[y][x]
        return
    elsif rows[y][x] == "#" || rows[y][x] == "X" || steps > maxsteps
   	    return
    end
    if rows[y][x] == "o" || rows[y][x] == "S" || rows[y][x] == "."
        tilevalue = 1
        if rows[y][x] == "." then tilevalue -= 0.2 end
        if rows[y][x] == "S" then tilevalue += 9 end
        # if deadends[y][x] == "D" || deadends[y][x] == "U"
        #     tilevalue /= 2
        # end
        tilevalue = tilevalue.to_f * ( (maxsteps + 1 - steps).to_f / maxsteps.to_f )
        value = value.to_f + tilevalue.to_f
    end
    rows[y][x] = "X"
    if steps > 0 && value > 0.0
    	currenttile = Target.new(:distance => steps, :value => value, :x => x, :y => y, :goto => [x, y], :gotohalf => [x, y], :origin => "floodfill", :pacid => currentpac.pac_id, :rushpellet => false,:manhattan => afstand( [currentpac.x, currentpac.y], [x, y], width))
    end
    if x == 0 then left = turnzerofloodfillchecks(rows, width - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) else left = turnzerofloodfillchecks(rows, x - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) end
    if x == width - 1 then right = turnzerofloodfillchecks(rows, 0, y, steps + 1, value, width, currentpac, deadends, maxsteps) else right = turnzerofloodfillchecks(rows, x + 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) end
    up = turnzerofloodfillchecks(rows, x, y - 1, steps + 1, value, width, currentpac, deadends, maxsteps)
    down = turnzerofloodfillchecks(rows, x, y + 1, steps + 1, value, width, currentpac, deadends, maxsteps)
    # if x == 0 then left = turnzerofloodfillchecks(rows.clone.map(&:clone), width - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) else left = turnzerofloodfillchecks(rows.clone.map(&:clone), x - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) end
    # if x == width - 1 then right = turnzerofloodfillchecks(rows.clone.map(&:clone), 0, y, steps + 1, value, width, currentpac, deadends, maxsteps) else right = turnzerofloodfillchecks(rows.clone.map(&:clone), x + 1, y, steps + 1, value, width, currentpac, deadends, maxsteps) end
    # up = turnzerofloodfillchecks(rows.clone.map(&:clone), x, y - 1, steps + 1, value, width, currentpac, deadends, maxsteps)
    # down = turnzerofloodfillchecks(rows.clone.map(&:clone), x, y + 1, steps + 1, value, width, currentpac, deadends, maxsteps)
    return collecttargets(left, right, up, down, currenttile, steps, currentpac, x, y, rows)
end
def reachamount(rows, height, width, mypacs, deadends)
    reachamount = Array.new(rows.length)
    reachamount.length.times do |h|
        reachamount[h] = Array.new(rows[h].length)
        reachamount[h].length.times do |w|
            if rows[h][w] != "#"
                time1 = Time.now
                maxsteps = 15
                a = turnzerofloodfillchecks(rows.clone.map(&:clone), w, h, 0, 0, width, mypacs[0], deadends, maxsteps)
                # STDERR.puts "a = #{a}, xy=#{w},#{h} "
                reachamount[h][w] = a.length
                if h == 11 && w == 15 then STDERR.puts "#{w},#{h}: #{reachamount[h][w]}" end
                # if true then STDERR.puts "fftest for #{w},#{h} with length #{v[h][w]}, duration=#{time_diff_milli(time1, Time.now)} " end
            else
                reachamount[h][w] = 0
            end
        end
    end
    return reachamount
end
def collecttargets(left, right, up, down, currenttile, steps, currentpac, x, y, rows)
	arr = Array.new
	if left != nil && left.instance_of?(Target) then arr.push(left) end
	if left != nil && left.instance_of?(Array) then arr.push(*left) end
	if right != nil && right.instance_of?(Target) then arr.push(right) end
	if right != nil && right.instance_of?(Array) then arr.push(*right) end
	if up != nil && up.instance_of?(Target) then arr.push(up) end
	if up != nil && up.instance_of?(Array) then arr.push(*up) end
	if down != nil && down.instance_of?(Target) then arr.push(down) end
	if down != nil && down.instance_of?(Array) then arr.push(*down) end
    if currenttile != nil && currenttile.rushpellet == true then currenttile.value *= 10 end
    if currenttile != nil && currenttile.instance_of?(Target) then arr.push(currenttile) end

    if steps == 1
        arr.each { |i| i.gotohalf = [x, y] }
        if currentpac.hasspeed == 0
            arr.each { |i| i.goto = [x, y] }
        end
    end
    if steps == 2 && currentpac.hasspeed == 1
        arr.each { |i| i.goto = [x, y] }
    end
	return arr
end
def eenfloodfillperpac(rows, x, y, steps, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers)
    if y < 0 || x < 0 || !rows[y][x]
        return
	elsif rows[y][x] == "#" || rows[y][x] == "X" || (rows[y][x] == "M" && steps != 0) || rows[y][x] == "E" || rows[y][x] == drawtype || rows[y][x] == losetype || steps > maxsteps
   	    return
    end
    # if currentpac.pac_id == 1 && (y == 9 || y == 10 || y == 11) then STDERR.puts "hes here lads xy=#{x},#{y} steps=#{steps}" end
    rushpellet = false
    if rows[y][x] == "o" || rows[y][x] == "S" || rows[y][x] == "."
        tilevalue = 1
        if rows[y][x] == "." then tilevalue -= 0.3 end
        if rows[y][x] == "S"
            tilevalue += 9
            mysupers.length.times do |i|
                mysupers[i].length.times do |s|
                    # STDERR.puts "check if  #{mysupers[i][s].pos} == #{[x, y]} d=#{steps} && #{mysupers[i][s].mine} == true && #{mysupers[i][s].pacid} == #{currentpac.pac_id}, reach=#{mysupers[i][s].pacid}"
                    if mysupers[i][s].pos == [x, y] && mysupers[i][s].mine == true && mysupers[i][s].pacid == currentpac.pac_id
                        # if mysupers[i][s].reachable == true then tilevalue *= 10 end
                        rushpellet = mysupers[i][s].reachable
                    end
                end
            end
        end
        if $turn < 30 && deadends[y][x] == "D" || deadends[y][x] == "U"
            tilevalue /= 2
        end
        tilevalue = tilevalue.to_f * ( (maxsteps + 1 - steps).to_f / maxsteps.to_f )
        value = value.to_f + tilevalue.to_f
    end
    if steps > 0 && value > 0.0
    	currenttile = Target.new(:distance => steps, :value => value, :x => x, :y => y, :goto => [x, y], :gotohalf => [x, y], :origin => "floodfill", :pacid => currentpac.pac_id, :rushpellet => rushpellet,:manhattan => afstand( [currentpac.x, currentpac.y], [x, y], width), )
    end
    rows[y][x] = "X"
    if x == 0 then left = eenfloodfillperpac(rows.clone.map(&:clone), width - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers) else left = eenfloodfillperpac(rows.clone.map(&:clone), x - 1, y, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers) end
    if x == width - 1 then right = eenfloodfillperpac(rows.clone.map(&:clone), 0, y, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers) else right = eenfloodfillperpac(rows.clone.map(&:clone), x + 1, y, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers) end
    up = eenfloodfillperpac(rows.clone.map(&:clone), x, y - 1, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers)
    down = eenfloodfillperpac(rows.clone.map(&:clone), x, y + 1, steps + 1, value, width, currentpac, deadends, maxsteps, drawtype, losetype, mysupers)
    return collecttargets(left, right, up, down, currenttile, steps, currentpac, x, y, rows)
end
def getleftoverpellets(pac, rows, width, ptargets, i)
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "." || rows[h][w] == "o"
                afstand = afstand([w, h], [pac.x, pac.y], width)
                t = Target.new(:x => pac.x, :y => pac.y, :distance => afstand, :manhattan => afstand, :pacid => pac.pac_id, :value => 1, :goto => [w, h], :gotohalf => [w, h], :origin => "leftover", :rushpellet => false)
                ptargets[i].push(t)
            end
        end
    end
    ptargets[i].sort_by! { |a| a.distance}
end
def socialdistancing(mypacs, ptargets, i, width, deadends, theirpacs)
    currentdistances = 0
    if mypacs.length > 1
        mypacs.length.times do |n|
            if i != n then currentdistances += afstand( [mypacs[i].x, mypacs[i].y], [mypacs[n].x, mypacs[n].y], width ) end
        end
        ptargets[i].length.times do |t|
            if deadends[ptargets[i][t].goto[1]][ptargets[i][t].goto[0]] == "U" #U for ultimate deadend
                if $turn > 30 then ptargets[i][t].value += 2 else ptargets[i][t].value += 1 end
            end
            newdistances = 0
            mypacs.length.times do |n|
                if i != n then newdistances += afstand( [mypacs[n].x, mypacs[n].y], [ptargets[i][t].x, ptargets[i][t].y], width) end
            end
            ptargets[i][t].value *= max(0.5, min(1.5, newdistances.to_f / currentdistances.to_f))
            theirpacs.length.times do |n|
                if theirpacs[n].lastseen + 2 > $turn && afstand( [theirpacs[n].x, theirpacs[n].y], ptargets[i][t].goto, width) < afstand( [theirpacs[n].x, theirpacs[n].y], [mypacs[i].x, mypacs[i].y], width)
                    if matchup(mypacs[i], theirpacs[n]) == "lose" then ptargets[i][t].value /= 3 else ptargets[i][t].value /= 1.5 end
                    # ptargets[i][t].value /= 2
                end
            end
        end
    end
end
def checkrushes(mysupers, ptargets, i, mypacs)
    a = mypacs[i].pac_id
    ret = 0
    dist = 100
    mysupers[a].length.times do |b|
        if mysupers[a][b].reachable == true && mysupers[a][b].distance < dist
            if ptargets[i] == nil then ptargets[i] = Array.new end
            ret = 1
            dist = mysupers[a][b].distance
            ptargets[i][0] = Target.new(:x => mysupers[a][b].pos[0], :y => mysupers[a][b].pos[1], :goto => mysupers[a][b].pos, :gotohalf => mysupers[a][b].pos, :value => 1200, :distance => mysupers[a][b].distance, :pacid => mysupers[a][b].pacid, :manhattan => mysupers[a][b].manhattan, :rushpellet => true )
        end
    end
    return ret
end
def eenteameentaak(rows, ptargets, mypacs, theirpacs, width, height, deadends, reachamount, mysupers)
    elapsedtime = 0
	mypacs.length.times do |i|
        start = Time.now
        timeleft = 42.0 - elapsedtime
        timeperpac = timeleft.to_f / (mypacs.length - i).to_f
        STDERR.puts "timeperpac = #{timeperpac}"
        # multip = (100.to_f / reachamount[mypacs[i].y][mypacs[i].x].to_f)
        # maxsteps = max(12, min(19, (13.0 * multip).to_f)).to_i
        if width > 33 then maxsteps = 13 else maxsteps = 15 end
        if mypacs.length > 3 then maxsteps -= mypacs.length + 3 end
        # rows.each { |item| STDERR.puts item}
        if checkrushes(mysupers, ptargets, i, mypacs) == 0
      		benched = Benchmark.measure { ptargets[i] = eenfloodfillperpac(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, 0, 0, width, mypacs[i], deadends, maxsteps, getdrawtype(mypacs[i]), getlosetype(mypacs[i]), mysupers) }
            if $timedebug then STDERR.puts "ff takes: benchmark=#{benched.real}, timediff=#{time_diff_milli(start, Time.now)}, size=#{ptargets[i].length}, reachamount=#{reachamount[mypacs[i].y][mypacs[i].x]}" end
            socialtime = Time.now
            benched = Benchmark.measure { socialdistancing(mypacs, ptargets, i, width, deadends, theirpacs) }
            if $timedebug then STDERR.puts "social distance takes: benchmark=#{benched.real}, timediff=#{time_diff_milli(socialtime, Time.now)}" end
        end
 
        if ptargets[i].length > 0 then ptargets[i] = ptargets[i].sort_by! {|a| a.value}.reverse end
        # if ptargets[i].length > 15 then ptargets[i] = ptargets[i].slice(0, 15) end
        if ptargets[i].length > 0 && ptargets[i][0].value == 0.0 then STDERR.puts "something wong, highest value = 0" end
        if ptargets[i].length == 0
            STDERR.puts "before: ptargets[#{i}].length = #{ptargets[i].length}"
            if blockedin(mypacs[i], rows, width) == 1 then ptargets[i][0] = Target.new(:x => mypacs[i].x, :y => mypacs[i].y, :distance => 0, :manhattan => 0, :pacid => mypacs[i].pac_id, :value => 0, :goto => [mypacs[i].x, mypacs[i].y], :gotohalf => [mypacs[i].x, mypacs[i].y], :origin => "self", :rushpellet => false ) else getleftoverpellets(mypacs[i], rows, width, ptargets, i) end
            STDERR.puts "after: ptargets[#{i}].length = #{ptargets[i].length}"
        end
        if $targetdebug then ptargets[i][0].puts(mypacs[i].x, mypacs[i].y) end
        roundtriptime = time_diff_milli(start, Time.now)
        elapsedtime += roundtriptime
 	end
    return ptargets
end
def findandreplace(row, from, to)
    row.length.times do |i|
        if row[i] == from
            row[i] = to
        end
    end
    return row
end
def printtars(arr)
    arr.length.times do |i|
        arr[i].p
    end
end
def getlastposition(positions, oldpositions_array, i)
    oldpositions_array.length.times do |a|
        if oldpositions_array[a][i] != positions[i] && oldpositions_array[a][i] != nil
            STDERR.puts "#{positions[i]} != #{oldpositions_array[a][i]}"
            return oldpositions_array[a][i]
        end
    end
    return positions[i]
end

def distance(target1, target2)
    distance = (target2[0] - target1[0]).abs + (target2[1] - target1[1]).abs
    return distance
end

def afstand(target1, target2, width)
    minim = (width / 3).to_i
    if $openside > 0 
        if target1[0] < target2[0]
            opendist = width - target2[0] + target1[0] + (target1[1] - target2[1]).abs
        else
            opendist = width - target1[0] + target2[0] + (target1[1] - target2[1]).abs
        end
    else
        opendist = width
    end
    distance = (target2[0] - target1[0]).abs + (target2[1] - target1[1]).abs
    # if min(distance, opendist) < 2 then STDERR.puts "distance = #{distance}, opendist = #{opendist}" end
    return min(distance, opendist)
end

def getamount(rows, check1, check2, check3)
    amount = 0
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == check1 || rows[h][w] == check2 || rows[h][w] == check3
                amount += 1
            end
        end
    end
    return amount
end
def randomtarget(rows)
    amount = getamount(rows, "S", "o", ".")
    rows.length.times do |h|
        rows[h].length.times do |w|
            if (rows[h][w] == "S" || rows[h][w] == "o" || rows[h][w] == ".") && rand(1..amount) == 7
                return [w, h]
            end
        end
    end
    return randomtarget(rows)
end

class Pac
    attr_accessor :pac_id, :mine, :x, :y, :type_id, :speed_turns_left, :ability_cooldown, :hasspeed, :lastseen, :abcdtimerlastturn
    def print
        STDERR.puts "id: #{pac_id}, mine?:#{mine}, x: #{x}, y: #{y}, type_id: #{type_id}, stl: #{speed_turns_left}, ability_cooldown: #{ability_cooldown}, hasspeed?:#{hasspeed}"
    end
        
    def initialize(pac_id: 0, mine: true, x: 0, y: 0, type_id: 0, speed_turns_left: 0, ability_cooldown: 0, hasspeed: 0, lastseen: 0)
        @pac_id = pac_id
        @mine = mine
        @x = x
        @y = y
        @type_id = type_id
        @speed_turns_left = speed_turns_left
        @ability_cooldown = ability_cooldown
        @hasspeed = hasspeed
        @lastseen = lastseen
    end
    def distance(target)
        distance = (target[0] - x).abs + (target[1] - y).abs
        return distance
    end
    def tooclose(my_pacs, goal)
        if goal.length == 0 || goal.empty?
            return 0
        end
        my_pacs.length.times do |i|
#           STDERR.puts "tooclose: #{pac_id != my_pacs[i].pac_id} && #{distance([my_pacs[i].x, my_pacs[i].y])}"
            if pac_id != my_pacs[i].pac_id && distance([my_pacs[i].x, my_pacs[i].y]) <= 1 + $speed
                check = distance(goal) - my_pacs[i].distance(goal)
#                STDERR.puts "goal = #{goal} & check = #{check}, pac_id = #{pac_id} & mypacs[i].pac_id = #{my_pacs[i].pac_id}"
                if check > 0
                    # STDERR.puts "giving way cus hes closer"
                    return 1
                elsif check == 0 && pac_id > my_pacs[i].pac_id
                    # STDERR.puts "giving way cus hes lower id"
                    return 1
                end
            end
        end
        return 0
    end
    def nearby(my_pacs, goal)
        if goal.length == 0 || goal.empty?
            return 0
        end
        my_pacs.length.times do |i|
#            STDERR.puts "#{pac_id != my_pacs[i].pac_id && distance([my_pacs[i].x, my_pacs[i].y]) < 2}"
            if pac_id > my_pacs[i].pac_id && distance([my_pacs[i].x, my_pacs[i].y]) < 2
                return 1
            end
        end
        return 0
    end
    def findclosest(pellets)
        ref = 100
        ret = [0, 0, 0]
        pellets.length.times do |i|
            distance = (x - pellets[i].x).abs + (y - pellets[i].y).abs
            if pellets[i].value == 10 && distance < ref
                ref = distance
                ret = [pac_id, pellets[i].x, pellets[i].y]
            end
        end
        if ret[0] == 0 && ret[1] == 0 && ret[2] == 0
            pellets.length.times do |i|
                distance = (x - pellets[i].x).abs + (y - pellets[i].y).abs
                if distance < ref
                    ref = distance
                    ret = [pac_id, pellets[i].x, pellets[i].y]
                end
            end
        end
        return ret
    end
    def vision(rows, pellets, dx, dy, width, height)
        tmpx = x.dup + dx
        tmpy = y.dup + dy
        count = 0
        while tmpy.between?(0, height - 1) && tmpx.between?(0, width - 1) && rows[tmpy][tmpx] != "#" && count < width
#        STDERR.puts "dxdy=[#{dx}, #{dy}], tmpxy = [#{tmpx}, #{tmpy}] ybetween?: #{(tmpy).between?(0, height - 1)}, xbetween?: #{(tmpx).between?(0, width - 1)} & tile = #{rows[tmpy][tmpx]}"
          #  STDERR.puts "checking rows[#{y + dy}][#{x + dx}] = #{rows[y + dy][x+dx]}"
            count += 1
            if rows[tmpy][tmpx] == "E" || rows[tmpy][tmpx] == "R" || rows[tmpy][tmpx] == "P" || rows[tmpy][tmpx] == "C"
                self.lastseen = 1
            else
                rows[tmpy][tmpx] = "-"
            end
            if tmpx == 0 && dx == -1
                tmpx = width - 1
            elsif tmpx == width - 1 && dx == 1
                tmpx = 0
            else
                tmpx = tmpx + dx
                tmpy = tmpy + dy
            end
        end
        return rows
	end
end

class Pellet
    attr_accessor :x, :y, :value
    def print
        STDERR.puts "x: #{x}, y: #{y}, value: #{value}"
    end
end

class Target
    attr_accessor :x, :y, :distance, :value, :pacid, :manhattan, :origin, :goto, :gotohalf,:goalvalue, :rushpellet
    def initialize(x: 0, y: 0, distance: 10, value: 0, ratio: 0, pacid: 0, manhattan: 0, origin: "default", goto: 0, gotohalf: 0, rushpellet: false)
        @x = x
        @y = y
        @distance = distance
        @value = value
        @ratio = ratio
        @pacid = pacid
        @manhattan = manhattan
        @goalvalue = goalvalue
        @origin = origin
        @goto = goto
        @gotohalf = gotohalf
        @rushpellet = rushpellet
    end
    def print(posx, posy)
        STDERR.print "pac[#{pacid}] --> [#{x}, #{y}], goto = #{goto}, val= #{value}, origin = #{origin}, dist = #{distance}, mh = #{manhattan}, ffneed=#{floodfillneed} | "
        # STDERR.puts "x:#{x}, y:#{y}, distance:#{distance}, value#{value}, ratio: #{ratio}, pacid: #{pacid}, goto: #{goto}, manhattan: #{manhattan}, eff: #{eff}, orig: #{origin}"
    end
    def puts(posx, posy)
        STDERR.puts "pac[#{pacid}] --> [#{x}, #{y}], goto = #{goto}, val= #{value}, dist = #{distance}| "
        # STDERR.puts "x:#{x}, y:#{y}, distance:#{distance}, value#{value}, ratio: #{ratio}, pacid: #{pacid}, goto: #{goto}, manhattan: #{manhattan}, eff: #{eff}, orig: #{origin}"
    end
    def sputs
        STDERR.puts "pac[#{pacid}]->#{x},#{y} og=#{origin},d=#{distance},v=#{value},goto=#{goto} "
    end
    def p
        STDERR.print "x:#{x}, y:#{y}, distance:#{distance}, value#{value}, ratio: #{ratio}, pacid: #{pacid}, manhattan: #{manhattan}, eff: #{eff} | "
    end
    def printif
        if distance > 0 && value > 0
            STDERR.puts "pac_id: #{pacid}, x:#{x}, y:#{y}, distance:#{distance}, value:#{value}, ratio: #{ratio}, manhattan: #{manhattan}, eff: #{eff}"
        end
    end
end
def iswall(tile)
    if tile == "D" || tile == "#" || tile == "M" || tile == "U"
        return 1
    end
    return 0
end
def ispound(tile)
    if tile == "#"
        return 1
    end
    return 0
end
def block(tile)
    if tile == "#" || tile == "E"
        return 1
    end
    return 0
end
def blockedin(pac, rows, width)
    if pac.x == 0 then left = rows[pac.y][width - 1] else left = rows[pac.y][pac.x - 1] end
    if pac.x == width - 1 then right = rows[pac.y][0] else right = rows[pac.y][pac.x + 1] end
    up = rows[pac.y - 1][pac.x]
    down = rows[pac.y + 1][pac.x]
    if block(left) == 1 && block(right) == 1 && block(up) == 1 && block(down) == 1
        return 1
    end
    return 0
end
def checkdeadends(deadends, x, y, width, height)
    if x < 0 || y < 0 || x > width - 1 || y > width - 1
        return
    end
    if x == 0 then left = [width - 1, y, deadends[y][width - 1]] else left = [x - 1, y, deadends[y][x - 1] ] end
    if x == width - 1 then right = [ 0, y, deadends[y][0] ] else right = [ x + 1, y, deadends[y][x + 1]] end
    up = [x, y - 1, deadends[y - 1][x] ]
    down = [x, y + 1, deadends[y + 1][x] ]
    if iswall(up[2]) + iswall(down[2]) + iswall(left[2]) + iswall(right[2]) >= 3
        deadends[y][x] = "D"
        if iswall(up[2]) == 0
            checkdeadends(deadends, up[0], up[1], width, height)
        end
        if iswall(down[2]) == 0
            checkdeadends(deadends, down[0], down[1], width, height)
        end
        if iswall(left[2]) == 0
            checkdeadends(deadends, left[0], left[1], width, height)
        end
        if iswall(right[2]) == 0
            checkdeadends(deadends, right[0], right[1], width, height)
        end
        if ispound(up[2]) + ispound(down[2]) + ispound(left[2]) + ispound(right[2]) >= 3
            deadends[y][x] = "U"
        end
    end
end

# width: size of the grid
# height: top left corner is (x=0, y=0)
width, height = gets.split(" ").collect {|x| x.to_i}
rows = Array.new
deadends = Array.new
height.times do
    row = gets.chomp # one line of the grid: space " " is floor, pound "#" is wall
    if row[0] == " " || row[0] == "."
        $openside = 1
    end    
    deadrow = row.clone(&:clone)
    row = findandreplace(row, " ", ".")
    rows = rows.push(row)
    deadends.push(deadrow)
end

deadends.length.times do |h|
    # STDERR.puts "#{deadends[h]}"
    deadends[h].length.times do |w|
        if w < 4 && h > 8 then $crackdebug = true else $crackdebug = false end
        if deadends[h][w] != "#"
            checkdeadends(deadends, w, h, width, height)
        end
    end
end

oldpositions_array = Array.new
positions = Array.new
theirunseens = Array.new
theirpacs = Array.new
ptargets = Array.new
reachamount = Array.new
mysupers = Array.new

# game loop
loop do
    $ffcounter = 0
    $enemynearcount = 0
    $enemyneartime = 0
    $maxfloodfilltargets = 3
    $superpelletsleft = 0
    mypacs = Array.new
    mygraveyard = Array.new
    theirgraveyard = Array.new
    oldenemies = theirpacs.clone(&:clone)
    oldenemies.length.times do |i|
        oldenemies[i].abcdtimerlastturn = oldenemies[i].ability_cooldown.clone
        if oldenemies[i].speed_turns_left > 0 then oldenemies[i].speed_turns_left -= 1 end
        if oldenemies[i].ability_cooldown > 0 then oldenemies[i].ability_cooldown -= 1 end
    end
    theirpacs = Array.new
    pellets = Array.new
    oldpositions = Array.new
    if positions != nil
        oldpositions_array = oldpositions_array.unshift(positions.map(&:clone))
    end
    # rows.length.times do |h|
    #     rows[h].length.times do |w|
    #         if rows[h][w] == "E" && $turn > 2
    #             rows[h][w] = " "
    #         end
    #         if rows[h][w] == "M"
    #             rows[h][w] = " "
    #         end
    #     end
    # end
    positions = Array.new
    scoretime = Time.now
    my_score, opponent_score = gets.split(" ").collect {|x| x.to_i}
    visible_pac_count = gets.to_i # all your pacs and enemy pacs in sight
    starttime = Time.now
    $starttime = starttime
    visible_pac_count.times do
        pac = Pac.new()
        pac_id, mine, x, y, type_id, speed_turns_left, ability_cooldown = gets.split(" ")
        pac.pac_id = pac_id.to_i
        pac.mine = mine.to_i == 1
        pac.x = x.to_i
        pac.y = y.to_i
        pac.type_id = type_id
        pac.lastseen = $turn
        pac.speed_turns_left = speed_turns_left.to_i
        if pac.speed_turns_left > 0 then pac.hasspeed = 1 else pac.hasspeed = 0 end
        pac.ability_cooldown = ability_cooldown.to_i
        pac.abcdtimerlastturn = pac.ability_cooldown.clone
        if pac.mine == true
            if pac.type_id == "DEAD"
                mygraveyard = mygraveyard.push(pac)
            else
                pac.lastseen = 0
                mypacs = mypacs.push(pac)
            end
            if $turn == 0
                oldenemies = oldenemies.push(Pac.new(:pac_id => pac.pac_id, :mine => !pac.mine, :x => width - pac.x - 1, :y => pac.y, :type_id => pac.type_id, :speed_turns_left => pac.speed_turns_left, :ability_cooldown => pac.ability_cooldown, :hasspeed => pac.hasspeed, :lastseen => pac.lastseen))
                rows[pac.y][width - pac.x - 1] = "E"
            end
            positions = positions.push([pac.x, pac.y])
            # STDERR.puts "pac[#{pac_id}]: stl=#{speed_turns_left} & ac = #{ability_cooldown}"
        else
            if pac.type_id == "DEAD"
                theirgraveyard = theirgraveyard.push(pac)
            else
                pac.lastseen = $turn
                theirpacs = theirpacs.push(pac)
            end
        end
    end
    # STDERR.puts "deadends including enemies"
    # deadends.length.times do |h|
    #     STDERR.puts deadends[h]
    # end
    $seenenemies = theirpacs.length
    if $turn == 0 || mypacs.length < 3 then $extra = 5 - mypacs.length else $extra = 0 end
    oldtargets = Array.new
    if $turn == 0
        mypacs.length.times do |i|
            oldtargets[i] = Target.new(:x => mypacs[i].x, :y => mypacs[i].y, :distance => 0, :goto => [mypacs[i].x, mypacs[i].y], :gotohalf => [mypacs[i].x, mypacs[i].y], :origin => "original location", :value => 1, :manhattan => 0, :rushpellet => false)
        end
    else
        ptargets.length.times do |i|
            if isalive(ptargets[i][0], mypacs) == 1
                ptargets[i][0].origin = "previous target"
                oldtargets.push(ptargets[i][0].clone(&:clone))
            end
        end
    end
    
    ptargets = Array.new(mypacs.length)
    visible_pellet_count = gets.to_i # all pellets in sight
    visible_pellet_count.times do
        pellet = Pellet.new()
        # value: amount of points this pellet is worth
        pellet.x, pellet.y, pellet.value = gets.split(" ").collect {|x| x.to_i}
        if pellet.value == 10
            $superpelletsleft += 1
            rows[pellet.y][pellet.x] = "S"
        end
        pellets = pellets.push(pellet)
    end
    oldenemies.length.times do |o|
        conflict = 0
        theirpacs.length.times do |t|
            if oldenemies[o].pac_id == theirpacs[t].pac_id || oldenemies[o].type_id == "DEAD"
                theirpacs[t].abcdtimerlastturn = oldenemies[o].abcdtimerlastturn.clone
                conflict = 1
            end
        end
        theirgraveyard.length.times do |g|
            if oldenemies[o].pac_id == theirgraveyard[g].pac_id
                conflict = 1
            end
        end
        if conflict == 0
            if $turn == 1
                oldenemies[o].ability_cooldown = 9
                oldenemies[o].speed_turns_left = 5
                oldenemies[o].hasspeed = 1
            end
            theirpacs = theirpacs.push(oldenemies[o].clone(&:clone))
        end
    end
    theirpacs.length.times do |n|
        if theirpacs[n].lastseen + 2 > $turn
            if theirpacs[n].lastseen == $turn && theirpacs[n].type_id == "ROCK" && theirpacs[n].ability_cooldown > 0
                rows[theirpacs[n].y][theirpacs[n].x] = "R"
            elsif theirpacs[n].lastseen == $turn && theirpacs[n].type_id == "PAPER" && theirpacs[n].ability_cooldown > 0
                rows[theirpacs[n].y][theirpacs[n].x] = "P"
            elsif theirpacs[n].lastseen == $turn && theirpacs[n].type_id == "SCISSORS" && theirpacs[n].ability_cooldown > 0
                rows[theirpacs[n].y][theirpacs[n].x] = "C"
            else
                rows[theirpacs[n].y][theirpacs[n].x] = "E"
            end
        end
    end
    theirpacs = theirpacs.sort_by { |i| i.pac_id}
    if $turn == 0
        $initialpaccount = mypacs.length.to_i
        getpelletcount(rows)
        test = Time.now
        reachamount = reachamount(rows, height, width, mypacs, deadends)
        if $timedebug then STDERR.puts "fftest: #{time_diff_milli(test, Time.now)} " end
        test2 = Time.now
        mysupers = getsuperinfo(rows, mypacs, theirpacs, width)
        mysupers.length.times do |i|
            STDERR.puts "s: #{mysupers[i]} "
        end
        if $timedebug then STDERR.puts "supers: #{time_diff_milli(test2, Time.now)} " end
    end
    if mypacs.length < 3 || $turn == 0then $maxfloodfilltargets = 5 else $maxfloodfilltargets = 3 end
    timestampnaparsing = Time.now
    mypacs.length.times do |i|
        rows = mypacs[i].vision(rows, pellets, 1, 0, width, height)
        rows = mypacs[i].vision(rows, pellets, -1, 0, width, height)
        rows = mypacs[i].vision(rows, pellets, 0, 1, width, height)
        rows = mypacs[i].vision(rows, pellets, 0, -1, width, height)
    end
    pellets.length.times do |i|
        if pellets[i].value == 10
            rows[pellets[i].y][pellets[i].x] = "S"
        else
            rows[pellets[i].y][pellets[i].x] = "o"
        end
    end
    mypacs.length.times do |i|
        rows[mypacs[i].y][mypacs[i].x] = "M"
    end
            # print map
    height.times do |i|
        STDERR.puts rows[i]
    end
    btime = Time.now
	#ptargets = bettertargets(rows, ptargets, mypacs, width, height, oldtargets)
    benched = Benchmark.measure { ptargets = eenteameentaak(rows, ptargets, mypacs, theirpacs, width, height, deadends, reachamount, mysupers) }
                if $timedebug then STDERR.puts "1team1taak(): bm=#{benched.real}ms, Time.now=#{time_diff_milli(btime, Time.now)}" end
    # benched = Benchmark.measure { unseenenemycheck(ptargets, mypacs, rows, positions, oldtargets, width, theirpacs) }
    #             if $timedebug then STDERR.puts "unseenenemy() takes #{benched.real} ms" end
                benched = Time.now
    ptargets = conflict(rows, mypacs, ptargets, width)
                if $timedebug then STDERR.puts "conflict() takes #{time_diff_milli(benched, Time.now)} ms" end
        moveset = Array.new()
        movesettime = Time.now
        benched = Benchmark.measure { moveset = rps(mypacs, ptargets, theirpacs, width, oldpositions_array, positions, rows, deadends, oldtargets) }
                if $timedebug then STDERR.puts "moveset(): bm=#{benched.real}ms Time=#{time_diff_milli(movesettime, Time.now)} " end
        mypacs.length.times do |i|
            debug = [somebody[$turn], ""]
            if i == mypacs.length - 1 then finish = "\n" else finish = "|" end
            if moveset[i][0] == "MOVE"
                if $sing == 0 then debug = [ moveset[i][2], moveset[i][3] ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{moveset[i][3]} #{debug[0]} #{debug[1]} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{moveset[i][3]} #{debug[0]} #{debug[1]} #{finish}"
            elsif moveset[i][0] == "SPEED"
                if $sing == 0 then debug = [ "GO ", "BRRR" ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{debug} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{finish}"
            elsif moveset[i][0] == "SWITCH"
                if $sing == 0 then debug = [ "RPS", "" ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{debug} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{finish}"
            end
            if $printdebug && finish == "\n" then STDERR.puts "withnewline" end
        end
    if $timedebug then STDERR.puts "total runtime including output: #{time_diff_milli(starttime, Time.now)}" end
    $turn += 1
    # STDERR.puts "turn is #{turn}"
    rows = clearmap(rows)
end
