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
$conflictdebug = false
$getstime = false
$debug = 0
$speed = 0
$turn = 0
$extra = 0
$openside = 0
$superpelletsleft = 0
$megadebug = 0
$honeypotsleft = 0
$sing = 1

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
        moveset[i] = ["MOVE", mypacs[i].pac_id, ptargets[i][0].x, ptargets[i][0].y]
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
            if $movedebug then STDERR.puts "flee if #{afstand} <= 3 + #{theirpacs[n].hasspeed} && matchup = #{matchup(mypacs[i], theirpacs[n])} && #{theirpacs[n].lastseen }+2 >= #{$turn} && ab.cd = #{mypacs[i].ability_cooldown} " end
            if afstand <= 3 + theirpacs[n].hasspeed && matchup(mypacs[i], theirpacs[n]) == "lose" && theirpacs[n].lastseen + 2 >= $turn && mypacs[i].ability_cooldown > 0
                threatened = 1
                # cant switch, gotta run
                flee = [mypacs[i].x, mypacs[i].y]
                threatened = 1
                lastpos = getlastposition(positions, oldpositions_array, i)
                if afstand(lastpos, [theirpacs[n].x, theirpacs[n].y], width) > afstand(lastpos, [mypacs[i].x, mypacs[i].y], width)
                    flee = lastpos
                    STDERR.puts "lastpos is further away! #{flee} "
                end
                STDERR.puts "need new target: #{ptargets[i]}"
                found = 0
                ptargets[i].length.times do |t|
                    if $movedebug then STDERR.puts "checking if #{afstand([ptargets[i][t].x, ptargets[i][t].y], [theirpacs[n].x, theirpacs[n].y], width)} > #{afstand([ptargets[i][t].x, ptargets[i][t].y], [mypacs[i].x, mypacs[i].y], width)}" end
                    if $movedebug then STDERR.puts "checking if afstand([#{ptargets[i][t].x}, #{ptargets[i][t].y}], [#{theirpacs[n].x}, #{theirpacs[n].y}], #{width}) > afstand([#{ptargets[i][t].x}, #{ptargets[i][t].y}], [#{mypacs[i].x}, #{mypacs[i].y}], #{width})" end
                    if afstand([ptargets[i][t].x, ptargets[i][t].y], [theirpacs[n].x, theirpacs[n].y], width) > afstand([ptargets[i][t].x, ptargets[i][t].y], [mypacs[i].x, mypacs[i].y], width)
                        flee = [ptargets[i][t].x, ptargets[i][t].y]
                        ptargets[i].unshift(ptargets[i][t])
                        found = 1
                        STDERR.puts "ptargets[i][#{t}] is further away! #{flee} "
                        break
                    end
                end
                tries = 0
                while found == 0 && tries < 8
                    rtar = getrandomtarget(rows, mypacs, i, width)
                    tries += 1
                    if afstand([rtar.x, rtar.y], [theirpacs[n].x, theirpacs[n].y], width) > afstand([rtar.x, rtar.y], [mypacs[i].x, mypacs[i].y], width)
                        found = 1
                        flee = [rtar.x, rtar.y]
                        ptargets[i][0] = rtar
                        STDERR.puts "random target is further away! #{flee} "
                    end
                end
                moveset[i] = ["MOVE", mypacs[i].pac_id, flee[0], flee[1]]
                if $movedebug then STDERR.puts "pac[#{mypacs[i].pac_id}]'s ability is on cooldown, gotta flee to #{flee}" end
            end
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
def itooclosetontarget(target1, pos1, target2, pos2, width, tooclose)
    if target1.value > 10
        return 0
    end
    currentdist = afstand( [pos1.x, pos1.y], [pos2.x, pos2.y], width)
    if currentdist > 6
        return 0
    end
    if afstand( [target1.x, target1.y], [target2.x, target2.y], width ) < tooclose
        if $conflictdebug then STDERR.puts "if1: #{afstand( [target1.x, target1.y], [target2.x, target2.y], width )} < #{tooclose}" end
        return 1
    elsif afstand( [target1.x,target1.y], target2.goto, width) < currentdist
        if $conflictdebug then STDERR.puts "if2: #{afstand( [target1.x,target1.y], target2.goto, width)} < #{currentdist}  " end
        return 1
    elsif afstand( [target1.x,target1.y], [pos2.x, pos2.y], width ) < afstand( [pos1.x, pos1.y], [pos2.x, pos2.y], width)
        if $conflictdebug then STDERR.puts "if3: #{afstand( [target1.x,target1.y], [pos2.x, pos2.y], width )} < #{currentdist} " end
        return 1
    end
    return 0
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
                if i != n
                    idist = afstand( [mypacs[i].x, mypacs[i].y], [ptargets[i][0].x, ptargets[i][0].y], width )
                    ndist = afstand( [mypacs[n].x, mypacs[n].y], [ptargets[i][0].x, ptargets[i][0].y], width )
                    itar = [ptargets[i][0].x, ptargets[i][0].y]
                    ntar = [ptargets[n][0].x, ptargets[n][0].y]
                    # if $conflictdebug then STDERR.puts "i=#{i} targets #{ptargets[i][0].x},#{ptargets[i][0].y}  & n=#{n} targets #{ptargets[n][0].x},#{ptargets[n][0].y} " end
                    # if $conflictdebug then STDERR.puts "#{ptargets[i][0].x} == #{ptargets[n][0].x} && #{ptargets[i][0].y} == #{ptargets[n][0].y}} && (#{idist > ndist} || #{(idist == ndist && mypacs[i].pac_id < mypacs[n].pac_id)})" end
                    if itar == ntar && (idist > ndist || (idist == ndist && mypacs[i].pac_id < mypacs[n].pac_id))
                        # same target, i should find a new one
                        conflicts += 1
                        currentconflict = 1
                        while currentconflict == 1
                            rtarg = Target.new
                            rtarg = getrandomtarget(rows, mypacs, i, width)
                            rtarg.goto = [rtarg.x, rtarg.y]
                            rtarg.goalvalue = 0
                            rtarg.gotohalf = [rtarg.x, rtarg.y]
                            if ptargets[i].length > 1 then ptargets[i] = ptargets[i].slice(1..-1) else ptargets[i][0] = rtarg end
                            currentconflict = itooclosetontarget(ptargets[i][0], mypacs[i], ptargets[n][0], mypacs[n], width, 3)
                        end
                        if $conflictdebug then STDERR.puts "i#{i}&#{n} same target: id=#{mypacs[i].pac_id}'s targets = #{ptargets[i]}" end

                    elsif itar != ntar && (ptargets[i][0].goto == ptargets[n][0].goto || ptargets[i][0].gotohalf == ptargets[n][0].gotohalf || ptargets[i][0].goto == ptargets[n][0].gotohalf || ptargets[i][0].gotohalf == ptargets[n][0].goto)
                        # they would cross paths
                        conflicts += 1
                        rtarg = Target.new
                        rtarg = getrandomtarget(rows, mypacs, i, width)
                        rtarg.goto = [rtarg.x, rtarg.y]
                        rtarg.goalvalue = 0
                        rtarg.gotohalf = [rtarg.x, rtarg.y]
                        if ptargets[i].length > 1 then ptargets[i] = ptargets[i].slice(1..-1) else ptargets[i][0] = rtarg end
                        if $conflictdebug then STDERR.puts "i#{i}&n#{n} would cross paths: id=#{mypacs[i].pac_id}'s targets = #{ptargets[i]}" end

                    elsif itooclosetontarget(ptargets[i][0], mypacs[i], ptargets[n][0], mypacs[n], width, 3) == 1
                        # I's target is too close to n's goto / I's goto gets him closer to N('s goto)
                        currentconflict = 1
                        while currentconflict == 1
                            rtarg = Target.new
                            rtarg = getrandomtarget(rows, mypacs, i, width)
                            rtarg.goalvalue = 0
                            rtarg.goto = [rtarg.x, rtarg.y]
                            rtarg.gotohalf = [rtarg.x, rtarg.y]
                            if ptargets[i].length > 1 then ptargets[i] = ptargets[i].slice(1..-1) else ptargets[i][0] = rtarg end
                            currentconflict = itooclosetontarget(ptargets[i][0], mypacs[i], ptargets[n][0], mypacs[n], width, 3)
                            if $conflictdebug then STDERR.puts "i's goto too close to ngoto (#{ptargets[n][0].goto}): id=#{mypacs[i].pac_id}'s targets = #{ptargets[i]}" end
                        end
                    end
                end
            end
        end
    end
    if $timedebug then STDERR.puts "conflict runtime = #{time_diff_milli(t1, Time.now)}" end
    return ptargets
