unit FloatConv;

interface

type
  TFloatFormatOption = (ffoConsiderSmallNumber, // show smaller number < 1e-Maxdigits
                        ffoFixDigit);           // padding with 0
  TFloatFormatOptions = set of TFloatFormatOption;


function MyFormatFloat(Val: Single; MaxDigits, ExpPrecision: Integer;
                       Options: TFloatFormatOptions = []): string; overload; //inline;

function MyFormatFloat(Val: Double; MaxDigits, ExpPrecision: Integer;
                       Options: TFloatFormatOptions = []): string; overload; //inline;

function MyFormatFloat(Val: Extended; MaxDigits, ExpPrecision: Integer;
                       Options: TFloatFormatOptions = []): string; overload; //inline;

function MyStrToFloat(Str: string): Double; //inline;
function MyStrToFloatS(Str: string): Single; //inline;
function MyStrToFloatD(Str: string): Double; //inline;
function MyStrToFloatE(Str: string): Extended; //inline;

function MyTryStrToFloat(const S: string; out Value: Single): Boolean; overload;
function MyTryStrToFloat(const S: string; out Value: Double): Boolean; overload;
function MyTryStrToFloat(const S: string; out Value: Extended): Boolean; overload;

implementation

uses
  FloatConv.Single,
  FloatConv.Double,
  FloatConv.Extended;

function MyFormatFloat(Val: Single; MaxDigits, ExpPrecision: Integer; Options: TFloatFormatOptions = []): string;
begin
  Result := FloatConv.Single.MyFormatFloat(Val, MaxDigits, ExpPrecision, Options);
end;

function MyFormatFloat(Val: Double; MaxDigits, ExpPrecision: Integer; Options: TFloatFormatOptions = []): string;
begin
  Result := FloatConv.Double.MyFormatFloat(Val, MaxDigits, ExpPrecision, Options);
end;

function MyFormatFloat(Val: Extended; MaxDigits, ExpPrecision: Integer; Options: TFloatFormatOptions = []): string;
begin
  Result := FloatConv.Extended.MyFormatFloat(Val, MaxDigits, ExpPrecision, Options);
end;

function MyStrToFloat(Str: string): Double;
begin
  Result := FloatConv.Double.MyStrToFloat(Str);
end;

function MyStrToFloatS(Str: string): Single;
begin
  Result := FloatConv.Single.MyStrToFloat(Str);
end;

function MyStrToFloatD(Str: string): Double;
begin
  Result := FloatConv.Double.MyStrToFloat(Str);
end;

function MyStrToFloatE(Str: string): Extended;
begin
  Result := FloatConv.Extended.MyStrToFloat(Str);
end;

function MyTryStrToFloat(const S: string; out Value: Single): Boolean;
begin
  Result := FloatConv.Single.MyTryStrToFloat(S, Value);
end;

function MyTryStrToFloat(const S: string; out Value: Double): Boolean;
begin
  Result := FloatConv.Double.MyTryStrToFloat(S, Value);
end;

function MyTryStrToFloat(const S: string; out Value: Extended): Boolean;
begin
  Result := FloatConv.Extended.MyTryStrToFloat(S, Value);
end;

end.
