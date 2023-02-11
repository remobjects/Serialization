namespace RemObjects.Elements.Serialization;

type
  XmlCoder = public partial class(GenericCoder<XmlElement>)
  public

    constructor;
    begin
    end;

    constructor withFile(aFileName: String);
    begin
      constructor withXml(XmlDocument.FromFile(aFileName).Root);
    end;

    constructor withXml(aXml: XmlElement);
    begin
      Xml := aXml;
      Hierarchy.Push(Xml);
    end;

    property Xml: XmlElement;

    method ToString: String; override;
    begin
      result := XmlDocument.WithRootElement(Xml).ToString(XmlFormattingOptions.StandardReadableStyle);
    end;

  end;

end.