STDOUT.sync = true # DO NOT REMOVE
include Math
require 'time'

# Grab the pellets as fast as you can!
somebody = ["SOME", "BODY", "ONCE", "TOLD", "ME", "THE", "WORLD", "IS", "GONNA", "ROLL", "ME", "I", "AIN'T", "THE", "SHARPEST", "TOOL", "IN", "THE", "SHED", "SHE", "WAS", "LOOKING", "KIND", "OF", "DUMB", "WITH", "HER", "FINGER", "AND", "HER", "THUMB", "IN", "THE", "SHAPE", "OF", "AN", "L", "ON", "HER", "FOREHEAD", "WELL", "THE", "YEARS", "START", "COMING", "AND", "THEY", "DON'T", "STOP", "COMING", "FED", "TO", "THE", "RULES", "AND", "I", "HIT", "THE", "GROUND", "RUNNING", "DIDN'T", "MAKE", "SENSE", "NOT", "TO", "LIVE", "FOR", "FUN", "YOUR", "BRAIN", "GETS", "SMART", "BUT", "YOUR", "HEAD", "GETS", "DUMB", "SO", "MUCH", "TO", "DO", "SO", "MUCH", "TO", "SEE", "SO", "WHAT'S", "WRONG", "WITH", "TAKING", "THE", "BACK", "STREETS", "YOU'LL", "NEVER", "KNOW", "IF", "YOU", "DON'T", "GO", "YOU'LL", "NEVER", 
"SHINE", "IF", "YOU", "DON'T", "GLOW", "HEY", "NOW", "YOU'RE", "AN", "ALL", "STAR", "GET", "YOUR", "GAME", "ON", "GO", "PLAY", "HEY", "NOW", "YOU'RE", "A", "ROCK", "STAR", "GET", "THE", "SHOW", "ON", "GET", "PAID", "AND", "ALL", "THAT", "GLITTERS", "IS", "GOLD","ONLY", "SHOOTING", "STARS", "BREAK", "THE", "MOLD", "IT'S", "A", "COOL", "PLACE", "AND", "THEY", "SAY", "IT", "GETS", "COLDER", "YOU'RE", "BUNDLED", "UP", "NOW", "WAIT", "TILL", "YOU", "GET", "OLDER", "BUT", "THE", "METEOR", "MEN", "BEG", "TO", "DIFFER", "JUDG-", "ING", "BY", "THE", "HOLE", "IN", "THE", "SA", "TEL", "LITE", "PIC", "TURE", "THE", "ICE", "WE", "SKATE", "IS", "GETTING", "PRETTY", "THIN", "THE", "WATER'S", "GETTING", "WARM", "SO", "YOU", "MIGHT", "AS", "WELL", "SWIM", "MY", "WORLD'S", "ON", "FIRE", "HOW", "ABOUT", "YOURS"]
$timedebug = false
$movedebug = false
$targetdebug = true
$printdebug = false
$conflictdebug = true
$getstime = false
$debug = 0
$speed = 0
$turn = 0
$extra = 0
$openside = 0
$superpelletsleft = 0
$megadebug = 0
$honeypotsleft = 0
$sing = 0

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
    if deadends[enemypac.y][enemypac.x] == "D"
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
def rps(mypacs, ptargets, theirpacs, width, oldpositions_array, positions, rows, deadends)
    # enemynear(rows.clone.map(&:clone), goal[0], goal[1], 0, maxcheck, width)
    moveset = Array.new(mypacs.length)
    mypacs.length.times do |i|
        threatened = 0
        moveset[i] = ["MOVE", mypacs[i].pac_id, ptargets[i][0].goto[0], ptargets[i][0].goto[1]]
        if ptargets[i][0].origin == "directvision" && ptargets[i][0].distance > (width / 2).to_i
            moveset[i] = ["MOVE", mypacs[i].pac_id, ptargets[i][0].goto[0], ptargets[i][0].goto[1]]
            if $movedebug then STDERR.puts "directvision too far, setting target from #{ptargets[i][0].x}, #{ptargets[i][0].y} to #{ptargets[i][0].goto} " end
        end
        # if $movedebug then STDERR.puts "moveset[#{i}] = #{moveset[i]}" end
        if $movedebug then STDERR.puts "i=#{i}, moveset[i] = #{moveset[i]}, targets [#{ptargets[i][0].x}, #{ptargets[i][0].y}]" end
        theirpacs.length.times do |n|
            afstand = afstand( [mypacs[i].x, mypacs[i].y], [theirpacs[n].x, theirpacs[n].y], width)
            if afstand < 3 then afstand = getrealdistance(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, [theirpacs[n].x, theirpacs[n].y], 0, width) end
            next if (theirpacs[n].lastseen + 3 < $turn || afstand > 8)
            
            if $movedebug then STDERR.puts "mine=#{mypacs[i].pac_id}&theirs=#{theirpacs[n].pac_id}, afstand = #{afstand}, threatened=#{threatened} myac=#{mypacs[i].ability_cooldown}&theirac=#{theirpacs[n].ability_cooldown}  " end
            # if $movedebug then STDERR.puts "id=#{mypacs[i].pac_id} (#{mypacs[i].type_id}) ac=#{mypacs[i].ability_cooldown}&stl=#{mypacs[i].speed_turns_left}, afstand to theirs[#{theirpacs[n].pac_id}] (#{theirpacs[n].type_id}) = #{afstand} " end
            if ((afstand == 1 && matchup(mypacs[i], theirpacs[n]) == "win") || (afstand <= 2 && matchup(mypacs[i], theirpacs[n]) == "draw")) && theirpacs[n].abcdtimerlastturn == 1 && theirpacs[n].ability_cooldown == 0 && theirpacs[n].lastseen == $turn && mypacs[i].ability_cooldown == 0
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
            end
            if ((afstand == 1 && theirpacs[n].hasspeed == 0) || afstand <= 2 && mypacs[i].hasspeed == 1) && matchup(mypacs[i], theirpacs[n]) == "win" && theirpacs[n].lastseen == $turn && theirpacs[n].ability_cooldown > 0 # maybe try to attack also on turn 0?
                # i can take his piece if i move into his current pos and he stands still (to speed maybe)
                moveset[i] = ["MOVE", mypacs[i].pac_id, theirpacs[n].x, theirpacs[n].y]
                if $movedebug then STDERR.puts "pac[#{mypacs[i].pac_id}] attacks enemy #{theirpacs[n].pac_id}" end
            end
            if $movedebug then STDERR.puts "sneak if #{matchup(mypacs[i], theirpacs[n])} == win && (#{mypacs[i].lastseen} >= #{max($turn - 2, 0)} || #{deadends[theirpacs[n].y][theirpacs[n].x]} == D) && #{theirpacs[n].ability_cooldown} > 0" end
            # if matchup(mypacs[i], theirpacs[n]) == "win" && (mypacs[i].lastseen >= max($turn - 2, 0) || deadends[theirpacs[n].y][theirpacs[n].x] == "D") && theirpacs[n].ability_cooldown > 0
            #     # ive not been spotted but im close to him or he's in a deadend
            #     moveset[i] = ["MOVE", mypacs[i].pac_id, theirpacs[n].x, theirpacs[n].y]
            #     if $movedebug then STDERR.puts "pac#{mypacs[i].pac_id} sneak attack on N#{theirpacs[n].pac_id} " end
            # end

            if afstand < 5 && matchup(mypacs[i], theirpacs[n]) == "lose" && theirpacs[n].lastseen + 3 > $turn then threatened = 1 end
            if $movedebug then STDERR.puts "switch if #{matchup(mypacs[i], theirpacs[n])}==lose, myls:#{mypacs[i].lastseen}, enls:#{theirpacs[n].lastseen}, threat=#{threatened}. #{afstand} <= #{1 + theirpacs[n].hasspeed}" end
            if mypacs[i].lastseen == 0 && theirpacs[n].lastseen == $turn && matchup(mypacs[i], theirpacs[n]) == "lose" && afstand <= 1 + theirpacs[n].hasspeed && mypacs[i].ability_cooldown == 0
                # He cant see me right now, but he can move to my position and kill me, so I have to switch (or speed away maybe)
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
                if $movedebug then STDERR.puts "SWITCH! he cant see me  " end
            elsif mypacs[i].lastseen == 1 && theirpacs[n].lastseen == $turn && matchup(mypacs[i], theirpacs[n]) == "lose" && afstand <= 1 + theirpacs[n].hasspeed && mypacs[i].ability_cooldown == 0
                # We both see each other, on this turn he can move and take my pac
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
                if $movedebug then STDERR.puts "SWITCH! he bout to snap me but sikes  " end
            elsif $turn == 0 && afstand == 2 && matchup(mypacs[i], theirpacs[n]) == "lose" && ptargets[i][0].distance == 1 && afstand( [theirpacs[n].x, theirpacs[n].y], ptargets[i][0].goto, width) == 1
                # spawned on the other side of my target (superpellet) from my counterenemy
                threatened = 1
                moveset[i] = ["SWITCH", mypacs[i].pac_id, getcounter(theirpacs[n])]
            end
            

            if theirpacs[n].lastseen + 2 <= $turn && afstand < 4 && matchup(mypacs[i], theirpacs[n]) == "win" && istrapped(deadends, theirpacs[n], mypacs) == 1 && ptargets[i][0].goalvalue == 0
                # possible to trap and kill their unit (not if current target is a superpellet)
                moveset[i] = ["MOVE", mypacs[i].pac_id, theirpacs[n].x, theirpacs[n].y]
                if $movedebug then STDERR.puts "pac[#{mypacs[i].pac_id}] can trap theirpac[#{theirpacs[n].pac_id}]" end
            end
            if $movedebug then STDERR.puts "i=#{mypacs[i].pac_id}, after checking enemy[#{theirpacs[n].pac_id}], move = #{moveset[i]}  " end
        end
        if threatened == 0 && mypacs[i].ability_cooldown == 0
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
    t.distance = afstand(r, [mypacs[i].x, mypacs[i].y], width)
    t.manhattan = t.distance
    return t