end
def stuckwithteammate(mypacs, ptargets, i, width)
    ptargets[i][0].gotohalf
    mypacs.length.times do |t|
        if i != t && afstand(ptargets[i][0].gotohalf, [mypacs[t].x, mypacs[t].y], width ) == 1
            return 1
        end
    end
    return 0
end
def saveenemy(theirpacs, stucktile, typeid, width)
    nsaved = -1
    refdist = 30
    theirpacs.length.times do |n|
        checkdist = afstand(stucktile, [theirpacs[n].x, theirpacs[n].y], width)
        if theirpacs[n].type_id == typeid && theirpacs[n].lastseen != $turn && checkdist < refdist
            refdist = checkdist
            nsaved = n
        end
    end
    if nsaved != -1
        theirpacs[nsaved].x = stucktile[0]
        theirpacs[nsaved].y = stucktile[1]
        theirpacs[nsaved].lastseen = $turn
    end
end

def checksforrandomizer(ptargets, mypacs, rows, positions, oldpositions_array, width, theirpacs)
    count = 0
    mypacs.length.times do |i|
        goal = randomtarget(rows)
        if stuckfor(positions, oldpositions_array, i, mypacs) >= 1 && stuckwithteammate(mypacs, ptargets, i, width)
            saveenemy(theirpacs, ptargets[i][0].gotohalf, mypacs[i].type_id, width)
        end
        # STDERR.puts "stuckfor(#{mypacs[i].pac_id}) = #{stuckfor(positions, oldpositions_array, i, mypacs)} && close=#{mypacs[i].tooclose(mypacs, goal)}"
        if ptargets[i] == nil || ptargets[i].length == 0 || (stuckfor(positions, oldpositions_array, i, mypacs) >= 1 && mypacs[i].tooclose(mypacs, goal) == 1)
            if ptargets[i] == nil then STDERR.puts "need a 'random' new target for #{mypacs[i].pac_id} cus ptargets[i] == nil" end
            if ptargets[i].length == 0 then STDERR.puts "need a 'random' new target for #{mypacs[i].pac_id} cus ptargets[i].length == 0" end
            if (stuckfor(positions, oldpositions_array, i, mypacs) >= 1 && mypacs[i].tooclose(mypacs, goal) == 1) then STDERR.puts "need a 'random' new target for #{mypacs[i].pac_id} cus hes stuck and tooclose to a teammate" end
            STDERR.puts "i is getting a new random target"
            if stuckfor(positions, oldpositions_array, i, mypacs) >= 1 && mypacs[i].tooclose(mypacs, goal) == 1
                # STDERR.puts "stuckfor on pacid=#{mypacs[i].pac_id} gives #{stuckfor(positions, oldpositions_array, i, mypacs)}"
                random = getlastposition(positions, oldpositions_array, i)
                isstuck = 1
                STDERR.puts "#{i} is stuck"
                # STDERR.puts "randomtarget (zit stuck) geeft: #{random}"
            else
                random = randomtarget(rows)
                isstuck = 0
                STDERR.puts "#{i} is random"
                # STDERR.puts "randomtarget (random)geeft: #{random}"
            end
            if random == nil || (random[0] == 0 && random[1] == 0)
                random = randomtarget(rows)
                STDERR.puts "#{i} is random part2"
                # STDERR.puts "randomtarget geeft: #{random}"
            end
            # STDERR.puts "2.rndomtarget geeft: #{random}"
            rtar = Target.new()
            rtar.x = random[0]
            rtar.y = random[1]
            rtar.goalvalue = 0
            rtar.pacid = mypacs[i].pac_id
            rtar.distance = afstand([random[0], random[1]], [mypacs[i].x, mypacs[i].y], width)
            if isstuck == 1
                ptargets[i][0] = rtar
            else
                ptargets[i] = ptargets[i].push(rtar.clone(&:clone))
            end
            # STDERR.puts "id=#{mypacs[i].pac_id}, ptarlen=#{ptargets[i].length}, targets with random = #{ptargets[i]}"
            # STDERR.puts "random target = #{random[0]}, #{random[1]}"
        end
    end
    # STDERR.puts "finished checking randomizer"
    return ptargets
