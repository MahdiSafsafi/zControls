// **************************************************************************************************
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is zObjInspDialogs.pas.
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

unit zObjInspDialogs;

interface

uses Vcl.Forms, zObjInspector;

type
  TzInspDialog = class(TForm)
  private
    FPropItem: PPropItem;
  protected
    procedure DoCreate; override;
  public
    property PropItem: PPropItem read FPropItem write FPropItem;
  end;

implementation

{ TzInspDialog }

procedure TzInspDialog.DoCreate;
begin
  inherited;
  FPropItem := nil;
end;

end.
