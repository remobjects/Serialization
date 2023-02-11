namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class
  protected

    method EncodeString(aName: String; aValue: not nullable String); override;
    begin
      Current[aName] := aValue as JsonStringValue;
    end;

    method EncodeInt64(aName: String; aValue: Int64); override;
    begin
      Current[aName] := aValue as JsonIntegerValue;
    end;

    method EncodeUInt64(aName: String; aValue: UInt64); override;
    begin
      Current[aName] := aValue as JsonIntegerValue; {$HINT Handle UInt properly}
    end;

    method EncodeDouble(aName: String; aValue: Double); override;
    begin
      Current[aName] := aValue as JsonFloatValue;
    end;

    method EncodeBoolean(aName: String; aValue: Boolean); override;
    begin
      Current[aName] := aValue as JsonBooleanValue;
    end;

    method EncodeGuid(aName: String; aValue: Guid); override;
    begin
      Current[aName] := aValue.ToString(GuidFormat.Default).ToLowerInvariant;
    end;

    method EncodeNil(aName: String); override;
    begin
      Current[aName] := JsonNullValue.Null;
    end;

    method EncodeObjectStart(aName: String; aValue: IEncodable); override;
    begin
      if assigned(aName) then begin
        var lObject := new JsonObject;
        Current[aName] := lObject;
        Hierarchy.Push(lObject);
        Current["__Ytpe"] := typeOf(lObject).ToString;
      end;
    end;

    method EncodeObjectEnd(aName: String; aValue: IEncodable); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

  end;

end.