end

def checksuperpellets(rows, mypacs, i, width)
    supers = Array.new()
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "S"
                dist = afstand( [w, h], [mypacs[i].x, mypacs[i].y], width)
                # STDERR.puts "sup.afstand([#{w},#{h}], [#{mypacs[i].x},#{mypacs[i].y}], #{width}) = #{dist}  openside = #{$openside} "
                next if dist > 16
                t = Target.new()
                t.x = w
                t.y = h
                t.distance = dist
                t.manhattan = dist
                t.origin = "superpellet"
                t.goalvalue = 5
                t.goto = [w, h]
                t.gotohalf = [w, h]
                t.value = 10 + t.distance
                t.pacid = mypacs[i].pac_id
                t.floodfillneed = 1
                if dist == 0 || t.value == 0
                    t.ratio = 0
                else
                    t.ratio = t.value.to_f / dist.to_f
                end
                supers = supers.push(t)
            end
        end
    end
    return supers
end
def checkhoneypots(rows, mypacs, i, width, deadends)
    honey = Array.new()
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "T" || rows[h][w] == "H"
                dist = afstand( [mypacs[i].x, mypacs[i].y], [w, h], width)
                next if dist > 16
                t = Target.new()
                t.x = w
                t.y = h
                t.distance = dist
                t.manhattan = dist
                t.goalvalue = 0
                if dist < 2 then STDERR.puts "i#{mypacs[i].pac_id} goal=#{w},#{h} dist=#{dist} " end
                t.value = 3
                if deadends[h][w] == "D"
                    t.value = 1
                end
                t.pacid = mypacs[i].pac_id
                t.origin = "honeypot"
                t.goto = [w, h]
                t.gotohalf = [w, h]
                t.floodfillneed = 1
                if dist == 0 || t.value == 0
                    t.ratio = 0
                else
                    t.ratio = t.value.to_f / dist.to_f
                end
                honey = honey.push(t)
            end
        end
    end
    return honey