end
def conflict(rows, mypacs, ptargets, width)
    conflicts = 1
    counter = 0
    t1 = Time.now
    while conflicts > 0 && counter < 8
        conflicts = 0
        counter += 1
        # STDERR.puts "conflictcounter = #{counter}"
        mypacs.length.times do |i|
            mypacs.length.times do |n|
                if i != n && ptargets[i][0].goto == ptargets[n][0].goto
                    if ptargets[i][0].value < ptargets[n][0].value || (i > n && ptargets[i][0].value == ptargets[n][0].value)
                        #i's value is lower so seek new target
                        STDERR.puts "rm ptargets[#{i}][0] and move to last. ptars = #{ptargets[i][0]}"
                        ptargets[i].insert(-1, ptargets[i].delete_at(0))
                        STDERR.puts "prev first should now be moved to last. ptars = #{ptargets[i][0]}"
                    end
                end
            end
        end
    end
    if $timedebug then STDERR.puts "conflict runtime = #{time_diff_milli(t1, Time.now)}" end
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
        STDERR.puts "i=#{mypacs[i].pac_id}.unseen en if: #{stuckfor(positions, oldtargets, i, mypacs)} >= 1 && #{stuckwithteammate(mypacs, ptargets, i, width)} == 0 "
        if stuckfor(positions, oldtargets, i, mypacs) >= 1 && stuckwithteammate(mypacs, ptargets, i, width) == 0
            saveenemy(theirpacs, ptargets[i][0].gotohalf, mypacs[i].type_id, width, rows)
        end
    end

