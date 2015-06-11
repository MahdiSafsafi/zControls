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
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2015 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

unit zObjInspList;

interface

uses
  System.Classes,
  System.Types,
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

implementation

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

end.
