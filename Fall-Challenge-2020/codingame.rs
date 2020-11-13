use std::io;
use std::cmp::max;
extern crate rand;
use rand::Rng;

macro_rules! parse_input {
	($x:expr, $t:ident) => ($x.trim().parse::<$t>().unwrap())
}

struct Ingredient {
	value: i32,
}

struct  Action {
    actype: String,
    id: i32,
    times: i32,
    price: i32,
    steps: i32
}

impl Action {
    fn  defaultnew() -> Action {
        Action { actype: "REST".to_string(), id: 0, times: 0, price: 0, steps: 0 }
    }
    fn  new(ac: String, id: i32, tim: i32, pr: i32, st: i32) -> Action {
        Action { actype: ac, id: id, times: tim, price: pr, steps: st }
    }
    fn  copy(&mut self, x: &mut Action) {
        self.actype = x.actype.clone();
        self.id = x.id;
        self.times = x.times;
        self.price = x.price;
        self.steps = x.steps;
    }
    fn  update(&mut self, a:String, b:i32, c:i32) {
        self.actype = a.clone();
        self.id = b;
        self.times = c;
    }
    fn  perform(&self) {
        if self.actype == "WAIT" || self.actype == "REST" {
            println!("{} sleepy", self.actype);
        } else if self.times <= 1 {
            println!("{} {} fuck no baby!~~~", self.actype, self.id);
        } else {
            println!("{} {} {} repeating of course", self.actype, self.id, self.times);
        }
    }
}

struct Choice {
	id: i32,
	value: i32,
    repeat: i32,
}

impl Choice {
	fn  new() -> Choice {
		Choice { id: -1, value: -1, repeat: 0 }
	}
	fn  set(&mut self, id: i32, val: i32, r: i32) {
		self.id = id;
		self.value = val;
        self.repeat = r;
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
    value: i32,
	price: i32,
	tome_index: i32,
	tax_count: i32,
	castable: i32,
	repeatable: i32,
}

impl Recipe {
	fn new(id: i32, atype: String, cost:Vec<i32>, val: i32, price:i32, ti:i32, tc:i32, c:i32, r:i32) -> Recipe {
		Recipe { id:id, action_type:atype, cost:cost, value: val, price:price, tome_index:ti, tax_count:tc, castable:c, repeatable:r }
	}
	fn  eprint(&mut self) {
		eprintln!("id: {}, type: {}, deltas: {}/{}/{}/{}, price: {}\ntome_index: {}, tax_count: {}, castable: {}, repeatable: {}", self.id, self.action_type, self.cost[0], self.cost[1], self.cost[2], self.cost[3], self.price, self.tome_index, self.tax_count, self.castable, self.repeatable);
	}
    fn  copy(&self) -> Recipe {
        return Recipe { id: self.id, action_type: self.action_type.clone(), cost: vec![self.cost[0], self.cost[1], self.cost[2], self.cost[3]], value: self.value, price: self.price, tome_index: self.tome_index, tax_count: self.tax_count, castable: self.castable, repeatable: self.repeatable };
    }
}

struct Field {
    tobrew: Vec<Recipe>,
    tocast: Vec<Recipe>,
    tolearn: Vec<Recipe>,
    oppocast: Vec<Recipe>,
}

impl Field {
    fn new() -> Field {
        Field { tobrew: Vec::new(), tocast: Vec::new(), tolearn: Vec::new(), oppocast: Vec::new() }
    }
    fn  push(&mut self, r: Recipe) {
        if r.action_type == "BREW" {
            self.tobrew.push(r);
        } else if r.action_type == "CAST" {
            self.tocast.push(r);
        } else if r.action_type == "LEARN" {
            self.tolearn.push(r);
        } else {
            self.oppocast.push(r);
        }
    }
}


struct Witch {
	inventory: Vec<i32>,
	score: i32,
    // action: Action,
    field: Field,
}

fn brewable(r: &Recipe, inv: &Vec<i32>) -> bool {
    for i in 0..4 {
        if inv[i] + r.cost[i] < 0 {
            return false;
        }
    }
    true
}

fn  castable(r: &Recipe, inv: &Vec<i32>) -> bool {
    if r.castable == 0 || brewable(r, inv) == false {
        return false;
    }
    let mut items = 0;
    for i in 0..4 {
        items += inv[i] + r.cost[i];
    }
    if items > 10 {
        return false;
    }
    true
}

fn  doineedit(r: &Recipe, inv: &Vec<i32>) -> bool {
    true
}

fn  get_missing_stones(target: &Recipe, inv: &Vec<i32>) -> Vec<i32> {
    let mut vec = Vec::new();
    for i in 0..4 {
        let mut n = target.cost[i] - inv[i];
        vec.push( max(0, n) );
    }
    vec
}

impl Witch {
	fn  new(inv:Vec<i32>, s:i32 ) -> Witch {
		Witch { inventory:inv, score:s, field: Field::new() }
	}
    fn  setfield(&mut self, f: Field) {
        self.field = f;
    }
	fn  eprint(&self) {
		eprintln!("Witches score is {}, tier inventory: {}-{}-{}-{}", self.score, self.inventory[0], self.inventory[1], self.inventory[2], self.inventory[3]);
	}