end
def hidesuperpellets(rows)
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "S"
                rows[h][w] = " "
            elsif rows[h][w] == "E"
                rows[h][w] = " "
            elsif rows[h][w] == "-"
                rows[h][w] = " "
            end
        end
    end
    return rows
end
def collecttargets(left, right, up, down, currenttile, steps, currentpac)
	arr = Array.new
	if left != nil && left.instance_of?(Target) && left.origin != "wall" then arr.push(left) end
	if left != nil && left.instance_of?(Array) then arr.push(*left) end
	if right != nil && right.instance_of?(Target) && right.origin != "wall" then arr.push(right) end
	if right != nil && right.instance_of?(Array) then arr.push(*right) end
	if up != nil && up.instance_of?(Target) && up.origin != "wall" then arr.push(up) end
	if up != nil && up.instance_of?(Array) then arr.push(*up) end
	if down != nil && down.instance_of?(Target) && down.origin != "wall" then arr.push(down) end
	if down != nil && down.instance_of?(Array) then arr.push(*down) end
    if currenttile != nil && currenttile.instance_of?(Target) then arr.push(currenttile) end

    if steps == 1
        arr.each { |i| i.gotohalf = [currenttile.x, currenttile.y] }
        if currentpac.hasspeed == 0
            arr.each { |i| i.goto = [currenttile.x, currenttile.y] }
        end
    end
    if steps == 2 && currentpac.hasspeed == 1
        arr.each { |i| i.goto = [currenttile.x, currenttile.y] }
    end
    # if $targetdebug && $turn == 83 && currenttile.x == 25 && currenttile.y == 7 then arr.each { |t| STDERR.puts "#{currentpac.pac_id}: #{t.x},#{t.y} d=#{t.distance} v=#{t.value}, o=#{t.origin}  " } end
    # if $targetdebug && $turn == 83 && currenttile.x == 25 && currenttile.y == 7 then STDERR.puts "right = #{right}" end
	return arr
