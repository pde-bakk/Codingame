#pragma GCC optimize("O3")
#pragma GCC optimize("inline")
#pragma GCC optimize("omit-frame-pointer")
#pragma GCC optimize("unroll-loops") //Optimization flags
#pragma GCC optimize("Ofast")
#pragma GCC option("march=native","tune=native","no-zero-upper") //Enable AVX (this thing gives errors on my laptop with clang 11)
#pragma GCC target("avx")  //Enable AVX
#pragma GCC target "bmi2"
#include <x86intrin.h> //AVX/SSE Extensions
#include <iostream>
#include <string>
#include <vector>
#include <array>
#include <cstdlib>
#include <algorithm>
#include <chrono>
using namespace std;

inline long long currTimeMilli(const chrono::steady_clock::time_point& begin) { return chrono::duration_cast<chrono::milliseconds>(chrono::steady_clock::now() - begin).count(); }
inline long long currTimeMicro(const chrono::steady_clock::time_point& begin) { return chrono::duration_cast<chrono::microseconds>(chrono::steady_clock::now() - begin).count(); }
inline long long currTimeNano(const chrono::steady_clock::time_point& begin) { return chrono::duration_cast<chrono::nanoseconds>(chrono::steady_clock::now() - begin).count(); }
size_t	g_turn = 0;
int 	g_CastValueMultiplier;
unsigned long long g_total = 0;
enum Player {
	ME,
	BITCH
};

enum e_Recipe {
	REST = -2,
	WAIT = -1,
	OPPONENT_CAST = 0,
	BREW = 1,
	CAST = 2,
	LEARN = 3
};

string Type2String(e_Recipe e) {
	switch (e) {
		case REST:
			return "REST";
		case WAIT:
			return "WAIT";
		case BREW:
			return "BREW";
		case CAST:
			return "CAST";
		case LEARN:
			return "LEARN";
		case OPPONENT_CAST:
			return "OPPONENT_CAST";
		default:
			throw runtime_error("Bad Type2String");
	}
}

class Recipe {
public:
	Recipe() = default;
	void init() {
		string str_actionType;
		cin >> id >> str_actionType >> cost[0] >> cost[1] >> cost[2] >> cost[3] >> price >> tomeIndex >> taxCount >> castable >> repeatable; cin.ignore();
		if (str_actionType == "BREW") this->actionType = BREW;
		else if (str_actionType == "CAST") this->actionType = CAST;
		else if (str_actionType == "LEARN") this->actionType = LEARN;
		else if (str_actionType == "OPPONENT_CAST") this->actionType = OPPONENT_CAST;
	}
//private:
	e_Recipe actionType{};
	int id{}, price{}, tomeIndex{}, taxCount{}, timesCraftable{};
	bool castable{}, repeatable{};
	array<int, 4> cost{};
};
ostream&    operator<<(ostream& o, const Recipe& r) {
	o   << "type: " << Type2String(r.actionType) << endl
		<< "id: " << r.id << ", price: " << r.price << endl
		<< "tomeIndex: " << r.tomeIndex << ", taxCount: " << r.taxCount << endl
		<< std::boolalpha << "castable: " << r.castable << ", repeatable: " << r.repeatable << endl
		<< "cost: [" << r.cost[0] << '/' << r.cost[1] << '/' << r.cost[2] << '/' << r.cost[3] << "]." << endl;
	return o;
}

Recipe	g_Rest;
Recipe	g_Wait;

