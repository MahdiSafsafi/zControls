// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zBase.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2018 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

// **************************************************************************************************
//
// https://github.com/MahdiSafsafi/zcontrols
//
// **************************************************************************************************

unit zBase;

interface

uses
  Windows,
  Messages,
  Types,
  SysUtils,
  Classes,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Controls,
  Vcl.Styles,
  Vcl.Themes,
  Vcl.AppEvnts,
  Generics.Collections;

const
  ZCM_BASE = WM_USER + $993;

type
  TMessageEventHide = function(Msg: TMsg): Boolean of object;

  IzControl = Interface(IInterface)
    ['{54A4B6B0-48DD-4F41-A889-4449ADF7D2F6}']
    function IsMouseInControl: Boolean;
    function IsMouseDown: Boolean;
    function IsVclStyleUsed: Boolean;
    function UseStyleColor: Boolean;
    function UseStyleFont: Boolean;
    function UseStyleBorder: Boolean;
  End;

  TzGraphicControl = class(TGraphicControl, IzControl)
  private
  var
    FMouseDown: Boolean;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  public
    function IsVclStyleUsed: Boolean;
    function UseStyleColor: Boolean;
    function UseStyleFont: Boolean;
    function UseStyleBorder: Boolean;
    function IsMouseInControl: Boolean;
    function IsMouseDown: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

type
  TzCustomControl = class(TCustomControl, IzControl)
  private
    FMouseDown: Boolean;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  public
    function IsMouseInControl: Boolean;
    function IsMouseDown: Boolean;
    function IsVclStyleUsed: Boolean;
    function UseStyleColor: Boolean;
    function UseStyleFont: Boolean;
    function UseStyleBorder: Boolean;
  end;

type
  TzToolWindow = class(TzCustomControl)
  private
    FNoActivate: Boolean;
    FNoMouseActivate: Boolean;
    FOnBeforeHiding: TNotifyEvent;
    FOnAfterHiding: TNotifyEvent;
    FWinVisible: Boolean;
    FControls: TList<HWND>;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show; overload; virtual;
    procedure Show(const X, Y: Integer); overload;
    procedure Show(const P: TPoint); overload;
    procedure Hide;
    property WinVisible: Boolean read FWinVisible;
    property NoActivate: Boolean read FNoActivate write FNoActivate;
    property NoMouseActivate: Boolean read FNoMouseActivate write FNoMouseActivate;
    property OnBeforeHiding: TNotifyEvent read FOnBeforeHiding write FOnBeforeHiding;
    property OnAfterHiding: TNotifyEvent read FOnAfterHiding write FOnAfterHiding;
    property ControlsList: TList<HWND> read FControls;
  end;

type
  TzPopupWindow = class(TzToolWindow)
  private
    FAppEvents: TApplicationEvents;
    FChildsEventsNoHide: Boolean;
    FExtMsgHiding: TMessageEventHide;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure OnAppEventsMsg(var Msg: TMsg; var Handled: Boolean); virtual;
    procedure DoHide;
  public
    procedure Show; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ChildsEventsNoHide: Boolean read FChildsEventsNoHide write FChildsEventsNoHide;
  published
    property Color;
    property Enabled;
    property StyleElements;
    property OnClick;
    property OnDblClick;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMsgHiding: TMessageEventHide read FExtMsgHiding write FExtMsgHiding;
  end;

implementation

{ TzGraphicControl }
procedure TzGraphicControl.WMLButtonDown(var Message: TWMLButtonDown);
begin
  FMouseDown := True;
  inherited;
end;

procedure TzGraphicControl.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FMouseDown := False;
  inherited;
end;

constructor TzGraphicControl.Create(AOwner: TComponent);
begin
  inherited;
  FMouseDown := False;
end;

destructor TzGraphicControl.Destroy;
begin

  inherited;
end;

function TzGraphicControl.IsMouseDown: Boolean;
begin
  Result := FMouseDown;
end;

function TzGraphicControl.IsMouseInControl: Boolean;
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  Result := ClientRect.Contains(P);
end;

function TzGraphicControl.IsVclStyleUsed: Boolean;
begin
  Result := StyleServices.Enabled and not StyleServices.IsSystemStyle;
end;

function TzGraphicControl.UseStyleBorder: Boolean;
begin
  Result := IsVclStyleUsed and (seBorder in StyleElements);
end;

function TzGraphicControl.UseStyleColor: Boolean;
begin
  Result := IsVclStyleUsed and (seClient in StyleElements);
end;

function TzGraphicControl.UseStyleFont: Boolean;
begin
  Result := IsVclStyleUsed and (seFont in StyleElements);
end;

{ TzCustomControl }

function TzCustomControl.IsMouseDown: Boolean;
begin
  Result := FMouseDown;
end;

function TzCustomControl.IsMouseInControl: Boolean;
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  Result := ClientRect.Contains(P);
end;

function TzCustomControl.IsVclStyleUsed: Boolean;
begin
  Result := StyleServices.Enabled and not StyleServices.IsSystemStyle;
end;

function TzCustomControl.UseStyleBorder: Boolean;
begin
  Result := IsVclStyleUsed and (seBorder in StyleElements);
end;

function TzCustomControl.UseStyleColor: Boolean;
begin
  Result := IsVclStyleUsed and (seClient in StyleElements);
end;

function TzCustomControl.UseStyleFont: Boolean;
begin
  Result := IsVclStyleUsed and (seFont in StyleElements);
end;

procedure TzCustomControl.WMLButtonDown(var Message: TWMLButtonDown);
begin
  FMouseDown := True;
  inherited;
