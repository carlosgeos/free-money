glpk: solution.txt

solution.txt: glpk_input.mod
	glpsol --pcost --math glpk_input.mod -d data/matches.dat --output solution.txt

glpk_input.mod: bets.mod solver.run
	cat bets.mod solver.run > glpk_input.mod