class Action {
public:
	Action() = default;
	explicit Action(const Recipe& r) {
		*this = r;
	}
	Action&	operator=(const Recipe& r) {
		this->actionType = r.actionType;
		this->id = r.id;
		this->times = r.timesCraftable;
		this->tomeIndex = r.tomeIndex;
		this->taxCount = r.taxCount;
		return *this;
	}
	void print() const {
		if (this->actionType == LEARN) {
			cerr << "tomeIndex = " << this->tomeIndex << ", taxCount = " << this->taxCount << endl;
		}
		cout << Type2String(this->actionType);
		if (this->actionType >= 0) { // its not WAIT or REST
			cout << ' ' << this->id;
			if (this->times > 1)
				cout << ' ' << this->times;
		}
		if (this->actionType == BREW)
			cout << " Heres your sir, shit.";
		else if (rand() % 10 == 0) // NOLINT(cert-msc50-cpp)
			cout << " Dont forget to kiss your homies goodnight!";
		cout << endl;
	}

// private:
	e_Recipe actionType{};
	int id{}, times{}, tomeIndex{}, taxCount{};
};

ostream&    operator<<(ostream& o, const Action& a) {
	o << Type2String(a.actionType) << ' ';
	if (a.actionType != REST && a.actionType != WAIT) {
		o << a.id << ' ';
		if (a.times > 1)
			o << a.times << ' ';
	}
	o << endl;
	return o;
}

class Witch {
public:
	Witch() = default;
	void initialize() { cin >> inventory[0] >> inventory[1] >> inventory[2] >> inventory[3] >> score; cin.ignore(); }

	inline bool CheckIfBrewable(const Recipe& r) const {
		for (int i = 0; i < 4; ++i) {
			if (this->inventory[i] + r.cost[i] < 0) {
				return false;
			}
		}
		return true;
	}
	inline int	TotalItems(const Recipe& r, const int Times) const {
		return	(inventory[0] + inventory[1] + inventory[2] + inventory[3] +
			Times * r.cost[0] + Times * r.cost[1] + Times * r.cost[2] + Times *r.cost[3]);
	}

	inline bool CheckIfCraftable(Recipe& r) const {
		if (!r.castable)
			return false;
		if (r.repeatable) {
			int t = 8;
			for (int i = 0; i < 4; ++i) {
				if (r.cost[i] < 0) {
					int tmp = this->inventory[i] / -r.cost[i];
					if (tmp < t)
						t = tmp;
				}
			}
			while (t > 0 && TotalItems(r, t) > 10)
				--t;
			if (t > 0)
				r.timesCraftable = t;
			return (t > 0);
		}
		else
			return (CheckIfBrewable(r) && TotalItems(r, 1) <= 10 );
	}
	inline bool CheckIfLearnable(const Recipe& r, const int& depth) const {
		return (r.tomeIndex <= this->inventory[0] && g_turn < 10 && depth == 0);
	}
	inline bool CheckIfPossible(Recipe& r, const int& depth) const {
		if (r.actionType == BREW)
			return (CheckIfBrewable(r));
		else if (r.actionType == CAST)
			return (CheckIfCraftable(r));
		else if (r.actionType == LEARN)
			return (CheckIfLearnable(r, depth));
		else
			return false;
	}

	void	ApplySpellOnWitch(Recipe& r, const int& depth) {
		if (r.actionType == LEARN) {
			r.actionType = CAST;
			r.castable = true;
			this->inventory[0] += r.taxCount - r.tomeIndex;
		}
		else {
			int t = 1;
			if (r.repeatable && r.timesCraftable > 1) {
				t = r.timesCraftable;
			}
			for (int i = 0; i < 4; ++i)
				this->inventory[i] += t * r.cost[i];
			if (r.actionType == CAST)
				r.castable = false;
			else if (r.actionType == BREW) {
				this->score += r.price;
				this->timesScored += 1;
				if (brewedInXSteps == 0)
					brewedInXSteps = depth;
			}
		}
	}
	int score{};
	int timesScored{};
	int brewedInXSteps{};
private:
	array<int, 4> inventory{};
};

