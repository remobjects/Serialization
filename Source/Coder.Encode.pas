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
            if aObject is IEncodable then begin
              EncodeObjectStart(aName, aObject as IEncodable);
              (aObject as IEncodable).Encode(self);
              EncodeObjectEnd(aName, aObject as IEncodable);
            end
            else begin
              raise new CodingExeption($"Type '{typeOf(aObject)}' is not encodable.");
            end;
          end;
        end;
      end
      else begin
        if ShouldEncodeNil then
          EncodeNil(aName);
      end;
    end;

  protected

    property ShouldEncodeNil: Boolean := true; virtual;

    method EncodeDateTime(aName: String; aValue: DateTime); virtual;
    begin
      EncodeString(aName, aValue:ToISO8601String)
    end;

    method EncodeInt64(aName: String; aValue: Int64); virtual;
    begin
      EncodeString(aName, aValue.ToString);
    end;

    method EncodeUInt64(aName: String; aValue: UInt64); virtual;
    begin
      EncodeString(aName, aValue.ToString);
    end;

    method EncodeDouble(aName: String; aValue: Double); virtual;
    begin
      EncodeString(aName, aValue.ToString); {$HINT Needs to be Invariant!}
    end;

    method EncodeBoolean(aName: String; aValue: Boolean); virtual;
    begin
      EncodeString(aName, if aValue then "True" else "False");
    end;

    method EncodeGuid(aName: String; aValue: Guid); virtual;
    begin
      EncodeString(aName, aValue.ToString(GuidFormat.Default));
    end;

    method EncodeInt8(aName: String; aValue: Int8); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt16(aName: String; aValue: Int16); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeInt32(aName: String; aValue: Int32); virtual;
    begin
      EncodeInt64(aName, aValue);
    end;

    method EncodeUInt8(aName: String; aValue: UInt8); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt16(aName: String; aValue: UInt16); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeUInt32(aName: String; aValue: UInt32); virtual;
    begin
      EncodeUInt64(aName, aValue);
    end;

    method EncodeSingle(aName: String; aValue: Single); virtual;
    begin
      EncodeDouble(aName, aValue);
    end;

    method EncodeString(aName: String; aValue: not nullable String); abstract;
    method EncodeObjectStart(aName: String; aValue: IEncodable); abstract;
    method EncodeObjectEnd(aName: String; aValue: IEncodable); abstract;
    method EncodeNil(aName: String); abstract;

  end;

end.