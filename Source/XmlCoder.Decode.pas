namespace RemObjects.Elements.Serialization;

type
  XmlCoder = public partial class
  public

    method DecodeString(aName: String): String; override;
    begin
      result := Current.FirstElementWithName(aName):Value;
    end;

    method DecodeObjectType(aName: String): String; override;
    begin
      result := Current.Elements.First.LocalName;
      Hierarchy.Push(Current.Elements.First);
    end;

    method DecodeObjectStart(aName: String): Boolean; override;
    begin
      if assigned(aName) then begin
        var lElement := Current.FirstElementWithName(aName);
        Hierarchy.Push(lElement);
        result := lElement:Elements.Any;
      end
      else begin
        result := true;
      end;
    end;

    method DecodeObjectEnd(aName: String); override;
    begin
      if assigned(aName) then begin
        Hierarchy.Pop;
        Hierarchy.Pop;
      end;
    end;

  end;

end.