end

def eenfloodfillperpac(rows, x, y, steps, value, width, currentpac, deadends)
    if y < 0 || x < 0 || !rows[y][x]
        # if y < 0 || x < 0 || !rows[y][x] || steps > 15 + $extra || steps + afstand([x, y], goal, width) > 10 + goalvalue + extravalue
        # if ($megadebug == 1 || $megadebug == true) && rows[y][x] != "#" then STDERR.puts "x=#{x},y=#{y}, goal=#{goal}, steps=#{steps}, steps+afstand=#{steps} + #{afstand([x, y], goal, width)} >? #{10} + #{goalvalue} + #{extravalue} " end
        return Target.new(:origin => "wall")
	elsif rows[y][x] == "#" || rows[y][x] == "X" || (rows[y][x] == "M" && steps != 0) || rows[y][x] == "E" || steps > 13 + $extra
        # if $megadebug == 1 then STDERR.puts "=M, x=#{x},y=#{y}, goal=#{goal}, steps=#{steps}, steps+afstand=#{steps} + #{afstand([x, y], goal, width)} >? #{10} + #{goalvalue} + #{$extra} " end
		return Target.new(:origin => "wall")
		# ret steps value x y gotox gotoy gotohalfx gotohalfy
    end
    if rows[y][x] == "o" || rows[y][x] == "S" || rows[y][x] == "." || rows[y][x] == "T" || rows[y][x] == "H"
        tilevalue = 1
        if rows[y][x] == "." || rows[y][x] == "T" || rows[y][x] == "H" then tilevalue -= 0.2 end
        if rows[y][x] == "S" then tilevalue += 9 end
        # if deadends[y][x] == "D"
        #     tilevalue /= 2
        # end
        tilevalue = tilevalue.to_f * ( (13 + $extra + 1 - steps).to_f / (13 + $extra).to_f)
        value = value.to_f + tilevalue.to_f
    end
