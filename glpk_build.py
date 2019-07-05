with open('bets.mod', 'rb') as f:
    model = f.read().decode('UTF-8')

with open('solver.run', 'rb') as f:
    commands = f.read().decode('UTF-8')

with open('glpk_input.mod', 'w+') as f:
    f.write(model + commands)