end
def seenpellets(rows, mypacs, i, width)
    honey = Array.new()
    rows.length.times do |h|
        rows[h].length.times do |w|
            if rows[h][w] == "o" || rows[h][w] == "."
                dist = afstand( [mypacs[i].x, mypacs[i].y], [w, h], width)
                # STDERR.puts "mypacs[#{mypacs[i].pac_id}->#{w},#{h} has dist: #{dist}"
                next if dist > 20
                t = Target.new()
                t.x = w
                t.y = h
                t.distance = dist
                t.manhattan = dist
                if rows[h][w] == "o"
                    t.value = 1
                else
                    t.value = 0.5
                end
                t.goalvalue = 0
                t.pacid = mypacs[i].pac_id
                t.origin = "seen sometime"
                t.goto = [w, h]
                t.gotohalf = [w, h]
                t.floodfillneed = 1
                if dist == 0 || t.value == 0
                    t.ratio = 0
                else
                    t.ratio = t.value.to_f / dist.to_f
                end
                honey = honey.push(t)
            end
        end
    end
    return honey
end
def scorevision(rows, x, y, dx, dy, width, height, neartarget, pacid)
    value = 0
    # tmpx = x.dup + dx
    if x == 0 && dx == -1
        tmpx = width - 1
    elsif x == width - 1 && dx == 1
        tmpx = 0
    else
        tmpx = x.dup + dx
    end
    tmpy = y.dup + dy
    speed = 1
    if $speed == 1
        speed = 2
    end
    counter = 0
    direction = Array.new()
    while tmpx != x && (tmpy).between?(0, height - 1) && (tmpx).between?(0, width - 1) && (rows[tmpy][tmpx] != "#" && rows[tmpy][tmpx] != "E" && rows[tmpy][tmpx] != "M")
        if rows[tmpy][tmpx] == "S"
            value += 10
        elsif rows[tmpy][tmpx] == "o"
            value += 1
        elsif rows[tmpy][tmpx] == "."
            value += 0.5
        end
        counter += 1
        if value > 1
            pos = Target.new()
            pos.x = tmpx
            pos.y = tmpy
            pos.value = value
            pos.distance = counter
            pos.manhattan = pos.distance
            pos.floodfillneed = 0
            pos.origin = "directvision"
            pos.goalvalue = 0
            if x + dx * speed < 0 then pos.goto = [width - dx * speed, y + dy * speed] else pos.goto = [x + dx * speed, y + dy * speed] end
            if x + dx * speed < 0 then pos.goto = [width - dx, y + dy] else pos.gotohalf = [x + dx, y + dy] end
            pos.pacid = pacid
            if pos.distance == 0 || pos.value == 0
                pos.ratio = 0
            else
                pos.ratio = pos.value.to_f / pos.distance.to_f
            end
            direction = direction.push(pos.clone)
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
    if direction != nil && direction[0] != nil && direction.length > 0
        direction = direction.sort_by! {|i| i.value}.reverse
        neartarget = neartarget.push(direction[0])
    end
    return neartarget
end
def getneartargets(rows, width, height, mypacs, i)
    neartargets = Array.new()
    x = mypacs[i].x
    y = mypacs[i].y
    # STDERR.puts "scorevision for i=#{i}"
    neartargets = scorevision(rows, x, y, -1, 0, width, height, neartargets, mypacs[i].pac_id)
    neartargets = scorevision(rows, x, y, 1, 0, width, height, neartargets, mypacs[i].pac_id)
    neartargets = scorevision(rows, x, y, 0, -1, width, height, neartargets, mypacs[i].pac_id)
    neartargets = scorevision(rows, x, y, 0, 1, width, height, neartargets, mypacs[i].pac_id)
    # STDERR.puts "neartarget at end gives: #{neartargets}"
    return neartargets
end

