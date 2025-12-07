# Building the sources # 

The Delphi 10.3.3 Community Edition or higher ise free for private use, you can register and download it here : https://www.embarcadero.com/products/delphi/starter?aldSet=en-GB.

The GPProf main program provides the UI for instrumentation and analysis of the collected data. The project file is 'sources\gpprof.dproj'. It uses: 

- VirtualTreeView as a high performance list and tree view implementation. Its a submodule in 'libs'.
- SynEdit for the source code view. Its a submodule in 'libs' in the older versions. Use GetIt if the folder is not there.
- GPComponents for storing and reading the registry using visual components. Its in 'GPComponents\GPNative'. 

After compiling the design bpls for you compiler, add it to the IDE.

Then start coding :)
