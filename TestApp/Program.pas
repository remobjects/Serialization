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

      var f := new Foo(Name := "test",
                       Age := 25,
                       Date := DateTime.UtcNow.AddDays(30),
                       Sub := new Bar(Street := "Happy", Number := 5, ID := Guid.NewGuid));

      var j := new JsonCoder;
      j.Encode(f);
      Log($"{j}");
      var x := new XmlCoder;
      x.Encode(f);
      Log($"{x}");

      var f2 := x.Decode(typeOf(Foo)) as Foo;
      var j2 := new JsonCoder;
      j2.Encode(f2);
      Log($"{j2}");

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

    property Street: String;
    property Number: Integer;
    property ID: Guid;

    property a1: Int8;
    property a2: UInt8;
    property b1: Int16;
    property b2: UInt16;
    property c1: Int32;
    property c2: UInt32;
    property d1: Int64;
    property d2: UInt64;
    property e1: IntPtr;
    property e2: UIntPtr;

    property e: Single;
    property f: Double;
    property g: Boolean;

  end;

end.