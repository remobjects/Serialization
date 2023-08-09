namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class
  public

    method EncodeString(aName: String; aValue: nullable String); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonStringValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeIntPtr(aName: String; aValue: nullable IntPtr); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonIntegerValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeUIntPtr(aName: String; aValue: nullable UIntPtr); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonIntegerValue) {$HINT Handle UInt properly}
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeInt64(aName: String; aValue: nullable Int64); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonIntegerValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeUInt64(aName: String; aValue: nullable UInt64); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonIntegerValue) {$HINT Handle UInt properly}
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeDouble(aName: String; aValue: nullable Double); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonFloatValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeBoolean(aName: String; aValue: nullable Boolean); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue as JsonBooleanValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeGuid(aName: String; aValue: nullable Guid); override;
    begin
      if assigned(aValue) then
        DoEncodeValue(aName, aValue.ToString(GuidFormat.Default).ToLowerInvariant as JsonStringValue)
      else if ShouldEncodeNil then
        EncodeNil(aName);
    end;

    method EncodeNil(aName: String); override;
    begin
      DoEncodeValue(aName, JsonNullValue.Null);
    end;

    //

    method EncodeList<T>(aName: String; aValue: List<T>);
    begin
      raise new NotImplementedException("EncodeList<T>");
    end;

  protected

    method EncodeObjectStart(aName: String; aValue: IEncodable); override;
    begin
      if assigned(aName) then begin
        var lObject := new JsonObject;
        Current[aName] := lObject;
        Hierarchy.Push(lObject);
        lObject["__Type"] := typeOf(aValue).ToString;
      end
      else if Current is var lJsonArray: JsonArray then begin
        var lObject := new JsonObject;
        lJsonArray.Add(lObject);
        Hierarchy.Push(lObject);
        lObject["__Type"] := typeOf(aValue).ToString;
      end;

      //var lObject := new JsonObject;

      //if assigned(aName) /*and (Current is JsonObject)*/ then
        //Current[aName] := lObject
      //else if Current is var lJsonArray: JsonArray then
        //lJsonArray.Add(lObject);

      //Hierarchy.Push(lObject);
      //Current["__Type"] := typeOf(aValue).ToString;

    end;

    method EncodeObjectEnd(aName: String; aValue: IEncodable); override;
    begin
      if Current ≠ Json.Root then
        Hierarchy.Pop;
    end;

    method EncodeArrayStart(aName: String); override;
    begin
      if assigned(aName) then begin
        var lArray := new JsonArray;
        Current[aName] := lArray;
        Hierarchy.Push(lArray);
      end
      else if Current is var lJsonArray: JsonArray then begin
        var lArray := new JsonArray;
        lJsonArray.Add(lArray);
        Hierarchy.Push(lArray);
      end;
    end;

    method EncodeArrayEnd(aName: String); override;
    begin
      if Current ≠ Json.Root then
        Hierarchy.Pop;
    end;

  private

    method DoEncodeValue(aName: nullable String; aValue: JsonNode);
    begin
      if assigned(aName) /*and (Current is JsonObject)*/ then
        Current[aName] := aValue
      else if Current is var lJsonArray: JsonArray then
        lJsonArray.Add(aValue)
      //else if not assigned(Current) then
        //Current := aValue;
    end;

  end;

end.