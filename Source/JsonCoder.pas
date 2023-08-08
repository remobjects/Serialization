namespace RemObjects.Elements.Serialization;

type
  JsonCoder = public partial class(GenericCoder<JsonNode>)
  public

    constructor;
    begin
      constructor withJson(JsonDocument.CreateDocument);
    end;

    constructor withFile(aFileName: String);
    begin
      constructor withJson(JsonDocument.FromFile(aFileName));
    end;

    constructor withJson(aJson: JsonDocument);
    begin
      Json := aJson;
      Hierarchy.Push(Json.Root as JsonObject);
    end;


    property Json: JsonDocument;

    method ToString: String; override;
    begin
      result := Json.ToString;
    end;

  end;

end.