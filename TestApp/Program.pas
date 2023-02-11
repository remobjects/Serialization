namespace TestApp;

uses
  RemObjects.Elements.Serialization;

type
  Program = class
  public
    class method Main(args: array of String): Int32;
    begin
      // add your own code here
      writeLn('The magic happens here.');

      var f := new Foo(Name := "test", Age := 25, Date := DateTime.UtcNow.AddDays(30), Sub := new Bar());

      var j := new JsonCoder;
      j.Encode(f);
      Log($"{j}");

      var x := new XmlCoder;
      x.Encode(f);
      Log($"{x}");

      var f2 := x.Decode(typeOf(Foo)) as Foo;
      writeLn($"f2 {f2.Name}");
      writeLn($"f2 {f2.Age}");
      writeLn($"f2 {f2.Date}");
      writeLn($"f2 {f2.Sub}");

    end;

  end;

  [Codable]
  Foo = public class
  public

    property Name: String;
    property Age: Integer;
    property Date: DateTime;

    property Sub: Bar;

  end;

  [Codable]
  Bar = public class
  public

    property Name: String;
    property Age: Integer;
    property Date: DateTime;

  end;

end.