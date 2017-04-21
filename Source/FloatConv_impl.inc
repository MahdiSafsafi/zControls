function MyStrToFloat(Str: string): TFloat; overload;

function MyFormatFloat(Val: TFloat; MaxDigits, ExpPrecision: Integer;
                       Options: TFloatFormatOptions = [ffoConsiderSmallNumber]): string; overload;

function MyTryStrToFloat(const S: string; out Value: TFloat): Boolean;

implementation

uses
  Math,
  System.SysUtils,
  System.RegularExpressions;

function MyTryStrToFloat(const S: string; out Value: TFloat): Boolean;
var
  Str: string;
  Sign: TFloat;
const
  cValidFloatRegExp = '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$';
begin
  Str := S.Trim.ToLower;
  Sign := 1.0;

  if Str[1] = '-' then
  begin
    Sign := -1.0;
    Str := Str.Remove(0,1);
  end
  else if Str[1] = '+' then
    Str := Str.Remove(0,1);

  if Str = 'nan' then
    Value := NaN
  else if Str = 'inf' then
    Value := Infinity
  else
  begin
    if not TryStrToFloat(Str, Value) then
      // valid regexp => overflow
      if TRegEx.IsMatch(Str, cValidFloatRegExp) then
      begin
        if Str.ToLower.Contains('e-') then
          Value := 0
        else
          Value := Infinity;
      end
      else // invalid float
      begin
        Result := False;
        Exit;
      end;
  end;
  Value := Value * Sign;
  Result := True;
end;

function MyStrToFloat(Str: string): TFloat;
var
  Sign: TFloat;
const
  cValidFloatRegExp = '^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$';
begin
  Str := Str.Trim.ToLower;
  Sign := 1.0;

  if Str[1] = '-' then
  begin
    Sign := -1.0;
    Str := Str.Remove(0,1);
  end
  else if Str[1] = '+' then
    Str := Str.Remove(0,1);

  if Str = 'nan' then
    Result := NaN
  else if Str = 'inf' then
    Result := Infinity
  else
  begin
    if not TryStrToFloat(Str, Result) then
      // valid regexp => overflow
      if TRegEx.IsMatch(Str, cValidFloatRegExp) then
      begin
        if Str.ToLower.Contains('e-') then
          Result := 0
        else
          Result := Infinity;
      end
      else // invalid float
      begin
        Result := StrToFloat(Str); // reraise Error
      end;
  end;

  Result := Result * Sign;
end;

function MyFormatFloat(Val: TFloat; MaxDigits, ExpPrecision: Integer; Options: TFloatFormatOptions): string;
var
  Normal, Small, Big: string;
  SArr: TArray<string>;
  DigitChar: Char;
begin
  if ffoFixDigit in Options then
    DigitChar := '0'
  else
    DigitChar := '#';

  Normal := FormatFloat('0.'+StringOfChar(DigitChar,MaxDigits), Val).Replace('E','e');
  if not (ffoFixDigit in Options) then
    Normal := TRegEx.Replace(Normal,'\.0+$', ''); // 0.00 -> 0

  if (ffoConsiderSmallNumber in Options) and
     (not IsNan(Val) and (Abs(Val)>0) and (Abs(Val) < Power10(1.0, -MaxDigits)) and (Normal = '0')) then
  begin
    Small := FormatFloat('#.'+ StringOfChar(DigitChar,ExpPrecision-1)+'e+0', Val); // e+## doesn't works correctly
    Result := Small;
  end
  else
  begin
    if Normal.Contains('e') then  // Big e
    begin
      SArr := Normal.Split(['e']);
      Big := FormatFloat('0.'+StringOfChar('#',ExpPrecision-1), StrToFloat(SArr[0])) + 'e' + SArr[1];
      Result := Big;
    end
    else
      Result := Normal;
  end;

  // tweak output
  Result := Result.Replace('NAN', 'NaN').Replace('INF', 'Inf');
end;
