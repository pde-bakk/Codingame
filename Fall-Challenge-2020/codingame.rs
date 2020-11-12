use std::io;
use std::cmp::max;
use rand::Rng;

macro_rules! parse_input {
	($x:expr, $t:ident) => ($x.trim().parse::<$t>().unwrap())
}

struct Ingredient {
	value: i32,
}

struct Choice {
	id: i32,
	value: i32,
}

impl Choice {
	fn  new(id: i32, val: i32) -> Choice {
		Choice { id: id, value: val }
	}
	fn  set(&mut self, id: i32, val: i32) {
		self.id = id;
		self.value = val;
	}
	fn  good(&self) -> bool {
		if (self.id <= 0 || self.value <= 0) {
			return false;
		}
		true
	}
}

struct Recipe {
	id: i32,
	action_type: String,
	cost: Vec<i32>,
	price: i32,
	tome_index: i32,
	tax_count: i32,
	castable: i32,
	repeatable: i32,
}

impl Recipe {
	fn new(id: i32, atype: String, cost:Vec<i32>, price:i32, ti:i32, tc:i32, c:i32, r:i32) -> Recipe {
		Recipe { id:id, action_type:atype, cost:cost, price:price, tome_index:ti, tax_count:tc, castable:c, repeatable:r }
	}
	fn  eprint(&self) {
		eprintln!("id: {}, type: {}, deltas: {}/{}/{}/{}, price: {}\ntome_index: {}, tax_count: {}, castable: {}, repeatable: {}", self.id, self.action_type, self.cost[0], self.cost[1], self.cost[2], self.cost[3], self.price, self.tome_index, self.tax_count, self.castable, self.repeatable);
	}
}

struct Witch {
	inventory: Vec<i32>,
	score: i32,
}

impl Witch {
	fn new(inv:Vec<i32>, s:i32) -> Witch {
		Witch { inventory:inv, score:s }
	}
	fn eprint(&self) {
		eprintln!("Witches score is {}, tier inventory: {}-{}-{}-{}", self.score, self.inventory[0], self.inventory[1], self.inventory[2], self.inventory[3]);
	}
	fn brewable(&self, r: &Recipe) -> bool {
		for i in 0..4 {
			if self.inventory[i] + r.cost[i] < 0 {
				return false;
			}
		}
		true
	}
	fn castable(&self, r: &Recipe) -> bool {
		if r.castable == 0 || self.brewable(r) == false {
			return false;
		}
		true
	}
	fn action(&self, board: Vec<Recipe>) {
		let mut bestbrew = Choice::new(-1, -1);
		let mut bestcast = Choice::new(-1, -1);
		let mut restable = false;
		for r in &board {
			if r.action_type == "BREW" { // We can brew, yeaaah!!
				if r.price > bestbrew.value && self.brewable(r) {
					bestbrew.value = r.price;
					bestbrew.id = r.id;
				}
			}
			else if r.action_type == "CAST" { // our spell to cast
				if r.castable == 0 {
					restable = true;
				}
				if self.castable(r) { // should change this to personal value
					let mut val: i32 = max(0, r.cost[0] - 1) + max(0, 2*r.cost[1]) + max(0, 3*r.cost[2]) + max(0, 4*r.cost[3]);
					// eprintln!("val is {}, bestcast.value: {}", val, bestcast.value);
					if val >= bestcast.value {
						bestcast.set(r.id, val);
					}
				}
				else {
					// eprintln!("{} is not castable.", r.id);
				}
			}
			else if r.action_type == "OPPONENT_CAST" { // spreekt voor zich...
			}
		}
		if (!bestbrew.good()) {
			let mut rng = rand::thread_rng();
			let mut n = rng.gen_range(0, 4);
			for r in board {
				if r.action_type == "CAST" {
					if n == 0 {
						if r.castable == 1 {
							println!("CAST {}", r.id);
						}
						else {
							println!("REST zzzz");
						}
						break;
					}
					n -= 1;
				}
			}
		}
		else {
			println!("BREW {} get that moolah", bestbrew.id);
			eprintln!("Brewing {} to get ${}", bestbrew.id, bestbrew.value);
		}
	}
}

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/
fn main() {

	// game loop
	loop {
		let mut Field: Vec<Recipe> = Vec::new();
		let mut input_line = String::new();
		io::stdin().read_line(&mut input_line).unwrap();
		let action_count = parse_input!(input_line, i32); // the number of spells and recipes in play
		for i in 0..action_count as usize {
			let mut input_line = String::new();
			io::stdin().read_line(&mut input_line).unwrap();
			let inputs = input_line.split(" ").collect::<Vec<_>>();
			// eprintln!("inputs: {}", inputs);
			let action_id = parse_input!(inputs[0], i32); // the unique ID of this spell or recipe
			let action_type = inputs[1].trim().to_string(); // in the first league: BREW; later: CAST, OPPONENT_CAST, LEARN, BREW
			let mut costs = vec![ parse_input!(inputs[2], i32) ];
				costs.push(parse_input!(inputs[3], i32) );
				costs.push(parse_input!(inputs[4], i32) );
				costs.push(parse_input!(inputs[5], i32) );
			let price = parse_input!(inputs[6], i32); // the price in rupees if this is a potion
			let tome_index = parse_input!(inputs[7], i32); // in the first two leagues: always 0; later: the index in the tome if this is a tome spell, equal to the read-ahead tax
			let tax_count = parse_input!(inputs[8], i32); // in the first two leagues: always 0; later: the amount of taxed tier-0 ingredients you gain from learning this spell
			let castable = parse_input!(inputs[9], i32); // in the first league: always 0; later: 1 if this is a castable player spell
			let repeatable = parse_input!(inputs[10], i32); // for the first two leagues: always 0; later: 1 if this is a repeatable player spell
			let rec = Recipe::new(action_id, action_type, costs, price, tome_index, tax_count, castable, repeatable );
			Field.push(rec);
		}
		let mut Witches: Vec<Witch> = Vec::new();
		for i in 0..2 as usize {
			let mut input_line = String::new();
			io::stdin().read_line(&mut input_line).unwrap();
			let inputs = input_line.split(" ").collect::<Vec<_>>();
			let mut inv = vec![ parse_input!(inputs[0], i32) ];
				inv.push( parse_input!(inputs[1], i32)) ;
				inv.push( parse_input!(inputs[2], i32) );
				inv.push( parse_input!(inputs[3], i32) );
			let score = parse_input!(inputs[4], i32);
			let w = Witch::new(inv, score);
			Witches.push(w);
		}
		for r in &Field {
			r.eprint();
		}
		// Witches[1].eprint();
		Witches[0].action(Field);

		// in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT
	}
}
