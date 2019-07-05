knitro:
	python NeosClient.py build_xml --solver Knitro
	python NeosClient.py neos_input.xml

baron:
	python NeosClient.py build_xml --solver BARON
	python NeosClient.py neos_input.xml

couenne:
	python NeosClient.py build_xml --solver Couenne
	python NeosClient.py neos_input.xml

cplex:
	python NeosClient.py build_xml --solver CPLEX
	python NeosClient.py neos_input.xml

mosek:
	python NeosClient.py build_xml --solver MOSEK
	python NeosClient.py neos_input.xml

glpk:
	python glpk_build.py
	glpsol --math glpk_input.mod -d matches.dat
