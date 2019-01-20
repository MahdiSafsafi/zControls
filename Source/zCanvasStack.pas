// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zCanvasStack.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi. are Copyright (C) 2013-2019 Mahdi Safsafi.
// All Rights Reserved.
//
// **************************************************************************************************

// **************************************************************************************************
//
// https://github.com/MahdiSafsafi/zcontrols
//
// **************************************************************************************************

unit zCanvasStack;

interface

uses
  System.SysUtils,
  System.RTLConsts,
  Vcl.Graphics,
  Generics.Collections;

type
  TStackEx<T> = class(TStack<T>)
  private
    function Get(const Index: Integer): T;
    property Items[const Index: Integer]: T read Get;
  public
    function Push(const Value: T): Integer;
    function Peek(const Index: Integer): T; overload;
  end;

type
  TzCanvasStack = class(TStackEx<TCanvas>)
  private
    FObjectsStack: TStackEx<TObject>;
  protected
    procedure UpdateCanvas(Canvas: TCanvas; Brush: TBrush; Font: TFont; Pen: TPen);
  public
    constructor Create; overload; virtual;
    constructor Create(const Collection: TEnumerable<TCanvas>); overload;
    destructor Destroy; override;
    procedure Clear;
    function Push(const Value: TCanvas): Integer;
    function Pop: TCanvas;
    function Peek(const Index: Integer): TCanvas; overload;
    function Peek: TCanvas; overload;
    function Extract: TCanvas;
    procedure TrimExcess;
  end;

implementation

{ TzCanvasStack }
constructor TzCanvasStack.Create;
begin
  inherited Create;
  FObjectsStack := TStackEx<TObject>.Create();
end;

constructor TzCanvasStack.Create(const Collection: TEnumerable<TCanvas>);
begin
  FObjectsStack := TStackEx<TObject>.Create();
  inherited Create(Collection);
end;

destructor TzCanvasStack.Destroy;
begin
  FObjectsStack.Free;
  inherited;
end;

procedure TzCanvasStack.Clear;
var
  i: Integer;
  LObj: TObject;
begin
  inherited Clear;
  for i := 0 to FObjectsStack.Count - 1 do
  begin
    LObj := FObjectsStack.Items[i];
    if Assigned(LObj) then
      FreeAndNil(LObj);
  end;
  FObjectsStack.Clear;
end;

function TzCanvasStack.Push(const Value: TCanvas): Integer;
var
  LBrush: TBrush;
  LFont: TFont;
  LPen: TPen;
begin
  LBrush := TBrush.Create;
  LFont := TFont.Create;
  LPen := TPen.Create;

  LBrush.Assign(Value.Brush);
  LFont.Assign(Value.Font);
  LPen.Assign(Value.Pen);

  { Do not change the order ! }
  FObjectsStack.Push(LBrush);
  FObjectsStack.Push(LFont);
  FObjectsStack.Push(LPen);

  Result := inherited Push(Value);

end;

function TzCanvasStack.Pop: TCanvas;
var
  LBrush: TBrush;
  LFont: TFont;
  LPen: TPen;
begin
  Result := inherited Pop;

  { Do not change the order ! }
  LPen := TPen(FObjectsStack.Pop);
  LFont := TFont(FObjectsStack.Pop);
  LBrush := TBrush(FObjectsStack.Pop);

  UpdateCanvas(Result, LBrush, LFont, LPen);

  LBrush.Free;
  LFont.Free;
  LPen.Free;
end;

function TzCanvasStack.Extract: TCanvas;
var
  LBrush: TBrush;
  LFont: TFont;
  LPen: TPen;
begin
  Result := inherited Extract;

  { Do not change the order ! }
  LPen := TPen(FObjectsStack.Extract);
  LFont := TFont(FObjectsStack.Extract);
  LBrush := TBrush(FObjectsStack.Extract);

  UpdateCanvas(Result, LBrush, LFont, LPen);

  LPen.Free;
  LFont.Free;
  LBrush.Free;
end;

function TzCanvasStack.Peek: TCanvas;
var
  LBrush: TBrush;
  LFont: TFont;
  LPen: TPen;
  LCount: Integer;
begin
  Result := inherited Peek;
  LCount := FObjectsStack.Count;

  LPen := TPen(FObjectsStack.Items[LCount - 1]);
  LFont := TFont(FObjectsStack.Items[LCount - 1 - 1]);
  LBrush := TBrush(FObjectsStack.Items[LCount - 1 - 1 - 1]);

  UpdateCanvas(Result, LBrush, LFont, LPen);
end;

function TzCanvasStack.Peek(const Index: Integer): TCanvas;
var
  LBrush: TBrush;
  LFont: TFont;
  LPen: TPen;
  LIndex: Integer;
begin
  Result := inherited Peek(Index);
  LIndex := ((Index * 3) + 3) - 1;

  LPen := TPen(FObjectsStack.Items[LIndex]);
  LFont := TFont(FObjectsStack.Items[LIndex - 1]);
  LBrush := TBrush(FObjectsStack.Items[LIndex - 1 - 1]);

  UpdateCanvas(Result, LBrush, LFont, LPen);

end;

procedure TzCanvasStack.UpdateCanvas(Canvas: TCanvas; Brush: TBrush; Font: TFont; Pen: TPen);
begin
  Assert(TObject(Brush) is TBrush);
  Assert(TObject(Font) is TFont);
  Assert(TObject(Pen) is TPen);

  Canvas.Brush.Assign(Brush);
  Canvas.Font.Assign(Font);
  Canvas.Pen.Assign(Pen);

  Canvas.Refresh;
end;

procedure TzCanvasStack.TrimExcess;
begin
  Assert(Count * 3 = FObjectsStack.Count);
  inherited TrimExcess;
  FObjectsStack.TrimExcess;
end;

{ TStackEx }

function TStackEx<T>.Get(const Index: Integer): T;
begin
  if Count = 0 then
    raise EListError.CreateRes(@SUnbalancedOperation);
  if (Index > -1) and (Index < Count) then
  begin
    Result := Items[Index];
    Exit;
  end;
  raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
end;

function TStackEx<T>.Peek(const Index: Integer): T;
begin
  Result := Get(Index);
end;

function TStackEx<T>.Push(const Value: T): Integer;
begin
  inherited Push(Value);
  Result := Count - 1;
end;

end.
