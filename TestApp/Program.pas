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
                       Sub := new Bar2(Street := "Happy", Number := 5, ID := Guid.NewGuid, Isbar2 := true),
                       //Sub2 := new Baz
                       );

      var j := new JsonCoder;
      j.Encode(f);
      Log($"{j}");
      //var x := new XmlCoder;
      //x.Encode(f);
      //Log($"{x}");

      //var f2 := x.Decode(typeOf(Foo)) as Foo;
      //var j2 := new JsonCoder;
      //j2.Encode(f2);
      //Log($"{j2}");

      //var f3 := j.Decode(typeOf(Foo)) as Foo;
      var f3 := j.Decode<Foo> as Foo;
      var j3 := new JsonCoder;
      j3.Encode(f3);
      Log($"{j3}");

    end;

  end;

  [Codable]
  Foo = public class
  public

    property Name: String;
    //[EncodeMember("Max")]
    property Age: Integer;
    property Date: DateTime;

    property Sub: Bar;
    property Sub2: Baz;

    //property Bars := new List<Bar>;

  end;

  [Codable]
  Bar = public class(IEncodable, IDecodable)
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

    constructor;
    begin
      writeLn("ctor");
    end;

  end;

  [Codable]
  Bar2 = public class(Bar)
  public
    property Isbar2: Boolean;

    constructor;
    begin
      writeLn("ctor Bar2");
    end;

  end;

  Baz = public class
  end;


end.