def filtertargets(rows, ptargets, mypacs, width, height, deadends)
    mypacs.length.times do |i|
        ptargets[i] = Array.new()
        count = 0
        maxcount = 10
        if mypacs[i].speed_turns_left > 0
            $speed = 1
        else
            $speed = 0
        end
        if $superpelletsleft > 0
            getsupers = checksuperpellets(rows, mypacs, i, width)
            getsupers.sort_by! { |i| i.distance }
            getsupers = getsupers.slice(0, 2)
            if $targetdebug then STDERR.puts "after slice: len=#{getsupers.length} supers = #{getsupers}" end
        end
        ptargets[i] = ptargets[i].push(*getsupers)
        neartargets = Array.new()
        neartargets = getneartargets(rows, width, height, mypacs, i)
        ptargets[i] = ptargets[i].push(*neartargets)
        if ptargets[i].length < 3 && $honeypotsleft > 0
            honeys = checkhoneypots(rows, mypacs, i, width, deadends)
            honeys = honeys.sort_by! {|i| i.distance}.reverse
            honeys.length.times do |h|
                next if honeys[h] == nil
                honeys.length.times do |j|
                    next if honeys[j] == nil || honeys[h] == nil
                    if j > 0 && honeys[j] != nil && afstand( [honeys[h].x, honeys[h].y], [honeys[j].x, honeys[j].y], width) <= 3
                        honeys.delete_at(j)
                    end
                end
            end
            honeys.compact
            if honeys.length > 5
                honeys = honeys.slice(0, 5)
            end
            # STDERR.puts "better honeys = #{honeys} "
            ptargets[i] = ptargets[i].push(*honeys)
        end
        if ptargets[i].length < 3 && $honeypotsleft < 4
            STDERR.puts " checking for more targets, pt[#{mypacs[i].pac_id}].len=#{ptargets[i].length}, $honeypotsleft = #{$honeypotsleft} "
            lastones = seenpellets(rows, mypacs, i, width)
            lastones = lastones.sort_by! {|i| i.ratio}.reverse
            if lastones.length > 5 then lastones = lastones.slice(0, 5) end
            ptargets[i] = ptargets[i].push(*lastones)
        end
        ptargets[i] = ptargets[i].sort_by! {|o| o.ratio.to_f}.reverse
        if ptargets[i].length > 5
            ptargets[i] = ptargets[i].slice(0, 5)
        end
    end
    if $targetdebug
        ptargets.length.times do |i|
            STDERR.puts "my pacman #{mypacs[i].pac_id}:"
            ptargets[i].length.times do |o|
                ptargets[i][o].print(mypacs[i].x, mypacs[i].y)
            end
            STDERR.puts ""
        end
    end
    return ptargets
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
def findoptimal(left, right, up, down, steps, x, y, goal, speed)
    arr = Array.new
    if left != nil && left[0] != nil && left[1] != nil && left[0] > 0 && left[1] > 0
        if steps == speed + 1
            left[2] = x
            left[3] = y
        end
        if steps == speed
            left[4] = x
            left[5] = y
        end
        if $megadebug == 1 && (steps == $speed + 1 || steps == $speed) then STDERR.puts "megadebug. x=#{x}, y=#{y} steps=#{steps}, left=#{left}" end
        arr = arr.push(left)
    end
    if right != nil && right[0] != nil && right[1] != nil && right[0] > 0 && right[1] > 0
        if steps == speed + 1
            right[2] = x
            right[3] = y
        end
        if steps == speed
            right[4] = x
            right[5] = y
        end
        if $megadebug == 1 && (steps == $speed + 1 || steps == $speed) then STDERR.puts "megadebug. x=#{x}, y=#{y} steps=#{steps}, right=#{right}" end
        arr = arr.push(right)
    end
    if up != nil && up[0] != nil && up[1] != nil && up[0] > 0 && up[1] > 0
        if steps == speed + 1
            up[2] = x
            up[3] = y
        end
        if steps == speed
            up[4] = x
            up[5] = y
        end
        if $megadebug == 1 && (steps == $speed + 1 || steps == $speed) then STDERR.puts "megadebug. x=#{x}, y=#{y} steps=#{steps}, up=#{up}" end
        arr = arr.push(up)
    end
    if down != nil && down[0] != nil && down[1] != nil && down[0] > 0 && down[1] > 0
        if steps == speed + 1
            down[2] = x
            down[3] = y
        end
        if steps == speed
            down[4] = x
            down[5] = y
        end
        if $megadebug == 1 && (steps == $speed + 1 || steps == $speed) then STDERR.puts "megadebug. x=#{x}, y=#{y} steps=#{steps}, down=#{down}" end
        arr = arr.push(down)
    end
    # if $debug == 1 && $superpelletsleft == 0 && steps < 4
    #     STDERR.puts "x=#{x}, y=#{y} unsorted array = #{arr} to goal=#{goal}"
    # end
    if arr.length > 0
        # arr = arr.sort_by {|i| i[0], i[1] }
        if arr.length > 1
            # STDERR.puts "g=#{goal} xy=#{x},#{y} steps=#{steps} unsort array: #{arr}"
            arr = arr.sort_by { |a| [a[0], -a[1]] }
            if arr[0][0] == arr[1][0] && (arr[0][2] != arr[1][2] || arr[0][3] != arr[1][3] || arr[0][4] != arr[1][4] || arr[0][5] != arr[1][5])
                arr[0][6] = 1
                arr[1][6] = 1 #not needed but sure
                # STDERR.puts "multiple solutions possible, chose for #{arr[0]} instead of #{arr[1]}"
            end
        end
        return arr[0]
    else
        # distance, value, gotox, gotoy, gotohalfx, gotohalfy, ismultiplesolutions
        return [0, 0, 0, 0, 0, 0, 0]
    end
