unit zControlsReg;

interface

uses
  System.Classes,
  zObjInspector;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('zControls', [TzObjectInspector]);
end;

end.
