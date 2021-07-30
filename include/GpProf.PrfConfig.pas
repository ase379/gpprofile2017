{$R-,C-,Q-,O+,H+}
unit GpProf.PrfConfig;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}


type
  TPrfConfig = class
  private
    fprofTableName : string;
    fProfProcSize : integer;
    fprfThreadBytes : integer;
    fprofCompressTicks,
    fprofCompressThreads,
    fprofProfilingAutostart : boolean;
    fprofPrfOutputFile : string;
    fprfDisabled : boolean;
    fprfMaxThreadNum : integer;

  public
    constructor Create();
    procedure LoadFromFile(const aFilename : string);
    property ProfTableName: String read fprofTableName;
    property ProfPrfOutputFile : String read fprofPrfOutputFile;
    property ProfProfilingAutostart : boolean read fprofProfilingAutostart;
    property ProfCompressTicks: Boolean read fprofCompressTicks;
    property ProfCompressThreads : Boolean read fprofCompressThreads;
    property ProfProcSize : integer read fprofProcSize;
    property PrfMaxThreadNum : integer read fprfMaxThreadNum write fprfMaxThreadNum;
    property PrfThreadBytes : integer read fprfThreadBytes write fprfThreadBytes;
  end;

implementation

uses
  System.Sysutils, System.IniFiles,
  GpProfCommon;

{ TPrfConfig }

constructor TPrfConfig.Create;
begin
  inherited Create();
  fprofProfilingAutostart := false;
  fprfDisabled := true;
  fprfMaxThreadNum := 256;
  fprfThreadBytes := 1;
end;

procedure TPrfConfig.LoadFromFile(const aFilename: string);
var
  lIniFile : TIniFile;
begin
  lIniFile := TIniFile.Create(aFilename);
  fprofTableName := lIniFile.ReadString('IDTables','TableName','');
  if fprofTableName <> '' then begin
    if FileExists(fprofTableName) then
    begin
      fProfProcSize           := lIniFile.ReadInteger('Procedures','ProcSize',4);
      fprofCompressTicks      := lIniFile.ReadBool('Performance','CompressTicks',false);
      fprofCompressThreads    := lIniFile.ReadBool('Performance','CompressThreads',false);
      fprofProfilingAutostart := lIniFile.ReadBool('Performance','ProfilingAutostart',true);
      fprofPrfOutputFile := lIniFile.ReadString('Output','PrfOutputFilename','$(ModulePath)');
      fprofPrfOutputFile := ResolvePrfRuntimePlaceholders(fprofPrfOutputFile);
      fprfDisabled            := false;
    end;
  end;
  lIniFile.Free;
end;

end.
