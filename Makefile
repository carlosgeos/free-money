SOLVER=BARON

all:
	python NeosClient.py build_xml --solver ${SOLVER}
	python NeosClient.py neos_input.xml
