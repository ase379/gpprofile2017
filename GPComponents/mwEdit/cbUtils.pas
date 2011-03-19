{+-----------------------------------------------------------------------------+
 | Unit:        cbUtils
 | Created:     12.98
 | Last change: 1999-05-07
 | Author:      Cyrille de Brebisson [cyrille_de-brebisson@aus.hp.com]
 | Description: fast string list class implementation
 | Version:     0.52 (for version history see version.rtf)
 | Copyright (c) 1998 Cyrille de Brebisson
 | All rights reserved.
 |
 | Thanks to: Primoz Gabrijelcic, Greg Chapman
 +----------------------------------------------------------------------------+}

{$IFOPT R+} {$DEFINE SetR} {$ELSE} {$UNDEF SetR} {$ENDIF}
{$R-}                                                                           //gc 1999-05-07

unit cbUtils;

interface

uses classes;

const
  NbSubList = 128;

Type
  TSpeedStringList = class;

  TSpeedListObject = class
  protected
    FName: String;
    FSpeedList: TSpeedStringList;
    procedure SetName(const Value: String); virtual;
  public
    Property Name: String read FName write SetName;
    constructor create(name: string);
    destructor destroy; override;
    property SpeedList: TSpeedStringList read FSpeedList write FSpeedList;
  end;

  PSpeedListObjects = ^TSpeedListObjects;                                       //gp 1998-12-30
  TSpeedListObjects = array [0..0] of TSpeedListObject;                         //gp 1998-12-30

  TSpeedStringList = class
  private
    function GetText: string;
    procedure SetText(const Value: string);
  Protected
    FOnChange: TNotifyEvent;
    SumOfUsed: array [0..NbSubList-1] of integer;
    datasUsed: array [0..NbSubList-1] of integer;
    datas: array [0..NbSubList-1] of PSpeedListObjects;                         //gp 1998-12-30
    lengthDatas: array [0..NbSubList-1] of integer;                             //gp 1998-12-30
    procedure Changed; virtual;
    function Get(Index: Integer): string; virtual;
    function GetObject(Index: Integer): TSpeedListObject;
    function GetCount: integer;
    Function GetStringList: TStrings;
    Procedure SetStringList(const value: TStrings);
  public
    Procedure NameChange(const obj: TSpeedListObject; const NewName: String);
    Procedure ObjectDeleted(const obj: TSpeedListObject);

    destructor Destroy; override;
    constructor create;
    function Add(const Value: TSpeedListObject): Integer;
    procedure Clear;
    function Find(const name: String): TSpeedListObject;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Objects[Index: Integer]: TSpeedListObject read GetObject;
    property Strings[Index: Integer]: string read Get; default;
    property count: integer read GetCount;
    Property StringList: TStrings read GetStringList write SetStringList;
    property text: string read GetText write SetText;
  end;

implementation

function StringCrc(S: string): integer;
var
  i :integer;
begin
  result:=0;
  for i:=1 to length(s) do
  begin
    result:= (result shr 4) xor (((result xor ord(s[i])) and $F) * $1081);
    result:= (result shr 4) xor (((result xor (ord(s[i]) shr 4)) and $F) * $1081);
  end;
end;

{ TSpeedListObject }

constructor TSpeedListObject.create(name: string);
begin
  inherited create;
  FName:= name;
end;

destructor TSpeedListObject.destroy;
begin
  if FSpeedList<>nil then
    FSpeedList.ObjectDeleted(Self);
  inherited destroy;
end;

procedure TSpeedListObject.SetName(const Value: String);
begin
  FName := Value;
  if FSpeedList<>nil then
    FSpeedList.NameChange(Self, Value);
end;

{ TSpeedStringList }

function TSpeedStringList.Add(const Value: TSpeedListObject): Integer;
var
  crc: integer;
  i: integer;
begin
  crc:= StringCrc(Value.Name) mod (High(Datas)+1);                              //gc 1999-05-07
  if DatasUsed[crc]=lengthDatas[crc] then begin                                 //gp 1998-12-30
    ReallocMem(datas[crc], (lengthDatas[crc]*2+1)*SizeOf(datas[1][0]));         //gp 1998-12-30
    lengthDatas[crc] := lengthDatas[crc]*2+1;                                   //gp 1998-12-30
//  SetLength(Datas[crc], Length(Datas[crc])*2+1);                              //gp 1998-12-30
  end;                                                                          //gp 1998-12-30
  Datas[crc][DatasUsed[crc]]:= Value;
  result:= SumOfUsed[crc]+DatasUsed[crc];
  inc(DatasUsed[crc]);
  for i:= crc+1 to High(SumOfUsed) do
    inc(SumOfUsed[i]);
  Value.SpeedList:= Self;
end;

procedure TSpeedStringList.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TSpeedStringList.Clear;
var
  i, j: integer;
