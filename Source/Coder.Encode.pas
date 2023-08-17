namespace RemObjects.Elements.Serialization;

type
  Coder = public partial class
  public

    method BeginWriteObject(aObject: IEncodable);
    begin

    end;

    method EndWriteObject(aObject: IEncodable);
    begin

    end;

    method Encode<T>(aValue: T);
    begin
      Encode(nil, aValue);
    end;

    method Encode<T>(aName: String; aValue: T);
    begin
      case typeOf(T) of
        DateTime: EncodeDateTime(aName, aValue as DateTime);
        String: EncodeString(aName, aValue as String);
        Int8: EncodeInt8(aName, aValue as Int8);
        Int16: EncodeInt16(aName, aValue as Int16);
        Int32: EncodeInt32(aName, aValue as Int32);
        Int64: EncodeInt64(aName, aValue as Int64);
        {$IF NOT COOPER}
        IntPtr: EncodeIntPtr(aName, aValue as IntPtr);
        {$ENDIF}
        uint8: EncodeUInt8(aName, aValue as uint8);
        UInt16: EncodeUInt16(aName, aValue as UInt16);
        UInt32: EncodeUInt32(aName, aValue as UInt32);
        UInt64: EncodeUInt64(aName, aValue as UInt64);
        {$IF NOT COOPER}
        UIntPtr: EncodeUIntPtr(aName, aValue as UIntPtr);
        {$ENDIF}
        Boolean: EncodeBoolean(aName, aValue as Boolean);
        Single: EncodeSingle(aName, aValue as Single);
        Double: EncodeDouble(aName, aValue as Double);
        Guid: EncodeGuid(aName, aValue as Guid);
        {$IF NOT COOPER} // On these platforms the types are aliased
        PlatformDateTime: EncodeDateTime(aName, aValue as DateTime);
        PlatformGuid: EncodeGuid(aName, aValue as Guid);
        {$ENDIF}
        else begin
          if aValue is IEncodable then
            EncodeObject(aName, aValue as IEncodable)
          else if assigned(aName) then
            raise new CodingExeption($"Type '{typeOf(aValue)}' for field or property '{aName}' is not encodable.")
          else
            raise new CodingExeption($"Type '{typeOf(aValue)}' is not encodable.");
        end;
      end;
    end;

    method EncodeObject(aName: String; aValue: IEncodable); virtual;
    begin
      if assigned(aValue) then begin
        EncodeObjectStart(aName, aValue);
        aValue.Encode(self);
        EncodeObjectEnd(aName, aValue);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    method EncodeArray<T>(aName: String; aValue: array of T); virtual;
    begin
      if assigned(aValue) then begin
        EncodeArrayStart(aName);
        for each e in aValue do
          Encode(nil, e);
        EncodeArrayEnd(aName);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;


    method EncodeList<T>(aName: String; aValue: List<T>);
    begin
      raise new NotImplementedException("EncodeList<T>");
    end;


    method EncodeDateTime(aName: String; aValue: nullable DateTime); virtual;
    begin
      EncodeString(aName, aValue:ToISO8601String)
    end;

    {$IF NOT COOPER}
    method EncodeIntPtr(aName: String; aValue: nullable IntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeUIntPtr(aName: String; aValue: nullable UIntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;
    {$ENDIF}

    method EncodeInt64(aName: String; aValue: nullable Int64); virtual;
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeUInt64(aName: String; aValue: nullable UInt64); virtual;
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeDouble(aName: String; aValue: nullable Double); virtual;
    begin
      if assigned(aValue) then
        EncodeString(aName, Convert.ToStringInvariant(aValue))
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeBoolean(aName: String; aValue: nullable Boolean); virtual;
    begin
      EncodeString(aName, if assigned(aValue) then (if aValue then "True" else "False"));
    end;

    method EncodeGuid(aName: String; aValue: nullable Guid); virtual;
    begin
      EncodeString(aName, aValue:ToString(GuidFormat.Default));
    end;

    method EncodeInt8(aName: String; aValue: nullable Int8); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt16(aName: String; aValue: nullable Int16); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt32(aName: String; aValue: nullable Int32); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeUInt8(aName: String; aValue: nullable UInt8); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt16(aName: String; aValue: nullable UInt16); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt32(aName: String; aValue: nullable UInt32); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeSingle(aName: String; aValue: nullable Single); virtual;
    begin
      EncodeDouble(aName, aValue);
    end;

    method EncodeString(aName: String; aValue: nullable String); abstract;
    method EncodeNil(aName: String); abstract;

  protected

    property ShouldEncodeNil: Boolean := true; virtual;

    method EncodeObjectStart(aName: String; aValue: IEncodable); abstract;
    method EncodeObjectEnd(aName: String; aValue: IEncodable); abstract;

    method EncodeArrayStart(aName: String); abstract;
    method EncodeArrayEnd(aName: String); abstract;

    method EncodeListStart(aName: String); virtual;
    begin
      EncodeArrayStart(aName);
    end;

    method EncodeListEnd(aName: String); virtual;
    begin
      EncodeArrayEnd(aName);
    end;

  end;

end.