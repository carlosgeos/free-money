glpk:
	python scripts/glpk_build.py
	glpsol --math glpk_input.mod -d matches.dat

knitro:
	python scripts/neos_build.py Knitro
	python scripts/NeosClient.py neos_input.xml

baron:
	python scripts/neos_build.py BARON
	python scripts/NeosClient.py neos_input.xml

couenne:
	python scripts/neos_build.py Couenne
	python scripts/NeosClient.py neos_input.xml

mosek:
	python scripts/neos_build.py MOSEK
	python scripts/NeosClient.py neos_input.xml