class  GameState {
public:
	GameState() = default;
	GameState(const GameState& x) {
		*this = x;
	}
	inline void ApplySpell(int depth) {
		if (depth == 0)
			return ;

		if (ToApplyID == -1) { // Resting value
			for (auto& r : this->recipes) {
				if (r.actionType == CAST)
					r.castable = true;
			}
			Actions.emplace_back(g_Rest);
		}
		else {
			int MyTomeIndex = 0;
			auto it = recipes.begin();
			while (it != recipes.end()) {
				if (it->id == this->ToApplyID)
					break;
				++it;
			}
			if (it->actionType == BREW) {
				this->value += static_cast<float>(static_cast<float>(it->price * it->price) / static_cast<float>(depth + 1));
			}
			else if (it->actionType == LEARN) {
				MyTomeIndex = it->tomeIndex;
				bool IsFreebie = (it->cost[0] >= 0 && it->cost[1] >= 0 && it->cost[2] >= 0 && it->cost[3] >= 0);
				int AmountItems = it->cost[0] + it->cost[1] + it->cost[2] + it->cost[3];
				float tmpvalue;
				if (g_turn < 8) {
					tmpvalue = static_cast<float>( (6 - it->tomeIndex) * (6 - it->tomeIndex) );
				}
				else {
					tmpvalue = static_cast<float>( rand() % 3 + 1) / 8 ; // NOLINT(cert-msc50-cpp)
				}
				if (IsFreebie && AmountItems >= 2 && it->tomeIndex < 3)
					tmpvalue += static_cast<float>( (5 - it->tomeIndex) * (5 - it->tomeIndex) );
//				cerr << "learning " << it->id << " is valued at " << tmpvalue << endl;
				this->value += tmpvalue;
			}
			else if (it->actionType == CAST) {
				float tmpvalue = 0.0f;
				if (g_CastValueMultiplier == 1 || depth > 1) {
					tmpvalue = static_cast<float>(rand() % 3 + 1) / 5; // NOLINT(cert-msc50-cpp)
					if (it->repeatable && it->timesCraftable > 1)
						tmpvalue *= 3 * static_cast<float>(it->timesCraftable);
				} else {
					for (int i = 1; i < 4; ++i)
						tmpvalue += static_cast<float>(it->cost[i] * g_CastValueMultiplier);
					if (it->repeatable && it->timesCraftable > 1)
						tmpvalue *= 2 * static_cast<float>(it->timesCraftable);
				}
				this->value += tmpvalue;
			}
			else throw runtime_error("Bad it->actionType in GameState::ApplySpell");

			Actions.emplace_back(*it);
			witches[ME].ApplySpellOnWitch(*it, depth);
			if (it->actionType == BREW)
				this->recipes.erase(it);
			else if (MyTomeIndex > 0) {
				for (auto &R : recipes) {
					if (R.actionType == LEARN && MyTomeIndex < R.tomeIndex)
						R.tomeIndex -= 1;
				}
			}
		}
	}
	GameState&  operator=(const GameState& x) {
		if (this != &x) {
			this->value = x.value;
			this->ToApplyID = x.ToApplyID;
			this->recipes = x.recipes;
			this->witches = x.witches;
			this->Actions = x.Actions;
		}
		return *this;
	}
	void	initialize(int actioncount) {
		recipes.reserve(actioncount);
		for (int i = 0; i < actioncount; ++i) {
			Recipe newrec;
			newrec.init();
			if (newrec.actionType != OPPONENT_CAST)
				recipes.push_back(newrec);
		}
		for (int i = 0; i < 2; ++i) {
			Witch w;
			w.initialize();
			witches[i] = w;
		}
	}
	void	SetCastValueMultiplier() {
		bool TheyCanBrew = false, ICanBrew = false;
		for (auto& R : this->recipes) {
			if (R.actionType != BREW)
				continue;
			if (this->witches[ME].CheckIfBrewable(R))
				ICanBrew = true;
			if (this->witches[BITCH].CheckIfBrewable(R))
				TheyCanBrew = true;
		}
		if (this->witches[BITCH].timesScored == 5 && TheyCanBrew && !ICanBrew)
			g_CastValueMultiplier = 20;
		else
			g_CastValueMultiplier = 1;
	}
//private:
	vector<Action>	Actions;
	float 			value{};
	int 			ToApplyID{};
	vector<Recipe>	recipes;
	array<Witch, 2>	witches{};
};

