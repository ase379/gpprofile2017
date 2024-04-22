unit gppMain.FrameInstrumentation.SelectionInfoIF;

interface

const
  ALL_UNITS = '<all units>';
  ALL_CLASSLESS_PROCEDURES = '<all classless procedures>';
  ALL_CLASSES = '<all classes>';
  ALL_PROCEDURES = '<all procedures>';
  ALL_METHODS_CLASS_START = '<all ';
  ALL_METHODS_CLASS_END = ' methods>';

type
  ISelectionInfo = interface
    ['{EB23DFD9-6A60-4F88-A1D8-5CE6DC18088C}']
    function getIsItem : boolean;
    function getSelectionString : String;

    property SelectionString: String read getSelectionString;
    property IsItem : boolean read getIsItem;

    function GetProcedureNameForSelection(const aProcedureName: string): string;
  end;


function GetAllClassMethodsString(const aClassName: String): String;


implementation

function GetAllClassMethodsString(const aClassName: String): String;
begin
  result := ALL_METHODS_CLASS_START + aClassName + ALL_METHODS_CLASS_END;
end;

end.