#    STDERR.puts "steps = #{steps} and position: [#{x}, #{y}]"
	rows[y][x] = "X"
    if steps > 0
    	currenttile = Target.new(:distance => steps, :value => value, :ratio => value / steps, :x => x, :y => y, :goto => [x, y], :gotohalf => [x, y], :origin => "floodfill", :pacid => currentpac.pac_id, :floodfillneed => 0, :manhattan => afstand( [currentpac.x, currentpac.y], [x, y], width))
        # if steps > 10 && $movedebug then STDERR.puts "ct: xy=#{currenttile.x},#{currenttile.y}. dist=#{currenttile.distance}, val=#{currenttile.value}, ratio=#{currenttile.ratio} " end
    end
    if x == 0
        left = eenfloodfillperpac(rows.clone.map(&:clone), width - 1, y, steps + 1, value, width, currentpac, deadends)
    else
        left = eenfloodfillperpac(rows.clone.map(&:clone), x - 1, y, steps + 1, value, width, currentpac, deadends)
    end
    if x == width - 1
        right = eenfloodfillperpac(rows.clone.map(&:clone), 0, y, steps + 1, value, width, currentpac, deadends)
    else
        right = eenfloodfillperpac(rows.clone.map(&:clone), x + 1, y, steps + 1, value, width, currentpac, deadends)
    end
    up = eenfloodfillperpac(rows.clone.map(&:clone), x, y - 1, steps + 1, value, width, currentpac, deadends)
    down = eenfloodfillperpac(rows.clone.map(&:clone), x, y + 1, steps + 1, value, width, currentpac, deadends)
    return collecttargets(left, right, up, down, currenttile, steps, currentpac)
end

def eenteameentaak(rows, ptargets, mypacs, width, height, deadends)
	mypacs.length.times do |i|
        time1 = Time.now
		ptargets[i] = eenfloodfillperpac(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, 0, 0, width, mypacs[i], deadends)
        time2 = Time.now
		ptargets[i] = ptargets[i].sort_by! {|a| a.value}.reverse
        if ptargets[i].length > 15 then ptargets[i] = ptargets[i].slice(0, 15) end
        if ptargets[i].length > 0 && ptargets[i][0].value == 0.0 then STDERR.puts "something wong, highest value = 0" end
        if ptargets[i].length == 0 then ptargets[i][0] = Target.new(:x => mypacs[i].x, :y => mypacs[i].y, :distance => 0, :manhattan => 0, :pacid => mypacs[i].pac_id, :value => 0, :ratio => 0, :goto => [mypacs[i].x, mypacs[i].y], :gotohalf => [mypacs[i].x, mypacs[i].y], :origin => "self" ) end
        # if ptargets[i].length == 0 then ptargets[i] = end
        time3 = Time.now
        # STDERR.puts "turn = #{$turn}"
        if $timedebug then STDERR.puts "ff voor pac#{mypacs[i].pac_id} took #{time_diff_milli(time1, time2)}ms and sorting the array took #{time_diff_milli(time2, time3)}ms " end
		if $targetdebug then ptargets[i][0].puts(mypacs[i].x, mypacs[i].y) end
        if $targetdebug
            # ptargets[i].each { |t| STDERR.puts "#{i}->#{t.x},#{t.y} val: #{t.value} d=#{t.distance} " }
        end
        # if $targetdebug then STDERR.puts "pac#{mypacs[i].pac_id} len=#{ptargets[i].length} -> #{ptargets[i]} " end
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
def enemynear(rows, x, y, steps, maxcheck, width)
    value = 0
    if y == nil || x == nil || rows == nil || rows[y][x] == nil
        return 30
    end
    if y < 0 || x < 0 || !rows[y][x] || steps > maxcheck
        return 30
    elsif rows[y][x] == "#" || rows[y][x] == "X"
        return 30
    end
    if rows[y][x] == "E"
        return steps
    end
    rows[y][x] = "X"
    if x == 0
        left = enemynear(rows.clone.map(&:clone), width - 1, y, steps + 1, maxcheck, width)
    else
        left = enemynear(rows.clone.map(&:clone), x - 1, y, steps + 1, maxcheck, width)
    end
    if x == width - 1
        right = enemynear(rows.clone.map(&:clone), 0, y, steps + 1, maxcheck, width)
    else
        right = enemynear(rows.clone.map(&:clone), x + 1, y, steps + 1, maxcheck, width)
    end
    up = enemynear(rows.clone.map(&:clone), x, y - 1, steps + 1, maxcheck, width)
    down = enemynear(rows.clone.map(&:clone), x, y + 1, steps + 1, maxcheck, width)
    # STDERR.puts "returning left=#{left} right=#{right} up=#{up} down=#{down}"
    return [left, right, up, down].min