end
def floodfillwithvalue(rows, x, y, goal, goalvalue, steps, value, width, extravalue, ogmh, maxomweg, speed)
    if $debug == 1
    #    STDERR.puts "commencing flood: x=#{x}, y=#{y}, steps=#{steps}, value=#{value}"
    end
    # if $megadebug == 1 then STDERR.puts "megadebug = #{$megadebug}" end
    if $megadebug == 1 && y >= 0 && x >= 0 && rows[y][x] then STDERR.puts "x=#{x},y=#{y}, goal=#{goal} && steps+afstand=#{steps + afstand([x, y], goal, width)} >? #{ogmh + maxomweg + $extra} " end
    if rows[y][x] == "#" || rows[y][x] == "X" || (rows[y][x] == "M" && steps != 0) || rows[y][x] == "E"
        if $megadebug == 1 && (rows[y][x] == "M" && steps != 0) then STDERR.puts "=M, x=#{x},y=#{y}, goal=#{goal}, steps=#{steps}, steps+afstand=#{steps} + #{afstand([x, y], goal, width)} >? #{10} + #{goalvalue} + #{$extra} " end
        return [0, 0, 0, 0, 0, 0, 0]
    elsif y < 0 || x < 0 || !rows[y][x] || steps + afstand([x, y], goal, width) > ogmh + maxomweg + $extra
        # if y < 0 || x < 0 || !rows[y][x] || steps > 15 + $extra || steps + afstand([x, y], goal, width) > 10 + goalvalue + extravalue
        if ($megadebug == 1 || $megadebug == true) && rows[y][x] != "#" then STDERR.puts "x=#{x},y=#{y}, goal=#{goal}, steps=#{steps}, steps+afstand=#{steps} + #{afstand([x, y], goal, width)} >? #{10} + #{goalvalue} + #{extravalue} " end
        return [0, 0, 0, 0, 0, 0, 0]
    end
    if rows[y][x] == "o" || rows[y][x] == "S" || rows[y][x] == "." || rows[y][x] == "T" || rows[y][x] == "H"
        value += 1
        if rows[y][x] == "."
            value -= 0.5
        end
        if rows[y][x] == "S"
            value += 9
        end
    # elsif rows[y][x] == "E"
    #     value -= 10
    end
    if goal[0] == x && goal[1] == y
        if speed + 1 == steps
            return [steps, value, x, y, 0, 0]
        else
            return [steps, value, 0, 0, 0, 0, 0]
        end
        #last one is 1 if theres multiple solutions (added in findoptimal)
    end
