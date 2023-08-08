
namespace RemObjects.Elements.Serialization;

uses
  RemObjects.Elements.Cirrus,
  RemObjects.Elements.Cirrus.Values,
  RemObjects.Elements.Cirrus.Statements;

type
  Codable = public class(System.Attribute, IBaseAspect, ITypeInterfaceDecorator)
  public

    method HandleInterface(aServices: IServices; fType: ITypeDefinition);
    begin
      var lCodableHelpers := new CodableHelpers(aServices, fType);
      lCodableHelpers.ImplementEncode;
      lCodableHelpers.ImplementDecode;
    end;

  end;

  Encodable = public class(System.Attribute, IBaseAspect, ITypeInterfaceDecorator)
  public

    method HandleInterface(aServices: IServices; fType: ITypeDefinition);
    begin
      var lCodableHelpers := new CodableHelpers(aServices, fType);
      lCodableHelpers.ImplementEncode;
    end;

  end;

  Decodable = public class(System.Attribute, IBaseAspect, ITypeInterfaceDecorator)
  public

    method HandleInterface(aServices: IServices; fType: ITypeDefinition);
    begin
      var lCodableHelpers := new CodableHelpers(aServices, fType);
      lCodableHelpers.ImplementDecode;
    end;

  end;

  //
  //
  //

  CodableHelpers = unit class
  unit

    constructor(aServices: IServices; aType: ITypeDefinition);
    begin
      fServices := aServices;
      fType := aType;
    end;

    var fServices: IServices; private;
    var fType: ITypeDefinition; private;

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

        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          case a.Type.Fullname of
            "RemObjects.Elements.Serialization.EncodeMember": begin
                lPosition := a;
                var lName := a.GetParameter(0);
                writeLn($"lName.ToString {lName.ToString}");
                //lValue := new IfStatement()
                lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [p.Name+"."+lName.ToString,
                                                                                       new IdentifierValue(new IdentifierValue(p.Name), lName.ToString)]);
                break;
              end;

            "RemObjects.Elements.Serialization.Encode": begin
                var lParameter := a.GetParameter(0) as DataValue;
                if lParameter.Value is Boolean then begin
                  if not Boolean(lParameter.Value) then
                    continue PropertiesLoop;
                end
                else begin
                  lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [lParameter.ToString, new IdentifierValue(p.Name)]);
                end;
                break;
              end;
          end;
        end;

        if not assigned(lValue) then
          lValue := new ProcValue(new ParamValue(0), "EncodeField", nil, false, [p.Name, new IdentifierValue(p.Name)]);
        var lStatement := new StandaloneStatement(lValue);
        if assigned(lPosition) then
          lStatement.Position := lPosition;
        lBody.Add(lStatement);
      end;
      lEncode.ReplaceMethodBody(lBody);

    end;

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

        var lType := p.Type;
        while lType is ILinkType do
          lType := (lType as ILinkType).SubType;
        while lType is IRemappedType do
          lType := (lType as IRemappedType).RealType;
        while lType is ILinkType do
          lType := (lType as ILinkType).SubType;

        //Log($"p.Type {p.Type.Fullname}, {lType.Fullname}");

        var lDecoderFunction: String;
        var lDecoderType: IType;
        case lType.Fullname of
          "System.String": lDecoderFunction := "String";

          "RemObjects.Elements.RTL.Guid",
          "System.Guid": lDecoderFunction := "Guid";

          "RemObjects.Elements.RTL.DateTime",
          "System.DateTime": lDecoderFunction := "DateTime";

          "System.Byte": lDecoderFunction := "UInt8";
          "System.SByte": lDecoderFunction := "Int8";
          "System.Int16": lDecoderFunction := "Int16";
          "System.Int32": lDecoderFunction := "Int32";
          "System.Int64", "System.IntPtr": lDecoderFunction := "Int64";
          "System.UInt16": lDecoderFunction := "UInt16";
          "System.UInt32": lDecoderFunction := "UInt32";
          "System.UInt64", "System.UIntPtr": lDecoderFunction := "UInt64";

          "System.Single": lDecoderFunction := "Single";
          "System.Double": lDecoderFunction := "Double";
          "System.Boolean": lDecoderFunction := "Boolean";

          else begin
            if IsDecodable(lType) then begin
              lDecoderFunction := "Object";
              lDecoderType := lType;
              //Log($"Decode: treating '{lType.Fullname}' as decodale object");
            end
            else if lType.IsReferenceType then begin
              //Log($"Decode: treating '{lType.Fullname}' as object, but its not decodable");
            end
            else begin
              //Log($"Decode: treating '{lType.Fullname}' is not an object and not decodable");
            end;
          end;
        end;

        //Log($"lDecoderFunction {p.Name}: {lType.Fullname} ({lType.IsReferenceType} {lType.IsValueType}) -> {lDecoderFunction}");

        if not assigned(lDecoderFunction) then begin
          fServices.EmitWarning(p, $"Type '{lType.Fullname}' for property '{p.Name}' is not decodable");
          continue;
        end;

        var lParameterName: String;

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

        var lValue := if lDecoderFunction = "Object"/*) and assigned(lDecoderType)*/ then
          new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, false, [coalesce(lParameterName, p.Name),
                                                                                                   new TypeOfValue(lDecoderType)]),
                          new TypeValue(p.Type),
                          BinaryOperator.As)
        else
          new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, false, [coalesce(lParameterName, p.Name)]);

        var lStatement := new AssignmentStatement(new IdentifierValue(p.Name),lValue);
        lBody.Add(lStatement);
      end;
      lDecode.ReplaceMethodBody(lBody);

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