end
def honeypot(rows, x, y, steps, width)
    # STDERR.puts "honeypotting: x=#{x},y=#{y}"
    value = 0
    if y < 0 || x < 0 || !rows[y][x]
        return 0
    elsif rows[y][x] == "#" || rows[y][x] == "X"
        return 0
    end
    if (rows[y][x] == "o" || rows[y][x] == ".") && steps != 2
        value += 1
    elsif rows[y][x] == "E"
        value -= 2
    end
    if steps == 0
        return value
    end
    rows[y][x] = "X"
    if x == 0
        left = honeypot(rows.clone.map(&:clone), width - 1, y, steps - 1, width)
    else
        left = honeypot(rows.clone.map(&:clone), x - 1, y, steps - 1, width)
    end
    if x == width - 1
        right = honeypot(rows.clone.map(&:clone), 0, y, steps - 1, width)
    else
        right = honeypot(rows.clone.map(&:clone), x + 1, y, steps - 1, width)
    end
    up = honeypot(rows.clone.map(&:clone), x, y - 1, steps - 1, width)
    down = honeypot(rows.clone.map(&:clone), x, y + 1, steps - 1, width)
    # STDERR.puts "returning left=#{left} right=#{right} up=#{up} down=#{down}"
    return value + left + right + up + down
end

def sethoneypots(rows, width)
    rows.length.times do |h|
        rows[h].length.times do |w|
            res = 0
            if rows[h][w] == "."
                res = honeypot(rows.clone.map(&:clone), w, h, 2, width)
            end
            if res >= 6
                rows[h][w] = "T"
            elsif res >= 5
                rows[h][w] = "H"
            end
        end
    end
    return rows
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
            if rows[tmpy][tmpx] == "E"
                lastseen = 1
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
    attr_accessor :x, :y, :distance, :value, :ratio, :pacid, :eff, :manhattan, :floodfillneed, :origin, :goto, :gotohalf, :deadend, :goalvalue
    def initialize(x: 0, y: 0, distance: 10, value: 0, ratio: 0, pacid: 0, eff: 0, manhattan: 0, goalvalue: 0, floodfillneed: 1, origin: "default", goto: 0, gotohalf: 0)
        @x = x
        @y = y
        @distance = distance
        @value = value
        @ratio = ratio
        @pacid = pacid
        @eff = eff
        @manhattan = manhattan
        @goalvalue = goalvalue
        @floodfillneed = floodfillneed
        @origin = origin
        @goto = goto
        @gotohalf = gotohalf
    end
    def print(posx, posy)
        STDERR.print "pac[#{pacid}] --> [#{x}, #{y}], goto = #{goto}, val= #{value}, origin = #{origin}, dist = #{distance}, mh = #{manhattan}, ffneed=#{floodfillneed} | "
        # STDERR.puts "x:#{x}, y:#{y}, distance:#{distance}, value#{value}, ratio: #{ratio}, pacid: #{pacid}, goto: #{goto}, manhattan: #{manhattan}, eff: #{eff}, orig: #{origin}"
    end
    def puts(posx, posy)
        STDERR.puts "pac[#{pacid}] --> [#{x}, #{y}], goto = #{goto}, val= #{value}, origin = #{origin}, dist = #{distance}, mh = #{manhattan}, ffneed=#{floodfillneed} | "
        # STDERR.puts "x:#{x}, y:#{y}, distance:#{distance}, value#{value}, ratio: #{ratio}, pacid: #{pacid}, goto: #{goto}, manhattan: #{manhattan}, eff: #{eff}, orig: #{origin}"
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
    if tile == "D" || tile == "#" || tile == "M"
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
    end
