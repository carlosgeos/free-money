set BELGIAN_BOOKIES;

param minimum_odds {BELGIAN_BOOKIES};
param money_per_bookie {BELGIAN_BOOKIES};
param bonus_multiplier {BELGIAN_BOOKIES};
param freebets_multiplier {BELGIAN_BOOKIES};

set BOOKIES within BELGIAN_BOOKIES;
set MATCHES;
set OUTCOMES;

param odds {BOOKIES, MATCHES, OUTCOMES};
param money_avail integer;
param dummy_max integer;
param profit_slack integer;

var money {BOOKIES, MATCHES, OUTCOMES} >= 0;
var profit_1 {BOOKIES, MATCHES, OUTCOMES} >= 0;
var freebets {BOOKIES} >= 0;
var rebet {BOOKIES} >= 0;
var rebet_allocation {BOOKIES, MATCHES, OUTCOMES} >= 0;
var profit_2 {BOOKIES, MATCHES, OUTCOMES} >= 0;

# Auxiliary variables to create Special Ordered Sets 1 (at most one
# value can be non-zero)
var chosen_1 {BOOKIES, MATCHES, OUTCOMES} binary;
var chosen_2 {BOOKIES, MATCHES, OUTCOMES} binary;
var chosen_match_1 {MATCHES} binary;
var chosen_match_2 {MATCHES} binary;
var chosen_combination {BOOKIES, OUTCOMES, OUTCOMES} binary;

##########
# Checks #
##########

### These might change with time ###
# check {b in BOOKIES, o in OUTCOMES, m in MATCHES}: odds[i, j, m] > minimum_odds[i], = 0;

######################
# Objective function #
######################

maximize profit:
    sum {b in BOOKIES, m in MATCHES, o in OUTCOMES} profit_2[b, m, o];

# Max values in each round
s.t. first_bet {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    money[b, m, o] * bonus_multiplier[b] * odds[b, m, o] + money[b, m, o] * freebets_multiplier[b] = profit_1[b, m, o];

# s.t. rbt {b in BOOKIES}:
#     rebet[b] <= (sum {m in MATCHES, o in OUTCOMES} profit_1[b, m, o]) + freebets[b];

s.t. rbt2 {b in BOOKIES}:
    sum {m in MATCHES, o in OUTCOMES} rebet_allocation[b, m, o] <= sum {m in MATCHES, o in OUTCOMES} profit_1[b, m, o];

s.t. second_bet {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    rebet_allocation[b, m, o] * odds[b, m, o] = profit_2[b, m, o];

s.t. link {m in MATCHES, o in OUTCOMES, M in MATCHES: m <> M}:
    (sum {b in BOOKIES} chosen_1[b, m, o]) >= card({O in OUTCOMES: sum {b in BOOKIES} odds[b, M, O] <> 0}) * chosen_match_2[M] * chosen_match_1[m];

s.t. asdf {}:
    sum {b in BOOKIES, o in OUTCOMES, O in OUTCOMES[M]} chosen_combination[b, m, o, M, O] = 1;

s.t. qwer {b in BOOKIES, o in OUTCOMES, O in OUTCOMES}:
    sum {m in MATCHES} money[b, m, o] * sum {m in MATCHES} rebet_allocation[b, m, O] <= chosen_combination[b, o, O] * dummy_max * dummy_max;


# For the same bookie, betting on different outcomes is not possible
s.t. first_round_one_option_one_bookie {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    money[b, m, o] <= chosen_1[b, m, o] * dummy_max;
s.t. first_round_one_option_one_bookie_aux {b in BOOKIES}:
    sum {m in MATCHES, o in OUTCOMES} chosen_1[b, m, o] = 1;
s.t. second_round_one_option_one_bookie {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    rebet_allocation[b, m, o] <= chosen_2[b, m, o] * dummy_max;
s.t. second_round_one_option_one_bookie_aux {b in BOOKIES}:
    sum {m in MATCHES, o in OUTCOMES} chosen_2[b, m, o] = 1;

# For the same bookie, even when different on the same outcome, only
# one match should be chosen
s.t. first_round_one_match {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    money[b, m, o] <= chosen_match_1[m] * dummy_max;
s.t. first_round_one_match_aux:
    sum {m in MATCHES} chosen_match_1[m] = 1;
s.t. second_round_one_match {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    rebet_allocation[b, m, o] <= chosen_match_2[m] * dummy_max;
s.t. second_round_one_match_aux:
    sum {m in MATCHES} chosen_match_2[m] = 1;

# Matches in different rounds should not be the same
s.t. different_picks {m in MATCHES}:
    chosen_match_1[m] + chosen_match_2[m] <= 1;

# At least 2 bookies per outcome after the first round
s.t. minimum_bookies_per_option {m in MATCHES, o in OUTCOMES}:
    sum {b in BOOKIES} chosen_1[b, m, o] >= 2 * chosen_match_1[m];

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. similar_profits {m in MATCHES, o in OUTCOMES, O in OUTCOMES: o <> O and sum {b in BOOKIES} odds[b, m, o] <> 0 and sum {b in BOOKIES} odds[b, m, O] <> 0}:
    sum {b in BOOKIES} profit_2[b, m, o] - sum {b in BOOKIES} profit_2[b, m, O] <= profit_slack;

# There is a maximum amount we can deposit in each bookie (no more
# bonus after that)
s.t. maximum_efficient_deposit {b in BOOKIES}:
    sum {m in MATCHES, o in OUTCOMES} money[b, m, o] <= money_per_bookie[b];

# Special conditions for bonuses. Minimum odds to bet on. Redundant if
# check captures it, but will work when check is commented out.
s.t. minimum_odds_condition1 {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    (if odds[b, m, o] < minimum_odds[b] then money[b, m, o] else 0) = 0;
s.t. minimum_odds_condition2 {b in BOOKIES, m in MATCHES, o in OUTCOMES}:
    (if odds[b, m, o] < minimum_odds[b] then rebet_allocation[b, m, o] else 0) = 0;

# Special condition to put some bookmaker in a group of N bookmakers
# (might be useful to play with higher odds in a second round and
# fulfill the bonus conditions)
# s.t. bookie_grouping {b in BOOKIES, o in OUTCOMES}: sum {b in BOOKIES} chosen[i, j] >= max {b in BOOKIES: } grouping[i];

# Total money available
s.t. total_money:
    sum {b in BOOKIES, m in MATCHES, o in OUTCOMES} money[b, m, o] <= money_avail;


##########################
# Post processing checks #
##########################
