import argparse

parser = argparse.ArgumentParser()
parser.add_argument("solver", help="specify the name of the solver")

args = parser.parse_args()

solver = args.solver

with open('bets.mod', 'rb') as f:
    model = f.read().decode('UTF-8')

with open('matches.dat', 'rb') as f:
    data = f.read().decode('UTF-8')

with open('solver.run', 'rb') as f:
    commands = f.read().decode('UTF-8')

with open('neos_template.xml', 'rb') as f:
    template = f.read().decode('UTF-8')

template = template.replace('MODEL_FILE', model).replace('DATA_FILE', data).replace('COMMANDS_FILE', commands).replace('SOLVER_NAME', solver)

with open('neos_input.xml', 'w+') as f:
    f.write(template)