end

# width: size of the grid
# height: top left corner is (x=0, y=0)
width, height = gets.split(" ").collect {|x| x.to_i}
rows = Array.new
ogdeadends = Array.new
height.times do
    row = gets.chomp # one line of the grid: space " " is floor, pound "#" is wall
    if row[0] == " " || row[0] == "."
        $openside = 1
    end    
    deadrow = row.clone(&:clone)
    row = findandreplace(row, " ", ".")
    rows = rows.push(row)
    ogdeadends = ogdeadends.push(deadrow)
end

ogdeadends.length.times do |h|
    # STDERR.puts "#{deadends[h]}"
    ogdeadends[h].length.times do |w|
        if w < 4 && h > 8 then $crackdebug = true else $crackdebug = false end
        if ogdeadends[h][w] != "#"
            checkdeadends(ogdeadends, w, h, width, height)
        end
    end
end

oldpositions_array = Array.new
positions = Array.new
theirunseens = Array.new
theirpacs = Array.new
ptargets = Array.new

# game loop
loop do
    $ffcounter = 0
    $enemynearcount = 0
    $enemyneartime = 0
    $maxfloodfilltargets = 3
    pactime2 = 0
    pellettime2 = 0
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
    $honeypotsleft = 0
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "T" || rows[h][w] == "H" then $honeypotsleft += 1 end
            if rows[h][w] == "E" && $turn > 2
                rows[h][w] = " "
            end
            if rows[h][w] == "M"
                rows[h][w] = " "
            end
        end
    end
    # oldpositions_array.length.times do |a|
    #     STDERR.puts "oldposarra[#{a}] is #{oldpositions_array[a]}"
    # end
