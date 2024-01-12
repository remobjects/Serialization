namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class(GenericCoder<JsonNode>)
  public

    constructor;
    begin
      constructor withJson(JsonDocument.CreateObject);
    end;

    constructor withFile(aFileName: String);
    begin
      constructor withJson(JsonDocument.FromFile(aFileName));
    end;

    constructor withJson(aJson: JsonDocument);
    begin
      Json := aJson;
      Hierarchy.Push(Json/*.Root*/ as JsonObject);
    end;


    property Json: JsonDocument;

    method ToString: String; override;
    begin
      result := Json.ToString;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := Json.ToJsonString(aFormat);
    end;

  end;

end.