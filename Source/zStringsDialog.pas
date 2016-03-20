// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zStringsDialog.pas.
//
// The Initial Developer of the Original Code is Mahdi Safsafi [SMP3].
// Portions created by Mahdi Safsafi . are Copyright (C) 2013-2016 Mahdi Safsafi .
// All Rights Reserved.
//
// **************************************************************************************************

unit zStringsDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  zObjInspector;

type
  TStringsDialog = class(TzInspDialog)
    GroupBox1: TGroupBox;
    pMemo: TMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    LblLines: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure pMemoChange(Sender: TObject);
  private
    { Private declarations }
    FItems: TStrings;
    FSaveItems: TStringList;
  public
    { Public declarations }
  protected
    procedure InitDialog; override;
    procedure UpdateCount;
  end;

implementation

{$R *.dfm}

procedure TStringsDialog.BtnOkClick(Sender: TObject);
begin
  FItems.Assign(pMemo.Lines);
  ModalResult := mrOk;
  Close;
end;

procedure TStringsDialog.BtnCancelClick(Sender: TObject);
begin
  FItems.Assign(FSaveItems);
  ModalResult := mrNone;
  Close;
end;

procedure TStringsDialog.FormCreate(Sender: TObject);
begin
  pMemo.Clear;
  UpdateCount;
end;

procedure TStringsDialog.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSaveItems);
end;

procedure TStringsDialog.InitDialog;
begin
  FItems := TStrings(PropItem.Value.AsObject);
  FSaveItems := TStringList.Create;
  FSaveItems.Assign(FItems);
  pMemo.Lines.Assign(FItems);
end;

procedure TStringsDialog.pMemoChange(Sender: TObject);
begin
  UpdateCount;
end;

procedure TStringsDialog.UpdateCount;
begin
  LblLines.Caption := Format('%d line ', [pMemo.Lines.Count])
end;

end.
