namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class
  public

    method DecodeString(aName: String): String; override;
    begin
      result := Current[aName]:StringValue
    end;

    method DecodeInt64(aName: String): nullable Int64; override;
    begin
      result := Current[aName]:IntegerValue
    end;

    method DecodeUInt64(aName: String): nullable UInt64; override;
    begin
      result := Current[aName]:IntegerValue {$HINT Handle UInt properly}
    end;

    method DecodeDouble(aName: String): nullable Double; override;
    begin
      result := Current[aName]:FloatValue
    end;

    method DecodeBoolean(aName: String): nullable Boolean; override;
    begin
      result := Current[aName]:BooleanValue
    end;

    method DecodeObjectType(aName: String): String; override;
    begin
      result := Current["__Type"]:StringValue;
    end;

    method DecodeObjectStart(aName: String): Boolean; override;
    begin
      if Current[aName] is JsonObject then
        Hierarchy.Push(Current[aName] as JsonObject);
      result := true;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      //if assigned(aName) then
        //Hierarchy.Pop;
    end;

  end;

end.