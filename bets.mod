set H;                          # Betting houses
set O;                          # Options
param odds {i in H, j in O};
param money_with_bonus_per_house{i in H};
# Binary value that determines if betting house h_i is chosen for some
# option
var chosen {i in H, j in O} binary;

# Amount of money in each house for each option
var money {i in H, j in O} >= 0;

# Amount of money made for each option, for each house
var max_profit {i in H, j in O};

maximize profit: sum {i in H, j in O} max_profit[i, j];

# Max values for each option
s.t. max {i in H, j in O}: money[i, j] * odds[i, j] = max_profit[i, j];

# We are bad at sports betting, so all outcomes should be leveled in
# terms of winning. Quirk: The profit of Napoleon is 50% of the
# initial money, since we get 50% of the initial money in free bets.
s.t. equilib {j in O, k in O}: sum {i in H} max_profit[i, j] = sum {i in H} max_profit[i, k];

# Special conditions for bonuses
# TODO: make conditions dynamic
s.t. betfirst {i in H: i = "betFIRST"}: sum {j in O} money[i, j] <= 400;
s.t. bingoal {i in H: i = "Bingoal"}: sum {j in O} money[i, j] <= 200;
s.t. bwin {i in H: i = "Bwin"}: sum {j in O} money[i, j] <= 240;
s.t. betway {i in H: i = "Betway"}: sum {j in O} money[i, j] <= 200;
s.t. bet777 {i in H: i = "Bet777"}: sum {j in O} money[i, j] <= 450;
s.t. napoleon {i in H: i = "Napoleon"}: sum {j in O} money[i, j] <= 400;
s.t. unibet {i in H: i = "Unibet"}: sum {j in O} money[i, j] <= 100;
s.t. ladbrokes {i in H: i = "Ladbrokes"}: sum {j in O} money[i, j] <= 400;

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

data;

# Houses
set H := betFIRST Bingoal Bwin Betway Bet777 Napoleon Unibet Ladbrokes;

# Options for the home team
set O := Win Draw Lose;

param odds:      Win    Draw    Lose :=
    betFIRST    2.30    3.05    3.45
    Bingoal     2.30    2.95    3.60
    Bwin        2.25    3.10    3.40
    Betway      2.37    2.90    3.40
    Bet777      2.25    3.00    3.45
    Napoleon    2.35    3.05    3.30
    Unibet      2.35    3.05    3.30
    Ladbrokes   2.25    2.80    3.40;

param money_with_bonus_per_house :=
    betFIRST 100
    Bingoal 100
    Bwin 100
    Betway 100
    Bet777 100
    Napoleon 100
    Unibet 100
    Ladbrokes 100;