begin
  for i:= low(datas) to high(datas) do
  Begin
    for j:= 0{low(datas[i])} to DatasUsed[i]-1 do                               //gp 1998-12-30
      datas[i][j].free;
    datasUsed[i]:= 0;
//  SetLength(Datas[i], 0);                                                     //gp 1998-12-30
    ReallocMem(datas[i],0);                                                     //gp 1998-12-30                                                 
    lengthDatas[i] := 0;                                                        //gp 1998-12-30
    SumOfUsed[i]:= 0;
  end;
  Changed;
end;

constructor TSpeedStringList.create;
var
  i: integer;
begin
  inherited Create;
  for i:= Low(Datas) to high(datas) do
  Begin
    SumOfUsed[i]:= 0;
    DatasUsed[i]:= 0;
    lengthDatas[i] := 0;                                                        //gp 1998-12-30
    datas[i] := nil;
  end;
end;

destructor TSpeedStringList.Destroy;
begin
  Clear;
  inherited destroy;
end;

function TSpeedStringList.Find(const name: String): TSpeedListObject;
var
  crc: integer;
  i: integer;
begin
  crc:= StringCrc(name) mod (High(Datas)+1);                                    //gc 1999-05-07
  for i:= 0 to DatasUsed[crc]-1 do
    if Datas[crc][i].name = name then
    Begin
      result:= Datas[crc][i];
      exit;
    end;
  result:= nil;
end;

function TSpeedStringList.Get(Index: Integer): string;
var
  i: integer;
begin
  for i:=low(SumOfUsed)+1 to High(SumOfUsed) do
    if Index>SumOfUsed[i] then
    Begin
      result:= Datas[i-1][Index-SumOfUsed[i-1]].name;
      exit;
    end;
  result:= '';
end;

function TSpeedStringList.GetCount: integer;
begin
  result:= SumOfUsed[High(datas)]+DatasUsed[High(Datas)];
end;

function TSpeedStringList.GetObject(Index: Integer): TSpeedListObject;
var
  i: integer;
begin
  for i:=low(SumOfUsed)+1 to High(SumOfUsed) do
    if Index>SumOfUSed[i] then
    Begin
      result:= Datas[i-1][Index-SumOfUsed[i-1]];
      exit;
    end;
  result:= nil;
end;

function TSpeedStringList.GetStringList: TStrings;
var
  i, j: integer;
begin
  result:= TStringList.Create;
  for i:= Low(Datas) to High(Datas) do
    for j:= 0{Low(Datas[i])} to DatasUsed[i]-1 do                               //gp 1998-12-30
      result.add(datas[i][j].name);
end;

function TSpeedStringList.GetText: string;
begin
  with StringList do
  Begin
    result:= Text;
    free;
  end;
end;

procedure TSpeedStringList.NameChange(const Obj: TSpeedListObject; const NewName: String);
var
  crc: integer;
  i: integer;
  j: integer;
begin
  crc:= StringCrc(obj.Name) mod (High(Datas)+1);                                //gc 1999-05-07
  for i:= 0 to DatasUsed[crc]-1 do
    if Datas[crc][i] = Obj then
    Begin
      for j:= i+1 to DatasUsed[crc]-1 do
        Datas[j-1]:= Datas[j];                                                  //gc 1999-05-07
      for j:= crc+1 to High(Datas) do
        dec(SumOfUsed[j]);
      if DatasUsed[crc]<lengthDatas[crc] div 2 then begin                       //gp 1998-12-30
        ReallocMem(Datas[crc],DatasUsed[crc]*SizeOf(Datas[crc][0]));            //gp 1998-12-30
        lengthDatas[crc] := DatasUsed[crc];                                     //gp 1998-12-30
//      SetLength(Datas[crc], DatasUsed[crc]);                                  //gp 1998-12-30
      end;
      Add(obj);
      exit;
    end;
end;

procedure TSpeedStringList.ObjectDeleted(const obj: TSpeedListObject);
var
  crc: integer;
  i: integer;
  j: integer;
begin
  crc:= StringCrc(obj.Name) mod (High(Datas)+1);                                //gc 1999-05-07
  for i:= 0 to DatasUsed[crc]-1 do
    if Datas[crc][i] = Obj then
    Begin
      for j:= i+1 to DatasUsed[crc]-1 do
        Datas[j-1]:= Datas[j];                                                  //gc 1999-05-07
      for j:= crc+1 to High(Datas) do
        dec(SumOfUsed[j]);
      Obj.FSpeedList:= nil;
      exit;
    end;
end;

procedure TSpeedStringList.SetStringList(const value: TStrings);
var
  i: integer;
begin
  clear;
  for i:= 0 to Value.Count-1 do
    add(TSpeedListObject.Create(value[i]));
end;

procedure TSpeedStringList.SetText(const Value: string);
var
  s: TStrings;
begin
  s:= TStringList.Create;
  try
    s.Text:= Value;
    StringList:= s;
  finally
    s.Free;
  end;
end;

end.
