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
param stake {i in Bookies};           # this is used to substract the
                                      # stake (often done when using
                                      # freebets)

# Amount of real money in each bookie for each option
var money {i in Bookies, j in Outcomes, m in Matches} >= 0;
# Amount of money made for each option, for each bookie
var profit_1 {i in Bookies, j in Outcomes, m in Matches};
var freebets {i in Bookies};
var profit_2 {i in Bookies, j in Outcomes, m in Matches};

# Auxiliary variable to create a Special Ordered Set 1 (at most one
# value can be non-zero)
var chosen_1 {i in Bookies, j in Outcomes, m in Matches} binary;
var chosen_2 {i in Bookies, j in Outcomes, m in Matches} binary;

##########
# Checks #
##########

### These might change with time ###
# check {i in Bookies, j in Outcomes, m in Matches}: odds[i, j, m] > minimum_odds[i], = 0;

######################
# Objective function #
######################

maximize profit: sum {i in Bookies, j in Outcomes, m in Matches} profit_2[i, j, m];

# Max values in each round
s.t. r1 {i in Bookies, j in Outcomes, m in Matches}: money[i, j, m] * bonuses[i] * odds[i, j, m] = profit_1[i, j, m];

s.t. fb {i in Bookies}: sum {j in Outcomes, m in Matches} money[i, j, m] * freebets_multiplier[i] = freebets[i];

s.t. r2 {i in Bookies, j in Outcomes, m in Matches}: profit_1[i, j, m] * odds[i, j, m] + freebets[i] * odds[i, j, m] - freebets[i] = profit_2[i, j, m];

# For the same bookie, betting on different outcomes is not possible
s.t. one_option_one_bookie {i in Bookies, j in Outcomes, m in Matches}: money[i, j, m] <= chosen_1[i, j, m] * dummy_max;
s.t. one_option_one_bookie_aux {i in Bookies}: sum {j in Outcomes, m in Matches} chosen_1[i, j, m] = 1;

# TODO: All moneys in one match (same match). google

s.t. one_match_one_bookie {i in Bookies, j in Outcomes, m in Matches}: money[i, j, m] <= chosen_1[i, j, m] * dummy_max;
s.t. one_match_one_bookie_aux {i in Bookies}: sum {j in Outcomes, m in Matches} chosen_1[i, j, m] = 1;


# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. similar_profits_on_each_outcome {j in Outcomes, k in Outcomes: k <> j}: sum {i in Bookies, m in Matches} profit_1[i, j, m] - sum {i in Bookies, m in Matches} profit_1[i, k, m] <= profit_slack;
#s.t. similar_profits_on_each_bookie {i in Bookies, k in Bookies: i <> k}: sum {j in Outcomes} max_profit[i, j] - sum {j in Outcomes} max_profit[k, j] <= bookie_profit_slack;

# <= bookie_profit_slack, >= -bookie_profit_slack;
# s.t. similar_profits_among_bookies_of_same_outcome {j in Outcomes, i in Bookies, k in Bookies: i <> k}: max_profit[i, j] - max_profit[k, j]

# There is a maximum amount we can deposit in each bookie (no more
# bonus after that)
# s.t. per_bookie_condition {i in Bookies}: sum {j in Outcomes} money[i, j] = money_per_bookie[i];

# Special conditions for bonuses. Minimum odds to bet on. Redundant if
# check captures it, but will work when check is commented out.
# s.t. bonus_condition1 {i in Bookies, j in Outcomes}: (if odds[i, j] < minimum_odds[i] then money[i, j] else 0) = 0;

# Special condition to put some bookmaker in a group of N bookmakers
# (might be useful to play with higher odds in a second round and
# fulfill the bonus conditions)
# s.t. bookie_grouping {i in Bookies, j in Outcomes}: sum {i in Bookies} chosen[i, j] >= max {i in Bookies: } grouping[i];

# Total money available
s.t. total_money: sum {i in Bookies, j in Outcomes, m in Matches} money[i, j, m] <= money_avail;


##########################
# Post processing checks #
##########################

# check

#############
# Reporting #
#############
# solve;
# printf '#################################\n\n';

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
