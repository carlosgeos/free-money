knitro:
	python NeosClient.py build_xml --solver Knitro
	python NeosClient.py neos_input.xml

baron:
	python NeosClient.py build_xml --solver BARON
	python NeosClient.py neos_input.xml

couenne:
	python NeosClient.py build_xml --solver Couenne
	python NeosClient.py neos_input.xml