#    STDERR.puts "steps = #{steps} and position: [#{x}, #{y}]"
    rows[y][x] = "X"
    if x == 0
        left = floodfillwithvalue(rows.clone.map(&:clone), width - 1, y, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    else
        left = floodfillwithvalue(rows.clone.map(&:clone), x - 1, y, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    end
    if x == width - 1
        right = floodfillwithvalue(rows.clone.map(&:clone), 0, y, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    else
        right = floodfillwithvalue(rows.clone.map(&:clone), x + 1, y, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    end
    up = floodfillwithvalue(rows.clone.map(&:clone), x, y - 1, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    down = floodfillwithvalue(rows.clone.map(&:clone), x, y + 1, goal, goalvalue, steps + 1, value, width, extravalue, ogmh, maxomweg, speed)
    return findoptimal(left, right, up, down, steps, x, y, goal, speed)
end

def gettarget(target, rows, width, height, mypacs, i)
    $debug = 0
    goal = [target.x, target.y]
    # if target.manhattan != afstand(goal, [mypacs[i].x, mypacs[i].y], width) then STDERR.puts "id=#{mypacs[i].pac_id} t.origin = #{target.origin} manh: #{target.manhattan} to goal=#{goal} isnot #{afstand(goal, [mypacs[i].x, mypacs[i].y], width)}" end 
    target.manhattan = afstand(goal, [mypacs[i].x, mypacs[i].y], width)
    # STDERR.puts "id=#{mypacs[i].pac_id} (goal=#{goal}), manhattan is: #{target.manhattan}"
    if target.manhattan > 15 + $extra
        STDERR.puts "id=#{mypacs[i].pac_id} (goal=#{goal}), manhattan is too large: #{target.manhattan} > #{15 + $extra}"
        target.x = 0
        target.y = 0
        return target
    end
    target.goalvalue = 0
    if rows[target.y][target.x] == "S"
        target.goalvalue = 5
    end
    t1 = Time.now
    $debug = 0
    if $extra > 0 then extravalue = 5 else extravalue = 0 end
    maxomweg = 5
    tmp = floodfillwithvalue(rows.clone.map(&:clone), mypacs[i].x, mypacs[i].y, goal, target.goalvalue, 0, 0, width, extravalue, target.manhattan, maxomweg, mypacs[i].hasspeed)
    $ffcounter += 1
    t2 = time_diff_milli(t1, Time.now)
    if t2 > 6
        STDERR.puts "FF: id=#{mypacs[i].pac_id}, target = #{goal}, tmp=#{tmp}, mh=#{target.manhattan} time to floodfill = #{t2}"
    end
    target.distance = tmp[0]
    # if target.distance == 0 || $timedebug then STDERR.puts "ff'ed: id=#{mypacs[i].pac_id} target = #{goal}, ff returned: #{tmp} in #{t2}ms manh:#{target.manhattan}" end
    target.value = tmp[1]
    if target.origin == "previous target" then target.value += 10 end
    target.floodfillneed = 1
    target.goto = [tmp[2], tmp[3]]
    if $speed == 1
        target.gotohalf = [tmp[4], tmp[5]]
    else
        target.gotohalf = target.goto
    end
    if target.distance <= 1
        target.gotohalf = [mypacs[i].x, mypacs[i].y]
        if target.distance == 1
            target.goto = goal
        else
            target.goto = [mypacs[i].x, mypacs[i].y]
        end
    end
    if target.goto == nil || target.goto[0] == nil || target.goto[1] == nil
        target.goto = [0, 0]
        target.gotohalf = [0, 0]
    end
    if target.goto == [0, 0]
        STDERR.puts "id=#{mypacs[i].pac_id}, tmp = #{tmp}, goto = #{target.goto} goal = #{goal} "
    end
    # STDERR.puts "id=#{mypacs[i].pac_id}. target=#{target.x}, #{target.y}, enemyclose=#{enemyclose}"
    if target.goalvalue == 5 && target.distance > 1 && target.distance < 10
        if target.distance > 5 then maxcheck = 5 else maxcheck = target.distance end
        # STDERR.puts "maxcheck for enemyclose to #{goal} is #{maxcheck} "
            tim1 = Time.now
        enemyclose = enemynear(rows.clone.map(&:clone), goal[0], goal[1], 0, maxcheck, width)
            tim2 = time_diff_milli(tim1, Time.now)
            $enemynearcount += 1
            $enemyneartime += tim2
            if tim2 > 0.8 then STDERR.puts "en.distance to #{goal}= #{enemyclose} duurde: #{tim2}ms " end
        if enemyclose < target.distance
            target.value -= 5
            if enemyclose <= 3 && target.distance > 3
                target.value = 0.5
            end
            STDERR.puts "pac#{mypacs[i].pac_id} is devalueing #{target.x},#{target.y} cus enemy is #{enemyclose} tiles away before turn 3. value=#{target.value}"
        end
        # STDERR.puts "enemy near to #{goal}"
    end
    if tmp[5] == 1
        target.x = target.goto[0]
        target.y = target.goto[1]
    end
    if target.distance == 0 || target.value == 0
        target.ratio = 0.01
    else
            target.ratio = target.value.to_f / target.distance.to_f
            if target.ratio == 0 || target.ratio.to_f.nan?
                STDERR.puts "ratio woulda been 0 or nan cus target:"
                target.print
                target.ratio = 0.02
            end
        # end
    end
    if mypacs[i].hasspeed == 1 && target.distance == 1 # && goalvalue == 1
        if target.x == 0 then xleft = [width - 1, target.y] else xleft = [target.x - 1, target.y] end
        if target.x == width - 1 then xright = [0, target.y] else xright = [target.x + 1, target.y] end
        xup = [target.x, target.y - 1]
        xdown = [target.x , target.y + 1]
        xdirs = [xleft, xright, xup, xdown]
        dirs = Array.new
        if !( rows[xleft[1]][xleft[0]] == "#" || (xleft[0] == mypacs[i].x && xleft[1] == mypacs[i].y) )
            # STDERR.puts "left possible: #{xleft} "
            dirs = dirs.push(xleft)
        end
        if !(rows[xright[1]][xright[0]] == "#" || (xright[0] == mypacs[i].x && xright[1] == mypacs[i].y) )
            # STDERR.puts "right possible: #{xright} "
            dirs = dirs.push(xright)
        end
        if !( rows[xup[1]][xup[0]] == "#" || (xup[0] == mypacs[i].x && xup[1] == mypacs[i].y) )
            # STDERR.puts "up possible: #{xup} "
            dirs = dirs.push(xup)
        end
        if !(rows[xdown[1]][xleft[0]] != "#" || (xdown[0] == mypacs[i].x && xdown[1] == mypacs[i].y) )
            # STDERR.puts "down possible: #{xdown} "
            dirs = dirs.push(xdown)
        end
        if dirs[0] != nil
            target.x = dirs[0][0]
            target.y = dirs[0][1]
        end
    end
    target.eff = target.ratio * target.value
    target.pacid = mypacs[i].pac_id
    # t.printif
    return target
end
def bettertargets(rows, ptargets, mypacs, width, height, oldtargets)
    counter = 0
    timeinbettertargets = Time.now
    ptargets.length.times do |i|
        if oldtargets[i] != nil && !(oldtargets[i].x == 0 && oldtargets[i].y == 0)
            next if mypacs[i].x == oldtargets[i].x && mypacs[i].y == oldtargets[i].y
            ptargets[i].unshift(oldtargets[i])
            STDERR.puts "pac#{mypacs[i].pac_id}'s old target is #{oldtargets[i].x},#{oldtargets[i].y} "
        end
    end
    ptargets.length.times do |i|
        counter = 0
        # STDERR.puts "bettertargets: pac#{mypacs[i].pac_id} has #{ptargets[i].length} targets "
        ptargets[i].length.times do |q|
            if mypacs[i] != nil && ptargets[i][q] != nil && ptargets[i][q].floodfillneed == 1 && counter < $maxfloodfilltargets
                counter += 1
                ptargets[i][q] = gettarget(ptargets[i][q], rows, width, height, mypacs, i)
                if ptargets[i][q].x == 0 && ptargets[i][q].y == 0
                    ptargets[i].delete_at(q)
                end
            end
        end
    end

    if $timedebug then STDERR.puts "#{$ffcounter} floodfills cost #{time_diff_milli(timeinbettertargets, Time.now)}ms, avg=#{time_diff_milli(timeinbettertargets, Time.now) / $ffcounter} ms" end

    mypacs.length.times do |i|
        # STDERR.puts "final targets (before sorting): id=#{mypacs[i].pac_id} length=#{ptargets[i].length}, #{ptargets[i]}"
        ptargets[i].compact
        ptargets[i] = ptargets[i].delete_if {|o| o.x == 0 && o.y == 0}
        # STDERR.puts "final targets before conflictcheck: id=#{mypacs[i].pac_id}: length=#{ptargets[i].length}, tar[i][0]=#{ptargets[i]}"
        ptargets[i] = ptargets[i].sort_by! {|i| i.ratio}.reverse
        if $targetdebug 
            STDERR.puts "better#{mypacs[i].pac_id}"
            ptargets[i].length.times do |q|
                ptargets[i][q].print(mypacs[i].x, mypacs[i].y)
            end
            STDERR.puts ""
        end
    end
    return ptargets
end

def closeto(x, y, rows, width, height)
    val = 0
    3.times do |i|
        3.times do |k|
            if (y - 1 + k).between?(0, height) && (x - 1 + k).between?(0, width) && (rows[y - 1 + k][x - 1 + k] == "o" || rows[y - 1 + k][x - 1 + k] == ".")
                val += 1
            end
        end
    end
    return val
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
def stuckfor(positions, oldpositions_array, i, mypacs)
    ret = 0
    a = 0
    # STDERR.print "stuckfor comparing #{positions[i]} to #{oldpositions_array[a][i]}"
    while positions[i] == oldpositions_array[a][i] && mypacs[i].speed_turns_left < 5 
        # STDERR.puts ", apparently #{positions[i]} is equal to #{oldpositions_array[a][i]}"
        ret += 1
        a += 1
    end
    # STDERR.print "\n"
    return ret
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
    def stuckcheck(oldpos)
        if oldpos != nil && oldpos[0] == x && oldpos[1] == y && speed_turns_left < 5
            return 1
        end
        return 0
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
    def initialize(x: 0, y: 0, distance: 10, value: 0, ratio: 0, pacid: 0, eff: 0, manhattan: 0, goalvalue: 0, floodfillneed: 1, origin: "honeypot", goto: 0, gotohalf: 0)
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
        STDERR.print "pac[#{pacid}] --> [#{x}, #{y}] origin = #{origin} dist = #{distance}, mh = #{manhattan}, goto = #{goto}, ffneed=#{floodfillneed} | "
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
        checkdeadends(ogdeadends, theirpacs[n].x, theirpacs[n].y, width, height)
    end
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
    if ptargets.length > 0
        ptargets.length.times do |i|
            if isalive(ptargets[i][0], mypacs) == 1
                oldtargets[i] = ptargets[i][0].clone(&:clone)
                oldtargets[i].floodfillneed = 1
                oldtargets[i].origin = "previous target"
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
    if $turn == 0
        rows = sethoneypots(rows, width)
    end
    mypacs.length.times do |i|
        rows[mypacs[i].y][mypacs[i].x] = "M"
    end
            # print map
    # height.times do |i|
    #     STDERR.puts rows[i]
    # end
    filtertime = Time.now
    ptargets = filtertargets(rows, ptargets, mypacs, width, height, deadends)
                if $timedebug then STDERR.puts "filtertargets takes: #{time_diff_milli(filtertime, Time.now)}ms" end
    btime = Time.now
    $btime = btime
    ptargets = bettertargets(rows, ptargets, mypacs, width, height, oldtargets)
                if $timedebug then STDERR.puts "time up till after bettertargets: #{time_diff_milli(btime, Time.now)}"end
                if $timedebug && $enemynearcount > 0 then STDERR.puts "#{$enemynearcount} enemynear() calls took #{$enemyneartime}ms avg=#{$enemyneartime / $enemynearcount}" end
    randtime = Time.now
    ptargets = checksforrandomizer(ptargets, mypacs, rows, positions, oldpositions_array, width, theirpacs)
                # STDERR.puts "after rands ptars[1] = #{ptargets[1]}"
                if $timedebug then STDERR.puts "checks for randomizer takes: #{time_diff_milli(randtime, Time.now)}" end
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
