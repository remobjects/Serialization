﻿namespace RemObjects.Elements.Serialization;

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

    {$IF NOT COOPER}
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
    {$ENDIF}

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
      if assigned(aValue) then begin
        if (aValue ≠ Guid.Empty) or ShouldEncodeDefault then
          DoEncodeValue(aName, aValue.ToString(GuidFormat.Default).ToLowerInvariant as JsonStringValue);
      end
      else if ShouldEncodeNil then begin
        EncodeNil(aName);
      end;
    end;

    method EncodeNil(aName: String); override;
    begin
      DoEncodeValue(aName, JsonNullValue.Null);
    end;

    method EncodeJsonNode(aName: String; aValue: nullable JsonNode); override;
    begin
      DoEncodeValue(aName, aValue);
    end;

    //

    method EncodeList<T>(aName: String; aValue: List<T>);
    begin
      raise new NotImplementedException("EncodeList<T>");
    end;

    class method ToJsonString(aObject: IEncodable; aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      var lTemp := new JsonCoder();
      lTemp.Encode(aObject);
      result := lTemp.ToJsonString(aFormat);
    end;

    class method FromJson<T>(aJson: JsonNode): T; where T has constructor, T is IDecodable;
    begin
      var lTemp := new JsonCoder withJson(aJson);
      result := lTemp.Decode<T>;
    end;

    class method FromJsonString<T>(aJsonString: String): T; where T has constructor, T is IDecodable;
    begin
      var lTemp := new JsonCoder withJson(JsonDocument.FromString(aJsonString));
      result := lTemp.Decode<T>;
    end;

  protected

    method EncodeObjectStart(aName: String; aValue: IEncodable; aExpectedType: &Type := nil); override;
    begin
      if assigned(aName) then begin
        var lObject := new JsonObject;
        Current[aName] := lObject;
        Hierarchy.Push(lObject);
        if typeOf(aValue) ≠ aExpectedType then
          lObject["__Type"] := typeOf(aValue).ToString;
      end
      else if Current is var lJsonArray: JsonArray then begin
        var lObject := new JsonObject;
        lJsonArray.Add(lObject);
        Hierarchy.Push(lObject);
        if typeOf(aValue) ≠ aExpectedType then
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
      if Current ≠ Json/*.Root*/ then
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
      if Current ≠ Json/*.Root*/ then
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

  IEncodable_Json_Extension = public extension class(IEncodable)
  public

    method ToJson(aFormat: JsonFormat := JsonFormat.HumanReadable): JsonNode;
    begin
      var lTemp := new JsonCoder();
      lTemp.Encode(self);
      result := lTemp.Json;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      var lTemp := new JsonCoder();
      lTemp.Encode(self);
      result := lTemp.ToJsonString(aFormat);
    end;

  end;

end.