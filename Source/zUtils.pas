// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zUtils.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2016 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

// **************************************************************************************************
//
// https://github.com/MahdiSafsafi/zcontrols
//
// **************************************************************************************************

unit zUtils;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Styles,
  Vcl.Themes;

function RectVCenter(var R: TRect; Bounds: TRect): TRect;
procedure DrawPlusMinus(Canvas: TCanvas; X, Y: Integer; Collapsed: Boolean);
procedure zFillRect(DC: HDC; R: TRect; Color: COLORREF); overload;
procedure zFillRect(DC: HDC; R: TRect; Color, BorderColor: COLORREF; DX, DY: Integer); overload;
procedure DrawHorzDotLine(Canvas: TCanvas; X, Y, Width: Integer);
function IsCaretVisible: Boolean;
function GetCaretControl: TControl;
function GetCaretWin: HWND;
function WinInWin(AWin, Test: HWND): Boolean;
function IsStrFirst(SubStr, Str: String; const CaseSensitive: Boolean = False): Boolean;
function VKeyToStr(vKey: Word): String;
procedure DbgPrint(S: String);

implementation

procedure DbgPrint(S: String);
begin
  OutputDebugString(PChar(S));
end;

function VKeyToStr(vKey: Word): String;
var
  KeyboardState: TKeyboardState;
  P: PChar;
begin
  Win32Check(GetKeyboardState(KeyboardState));
  GetMem(P, 4);
  ZeroMemory(P, 4);
  SetLength(Result, 2);
  if ToAscii(vKey, MapVirtualKey(vKey, 0), KeyboardState, P, 0) > 0 then
    Result := StrPas(P)
  else
    Result := '';
  FreeMem(P, 4);
end;

procedure DrawHorzDotLine(Canvas: TCanvas; X, Y, Width: Integer);
var
  i: Integer;
begin
  for i := X to Width do
    if i mod 2 = 0 then
    begin
      Canvas.MoveTo(i, Y);
      Canvas.LineTo(i + 1, Y);
    end;
end;

function WinInWin(AWin, Test: HWND): Boolean;
var
  P: HWND;
begin
  Result := AWin = Test;
  if Result then
    exit;
  P := GetParent(AWin);
  while P <> 0 do
  begin
    Result := P = Test;
    if Result then
      exit;
    P := GetParent(P);
  end;
end;

function IsCaretVisible: Boolean;
var
  LInfo: TGUIThreadInfo;
begin
  Result := False;
  FillChar(LInfo, sizeof(TGUIThreadInfo), #0);
  LInfo.cbSize := sizeof(TGUIThreadInfo);
  if GetGUIThreadInfo(GetCurrentThreadId, LInfo) then
    Result := LInfo.flags and GUI_CARETBLINKING = GUI_CARETBLINKING;
end;

function GetCaretWin: HWND;
var
  LInfo: TGUIThreadInfo;
begin
  Result := 0;
  FillChar(LInfo, sizeof(TGUIThreadInfo), #0);
  LInfo.cbSize := sizeof(TGUIThreadInfo);
  if GetGUIThreadInfo(GetCurrentThreadId, LInfo) then
    if LInfo.hwndCaret > 0 then
      Result := LInfo.hwndCaret;
end;

function IsStrFirst(SubStr, Str: String; const CaseSensitive: Boolean = False): Boolean;
begin
  if not CaseSensitive then
  begin
    SubStr := LowerCase(SubStr);
    Str := LowerCase(Str);
  end;
  Result := Pos(SubStr, Str) = 1;
end;

function GetCaretControl: TControl;
begin
  Result := FindControl(GetCaretWin);
end;

procedure zFillRect(DC: HDC; R: TRect; Color, BorderColor: COLORREF; DX, DY: Integer);
var
  ARect: TRect;
begin
  ARect := R;
  zFillRect(DC, ARect, BorderColor);
  InflateRect(ARect, -DX, -DY);
  zFillRect(DC, ARect, Color);
end;

procedure zFillRect(DC: HDC; R: TRect; Color: COLORREF);
var
  Brush: HBRUSH;
begin
  if R.IsEmpty then
    exit;
  Brush := CreateSolidBrush(Color);
  FillRect(DC, R, Brush);
  DeleteObject(Brush);
end;

function RectVCenter(var R: TRect; Bounds: TRect): TRect;
begin
  OffsetRect(R, -R.Left, -R.Top);
  OffsetRect(R, 0, (Bounds.Height - R.Height) div 2);
  OffsetRect(R, Bounds.Left, Bounds.Top);
  Result := R;
end;

procedure DrawPlusMinus(Canvas: TCanvas; X, Y: Integer; Collapsed: Boolean);
var
  Width, Height: Integer;
  Details: TThemedElementDetails;
  LStyle: TCustomStyleServices;
begin
  Width := 9;
  Height := Width;
  Inc(X, 2);
  Inc(Y, 2);
  LStyle := StyleServices;
  if LStyle.Enabled then
  begin
    if Collapsed then
      Details := LStyle.GetElementDetails(tcbCategoryGlyphClosed)
    else
      Details := LStyle.GetElementDetails(tcbCategoryGlyphOpened);
    LStyle.DrawElement(Canvas.Handle, Details, Rect(X, Y, X + Width, Y + Width));
  end
  else
  begin
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Brush.Color := clWindow;
    Canvas.Rectangle(X, Y, X + Width, Y + Height);
    Canvas.Pen.Color := clWindowText;

    Canvas.MoveTo(X + 2, Y + Width div 2);
    Canvas.LineTo(X + Width - 2, Y + Width div 2);

    if Collapsed then
    begin
      Canvas.MoveTo(X + Width div 2, Y + 2);
      Canvas.LineTo(X + Width div 2, Y + Width - 2);
    end;
  end;
end;


end.
