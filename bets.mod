set BOOKIES;
set MARKETS;
set OUTCOMES;

param minimum_odds {BOOKIES};
param minimum_odds_freebet {BOOKIES} default 1.0;
param max_freebet {BOOKIES};
param freebet_snr {BOOKIES} binary default 1;  # 1 = stake not returned, 0 = stake returned

param odds {BOOKIES, MARKETS, OUTCOMES} default 0;

param initial_cash >= 0;
param dummy_max    >= 0;
param profit_slack >= 0 default 300;

# ----------------
# Decision vars
# ----------------
var bookie_selected {b in BOOKIES} binary;

# Round 1
var chosen_market_1 {m in MARKETS} binary;
var chosen_1 {b in BOOKIES, m in MARKETS, o in OUTCOMES} binary;
var first_round_bet {b in BOOKIES, m in MARKETS, o in OUTCOMES} >= 0;

# Earned freebet amount at each bookie (capped)
var freebets {b in BOOKIES} >= 0;

# Round 2 is recourse: depends on which outcome o1 won in round 1
var chosen_market_2 {o1 in OUTCOMES, m in MARKETS} binary;
var chosen_2 {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES} binary;

var rebet_cash    {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES} >= 0;
var rebet_freebet {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES} >= 0;

# Derived total bet in round 2 (optional, but handy)
var second_round_bet {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES} >= 0;

# Path profit
var path_profit {o1 in OUTCOMES, o2 in OUTCOMES};

# Maximin objective helpers
var min_profit;
var max_profit;

# ----------------
# Objective
# ----------------
maximize profit: min_profit;

# ----------------
# ROUND 1 constraints
# ----------------
# One market for round 1
s.t. one_market_round1:
    sum {m in MARKETS} chosen_market_1[m] = 1;