class Node {
public:
	Node() = default;
	Node(const Node& x) {
		*this = x;
	}
	Node&	operator=(const Node& x) {
		if (this != &x) {
			this->State = x.State;
			this->depth = x.depth;
		}
		return *this;
	}
	inline bool	operator<(const Node& x) const { return (this->State.value < x.State.value); } // Maybe change to State.witches[ME].score
	inline bool	operator>(const Node& x) const { return (this->State.value > x.State.value); }
	inline bool	operator<=(const Node& x) const { return (this->State.value <= x.State.value); }
	inline bool	operator>=(const Node& x) const { return (this->State.value >= x.State.value); }

	Node(const GameState& GS, int depth) : State(GS), depth(depth) { }


	inline void	ApplyPreviousSpell() {
		this->State.ApplySpell(depth);
	}

	inline void 	PutChildrenInQueue(vector<Node>& MyQueue ) {
		float Value2Rest = 0;
		if (this->State.witches[ME].timesScored == 6 || (g_CastValueMultiplier > 1 && depth > 0))
			return;
		for (auto& r : State.recipes) {
			if (r.actionType == CAST && !r.castable) {
				Value2Rest += 1.0f;
				continue;
			}
			else if (!this->State.witches[ME].CheckIfPossible(r, this->depth))
				continue;
			if (r.actionType == CAST && r.repeatable) {
				while (r.timesCraftable >= 1) {
					GameState NewState(State);
					NewState.ToApplyID = r.id;
					MyQueue.emplace_back(NewState, depth + 1);
					--r.timesCraftable;
				}
			}
			else {
				GameState NewState(State);
				NewState.ToApplyID = r.id;
				MyQueue.emplace_back(NewState, depth + 1);
			}
		}

		if (Value2Rest > 0.5) {
			GameState	RestingState(State);
			RestingState.ToApplyID = -1;
			MyQueue.emplace_back( RestingState, depth + 1 );
		}
	}

	inline void PrintPath() const {
		cerr << "best path value = " << this->State.value << endl;
		cerr << "Path in question:\n";
		for (auto& i : State.Actions) {
			cerr << '\t' << i;
		}
		cerr << "   My witch would have " << State.witches[ME].score << " points at the end of this path." << endl;

	}
	inline void TakeAction(const bool pathdebug) const {
		if (pathdebug)
			this->PrintPath();
		State.Actions[0].print();
	}

//private:
	GameState		State;
	int 			depth{};
};

bool	FiveGoalsCompare(const Node& a, const Node& b) {
	if (a.State.witches[ME].brewedInXSteps == 0 && b.State.witches[ME].brewedInXSteps > 0)
		return true;
	else if (b.State.witches[ME].brewedInXSteps != 0 && b.State.witches[ME].brewedInXSteps < a.State.witches[ME].brewedInXSteps)
		return true;
	return false;
}

