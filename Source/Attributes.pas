namespace RemObjects.Elements.Serialization;

type
  EncodeMember = public class(System.Attribute)
  public

    constructor(aMemberName: String); empty;

  end;

  Encode = public class(System.Attribute)
  public

    constructor(aName: String); empty;
    constructor(aShouldEncode: Boolean); empty;

  end;

end.