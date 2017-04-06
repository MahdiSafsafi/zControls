// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zObjInspList.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2017 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

// **************************************************************************************************
//
// https://github.com/MahdiSafsafi/zcontrols
//
// **************************************************************************************************

unit zObjInspList;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  System.SysUtils,
  Vcl.Consts,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  WinApi.Windows,
  Vcl.Graphics,
  zObjInspector;

type
  TzCustomPopupListBox = class(TzPopupListBox)
    { =>This class is used to test if the ListBox has custom items .
      =>Any CustomListBox must be derived from this class !
    }
  end;

  TzPopupColorListBox = class(TzCustomPopupListBox)
  private
    function GetColor(Index: Integer): TColor;
  protected
    procedure PopulateList;
    procedure ColorCallBack(const AName: string);
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Colors[Index: Integer]: TColor read GetColor;

  end;

  TzPopupCursorListBox = class(TzCustomPopupListBox)
  private
    function GetCursor(Index: Integer): TCursor;
  protected
    procedure PopulateList;
    procedure CursorCallBack(const AName: string);
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Cursors[Index: Integer]: TCursor read GetCursor;
  end;

  TzPopupShortCutListBox = class(TzCustomPopupListBox)
  private
    function GetShortCut(Index: Integer): TShortCut;
  protected
    procedure EnumShortCuts;
    procedure PopulateList;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property ShortCuts[Index: Integer]: TShortCut read GetShortCut;
  end;

function fShortCutToText(ShortCut: TShortCut): string;

implementation

type
  TMenuKeyCap = (mkcBkSp, mkcTab, mkcEsc, mkcEnter, mkcSpace, mkcPgUp, mkcPgDn, mkcEnd, mkcHome, mkcLeft, mkcUp, mkcRight, mkcDown, mkcIns, mkcDel, mkcShift, mkcCtrl, mkcAlt);

var
  MenuKeyCaps: array [TMenuKeyCap] of string = (
    SmkcBkSp,
    SmkcTab,
    SmkcEsc,
    SmkcEnter,
    SmkcSpace,
    SmkcPgUp,
    SmkcPgDn,
    SmkcEnd,
    SmkcHome,
    SmkcLeft,
    SmkcUp,
    SmkcRight,
    SmkcDown,
    SmkcIns,
    SmkcDel,
    SmkcShift,
    SmkcCtrl,
    SmkcAlt
  );

function GetSpecialName(ShortCut: TShortCut): string;
var
  ScanCode: Integer;
{$IF DEFINED(CLR)}
  KeyName: StringBuilder;
{$ELSE}
  KeyName: array [0 .. 255] of Char;
{$ENDIF}
begin
  Result := '';
  ScanCode := MapVirtualKey(LoByte(Word(ShortCut)), 0) shl 16;
  if ScanCode <> 0 then
  begin
{$IF DEFINED(CLR)}
    KeyName := StringBuilder.Create(256);
    GetKeyNameText(ScanCode, KeyName, KeyName.Capacity);
    GetSpecialName := KeyName.ToString;
{$ELSE}
    if GetKeyNameText(ScanCode, KeyName, Length(KeyName)) <> 0 then
      Result := KeyName
    else
      Result := '';
{$ENDIF}
  end;
end;

function fShortCutToText(ShortCut: TShortCut): string;
{ The original ShortCutToText function found in Vcl.Menus
  has a bug with scCommand !!! }
var
  Name: string;
  Key: Byte;

begin
  if ShortCut = scNone then
    Exit('(None)');
  Key := LoByte(Word(ShortCut));
  case Key of
    $08, $09: Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcBkSp) + Key - $08)];
    $0D: Name := MenuKeyCaps[mkcEnter];
    $1B: Name := MenuKeyCaps[mkcEsc];
    $20 .. $28: Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcSpace) + Key - $20)];
    $2D .. $2E: Name := MenuKeyCaps[TMenuKeyCap(Ord(mkcIns) + Key - $2D)];
    $30 .. $39: Name := Chr(Key - $30 + Ord('0'));
    $41 .. $5A: Name := Chr(Key - $41 + Ord('A'));
    $60 .. $69: Name := Chr(Key - $60 + Ord('0'));
    $70 .. $87: Name := 'F' + IntToStr(Key - $6F);
  else Name := GetSpecialName(ShortCut);
  end;
  if Name <> '' then
  begin
    Result := '';
    if ShortCut and scShift <> 0 then
      Result := Result + MenuKeyCaps[mkcShift];
    if ShortCut and scCtrl <> 0 then
      Result := Result + MenuKeyCaps[mkcCtrl];
    if ShortCut and scAlt <> 0 then
      Result := Result + MenuKeyCaps[mkcAlt];
    { ---> Fix scCommand bug <--- }
    if ShortCut and scCommand <> 0 then
      Result := Result + 'Cmd+';
    Result := Result + Name;
  end
  else
    Result := '';
end;

{ TzPopupColorListBox }

constructor TzPopupColorListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited Style := lbOwnerDrawFixed;
end;

procedure TzPopupColorListBox.CreateWnd;
begin
  inherited;
  PopulateList;
end;

procedure TzPopupColorListBox.ColorCallBack(const AName: string);
var
  LColor: TColor;