void	Setup(GameState& state, const chrono::steady_clock::time_point& begin) {
	size_t i_Evaluated = 0, i_ChildrenAdded = 0;
	vector< Node >	Results;
	Results.reserve(100000);
	Node	Root(state, 0);
	Root.PutChildrenInQueue(Results);

	while ( currTimeMilli(begin) < 47 ) {
		while (Results.size() > i_Evaluated) {
			Results.at(i_Evaluated).ApplyPreviousSpell();
			++i_Evaluated;
		}
		try {
			Results.at(i_ChildrenAdded).PutChildrenInQueue(Results);
			++i_ChildrenAdded;
		} catch (exception& e) {
			cerr << "Trying to add child nodes threw " << e.what() << endl;
			break;
		}
	}

	g_total += Results.size();
	cerr << "Checked " << Results.size() << " nodes this turn, averaging " << g_total / (g_turn + 1) << endl;
	vector<Node>::const_iterator Max;
	if (g_turn > 20 && (state.witches[BITCH].timesScored == 5 || state.witches[ME].timesScored == 5)) {// or i scored 5 times
		Max = max_element(Results.begin(), Results.end(), FiveGoalsCompare);
		cerr << "FiveGoalsCompare has been used\n";
		if (Max == Results.begin()) {
			cerr << "FiveGoalsCompare gives a bad sort" << endl;
			Max = max_element(Results.begin(), Results.end());
		}
	}
	else
		Max = max_element(Results.begin(), Results.end());
//	cerr << "After finding max element, timestamp is " << static_cast<double>(currTimeMicro(begin)) / 1000.0 << " ms.\n";
	Max->TakeAction(true);
	Results.clear();
}

#pragma ide diagnostic ignored "EndlessLoop"
int main()
{
	g_Rest.actionType = REST;
	g_Wait.actionType = WAIT;
	int ScoreTable[2]{}, TimesScored[2]{};

	while (true) {
		int actionCount;
		cin >> actionCount; cin.ignore();
		GameState State;
		State.initialize(actionCount);
		auto begin = chrono::steady_clock::now();
		if (g_turn > 0) {
			for (int player = ME; player <= BITCH; ++player) {
				if (State.witches[player].score != ScoreTable[player]) ++TimesScored[player];
					State.witches[player].timesScored = TimesScored[player];
			}
		}
//		cerr << "I have scored " << State.witches[ME].timesScored << " times, and the opponent " << State.witches[BITCH].timesScored << " times." << endl;
		ScoreTable[ME] = State.witches[ME].score;
		ScoreTable[BITCH] = State.witches[BITCH].score;
		cerr << "turn " << g_turn << endl;
		State.SetCastValueMultiplier();
		Setup(State, begin);
		++g_turn;
	}
}


		}
	}

	g_total += Results.size();
	cerr << "Checked " << Results.size() << " nodes this turn, averaging " << g_total / (g_turn + 1) << endl;
	vector<Node>::const_iterator Max;
	if (g_turn > 20 && (state.witches[BITCH].timesScored == 5 || state.witches[ME].timesScored == 5)) {// or i scored 5 times
		Max = max_element(Results.begin(), Results.end(), FiveGoalsCompare);
		cerr << "FiveGoalsCompare has been used\n";
		if (Max == Results.begin()) {
			cerr << "FiveGoalsCompare gives a bad sort" << endl;
			Max = max_element(Results.begin(), Results.end());
		}
	}
	else
		Max = max_element(Results.begin(), Results.end());
//	cerr << "After finding max element, timestamp is " << static_cast<double>(currTimeMicro(begin)) / 1000.0 << " ms.\n";
	Max->TakeAction(true);
	Results.clear();
}

#pragma ide diagnostic ignored "EndlessLoop"
int main()
{
	g_Rest.actionType = REST;
	g_Wait.actionType = WAIT;
	int ScoreTable[2]{}, TimesScored[2]{};

	while (true) {
		int actionCount;
		cin >> actionCount; cin.ignore();
		GameState State;
		State.initialize(actionCount);
		auto begin = chrono::steady_clock::now();
		if (g_turn > 0) {
			for (int player = ME; player <= BITCH; ++player) {
				if (State.witches[player].score != ScoreTable[player]) ++TimesScored[player];
					State.witches[player].timesScored = TimesScored[player];
			}
		}
//		cerr << "I have scored " << State.witches[ME].timesScored << " times, and the opponent " << State.witches[BITCH].timesScored << " times." << endl;
		ScoreTable[ME] = State.witches[ME].score;
		ScoreTable[BITCH] = State.witches[BITCH].score;
		cerr << "turn " << g_turn << endl;
		State.SetCastValueMultiplier();
		Setup(State, begin);
		++g_turn;
	}
}

