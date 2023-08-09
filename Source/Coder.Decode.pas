namespace RemObjects.Elements.Serialization;

type
  Coder = public partial class
  public

    method Decode(aType: &Type): IDecodable;
    begin
      result := aType.Instantiate() as IDecodable;
      result.Decode(self);
    end;

    method Decode<T>: T; where T has constructor, T is IDecodable;
    begin
      result := new T;
      result.Decode(self);
    end;

    method DecodeArray<T>(aName: String): array of T;
    begin
      if DecodeArrayStart(aName) then begin
        result := DecodeArrayElements<T>(aName);
        DecodeArrayEnd(aName);
      end;
    end;

    method DecodeList<T>(aName: String): List<T>;
    begin
      raise new NotImplementedException("DecodeList<T>");
    end;

    method DecodeObject(aName: String; aType: &Type): IDecodable;
    begin
      if DecodeObjectStart(aName) then begin
        var lTypeName := DecodeObjectType(aName);

        if assigned(lTypeName) then begin
          var aConcreteType := FindType(lTypeName);
          if not assigned(aConcreteType) then
            raise new CoderException($"Unknown type '{lTypeName}'.");
          if assigned(aType) and (aConcreteType ≠ aType) and not aConcreteType.IsSubclassOf(aType) then
            raise new CoderException($"Concrete type '{aConcreteType.Name}' does not descend from {aType.Name}.");
          aType := aConcreteType;
        end;

        if not assigned(aType) then
          raise new CoderException($"Unknown type.");

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

    method DecodeIntPtr(aName: String): nullable IntPtr; virtual;
    begin
      result := Convert.TryToIntPtr(DecodeString(aName));
    end;

    method DecodeUIntPtr(aName: String): nullable UIntPtr; virtual;
    begin
      var lIntPtr := Convert.TryToIntPtr(DecodeString(aName));
      if assigned(lIntPtr) then // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
        result := lIntPtr;
      //result := Convert.TryToUInt64(DecodeString(aName)); {$HINT Implement properly/lossles}
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

    method DecodeString(aName: String): String; abstract;

    method DecodeObjectType(aName: String): String; virtual; empty;
    method DecodeObjectStart(aName: String): Boolean; abstract;
    method DecodeObjectEnd(aName: String); abstract;

    method DecodeArrayStart(aName: String): Boolean; abstract;
    method DecodeArrayElements<T>(aName: String): array of T; abstract;
    method DecodeArrayEnd(aName: String); abstract;

    method DecodeArrayElement<T>(aName: String): Object; virtual;
    begin
      case typeOf(T) of
        DateTime, PlatformDateTime: result := DecodeDateTime(nil);
        String: result := DecodeString(nil);
        Int8: result := DecodeInt8(nil);
        Int16: result := DecodeInt16(nil);
        Int32: result := DecodeInt32(nil);
        Int64: result := DecodeInt64(nil);
        IntPtr: result := DecodeInt64(nil) as IntPtr;
        UInt8: result := DecodeUInt8(nil);
        UInt16: result := DecodeUInt16(nil);
        UInt32: result := DecodeUInt32(nil);
        UInt64: result := DecodeUInt64(nil);
        UIntPtr: result := DecodeUInt64(nil) as UIntPtr;
        Boolean: result := DecodeBoolean(nil);
        Single: result := DecodeSingle(nil);
        Double: result := DecodeDouble(nil);
        Guid, PlatformGuid: result := DecodeGuid(nil);
        else result := Decode(typeOf(T));
      end;
    end;

    method DecodeListStart(aName: String): Boolean; virtual;
    begin
      result := DecodeArrayStart(aName);
    end;

    method DecodeListElements<T>(aName: String): List<T>; virtual;
    begin
      result := DecodeArrayElements<T>(aName).ToList;
    end;

    method DecodeListEnd(aName: String); virtual;
    begin
      DecodeArrayEnd(aName);
    end;


    //method DecodeListStart(aName: String); abstract;
    //method DecodeListEnd(aName: String); abstract;

  private

    method FindType(aName: String): &Type;
    begin
      if not assigned(fTypesCache) then
        fTypesCache := &Type.AllTypes;
      result := fTypesCache.FirstOrDefault(t -> t.FullName = aName);
      if not assigned(result) then begin
        fTypesCache := &Type.AllTypes; // load again, maye we have new types now
        result := fTypesCache.FirstOrDefault(t -> t.FullName = aName);
      end;
    end;

    var fTypesCache: ImmutableList<&Type>;

  end;

end.