end;

procedure TzCustomControl.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FMouseDown := False;
  inherited;
end;

{ TzToolWindow }

constructor TzToolWindow.Create(AOwner: TComponent);
begin
  inherited;
  FControls := nil;
  FWinVisible := False;
  FNoActivate := True;
  FNoMouseActivate := False;
  FOnBeforeHiding := nil;
  FOnAfterHiding := nil;
end;

procedure TzToolWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    if FNoActivate then
      ExStyle := ExStyle or WS_EX_NOACTIVATE;
  end;
end;

procedure TzToolWindow.CreateWnd;
begin
  inherited;
end;

destructor TzToolWindow.Destroy;
begin
  if Assigned(FControls) then
  begin
    FControls.Clear;
    FreeAndNil(FControls);
  end;
  inherited;
end;

procedure TzToolWindow.Hide;
begin
  if (HandleAllocated and FWinVisible) then
  begin
    ShowWindow(Handle, SW_HIDE);
  end;
  FWinVisible := False;
end;

procedure TzToolWindow.Show(const X, Y: Integer);
begin
  Show(Point(X, Y));
end;

procedure TzToolWindow.Show(const P: TPoint);
begin
  Left := P.X;
  Top := P.Y;
  Show;
end;

procedure TzToolWindow.Show;
  procedure DoShowControls(Control: TControl);
  var
    c, Child: TControl;
    i: Integer;
  begin
    c := Control;
    if c is TWinControl then
    begin
      if (TWinControl(c).Visible) and (Control <> Self) then
      begin
        ShowWindow(TWinControl(c).Handle, SW_SHOWNORMAL);
        if not FControls.Contains(TWinControl(c).Handle) then
          FControls.Add(TWinControl(c).Handle);
      end;
      for i := 0 to TWinControl(c).ControlCount - 1 do
      begin
        Child := TWinControl(c).Controls[i];
        if Child is TWinControl then
          if TWinControl(Child).ControlCount > 0 then
            DoShowControls(Child)
          else if TWinControl(Child).Visible then
          begin
            ShowWindow(TWinControl(Child).Handle, SW_SHOWNORMAL);
            if not FControls.Contains(TWinControl(Child).Handle) then
              FControls.Add(TWinControl(Child).Handle);
          end;
      end;
    end;
  end;

begin
  if not Assigned(FControls) then
    FControls := TList<HWND>.Create;

  FWinVisible := True;

  if FNoActivate then
    ShowWindow(Handle, SW_SHOWNOACTIVATE)
  else
    ShowWindow(Handle, SW_SHOWNORMAL);

  DoShowControls(Self);
end;

procedure TzToolWindow.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_ACTIVATE:
      if FNoActivate then
      begin
        Message.WParam := WA_INACTIVE;
        Message.Result := 0;
        Exit;
      end;
    WM_MOUSEACTIVATE:
      if FNoMouseActivate then
      begin
        Message.Result := MA_NOACTIVATE;
        Exit;
      end;
  end;
  inherited;
end;

{ TzPopupWindow }

constructor TzPopupWindow.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls];
  FNoActivate := True;
  FNoMouseActivate := True;
  FChildsEventsNoHide := True;
  FAppEvents := TApplicationEvents.Create(Self);
  FAppEvents.OnMessage := OnAppEventsMsg;
  FExtMsgHiding := nil;
end;

procedure TzPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_THICKFRAME;
  end;
end;

procedure TzPopupWindow.DoHide;
begin
  if FWinVisible then
  begin
    if Assigned(FOnBeforeHiding) then
      FOnBeforeHiding(Self);
    Hide;
    if Assigned(FOnAfterHiding) then
      FOnAfterHiding(Self);
  end;
end;

destructor TzPopupWindow.Destroy;
begin
  FAppEvents.OnMessage := nil;
  FreeAndNil(FAppEvents);
  inherited;
end;

procedure TzPopupWindow.OnAppEventsMsg(var Msg: TMsg; var Handled: Boolean);
var
  SkipMsg: Boolean;
begin
  SkipMsg := False;
  if not IsWindowVisible(Handle) then
  begin
    FAppEvents.OnMessage := nil;
    Handled := False;
    Exit;
  end;
  if Msg.HWND <> Handle then
  begin
    if FChildsEventsNoHide then
    begin
      if Assigned(FControls) then
        if FControls.Contains(Msg.HWND) then
          SkipMsg := True;
    end;
    if not SkipMsg then
    begin
      case Msg.Message of
        WM_LBUTTONDOWN .. WM_MBUTTONDBLCLK, { Mouse Events }
        WM_XBUTTONDOWN .. WM_XBUTTONDBLCLK, { Mouse Events }
        WM_NCLBUTTONDOWN .. WM_NCXBUTTONDBLCLK, { NC Mouse Events }
        WM_INITMENU, WM_INITMENUPOPUP, WM_ACTIVATEAPP:
          begin
            if Assigned(FExtMsgHiding) then
            begin
              if FExtMsgHiding(Msg) then
                DoHide;
            end
            else
              DoHide;
          end;
      end;
    end;
  end;
  Handled := False;
end;

procedure TzPopupWindow.Show;
begin
  if Assigned(FAppEvents) then
    if not Assigned(FAppEvents.OnMessage) then
      FAppEvents.OnMessage := OnAppEventsMsg;
  inherited;
end;

procedure TzPopupWindow.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_KILLFOCUS, WM_ACTIVATEAPP:
      begin
        DoHide;
      end;
  end;
  inherited;
end;

end.