# If a bet is placed it must be on the chosen market and selected bookie
s.t. r1_market_link {b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    first_round_bet[b,m,o] <= chosen_market_1[m] * dummy_max;

s.t. r1_selected_link {b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    first_round_bet[b,m,o] <= bookie_selected[b] * dummy_max;

# At most one (market,outcome) per bookie in round 1 (but can also sit out)
s.t. r1_one_choice_per_bookie {b in BOOKIES}:
    sum {m in MARKETS, o in OUTCOMES} chosen_1[b,m,o] <= 1;

s.t. r1_choice_implies_bet {b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    first_round_bet[b,m,o] <= chosen_1[b,m,o] * dummy_max;

# Total cash used in round 1 cannot exceed initial cash
s.t. cash_budget_round1:
    sum {b in BOOKIES, m in MARKETS, o in OUTCOMES} first_round_bet[b,m,o] <= initial_cash;

# Minimum odds / zero odds guards (round 1)
s.t. r1_min_odds_block {b in BOOKIES, m in MARKETS, o in OUTCOMES :
        odds[b,m,o] > 0 && odds[b,m,o] < minimum_odds[b]}:
    first_round_bet[b,m,o] = 0;

s.t. r1_zero_odds_block {b in BOOKIES, m in MARKETS, o in OUTCOMES :
        odds[b,m,o] = 0}:
    first_round_bet[b,m,o] = 0;

# Freebet earned: <= qualifying stake, <= cap, and 0 if bookie not selected
s.t. freebet_le_stake {b in BOOKIES}:
    freebets[b] <= sum {m in MARKETS, o in OUTCOMES} first_round_bet[b,m,o];

s.t. freebet_le_cap {b in BOOKIES}:
    freebets[b] <= max_freebet[b];

s.t. freebet_only_if_selected {b in BOOKIES}:
    freebets[b] <= bookie_selected[b] * max_freebet[b];

# -------------------
# ROUND 2 constraints
# -------------------
# Define total bet
s.t. r2_total_def {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    second_round_bet[o1,b,m,o] = rebet_cash[o1,b,m,o] + rebet_freebet[o1,b,m,o];

# One market for round 2 (for each o1 scenario)
s.t. one_market_round2 {o1 in OUTCOMES}:
    sum {m in MARKETS} chosen_market_2[o1,m] = 1;

# Round 2 market must be different from Round 1 market
s.t. r2_different_market {o1 in OUTCOMES, m in MARKETS}:
    chosen_market_1[m] + chosen_market_2[o1,m] <= 1;

# Link to chosen market and selected bookies
s.t. r2_market_link {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    second_round_bet[o1,b,m,o] <= chosen_market_2[o1,m] * dummy_max;

s.t. r2_selected_link {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    second_round_bet[o1,b,m,o] <= bookie_selected[b] * dummy_max;

# At most one outcome per bookie in round 2 (per scenario), can sit out
s.t. r2_one_choice_per_bookie {o1 in OUTCOMES, b in BOOKIES}:
    sum {m in MARKETS, o in OUTCOMES} chosen_2[o1,b,m,o] <= 1;

s.t. r2_choice_implies_bet {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES}:
    second_round_bet[o1,b,m,o] <= chosen_2[o1,b,m,o] * dummy_max;

# Odds guards round 2 (cash + freebet)
s.t. r2_min_odds_block {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES :
        odds[b,m,o] > 0 && odds[b,m,o] < minimum_odds[b]}:
    second_round_bet[o1,b,m,o] = 0;

s.t. r2_zero_odds_block {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES :
        odds[b,m,o] = 0}:
    second_round_bet[o1,b,m,o] = 0;

# Freebet minimum odds constraint (only on freebet portion)
s.t. r2_min_odds_freebet_block {o1 in OUTCOMES, b in BOOKIES, m in MARKETS, o in OUTCOMES :
        odds[b,m,o] > 0 && odds[b,m,o] < minimum_odds_freebet[b]}:
    rebet_freebet[o1,b,m,o] = 0;

# Freebet usage limited by earned freebets (per scenario same cap)
s.t. freebet_usage_limit {o1 in OUTCOMES, b in BOOKIES}:
    sum {m in MARKETS, o in OUTCOMES} rebet_freebet[o1,b,m,o] <= freebets[b];

# ----------------
# Budget flow: round 2 cash depends on round-1 outcome o1
# ----------------
# Cash available after round 1 when outcome o1 wins:
# initial_cash
#   - total round1 stakes
#   + payout from the winning round1 bets (stake * odds)
s.t. r2_cash_budget {o1 in OUTCOMES}:
    sum {b in BOOKIES, m in MARKETS, o in OUTCOMES} rebet_cash[o1,b,m,o]
    <= initial_cash
       - sum {b in BOOKIES, m in MARKETS, o in OUTCOMES} first_round_bet[b,m,o]
       + sum {b in BOOKIES, m in MARKETS} first_round_bet[b,m,o1] * odds[b,m,o1];

# ----------------
# Profit calculation
# ----------------
s.t. calc_path_profit {o1 in OUTCOMES, o2 in OUTCOMES}:
    path_profit[o1,o2] =
        # Round 1 net
        + sum {b in BOOKIES, m in MARKETS} first_round_bet[b,m,o1] * odds[b,m,o1]
        - sum {b in BOOKIES, m in MARKETS, o in OUTCOMES} first_round_bet[b,m,o]
        # Round 2 cash net (scenario o1)
        + sum {b in BOOKIES, m in MARKETS} rebet_cash[o1,b,m,o2] * odds[b,m,o2]
        - sum {b in BOOKIES, m in MARKETS, o in OUTCOMES} rebet_cash[o1,b,m,o]
        # Round 2 freebet return (scenario o1)
        + sum {b in BOOKIES, m in MARKETS}
            rebet_freebet[o1,b,m,o2] *
            (if freebet_snr[b] then (odds[b,m,o2] - 1) else odds[b,m,o2]);

# Maximin bounds
s.t. min_profit_bound {o1 in OUTCOMES, o2 in OUTCOMES}:
    min_profit <= path_profit[o1,o2];

# Readd ?
# s.t. max_profit_bound {o1 in OUTCOMES, o2 in OUTCOMES}:
#     max_profit >= path_profit[o1,o2];

# s.t. profit_spread:
    #     max_profit - min_profit <= profit_slack;
