﻿namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.Cirrus,
  RemObjects.Elements.Cirrus.Values,
  RemObjects.Elements.Cirrus.Statements;

type
  NamingStyle = public enum(AsIs, PascalCase, camelCase, lowercase, UPPERCASE);

  Codable = public class(System.Attribute, IBaseAspect, ITypeInterfaceDecorator)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); virtual;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, NamingStyle);
      lCodableHelpers.ImplementEncode;
      lCodableHelpers.ImplementDecode;
    end;

    constructor; empty;

    constructor (aNamingStyle: NamingStyle);
    begin
      NamingStyle := aNamingStyle;
    end;

    property NamingStyle: NamingStyle;

  end;

  Encodable = public class(Codable)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, NamingStyle);
      lCodableHelpers.ImplementEncode;
    end;

  end;

  Decodable = public class(Codable)
  public

    method HandleInterface(aServices: IServices; aType: ITypeDefinition); override;
    begin
      var lCodableHelpers := new CodableHelpers(aServices, aType, NamingStyle);
      lCodableHelpers.ImplementDecode;
    end;

  end;

  //
  //
  //

  CodableHelpers = unit class
  unit

    constructor(aServices: IServices; aType: ITypeDefinition; aNamingStyle: NamingStyle);
    begin
      fServices := aServices;
      fType := aType;
      fNamingStyle := aNamingStyle;
    end;

    var fServices: IServices; private;
    var fType: ITypeDefinition; private;
    var fNamingStyle: NamingStyle;

    //
    // ENCODE
    //

    method ImplementEncode;
    begin
      AddInterface("RemObjects.Elements.Serialization.IEncodable");

      var lExisting := fType.GetMethod("Encode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if assigned(lExisting) then
        exit;

      var lEncode := fType.AddMethod("Encode", fServices.GetType("System.Void"), false);
      lEncode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      var lBody := new BeginStatement;

      if IsEncodable(fType.ParentType) then begin
        //writeLn($"ParentType {fType.ParentType.Fullname} of {fType.Fullname} is encodable");
        var lInheritedCall := new ProcValue(new SelfValue, "Encode", new IdentifierValue("aCoder"), &Inherited := true);
        lBody.Add(new StandaloneStatement(lInheritedCall));
        lEncode.Virtual := VirtualMode.Override;
      end
      else begin
        lEncode.Virtual := VirtualMode.Virtual;
      end;

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        var lValue: Value;
        var lPosition: IPosition := nil;

        var (lEncoderFunction, lEncoderType) := GetCoderFunctionName(p.Type);

        if not assigned(lEncoderFunction) then begin
          fServices.EmitWarning(p, $"Type '{p.Type.Fullname}' for property '{p.Name}' is not encodable");
          continue;
        end;

        var lParameterName := AdjustName(p.Name);

        //for i := 0 to p.AttributeCount-1 do begin
          //var a := p.GetAttribute(i);
          //case a.Type.Fullname of
            //"RemObjects.Elements.Serialization.EncodeMember": begin
                //lPosition := a;
                //var lName := a.GetParameter(0);
                ////writeLn($"lName.ToString {lName.ToString}");
                ////lValue := new IfStatement()
                //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name)+"."+AdjustName(lName.ToString),
                                                                                       //new IdentifierValue(new IdentifierValue(p.Name), lName.ToString)]);
                //break;
              //end;

            //"RemObjects.Elements.Serialization.Encode": begin
                //var lParameter := a.GetParameter(0) as DataValue;
                //if lParameter.Value is Boolean then begin
                  //if not Boolean(lParameter.Value) then
                    //continue PropertiesLoop;
                //end
                //else begin
                  //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [lParameter.ToString, new IdentifierValue(p.Name)]);
                //end;
                //break;
              //end;
          //end;
        //end;

        case lEncoderFunction of
          //"Object": begin
              //lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, [lParameterName, new IdentifierValue(p.Name)]);
            //end;
          "Array", "List": begin
              lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, [lEncoderType], [lParameterName, new IdentifierValue(p.Name)]);
            end;
          else begin
              lValue := new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, [lParameterName, new IdentifierValue(p.Name)]);
            end;
        end;

        //var lValue := case lEncoderFunction in ["Object", "Array", "List"] then
          //new BinaryValue(new ProcValue(new ParamValue(0), "Encode"+lEncoderFunction, nil, false, [lParameterName,
                                                                                                   //new TypeOfValue(lDecoderType)]),
                          //new TypeValue(p.Type),
                          //BinaryOperator.As)
        //else
          //new ProcValue(new ParamValue(0), "Encode"+lDecoderFunction, nil, false, [lParameterName]);

        //if not assigned(lValue) then
          //lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [AdjustName(p.Name), new IdentifierValue(p.Name)]);
        var lStatement := new StandaloneStatement(lValue);
        if assigned(lPosition) then
          lStatement.Position := lPosition;
        lBody.Add(lStatement);
      end;
      lEncode.ReplaceMethodBody(lBody);

    end;

    //
    // DECODE
    //

    method ImplementDecode;
    begin
      AddInterface("RemObjects.Elements.Serialization.IDecodable");

      var lExisting := fType.GetMethod("Decode", ["RemObjects.Elements.Serialization.Coder"], [ParameterModifier.In]);
      if assigned(lExisting) then
        exit;

      var lDecode := fType.AddMethod("Decode", fServices.GetType("System.Void"), false);
      lDecode.AddParameter("aCoder", ParameterModifier.In, fServices.GetType("RemObjects.Elements.Serialization.Coder"));

      var lBody := new BeginStatement;

      if IsDecodable(fType.ParentType) then begin
        //writeLn($"ParentType {fType.ParentType.Fullname} of {fType.Fullname} is decodable");
        var lInheritedCall := new ProcValue(new SelfValue, "Decode", new IdentifierValue("aCoder"), &Inherited := true);
        lBody.Add(new StandaloneStatement(lInheritedCall));
        lDecode.Virtual := VirtualMode.Override;
      end
      else begin
        lDecode.Virtual := VirtualMode.Virtual;
      end;

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        if p.ReadOnly then
          continue;

        var lValue: Value;
        var lPosition: IPosition := nil;

        //Log($"p.Type {p.Type.Fullname}, {lType.Fullname}");

        var (lDecoderFunction, lDecoderType) := GetCoderFunctionName(p.Type);

        if not assigned(lDecoderFunction) then begin
          fServices.EmitWarning(p, $"Type '{p.Type.Fullname}' for property '{p.Name}' is not decodable");
          continue;
        end;

        var lParameterName := AdjustName(p.Name);

        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          case a.Type.Fullname of
            //"RemObjects.Elements.Serialization.EncodeMember":
            "RemObjects.Elements.Serialization.Encode": begin
                var lParameter := a.GetParameter(0) as DataValue;
                if lParameter.Value is Boolean then begin
                  if not Boolean(lParameter.Value) then
                    continue PropertiesLoop;
                end
                else begin
                  lParameterName := lParameter.ToString;
                end;
                break;
              end;
          end;
        end;

        case lDecoderFunction of
          "Object": begin
              lValue := new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, [lParameterName, new TypeOfValue(lDecoderType)]),
                                        new TypeValue(p.Type),
                                        BinaryOperator.As)
            end;
          "Array", "List": begin
              Log($"""Decode""+lDecoderFunction {"Decode"+lDecoderFunction}");
              lValue := new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, [lDecoderType], [lParameterName/*, new TypeOfValue(lDecoderType)*/]),
                                        new TypeValue(p.Type),
                                        BinaryOperator.As)
            end;
          else begin
              lValue := new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, [lParameterName]);
            end;
        end;

        var lStatement := new AssignmentStatement(new IdentifierValue(p.Name), lValue);
        if assigned(lPosition) then
          lStatement.Position := lPosition;
        lBody.Add(lStatement);
      end;
      lDecode.ReplaceMethodBody(lBody);

    end;

    method GetCoderFunctionName(aType: IType): tuple of (String, IType);
    begin

      method FlattenType(aType: IType): IType;
      begin
        while aType is ILinkType do
          aType := (aType as ILinkType).SubType;
        while aType is IRemappedType do
          aType := (aType as IRemappedType).RealType;
        while aType is ILinkType do
          aType := (aType as ILinkType).SubType;
        result := aType;
      end;

      aType := FlattenType(aType);

      var lCoderFunction: String;
      var lCoderType: IType;
      case aType.Fullname of
        "System.String": lCoderFunction := "String";

        "RemObjects.Elements.RTL.Guid",
        "System.Guid": lCoderFunction := "Guid";

        "RemObjects.Elements.RTL.DateTime",
        "System.DateTime": lCoderFunction := "DateTime";

        "System.Byte": lCoderFunction := "UInt8";
        "System.SByte": lCoderFunction := "Int8";
        "System.Int16": lCoderFunction := "Int16";
        "System.Int32": lCoderFunction := "Int32";
        "System.Int64", "System.IntPtr": lCoderFunction := "Int64";
        "System.UInt16": lCoderFunction := "UInt16";
        "System.UInt32": lCoderFunction := "UInt32";
        "System.UInt64", "System.UIntPtr": lCoderFunction := "UInt64";

        "System.Single": lCoderFunction := "Single";
        "System.Double": lCoderFunction := "Double";
        "System.Boolean": lCoderFunction := "Boolean";
        else begin
          if IsDecodable(aType) then begin
            lCoderFunction := "Object";
            lCoderType := aType;
            //Log($"Decode: treating '{lType.Fullname}' as decodale object");
          end
          else if aType is var lArrayType: IArrayType then begin
            lCoderFunction := "Array";
            lCoderType := FlattenType(lArrayType.SubType);
            writeLn($"lCoderType {lCoderType}");
            //writeLn($"lCoderType {lCoderType.Fullname}");
            //if lCoderType is then
          end
          else begin
            //Log($"lType {lType}");
            //Log($"lType.Fullname {lType.Fullname}");
          end;
        end;
      end;
      result := (lCoderFunction, lCoderType);
    end;

    method GetCodableProperties: sequence of IPropertyDefinition; iterator;
    begin
      for i := 0 to fType.PropertyCount-1 do begin
        var p := fType.GetProperty(i);
        //Log($"- {p.Name}: {p.Type.Name}");
        // Todo: check if it can be serialized
        yield p;
      end;
    end;

    method AdjustName(aName: String): String;
    begin
      result := case fNamingStyle of
        NamingStyle.AsIs: aName;
        NamingStyle.lowercase: aName:ToLowerInvariant;
        NamingStyle.UPPERCASE: aName:ToUpperInvariant;
        NamingStyle.PascalCase: ConvertToPascalCase(aName);
        NamingStyle.camelCase: ConvertToCamelCase(aName);
        else raise new Exception($"The '{fNamingStyle}' naming style is not implemented yet");
      end;
    end;

    method ConvertToPascalCase(aName: String): String;
    begin
      var lChars := aName.ToCharArray;
      var i := 0;
      lChars[i] := Char.ToUpperInvariant(lChars[i]);
      while i < length(lChars) do begin
        if (lChars[i] = 'I') and (i < length(lChars)) then begin
          if (i = length(lChars)-2) and (lChars[i+1] = "d") then begin
            lChars[i+1] := 'D';
            break;
          end
        end;
        inc(i);
      end;
      result := new String(lChars);
    end;

    method ConvertToCamelCase(aName: String): String;
    begin
      if length(aName) = 0 then
        exit aName;
      var lChars := aName.ToCharArray;
      var i := 0;
      while i < length(lChars) do begin
        if Char.IsUpper(lChars[i]) then begin
          if (i = 0) then
            lChars[i] := Char.ToLowerInvariant(lChars[i]);
          inc(i);
          if (i < length(lChars)) and Char.IsUpper(lChars[i]) then begin
            while (i < length(lChars)-1) and Char.IsUpper(lChars[i]) and Char.IsUpper(lChars[i+1]) do begin
              lChars[i] := Char.ToLowerInvariant(lChars[i]);
              inc(i);
            end;
            if (i = length(lChars)-1) and Char.IsUpper(lChars[i]) then begin
              lChars[i] := Char.ToLowerInvariant(lChars[i]);
              inc(i);
            end;
          end;
        end;
        while (i < length(lChars)) and not Char.IsUpper(lChars[i]) do begin
          inc(i);
        end;
      end;
      result := new String(lChars);
    end;

    method AddInterface(aName: String);
    begin
      for i := 0 to fType.InterfaceCount-1 do
        if fType.GetInterface(i).Name = aName then
          exit;
      fType.AddInterface(fServices.GetType(aName));
    end;

    method TypeImplementsInterface(aType: IType; aName: String): Boolean;
    begin
      for i := 0 to aType.InterfaceCount-1 do begin
        if aType.GetInterface(i).Name = aName then
          exit true;
      end;
    end;

    method TypeHasAttribute(aType: IType; aName: String): Boolean;
    begin
      if aType is var lAttributesProvider: IAttributesProvider then
        for i := 0 to lAttributesProvider.AttributeCount-1 do
          if lAttributesProvider.GetAttribute(i).Type.Fullname = aName then
            exit true;
    end;

    method IsDecodable(aType: IType): Boolean;
    begin
      result := TypeImplementsInterface(aType, "RemObjects.Elements.Serialization.IDecodable") or
                TypeHasAttribute(aType, "RemObjects.Elements.Serialization.Decodable") or
                TypeHasAttribute(aType, "RemObjects.Elements.Serialization.Codable");

    end;

    method IsEncodable(aType: IType): Boolean;
    begin
      result := TypeImplementsInterface(aType, "RemObjects.Elements.Serialization.IEncodable") or
                TypeHasAttribute(aType, "RemObjects.Elements.Serialization.Encodable") or
                TypeHasAttribute(aType, "RemObjects.Elements.Serialization.Codable");

    end;
  end;

end.