begin
  LColor := StringToColor(AName);
  Items.AddObject(AName, TObject(LColor));
end;

procedure TzPopupColorListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LRect: TRect;
  LBackground: TColor;
  function ColorToBorderColor(AColor: TColor; State: TOwnerDrawState): TColor;
  begin
    if (Byte(AColor) > 192) or { Red }
      (Byte(AColor shr 8) > 192) or { Green }
      (Byte(AColor shr 16) > 192) then { Blue }
      Result := clBlack
    else if odSelected in State then
      Result := clWhite
    else
      Result := AColor;
  end;

begin
  with Canvas do
  begin
    FillRect(Rect);
    LBackground := Brush.Color;

    LRect := Rect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left + 5;
    InflateRect(LRect, -1, -1);
    Brush.Color := Colors[Index];
    FillRect(LRect);
    Brush.Color := ColorToBorderColor(ColorToRGB(Brush.Color), State);
    FrameRect(LRect);

    Brush.Color := LBackground;
    Rect.Left := LRect.Right + 5;

    TextRect(Rect, Rect.Left, Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(Items[Index])) div 2, Items[Index]);
  end;

end;

function TzPopupColorListBox.GetColor(Index: Integer): TColor;
begin
  Result := TColor(Items.Objects[Index]);
end;

procedure TzPopupColorListBox.PopulateList;
begin
  Items.Clear;
  Items.BeginUpdate;
  GetColorValues(ColorCallBack);
  Items.EndUpdate;
end;

{ TzPopupCursorListBox }
constructor TzPopupCursorListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited Style := lbOwnerDrawFixed;
  ItemHeight := 35;
end;

procedure TzPopupCursorListBox.CreateWnd;
begin
  inherited;
  PopulateList;
end;

procedure TzPopupCursorListBox.CursorCallBack(const AName: string);
var
  LCursor: TCursor;
begin
  LCursor := StringToCursor(AName);
  Items.AddObject(AName, TObject(LCursor));
end;

procedure TzPopupCursorListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LRect: TRect;
  LCursor: TCursor;
begin
  with Canvas do
  begin
    FillRect(Rect);

    LRect := Rect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left + 5;
    InflateRect(LRect, -1, -1);
    LCursor := Cursors[Index];
    DrawIconEx(Canvas.Handle, LRect.Left, LRect.Top, Screen.Cursors[LCursor], 32, 32, 0, 0, DI_NORMAL);
    Rect.Left := LRect.Right + 2;
    TextRect(Rect, Rect.Left, Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(Items[Index])) div 2, Items[Index]);
  end;
end;

function TzPopupCursorListBox.GetCursor(Index: Integer): TCursor;
begin
  Result := TCursor(Items.Objects[Index]);
end;

procedure TzPopupCursorListBox.PopulateList;
begin
  Items.Clear;
  Items.BeginUpdate;
  GetCursorValues(CursorCallBack);
  Items.EndUpdate;
end;

{ TzPopupShortCutListBox }

constructor TzPopupShortCutListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

procedure TzPopupShortCutListBox.CreateWnd;
begin
  inherited;
  PopulateList;
end;

procedure TzPopupShortCutListBox.EnumShortCuts;
var
  C: Byte;
  K: Integer;
const
  MultiKeysArray: array [0 .. 5] of TShortCut = (scCtrl, scCtrl + scAlt, scCommand, scCtrl + scCommand, scShift + scCommand, scCommand + scAlt);
  UniqueKeysArray: array [0 .. 3] of TShortCut = (scShift, scCtrl, scAlt, scCommand);

  procedure AddShortCut(ShortCut: TShortCut);
  begin
    Items.AddObject(fShortCutToText(ShortCut), TObject(ShortCut));
  end;

begin
  AddShortCut(scNone);
  { Keys + (A .. Z) }
  for K := Low(MultiKeysArray) to High(MultiKeysArray) do
  begin
    for C := $41 to $5A do
      AddShortCut(C or MultiKeysArray[K]);
  end;

  { Keys + (F1 .. F12) }
  for K := Low(MultiKeysArray) to High(MultiKeysArray) do
  begin
    for C := $70 to $7B do
      AddShortCut(C or MultiKeysArray[K]);
  end;

  { Key + (Insert,Delete,Enter,Esc) }
  for K := Low(UniqueKeysArray) to High(UniqueKeysArray) do
  begin
    AddShortCut(UniqueKeysArray[K] + $2D); // Insert
    AddShortCut(UniqueKeysArray[K] + $2E); // Delete
    AddShortCut(UniqueKeysArray[K] + $0D); // Enter
    AddShortCut(UniqueKeysArray[K] + $1B); // Esc
  end;

  { Special ShortCuts }
  AddShortCut(scAlt + $08); // Alt+BkSp
  AddShortCut(scShift + scAlt + $08); // Shift+Alt+BkSp
end;

function TzPopupShortCutListBox.GetShortCut(Index: Integer): TShortCut;
begin
  Result := TShortCut(Items.Objects[Index]);
end;

procedure TzPopupShortCutListBox.PopulateList;
begin
  Items.Clear;
  Items.BeginUpdate;
  EnumShortCuts;
  Items.EndUpdate;
end;

end.
