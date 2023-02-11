namespace RemObjects.Elements.Serialization;

type
  Coder = public partial class
  public

    method Decode(aType: &Type): IDecodable;
    begin
      result := aType.Instantiate() as IDecodable;
      result.Decode(self);
    end;


    method DecodeObject(aName: String; aType: &Type): IDecodable;
    begin
      if DecodeObjectStart(aName) then begin
        var lTypeName := DecodeObjectType(aName);
        if assigned(lTypeName) then
          aType := &Type.AllTypes.FirstOrDefault(t -> t.Name = aName);
        if not assigned(aType) then
          raise new CoderException($"Unknown type '{lTypeName}'.");

        result := aType.Instantiate() as IDecodable;
        result.Decode(self);
        DecodeObjectEnd(aName);
      end;
    end;


    //method BeginReadObject(aObject: IDecodable);
    //begin

    //end;

    //method EndReadObject(aObject: IDecodable);
    //begin

    //end;

    method DecodeDateTime(aName: String): DateTime; virtual;
    begin
      result := DateTime.TryParseISO8601(DecodeString(aName));
    end;

    method DecodeInt64(aName: String): nullable Int64; virtual;
    begin
      result := Convert.TryToInt64(DecodeString(aName));
    end;

    method DecodeUInt64(aName: String): nullable UInt64; virtual;
    begin
      result := Convert.TryToInt64(DecodeString(aName)); {$HINT Implement properly}
      //result := Convert.TryToUInt64(DecodeString(aName));
    end;

    method DecodeDouble(aName: String): nullable Double; virtual;
    begin
      result := Convert.TryToDoubleInvariant(DecodeString(aName));
    end;

    method DecodeBoolean(aName: String): nullable Boolean; virtual;
    begin
      result := DecodeString(aName):ToLowerInvariant = "true";
    end;

    method DecodeGuid(aName: String): nullable Guid; virtual;
    begin
      result := Guid.TryParse(DecodeString(aName));
    end;

    method DecodeInt8(aName: String): nullable Int8; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeInt16(aName: String): nullable Int16; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeInt32(aName: String): nullable Int32; virtual;
    begin
      result := DecodeInt64(aName);
    end;

    method DecodeUInt8(aName: String): nullable UInt8; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeUInt16(aName: String): nullable UInt16; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeUInt32(aName: String): nullable UInt32; virtual;
    begin
      result := DecodeUInt64(aName);
    end;

    method DecodeSingle(aName: String): nullable Single; virtual;
    begin
      result := DecodeDouble(aName);
    end;

    method DecodeString(aName: String): nullable String; abstract;

    method DecodeObjectType(aName: String): String; virtual; empty;
    method DecodeObjectStart(aName: String): Boolean; abstract;
    method DecodeObjectEnd(aName: String); abstract;

  end;

end.