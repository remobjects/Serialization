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
        //writeLn('The magic happens here.');

        //var f := new Foo(Name := "test",
                         //Age := 25,
                         ////DateOfBirth := DateTime.UtcNow.AddDays(30),
                         ////DateOfBirth2 := DateTime.UtcNow.AddDays(30),
                         //Sub := new Bar2(Street := "Happy", Number := 5, ID := Guid.NewGuid, Isbar2 := true),
                         //Arr := ["Hello", "World"],
                         //Arr2 := [1,2],
                         //Arr3 := [new Bar(Street := "Bar1"),
                                  //new Bar2(Street := "Bar2")],
                         ////Sub2 := new Baz
                         //);

        //var j := new JsonCoder;
        //j.Encode(f);
        //Log($"---");
        //Log($"{j}");
        //Log($"---");
        //var x := new XmlCoder;
        //x.Encode(f);
        //Log($"{x}");
        //Log($"---");

        ////var f2 := x.Decode(typeOf(Foo)) as Foo;
        ////var j2 := new JsonCoder;
        ////j2.Encode(f2);
        ////Log($"{j2}");

        //////var f3 := j.Decode(typeOf(Foo)) as Foo;
        ////var f3 := j.Decode<Foo> as Foo;
        ////var j3 := new JsonCoder;
        ////j3.Encode(f3)
        ////Log($"{j3}");

        //var f4 := x.Decode<Foo> as Foo;
        //var j4 := new JsonCoder;
        //j4.Encode(f4);
        //Log($"{j4}");

        ////var j2 := new JsonCoder withJson(JsonDocument.FromString('{"id":"42000595-512a-47f5-a56f-5978d6dddaae","userId":"58a30cca-633d-48b3-85c1-76b9e7548142","user":{"name":"","profilePictureUrl":"https://profiles.static.staging.wunite.io/58a30cca-633d-48b3-85c1-76b9e7548142.jpeg"},"date":"2023-11-24T19:15:01","text":"A random dummy post #2","link":"https://www.wunite.io/","mediaUrls":["https://feed.static.staging.wunite.io/missing.jpeg","https://feed.static.staging.wunite.io/missing.jpeg","https://feed.static.staging.wunite.io/missing.jpeg"],"numberOfLikes":22,"numberOfDislikes":0,"numberOfComments":71}'));
        ////var p := j2.Decode<Post>;
        ////Log($"p {p}");
        //var p := new Post;
        ////p.MediaUrls := nil;

        //p.Users := [new User(Roles1 := ['a', 'b'], Roles2 := ["c", "d"].ToList), new User2, new User];

        ////var x := new Post;
        //p.ToJson();
        ////x.UserA := new User(Email := "test@test.com");
        ////x.UserB := new User2(Email := "test@test.com");
        ////x.UserC := new User2(Email := "test@test.com");
        //var j := new JsonCoder;
        //j.Encode(p);
        //Log($"j.json {j.Json}");

        //j := new JsonCoder withJson(j.Json/*new JsonObject*/);
        //var lPost := j.Decode<Post>;

        //Log($"lPost {lPost}");

        //var c := new JsonCoder withFile("/Users/mh/Downloads/fba90903-f601-46f6-8c04-40f6135da12d.json");
        //var u := c.Decode<PlayseUser>;
        //Log($"u.Roles.Count {u.Roles.Count}");
        //Log($"u.Roles.First {u.Roles.First}");

        var lSocialMediaUrls := ["a", "b"];

        var lEncoder := new JsonCoder();
        //lEncoder.Encode(lSocialMediaUrls);
        lEncoder.EncodeArray(nil, lSocialMediaUrls);
        Log($"lEncoder {lEncoder.Json}");


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
    property DateOfBirth2: PlatformDateTime;

    property g: Guid;
    property g2: PlatformGuid;

    property g3: nullable Guid;
    property g4: not nullable Guid := new Guid;

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
  Bar = public class//(IEncodable, IDecodable)
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

    property na1: nullable Int8;
    property na2: nullable UInt8;
    property nb1: nullable Int16;
    property nb2: nullable UInt16;
    property nc1: nullable Int32;
    property nc2: nullable UInt32;
    property nd1: nullable Int64;
    property nd2: nullable UInt64;
    property ne1: nullable IntPtr;
    property ne2: nullable UIntPtr;

    property ne: nullable Single;
    property nf: nullable Double;
    property ng: nullable Boolean;
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

type
  //[Codable(NamingStyle.camelCase)]
  //FeedItem = public class(CodableHelper)
  //public

    //property ID: Guid := new Guid;
    //property UserID: Guid := new Guid;
    //property User: User := new User;
    //property Date: DateTime := DateTime.UtcNow;
    //property Text: String;
    //property Link: String;
    //property Ad: nullable Boolean;
    //property MediaUrls: array of String;

  //end;

  //[Codable(NamingStyle.camelCase)]
  //Post = public class(FeedItem)
  //public

    //property NumberOfLikes: nullable Integer;
    //property NumberOfDislikes: nullable Integer;
    //property NumberOfComments: nullable Integer;

    ////class method FromJson(aJson: JsonDocument): InstanceType;
    ////begin
      ////var lCoder := new JsonCoder withJson(aJson);
      ////result := lCoder.Decode(self) as InstanceType;
    ////end;

    ////class method FromRecord(aRow: posts): InstanceType;
    ////begin
      ////var lCoder := new JsonCoder withJson(JsonDocument.FromString(aRow.data));
      ////result := lCoder.Decode<Post>;
      ////result.ID := aRow.ID;
      ////result.User := UserCache.Instance.GetFeedUser(aRow.user_id);
      ////result.Date := aRow.Date;
    ////end;

    //property Users: array of User;

  //end;

  //[Codable(NamingStyle.camelCase)]
  //User = public class
  //public
    //property Test: Integer;
    //property Handle: String;
    //property Name: String;
    //property Email: String;

    //property Roles1: array of String;
    //property Roles2: List<String>;
  //end;

  //[Codable(NamingStyle.camelCase)]
  //User2 = public class(User)
  //public
    //property Test2: Integer;
  //end;

  //CodableHelper = public class
  //public

    //method ToJson: JsonDocument;
    //begin
      //var lCoder := new JsonCoder;
      //lCoder.Encode(self);
      //result := lCoder.Json;
    //end;

    ////class method FromJson(aJson: JsonDocument): InstanceType; virtual;
    ////begin
      ////var lCoder := new JsonCoder withJson(aJson);
      ////result := lCoder.Decode(self) as InstanceType;
    ////end;

    //[ToString]
    //method ToString: String; override;
    //begin
      //result := ToJson.ToString;
    //end;

  //end;

  [Codable(NamingStyle.camelCase)]
  PlayseUser = public class/*(RemObjects.Infrastructure.Identity.User)*/
  public

    property ID: Guid;
    property ManagerID: Guid;
    property FirstName: String;
    property LastName: String;
    property Handle: String;
    property Roles: array of String;

    property PhoneNumber: String;
    property BirthDate: String;
    property Email: String;

    property PasswordHash: String;
    property Confirmed: Boolean;

    property FidelitySessionCount: nullable Integer;
    property Banned: nullable Boolean;

    property City: String;
    //property CityGeolocation: Coordinates;
    //property Cities: array of City;

    property ImageURL: String;

    //method ValidatePassword(aPassword: String): Boolean;
    //begin
      //result := false;
    //end;

  end;

end.