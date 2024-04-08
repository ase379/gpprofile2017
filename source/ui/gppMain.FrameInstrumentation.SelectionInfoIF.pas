unit gppMain.FrameInstrumentation.SelectionInfoIF;

interface

type
  ISelectionInfo = interface
    ['{EB23DFD9-6A60-4F88-A1D8-5CE6DC18088C}']
    function getIsItem : boolean;
    function getSelectionString : String;

    property SelectionString: String read getSelectionString;
    property IsItem : boolean read getIsItem;

    function getSelectedProcNameForClassSelection(const aProcedureName: string): string;
  end;

implementation

end.
