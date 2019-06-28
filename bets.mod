set H;                          # Betting houses
set O;                          # Options
param odds {i in H, j in O};
param after_bet {i in H};
param freebets {i in H};
param money_with_bonus_per_house{i in H};

# Amount of money in each house for each option
var money {i in H, j in O} >= 0;

# Amount of money made for each option, for each house
var max_profit {i in H, j in O};

maximize profit: sum {i in H, j in O} max_profit[i, j];

# Max values for each option
s.t. max {i in H, j in O}: money[i, j] * odds[i, j] + money[i, j] * after_bet[i] - money[i, j] * freebets[i] = max_profit[i, j];

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning.
s.t. equilib {j in O, k in O: k <> j}: sum {i in H} max_profit[i, j] = sum {i in H} max_profit[i, k];

# Special conditions for bonuses
# TODO: make conditions dynamic
s.t. per_house_condition {i in H}: sum {j in O} money[i, j] <= money_with_bonus_per_house[i];

# TODO: add special ordered set of type 1 if no more than one betting
# house should be used for one option:
# https://en.wikibooks.org/wiki/GLPK/Modeling_tips#SOS1_:_special_ordered_set_of_type_1

solve;

printf '#################################\n\n';

printf {j in O}: 'Total for %s = %.3f\n', j, sum{i in H} max_profit[i, j];
printf '\n';

for {j in O}{
    printf 'Houses for %s:\n' , j;
    for {i in H: money[i, j] > 0} {
        printf '%s ', i;
    }
    printf '\n\n';
}
printf {i in H, j in O: money[i, j] <> 0}: 'Money on %s for %s = %.2f\n', i, j, money[i, j];
