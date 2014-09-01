// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zGraphicDialog.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2014 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

unit zGraphicDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  zObjInspector;

type
  TGraphicDialog = class(TzInspDialog)
    BtnSave: TButton;
    BtnCancel: TButton;
    BtnLoad: TButton;
    opd: TOpenDialog;
    Panel1: TPanel;
    Image1: TImage;
    procedure BtnLoadClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FUserGraphic: TGraphic;
    FGraphic: TGraphic;
    FFilter: string;
  public
    { Public declarations }
  protected
    procedure InitDialog; override;
    procedure DisplayGraphic(AGraphic: TGraphic);
  end;

implementation

uses Types;
{$R *.dfm}

procedure TGraphicDialog.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrNone;
  Close;
end;

procedure TGraphicDialog.BtnLoadClick(Sender: TObject);
begin
  opd.Filter := FFilter;
  if opd.Execute then
  begin
    FUserGraphic.LoadFromFile(opd.FileName);
    DisplayGraphic(FUserGraphic);
  end;
end;

procedure TGraphicDialog.BtnSaveClick(Sender: TObject);
begin
  FGraphic.Assign(FUserGraphic);
  ModalResult := mrOk;
  Close;
end;

procedure TGraphicDialog.DisplayGraphic(AGraphic: TGraphic);
var
  LBMP: TBitmap;
begin
  LBMP := TBitmap.Create;
  LBMP.Assign(AGraphic);
  Image1.Picture.Bitmap := LBMP;
  LBMP.Free;
end;

procedure TGraphicDialog.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUserGraphic);
end;

procedure TGraphicDialog.InitDialog;
begin
  FGraphic := TGraphic(PropItem.Value.AsObject);
  if FGraphic is TBitmap then
    FFilter := 'Bitmaps|*.bmp'
  else if FGraphic is TIcon then
    FFilter := 'Icons|*.ico'
  else
    FFilter := '';
  FUserGraphic := TGraphicClass(FGraphic.ClassType).Create;

  FUserGraphic.Assign(FGraphic);
  DisplayGraphic(FUserGraphic);
end;

end.
