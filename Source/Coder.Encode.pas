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

    method Encode(aObject: Object);
    begin
      EncodeField(nil, aObject);
    end;

    method EncodeField(aName: String; aObject: Object);
    begin
      if assigned(aObject) then begin
        case aObject type of
          DateTime,
          PlatformDateTime: EncodeDateTime(aName, aObject as DateTime);
          String: EncodeString(aName, aObject as String);
          Int8: EncodeInt8(aName, aObject as Int8);
          Int16: EncodeInt16(aName, aObject as Int16);
          Int32: EncodeInt32(aName, aObject as Int32);
          Int64: EncodeInt64(aName, aObject as Int64);
          IntPtr: EncodeInt64(aName, aObject as IntPtr as Int64);
          UInt8: EncodeUInt8(aName, aObject as UInt8);
          UInt16: EncodeUInt16(aName, aObject as UInt16);
          UInt32: EncodeUInt32(aName, aObject as UInt32);
          UInt64: EncodeUInt64(aName, aObject as UInt64);
          UIntPtr: EncodeUInt64(aName, aObject as UIntPtr as UInt64);
          Boolean: EncodeBoolean(aName, aObject as Boolean);
          Single: EncodeSingle(aName, aObject as Single);
          Double: EncodeDouble(aName, aObject as Double);
          Guid: EncodeGuid(aName, aObject as Guid);
          else begin
            if aObject is IEncodable then
              EncodeObject(aName, aObject as IEncodable)
            else
              raise new CodingExeption($"Type '{typeOf(aObject)}' for field or property '{aName}' is not encodable.");
          end;
        end;
      end
      else begin
        if ShouldEncodeNil then
          EncodeNil(aName);
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
          EncodeField(nil, e);
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

    method EncodeIntPtr(aName: String; aValue: nullable IntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;

    method EncodeUIntPtr(aName: String; aValue: nullable UIntPtr); virtual; // E26700: Passing a nil nullable IntPtr as nullable UInt64 converts to 0
    begin
      EncodeString(aName, aValue:ToString);
    end;

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