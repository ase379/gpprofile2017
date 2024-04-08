unit gppMain.FrameInstrumentation.SelectionInfoIF;

interface

const
  ALL_UNITS = '<all units>';
  ALL_CLASSLESS_PROCEUDURES = '<all classless procedures>';
  ALL_CLASSES = '<all classes>';
  ALL_PROCEDURES = '<all procedures>';

type
  ISelectionInfo = interface
    ['{EB23DFD9-6A60-4F88-A1D8-5CE6DC18088C}']
    function getIsItem : boolean;
    function getSelectionString : String;

    property SelectionString: String read getSelectionString;
    property IsItem : boolean read getIsItem;

    function GetProcedureNameForSelection(const aProcedureName: string): string;
  end;

implementation

end.
