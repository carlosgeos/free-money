set B;                          # Betting bookies
set O;                          # Outcomes
param dummy_max;
param slack;
param odds {i in B, j in O};
param bonuses {i in B};
param freebets {i in B};
param money_per_bookie {i in B};
param stake {i in B};           # this is used to substract the stake
                                # (often done when using freebets)
param grouping {i in B};

# Amount of money in each bookie for each option
var money {i in B, j in O} >= 0;

# Amount of money made for each option, for each bookie
var max_profit {i in B, j in O};

# Auxiliary variable to create a Special Ordered Set 1 (at most one
# value can be non-zero)
var chosen {i in B, j in O} binary;
var chosen_chosen {i in B, j in O} binary;

##########
# Checks #
##########

### These might change with time ###

######################
# Objective function #
######################

maximize profit: sum {i in B, j in O} max_profit[i, j];

# Max values for each option
s.t. max {i in B, j in O}: money[i, j] * bonuses[i] * odds[i, j] + money[i, j] * freebets[i] - money[i, j] * stake[i] = max_profit[i, j];

# For the same bookie, betting on different outcomes is not possible
s.t. one_option_one_bookie {i in B, j in O}: money[i, j] <= chosen[i, j] * dummy_max;
s.t. one_option_one_bookie_aux {i in B}: sum {j in O} chosen[i, j] = 1;


#s.t. n_bookies_one_option {j in O}: sum {i in B}
# To force a second round, uncomment the following. It can be
# problematic when used in the second round itself.
#s.t. two_bookies_per_option {j in O}: sum {i in B} chosen[i, j] >= 2;

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. equilib {j in O, k in O: k <> j}: sum {i in B} max_profit[i, j] - sum {i in B} max_profit[i, k] <= slack;

# There is a maximum amount we can deposit in each bookie (no more
# bonus after that)
s.t. per_bookie_condition {i in B}: sum {j in O} money[i, j] <= money_per_bookie[i];

# Special conditions for bonuses. These can change over time.
s.t. bonus_condition1 {i in B, j in O}: (if i = 'betFIRST' and odds[i, j] < 1.4 then money[i, j] else 0) = 0;


# Special condition to put some bookmaker in a group of N bookmakers
# (might be useful to play with higher odds in a second round and
# fulfill the bonus conditions)
# s.t. bookie_grouping {j in O}: sum {i in B} chosen[i, j] >= max {i in B: } grouping[i];

solve;

##########################
# Post processing checks #
##########################

# check

#############
# Reporting #
#############

printf '#################################\n\n';

printf 'Starting money: %.2f\n', sum {i in B} money_per_bookie[i];
printf 'Money used: %.2f\n\n', sum {i in B, j in O} money[i, j];
printf 'Total: %.2f\n', sum {i in B, j in O} max_profit[i, j];
printf {j in O}: 'Total for %s = %.2f\n', j, sum{i in B} max_profit[i, j];
printf '\n';

for {j in O}{
    printf 'Bookies for %s:\n' , j;
    for {i in B: money[i, j] > 0} {
        printf '%s ', i;
    }
    printf '\n\n';
}
printf {i in B, j in O: money[i, j] <> 0}: 'Money on %s for %s = %.2f\n', i, j, money[i, j];
