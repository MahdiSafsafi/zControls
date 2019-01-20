program InspDemo;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  zBase in '..\Source\zBase.pas',
  zCanvasStack in '..\Source\zCanvasStack.pas',
  zControlsReg in '..\Source\zControlsReg.pas',
  zGraphicDialog in '..\Source\zGraphicDialog.pas' {GraphicDialog},
  zObjInspDialogs in '..\Source\zObjInspDialogs.pas',
  zObjInspector in '..\Source\zObjInspector.pas',
  zObjInspList in '..\Source\zObjInspList.pas',
  zRecList in '..\Source\zRecList.pas',
  zStringsDialog in '..\Source\zStringsDialog.pas' {StringsDialog},
  zUtils in '..\Source\zUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