#    oldpositions = positions.map(&:clone)
    positions = Array.new
    scoretime = Time.now
    my_score, opponent_score = gets.split(" ").collect {|x| x.to_i}
    visible_pac_count = gets.to_i # all your pacs and enemy pacs in sight
    if $getstime then STDERR.puts "first 2 gets calls take #{time_diff_milli(scoretime, Time.now)} " end
    starttime = Time.now
    $starttime = starttime
    visible_pac_count.times do
        pac = Pac.new()
        # pac_id: pac number (unique within a team)
        # mine: true if this pac is yours
        # x: position in the grid
        # y: position in the grid
        # type_id: unused in wood leagues
        # speed_turns_left: unused in wood leagues
        # ability_cooldown: unused in wood leagues
        pactime = Time.now
        pac_id, mine, x, y, type_id, speed_turns_left, ability_cooldown = gets.split(" ")
        pactime2 += time_diff_milli(pactime, Time.now)
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
    deadends = Array.new
    deadends = ogdeadends.clone.map(&:clone)
    theirpacs.length.times do |n|
        if theirpacs[n].lastseen + 2 > $turn then checkdeadends(ogdeadends, theirpacs[n].x, theirpacs[n].y, width, height) end
    end
    STDERR.puts "deadends including enemies"
    deadends.length.times do |h|
        STDERR.puts deadends[h]
    end
    $seenenemies = theirpacs.length
        if $getstime then STDERR.puts "gets calls for pacs take #{pactime2} " end
    if $turn == 0 || ($turn > 10 && mypacs.length < 3) then $extra = 5 - mypacs.length else $extra = 0 end
    # if $extra == 5 && $turn > 50 then $megadebug = 1 else $megadebug = 0 end
    $megadebug = 0
    # STDERR.puts "$extra = #{$extra}, $turn = #{$turn}, $megadebug = #{$megadebug} "
    oldtargets = Array.new
    if $turn == 0
        mypacs.length.times do |i|
            oldtargets[i] = Target.new(:x => mypacs[i].x, :y => mypacs[i].y, :distance => 0, :goto => [mypacs[i].x, mypacs[i].y], :gotohalf => [mypacs[i].x, mypacs[i].y], :origin => "original location", :value => 1, :ratio => 0, :manhattan => 0)
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
        pellettime = Time.now
        pellet.x, pellet.y, pellet.value = gets.split(" ").collect {|x| x.to_i}
        pellettime2 += time_diff_milli(pellettime, Time.now)
        if pellet.value == 10
            $superpelletsleft += 1
            rows[pellet.y][pellet.x] = "S"
        end
        pellets = pellets.push(pellet)
    end
    if $getstime then STDERR.puts "gets calls for pellets take #{pellettime2} " end
    if $turn == 0
        $initialpaccount = mypacs.length.to_i
    end
    if theirgraveyard.length == nil then tgyl = 0 else tgyl = theirgraveyard.length end
    theirpacs.length.times do |i|
        rows[theirpacs[i].y][theirpacs[i].x] = "E"
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

    theirpacs = theirpacs.sort_by { |i| i.pac_id}
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
    # if $turn == 0
    #     rows = sethoneypots(rows, width)
    # end
    mypacs.length.times do |i|
        rows[mypacs[i].y][mypacs[i].x] = "M"
    end
            # print map
    height.times do |i|
        STDERR.puts rows[i]
    end
    #filtertime = Time.now

    #            if $timedebug then STDERR.puts "filtertargets takes: #{time_diff_milli(filtertime, Time.now)}ms" end
    btime = Time.now
    $btime = btime
	#ptargets = bettertargets(rows, ptargets, mypacs, width, height, oldtargets)
	ptargets = eenteameentaak(rows, ptargets, mypacs, width, height, deadends)
                if $timedebug then STDERR.puts "eenteameentaak takes: #{time_diff_milli(btime, Time.now)}"end
                # if $timedebug && $enemynearcount > 0 then STDERR.puts "#{$enemynearcount} enemynear() calls took #{$enemyneartime}ms avg=#{$enemyneartime / $enemynearcount}" end
    unseenenemycheck(ptargets, mypacs, rows, positions, oldtargets, width, theirpacs)
    confltime = Time.now
    ptargets = conflict(rows, mypacs, ptargets, width)
                # STDERR.puts "after conflict() ptars[1] = #{ptargets[1]}"
                if $timedebug then STDERR.puts "total runtime including conflict(): #{time_diff_milli(confltime, Time.now)}" end
        moveset = Array.new()
    movesettime = Time.now
        moveset = rps(mypacs, ptargets, theirpacs, width, oldpositions_array, positions, rows, deadends)
                if $timedebug then STDERR.puts "rps() takes #{time_diff_milli(movesettime, Time.now)}ms" end
        # STDERR.puts  "mypacs.len = #{mypacs.length}, moveset after () = #{moveset}"
        mypacs.length.times do |i|
            debug = [somebody[$turn], ""]
            if i == mypacs.length - 1 then finish = "\n" else finish = "|" end
            if moveset[i][0] == "MOVE"
                if $sing == 0 then debug = [ moveset[i][2], moveset[i][3] ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{moveset[i][3]} #{debug[0]} #{debug[1]} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{moveset[i][3]} #{debug[0]} #{debug[1]} #{finish}"
            elsif moveset[i][0] == "SPEED"
                if $sing == 0 then debug = [ "GO ", "BRRR" ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{finish}"
            elsif moveset[i][0] == "SWITCH"
                if $sing == 0 then debug = [ "RPS", "" ] end
                if $printdebug then STDERR.print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{finish}" end
                print "#{moveset[i][0]} #{moveset[i][1]} #{moveset[i][2]} #{finish}"
            end
            if $printdebug && finish == "\n" then STDERR.puts "withnewline" end
        end
    if $timedebug then STDERR.puts "total runtime including output: #{time_diff_milli(starttime, Time.now)}" end
    $turn += 1
    # STDERR.puts "turn is #{turn}"
    rows = hidesuperpellets(rows)
end
