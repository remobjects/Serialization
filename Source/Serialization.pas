namespace RemObjects.Workflow.Serialization;

uses
  RemObjects.Elements.Cirrus;

type
  Serialize = public class(System.Attribute)
  public

    [AutoInjectIntoTarget]
    method Encode(aCoder: Coder);
    begin
    end;

    [AutoInjectIntoTarget]
    method Decode(aCoder: Coder);
    begin
    end;

  end;

  Coder = public class

  end;

end.