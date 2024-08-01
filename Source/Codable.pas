namespace RemObjects.Elements.Serialization;

type
  Codable = public class
  public

    constructor; empty;

    constructor withJson(aJson: JsonDocument);
    begin
      var lCoder := new JsonCoder withJson(aJson);
      (self as IDecodable).Decode(lCoder);
    end;

    method ToJson: JsonDocument;
    begin
      var lCoder := new JsonCoder;
      lCoder.Encode(self);
      result := lCoder.Json;
    end;

    method ToJsonString(aFormat: JsonFormat := JsonFormat.HumanReadable): String;
    begin
      result := ToJson.ToJsonString(aFormat);
    end;

    [ToString]
    method ToString: String; override;
    begin
      result := ToJson.ToString;
    end;

  end;
end.