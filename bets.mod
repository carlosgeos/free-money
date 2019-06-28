set H;                          # Betting houses
set O;                          # Options
param dummy_max;
param slack;
param odds {i in H, j in O};
param bonuses {i in H};
param freebets {i in H};
param money_per_house {i in H};
param stake {i in H};           # this is used to substract the stake
                                # (often done when using freebets)

# Amount of money in each house for each option
var money {i in H, j in O} >= 0;

# Amount of money made for each option, for each house
var max_profit {i in H, j in O};

# Auxiliary variable to create a Special Ordered Set 1 (at most one
# value can be non-zero)
var chosen {i in H, j in O} binary;

##########
# Checks #
##########

### These might change with time ###

# check

######################
# Objective function #
######################

maximize profit: sum {i in H, j in O} max_profit[i, j];

# Max values for each option
s.t. max {i in H, j in O}: money[i, j] * bonuses[i] * odds[i, j] + money[i, j] * freebets[i] - money[i, j] * stake[i] = max_profit[i, j];

# For the same house, betting on different outcomes is not possible
s.t. one_option_one_house {i in H, j in O}: money[i, j] <= chosen[i, j] * dummy_max;
s.t. one_option_one_house_aux {i in H}: sum {j in O} chosen[i, j] = 1;

# To force a second round, uncomment the following. It can be
# problematic when used in the second round itself.
#s.t. two_houses_per_option {j in O}: sum {i in H} chosen[i, j] >= 2;

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. equilib {j in O, k in O: k <> j}: sum {i in H} max_profit[i, j] - sum {i in H} max_profit[i, k] <= slack;

# There is a maximum amount we can deposit in each house (no more
# bonus after that)
s.t. per_house_condition {i in H}: sum {j in O} money[i, j] <= money_per_house[i];

# Special conditions for bonuses. These can change over time.
s.t. bonus_condition1 {i in H, j in O}: (if i = 'betFIRST' and odds[i, j] < 1.4 then money[i, j] else 0) = 0;

solve;

##########################
# Post processing checks #
##########################

# check

#############
# Reporting #
#############

printf '#################################\n\n';

printf 'Starting money: %.2f\n', sum {i in H} money_per_house[i];
printf 'Money used: %.2f\n\n', sum {i in H, j in O} money[i, j];
printf 'Total: %.2f\n', sum {i in H, j in O} max_profit[i, j];
printf {j in O}: 'Total for %s = %.2f\n', j, sum{i in H} max_profit[i, j];
printf '\n';

for {j in O}{
    printf 'Houses for %s:\n' , j;
    for {i in H: money[i, j] > 0} {
        printf '%s ', i;
    }
    printf '\n\n';
}
printf {i in H, j in O: money[i, j] <> 0}: 'Money on %s for %s = %.2f\n', i, j, money[i, j];
