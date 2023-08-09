namespace TestApp;

uses
  RemObjects.Elements.Serialization;

type
  Program = class
  public
    class method Main(args: array of String): Int32;
    begin
      try
      // add your own code here
        writeLn('The magic happens here.');

        var f := new Foo(Name := "test",
                         Age := 25,
                         DateOfBirth := DateTime.UtcNow.AddDays(30),
                         Sub := new Bar2(Street := "Happy", Number := 5, ID := Guid.NewGuid, Isbar2 := true),
                         Arr := ["Hello", "World"],
                         Arr2 := [1,2],
                         Arr3 := [new Bar(Street := "Bar1"),
                                  new Bar2(Street := "Bar2")],
                         //Sub2 := new Baz
                         );

        var j := new JsonCoder;
        j.Encode(f);
        Log($"---");
        Log($"{j}");
        Log($"---");
        var x := new XmlCoder;
        x.Encode(f);
        Log($"{x}");
        Log($"---");

        //var f2 := x.Decode(typeOf(Foo)) as Foo;
        //var j2 := new JsonCoder;
        //j2.Encode(f2);
        //Log($"{j2}");

        ////var f3 := j.Decode(typeOf(Foo)) as Foo;
        //var f3 := j.Decode<Foo> as Foo;
        //var j3 := new JsonCoder;
        //j3.Encode(f3)
        //Log($"{j3}");

        var f4 := x.Decode<Foo> as Foo;
        var j4 := new JsonCoder;
        j4.Encode(f4);
        Log($"{j4}");

      except
        on E: Exception do
          writeLn(E);
      end;

    end;

  end;

  [Codable(NamingStyle.PascalCase)]
  Foo = public class
  public

    property Name: String;
    //[EncodeMember("Max")]
    property Age: Integer;
    property DateOfBirth: DateTime;

    property id: String;
    property fooBar: String;

    //property ID: String;
    property HtmlTest: String;
    property IOStream: String;
    //property SessionID: String;
    property sessionId: String;

    property Sub: Bar;
    property Sub2: Baz;

    property Arr: array of String;
    property Arr2: array of Integer;
    property Arr3: array of Bar;

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

    //constructor;
    //begin
      //writeLn("ctor");
    //end;

  end;

  [Codable]
  Bar2 = public class(Bar)
  public
    property Isbar2: Boolean;

    //constructor;
    //begin
      //writeLn("ctor Bar2");
    //end;

  end;

  Baz = public class
  end;


end.