    fn  simulate(&mut self, mut inv: Vec<i32>, target: &Recipe, steps: i32) -> Action {
        let mut action = Action::new("REST".to_string(), 0, 0, inv[0] + 2 * inv[1] + 3 * inv[2] + 4 * inv[3], steps);
            if steps > 6 {
                return action;
            }
            if inv[1] >= 2 && inv[3] >= 2 {
                eprintln!("step {}: simulate: inventory = {}/{}/{}/{}", steps, inv[0], inv[1], inv[2], inv[3]);
            }
            // eprintln!("action: {} id{} x{} ${} {}steps", action.actype, action.id, action.times, action.price, action.steps);
            for r in self.field.tobrew.iter() { // could use iter_mut( )
                if brewable(&r, &self.inventory) {
                    eprintln!("on step {} we can brew potion {} for ${}", steps, r.id, r.price);
                    return Action::new(r.action_type.clone(), r.id, 0, r.price, steps); // action_type, id, times, price, steps
                }
            }
            for i in (0..self.field.tocast.len()).rev() {
                if castable(&self.field.tocast[i], &inv ) && doineedit(&self.field.tocast[i], &inv) { // and if I need it
                    for n in 0..4 {
                        inv[n] += self.field.tocast[i].cost[n];
                    }
                    let mut check = self.simulate(inv.to_vec(), target, steps + 1);
                    if check.price > action.price {
                        action.copy(&mut check);
                        if steps == 0 {
                            action.actype = self.field.tocast[i].action_type.clone();
                            action.id = self.field.tocast[i].id;
                        }
                    }
                }
            }
        if (steps == 0) {
            eprintln!("final action: {} id{} x{} ${} {}steps", action.actype, action.id, action.times, action.price, action.steps);
        }
        return action;
    }
    fn  action(&mut self) -> Action {
        let mut price = 0;
        let mut id = 0;
        for i in 0..self.field.tobrew.len() {
            if self.field.tobrew[i].price > price {
                id = i;
                price = self.field.tobrew[i].price;
            }
        }
        let target = self.field.tobrew[id].copy();
        let mut inv = self.inventory.to_vec();
        return self.simulate(inv, &target, 0);
    }
}

fn main() {

	// game loop
	loop {
		let mut field = Field::new();
		let mut input_line = String::new();
		io::stdin().read_line(&mut input_line).unwrap();
		let action_count = parse_input!(input_line, i32); // the number of spells and recipes in play
		for i in 0..action_count as usize {
			let mut input_line = String::new();
			io::stdin().read_line(&mut input_line).unwrap();
			let inputs = input_line.split(" ").collect::<Vec<_>>();
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
			let rec = Recipe::new(action_id, action_type, costs, 0, price, tome_index, tax_count, castable, repeatable );
			field.push(rec);
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
		// for r in &Field {
		// 	r.eprint();
		// }
        Witches[0].setfield(field);
		let mut action = Witches[0].action();
        action.perform();

		// in the first league: BREW <id> | WAIT; later: BREW <id> | CAST <id> [<times>] | LEARN <id> | REST | WAIT
	}
}
