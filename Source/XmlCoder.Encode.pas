namespace RemObjects.Elements.Serialization;

type
  XmlCoder = public partial class
  protected

    method EncodeString(aName: String; aValue: not nullable String); override;
    begin
      Current.AddElement(aName, aValue);
    end;

    method EncodeNil(aName: String); override;
    begin
      Current.AddElement(aName);
    end;

    method EncodeObjectStart(aName: String; aValue: IEncodable); override;
    begin
      var lNew := new XmlElement withName(typeOf(aValue).ToString);

      if assigned(aName) then
        Current.AddElement(aName).AddElement(lNew)
      else
        Xml := lNew;
      Hierarchy.Push(lNew);
    end;

    method EncodeObjectEnd(aName: String; aValue: IEncodable); override;
    begin
      if assigned(aName) then
        Hierarchy.Pop;
    end;

  end;

end.