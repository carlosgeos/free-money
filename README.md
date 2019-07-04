# Free Money

## Usage

The NEOS Server provides access to commercial/proprietary solvers
through its web interface or the XML-RPC interface (the one used in
this case). `NeosClient.py` contains a small client to communicate
with the server, send the model and data files, and receive a
response.

```sh
$ python NeosClient.py create_xml
$ python NeosClient.py neos_input.xml
```
