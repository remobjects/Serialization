﻿namespace RemObjects.Elements.Serialization;

type
  ICodable = public IEncodable and IDecodable;

  IEncodable = public interface
    method Encode(aCoder: Coder);
  end;

  IDecodable = public interface
    method Decode(aCoder: Coder);
  end;

  CodingExeption = public class(Exception)
  end;

  //
  //
  //

  Coder = public partial abstract class
  public

  end;

  GenericCoder<T> = public abstract class(Coder)
  public

    property Current: T read Hierarchy.Peek;
    property Hierarchy := new Stack<T>; readonly;

  end;

  //
  //
  //

  CoderType = public enum ( Undefined = -1, Null = 0, Boolean = 1, String = 2, Int = 3, UInt = 4, Date = 5, Object = 6, IEnumerable = 7);
  Int8 = public SByte;
  UInt8 = public Byte;

  CoderException = public class(Exception)
  end;

end.