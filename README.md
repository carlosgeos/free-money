# Free Money

## Usage

The NEOS Server provides access to commercial/proprietary solvers
(Artelys Knitro, BARON, etc) through its web interface or the XML-RPC
interface (the one used in this case). `NeosClient.py` contains a
small client to communicate with the server, send the model and data
files, and receive a response.

```sh
$ python NeosClient.py build_xml <solver_name>
$ python NeosClient.py neos_input.xml
```

where `<solver_name>` is one of `Couenne|Knitro|BARON`

or just:

```sh
$ make baron
```
