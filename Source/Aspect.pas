
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

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        var lValue: Value;

        for i := 0 to p.AttributeCount-1 do begin
          var a := p.GetAttribute(i);
          case a.Type.Fullname of
            "RemObjects.Elements.Serialization.EncodeMember": begin
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
        lBody.Add(new StandaloneStatement(lValue));
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

      //var lCoder := fServices.GetType("RemObjects.Elements.Serialization.Coder");
      //var lCoderEncode := lCoder.GetMethod("Encode", ["System.String", "System.Object"], [ParameterModifier.In, ParameterModifier.In]);

      PropertiesLoop:
      for each p in GetCodableProperties do begin

        var lDecoderFunction := case p.Type.Fullname of
          "String",
          "System.String",
          "RemObjects.Elements.RTL.String": "String";

          "System.DateTime",
          "RemObjects.Elements.RTL.DateTime": "DateTime";

          "RemObjects.Elements.System.Integer": "Int32";
          else "Object"
          //else raise new Exception($"Type '{p.Type.Fullname}' is not decodable");
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

        var lValue := if lDecoderFunction = "Object" then
          new BinaryValue(new ProcValue(new ParamValue(0), "Decode"+lDecoderFunction, nil, false, [coalesce(lParameterName, p.Name),
                                                                                                   /*new TypeOfValue(p.Type)*/new NilValue]),
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


  end;

end.