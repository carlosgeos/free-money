set Bookies;
set Outcomes;
set Matches;

param money_avail;
param dummy_max;
param profit_slack;
param odds {i in Bookies, j in Outcomes, m in Matches};
param minimum_odds {i in Bookies};
param bonuses {i in Bookies};
param freebets_multiplier {i in Bookies};
param money_per_bookie {i in Bookies};

# Amount of real money in each bookie for each option
var money {i in Bookies, j in Outcomes, m in Matches} >= 0;
# Amount of money made for each option, for each bookie
var profit_1 {i in Bookies, j in Outcomes, m in Matches};
var freebets {i in Bookies};
var rebet {i in Bookies, j in Outcomes, m in Matches};
var profit_2 {i in Bookies, j in Outcomes, m in Matches};

# Auxiliary variables to create Special Ordered Sets 1 (at most one
# value can be non-zero)
var chosen_1 {i in Bookies, j in Outcomes, m in Matches} binary;
var chosen_2 {i in Bookies, j in Outcomes, m in Matches} binary;
var chosen_match_1 {m in Matches} binary;
var chosen_match_2 {m in Matches} binary;

##########
# Checks #
##########

### These might change with time ###
# check {i in Bookies, j in Outcomes, m in Matches}: odds[i, j, m] > minimum_odds[i], = 0;

######################
# Objective function #
######################

maximize profit:
    sum {i in Bookies, j in Outcomes, m in Matches} profit_2[i, j, m];

# Max values in each round
s.t. r1 {i in Bookies, j in Outcomes, m in Matches}:
    money[i, j, m] * bonuses[i] * odds[i, j, m] = profit_1[i, j, m];

s.t. fb {i in Bookies}:
    sum {j in Outcomes, m in Matches} money[i, j, m] * freebets_multiplier[i] = freebets[i];

s.t. rbt {i in Bookies, j in Outcomes, m in Matches}:
    rebet[i, j, m] = profit_1[i, j, m] + freebets[i];

s.t. r2 {i in Bookies, j in Outcomes, m in Matches}:
    profit_1[i, j, m] * odds[i, j, m] + freebets[i] * odds[i, j, m] - freebets[i] = profit_2[i, j, m];

# For the same bookie, betting on different outcomes is not possible
s.t. one_option_one_bookie {i in Bookies, j in Outcomes, m in Matches}:
    money[i, j, m] <= chosen_1[i, j, m] * dummy_max;
s.t. one_option_one_bookie_aux {i in Bookies}:
    sum {j in Outcomes, m in Matches} chosen_1[i, j, m] = 1;

s.t. second_round_one_option_one_bookie {i in Bookies, j in Outcomes, m in Matches}:
    rebet[i, j, m] <= chosen_2[i, j, m] * dummy_max;
s.t. second_round_one_option_one_bookie_aux {i in Bookies}:
    sum {j in Outcomes, m in Matches} chosen_2[i, j, m] = 1;

# We can only go for one match at a time
s.t. first_betting_round_one_match {i in Bookies, j in Outcomes, m in Matches}:
    money[i, j, m] <= chosen_match_1[m] * dummy_max;
s.t. first_betting_round_one_match_aux:
    sum {m in Matches} chosen_match_1[m] = 1;
s.t. second_betting_round_one_match {i in Bookies, j in Outcomes, m in Matches}:
    rebet[i, j, m] <= chosen_match_2[m] * dummy_max;
s.t. second_betting_round_one_match_aux:
    sum {m in Matches} chosen_match_2[m] = 1;

# At least 2 bookies per option after the first round
s.t. minimum_bookies_per_option {j in Outcomes}:
    sum {i in Bookies, m in Matches} chosen_1[i, j, m] >= 2;

# Matches in different rounds should not be the same
s.t. different_picks {m in Matches}: chosen_match_1[m] + chosen_match_2[m] <= 1;

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. similar_profits_on_each_outcome {j in Outcomes, k in Outcomes: k <> j}:
    sum {i in Bookies, m in Matches} profit_2[i, j, m] - sum {i in Bookies, m in Matches} profit_2[i, k, m] <= profit_slack;
#s.t. similar_profits_on_each_bookie {i in Bookies, k in Bookies: i <> k}: sum {j in Outcomes} max_profit[i, j] - sum {j in Outcomes} max_profit[k, j] <= bookie_profit_slack;

# <= bookie_profit_slack, >= -bookie_profit_slack;
# s.t. similar_profits_among_bookies_of_same_outcome {j in Outcomes, i in Bookies, k in Bookies: i <> k}: max_profit[i, j] - max_profit[k, j]

# There is a maximum amount we can deposit in each bookie (no more
# bonus after that)
s.t. maximum_efficient_deposit {i in Bookies}:
    sum {j in Outcomes, m in Matches} money[i, j, m] <= money_per_bookie[i];

# There is a maximum amount we can rebet on each bookie
#s.t. maximum_rebet_money {}

# Special conditions for bonuses. Minimum odds to bet on. Redundant if
# check captures it, but will work when check is commented out.
# s.t. bonus_condition1 {i in Bookies, j in Outcomes}: (if odds[i, j] < minimum_odds[i] then money[i, j] else 0) = 0;

# Special condition to put some bookmaker in a group of N bookmakers
# (might be useful to play with higher odds in a second round and
# fulfill the bonus conditions)
# s.t. bookie_grouping {i in Bookies, j in Outcomes}: sum {i in Bookies} chosen[i, j] >= max {i in Bookies: } grouping[i];

# Total money available
s.t. total_money:
    sum {i in Bookies, j in Outcomes, m in Matches} money[i, j, m] <= money_avail;


##########################
# Post processing checks #
##########################

# check

# printf 'Starting money: %.2f\n', money_avail;
# printf 'Money used: %.2f\n\n', sum {i in Bookies, j in Outcomes, m in Matches} money[i, j, m];

# printf 'Total after first bet: %.2f\n', sum {i in Bookies, j in Outcomes, m in Matches} profit_1[i, j, m];
# printf {j in Outcomes, m in Matches}: 'Total for %s = %.2f\n', j, sum{i in Bookies} profit_1[i, j, m];
# printf '\n';

# for {j in Outcomes}{
#     printf 'Bookiesookies on %s:\n' , j;
#     for {i in Bookies: money[i, j] > 0} {
#         printf '%s ', i;
#     }
# #    printf ''
#     printf '\n\n';
# }

# printf {i in Bookies, j in Outcomes: money[i, j] <> 0}: 'Money on %10s for %2s: \t%6.2fe | Profit: %6.2fe\n', i, j, money[i, j], max_profit[i, j];
