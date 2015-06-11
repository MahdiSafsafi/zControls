// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zRecList.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2015 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

unit zRecList;

interface

uses
  System.Classes,
  System.SysUtils,
  System.RTLConsts,
  WinApi.Windows,
  TypInfo;

type
  TzRecordList<T, P> = class
  private
    FCount: Integer;
    FList: TList;
  strict private
  type
    PT = ^T; // To test compatibility !
  protected
    function PToPointer(PRec: P): Pointer;
    function PointerToP(APointer: Pointer): P;
    procedure FreeRecord(PRec: Pointer); virtual;
  public type
    InvalidPType = class(Exception);
    InvalidTType = class(Exception);
  class function CheckPType: Boolean;
  class function CheckTType: Boolean;
  constructor Create; virtual;
  destructor Destroy; override;
  function First: P;
  function Last: P;
  procedure Clear; virtual;
  function Delete(const Index: Integer): Boolean; virtual;
  function Add: P; overload; virtual;
  function Add(const Rec: T): Integer; overload; virtual;
  function Get(const Index: Integer): P; virtual;
  function IndexOf(PRec: P): Integer;
  property Items[const Index: Integer]: P read Get;
  property Count: Integer read FCount;
  end;

implementation

{ TzRecordList<T> }

class function TzRecordList<T, P>.CheckPType: Boolean;
var
  LPInfo: PTypeInfo;
  LPTInfo: PTypeInfo;
begin
  { Check if P is a Pointer to T ! }
  Result := SizeOf(P) = SizeOf(Pointer);
  if Result then
  begin
    LPInfo := TypeInfo(P);
    LPTInfo := TypeInfo(PT);
    Result := LPInfo.TypeData.RefType = LPTInfo.TypeData.RefType;
  end;
  if not Result then
    raise InvalidPType.Create('Invalid P Type , P must be pointer to T.');
end;

class function TzRecordList<T, P>.CheckTType: Boolean;
var
  LTInfo: PTypeInfo;
begin
  LTInfo := TypeInfo(T);
  Result := LTInfo.Kind = tkRecord;
  if not Result then
    raise InvalidTType.Create('Invalid T Type , T must be Record.');
end;

constructor TzRecordList<T, P>.Create;
begin
  CheckTType;
  CheckPType;
  FCount := 0;
  FList := TList.Create;
end;

destructor TzRecordList<T, P>.Destroy;
begin
  Clear;
  FreeAndNil(FList);
  inherited;
end;

function TzRecordList<T, P>.Add(const Rec: T): Integer;
var
  PRec: PByte;
begin
  (* PRec := AllocMem(SizeOf(T));
    FList.Add(PRec);
    PT(PRec)^ := Rec; // Copy Item to list !
    Result := FCount;
    Inc(FCount); *)
  PT(PToPointer(Add))^ := Rec;
  Result := FCount - 1;
end;

function TzRecordList<T, P>.Add: P;
begin
  Result := PointerToP(AllocMem(SizeOf(T)));
  FList.Add(PToPointer(Result));
  Inc(FCount);
end;

procedure TzRecordList<T, P>.Clear;
var
  i, L: Integer;
  PRec: Pointer;
begin
  L := FList.Count;
  for i := 0 to L - 1 do
  begin
    PRec := FList.Items[i];
    FreeRecord(PRec);
  end;
  FList.Clear;
  FCount := 0;
end;

function TzRecordList<T, P>.Delete(const Index: Integer): Boolean;
var
  PRec: Pointer;
begin
  Result := False;
  if (Index > -1) and (Index < FCount) then
  begin
    PRec := FList.Items[Index];
    FreeRecord(PRec);
    FList.Delete(Index);
    Dec(FCount);
    Exit(True);
  end;
  raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
end;

function TzRecordList<T, P>.First: P;
begin
  Result := P(nil);
  if FCount > 0 then
    Result := Get(0);
end;

function TzRecordList<T, P>.Last: P;
begin
  Result := P(nil);
  if FCount > 0 then
    Result := Get(FCount - 1);
end;

function TzRecordList<T, P>.PointerToP(APointer: Pointer): P;
var
  R: P absolute APointer;
begin
  Result := R;
end;

function TzRecordList<T, P>.PToPointer(PRec: P): Pointer;
var
  R: Pointer absolute PRec;
begin
  Result := R;
end;

procedure TzRecordList<T, P>.FreeRecord(PRec: Pointer);
begin
  if Assigned(PRec) then
  begin
    Finalize(PT(PRec)^);
    FreeMem(PRec, SizeOf(T));
    ZeroMemory(PRec, SizeOf(T));
    PT(PRec) := nil;
  end;
end;

function TzRecordList<T, P>.Get(const Index: Integer): P;
begin
  Result := P(nil);
  if (Index > -1) and (Index < FCount) then
  begin
    Result := PointerToP(FList.Items[Index]);
    Exit;
  end;
  raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
end;

function TzRecordList<T, P>.IndexOf(PRec: P): Integer;
begin
  Result := FList.IndexOf(PToPointer(PRec));
end;

end.
