namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class
  public

    method DecodeString(aName: String): String; override;
    begin
      result := DoGetValue(aName):StringValue
    end;

    method DecodeIntPtr(aName: String): nullable IntPtr; override;
    begin
      result := DoGetValue(aName):IntegerValue
    end;

    method DecodeUIntPtr(aName: String): nullable UIntPtr; override;
    begin
      result := DoGetValue(aName):IntegerValue {$HINT Handle UInt properly}
    end;

    method DecodeInt64(aName: String): nullable Int64; override;
    begin
      result := DoGetValue(aName):IntegerValue
    end;

    method DecodeUInt64(aName: String): nullable UInt64; override;
    begin
      result := DoGetValue(aName):IntegerValue {$HINT Handle UInt properly}
    end;

    method DecodeDouble(aName: String): nullable Double; override;
    begin
      result := DoGetValue(aName):FloatValue
    end;

    method DecodeBoolean(aName: String): nullable Boolean; override;
    begin
      result := DoGetValue(aName):BooleanValue
    end;

    //

    method DecodeObjectType(aName: String): String; override;
    begin
      result := Current["__Type"]:StringValue;
    end;

    method DecodeObjectStart(aName: String): Boolean; override;
    begin
      if DoGetValue(aName) is JsonObject then
        Hierarchy.Push(DoGetValue(aName));
      result := true;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

    //

    method DecodeArrayStart(aName: String): Boolean; override;
    begin
      if DoGetValue(aName) is JsonArray then begin
        Hierarchy.Push(DoGetValue(aName));
      end;
      result := true;
    end;

    method DecodeArrayElements<T>(aName: String): array of T; override;
    begin
      if Current is var lJsonArray: JsonArray then begin
        result := new array of T(lJsonArray.Count);
        for i := 0 to lJsonArray.Count-1 do begin
          Hierarchy.Push(lJsonArray[i]);
          var lValue := DecodeArrayElement<T>(aName);
          if assigned(lValue) then
            result[i] := lValue as T;
          Hierarchy.Pop;
        end;
      end;
    end;

    method DecodeArrayEnd(aName: String); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

  private

    method DoGetValue(aName: nullable String): JsonNode;
    begin
      if assigned(aName) and (Current is JsonObject) then
        result := Current[aName];
      //else
        //result := Current;
    end;

  end;

end.