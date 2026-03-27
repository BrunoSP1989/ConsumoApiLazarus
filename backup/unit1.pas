unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  fphttpclient, fpjson, jsonparser, opensslsockets;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    UF,codigoUF : String;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if ComboBox1.ItemIndex >= 0 then
  begin
    UF := ComboBox1.Text;
    CodigoUF := IntToStr(Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]));


    Button1Click(Sender); // carrega os municípios da UF selecionada
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ComboBox1.Items.AddObject('RO', TObject(11));
  ComboBox1.Items.AddObject('AC', TObject(12));
  ComboBox1.Items.AddObject('AM', TObject(13));
  ComboBox1.Items.AddObject('RR', TObject(14));
  ComboBox1.Items.AddObject('PA', TObject(15));
  ComboBox1.Items.AddObject('AP', TObject(16));
  ComboBox1.Items.AddObject('TO', TObject(17));
  ComboBox1.Items.AddObject('MA', TObject(21));
  ComboBox1.Items.AddObject('PI', TObject(22));
  ComboBox1.Items.AddObject('CE', TObject(23));
  ComboBox1.Items.AddObject('RN', TObject(24));
  ComboBox1.Items.AddObject('PB', TObject(25));
  ComboBox1.Items.AddObject('PE', TObject(26));
  ComboBox1.Items.AddObject('AL', TObject(27));
  ComboBox1.Items.AddObject('SE', TObject(28));
  ComboBox1.Items.AddObject('BA', TObject(29));
  ComboBox1.Items.AddObject('MG', TObject(31));
  ComboBox1.Items.AddObject('ES', TObject(32));
  ComboBox1.Items.AddObject('RJ', TObject(33));
  ComboBox1.Items.AddObject('SP', TObject(35));
  ComboBox1.Items.AddObject('PR', TObject(41));
  ComboBox1.Items.AddObject('SC', TObject(42));
  ComboBox1.Items.AddObject('RS', TObject(43));
  ComboBox1.Items.AddObject('MS', TObject(50));
  ComboBox1.Items.AddObject('MT', TObject(51));
  ComboBox1.Items.AddObject('GO', TObject(52));
  ComboBox1.Items.AddObject('DF', TObject(53));
  ComboBox1.Items.AddObject('EX', TObject(99)); // Exterior
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  Client : TFPHttpClient;
  JsonData : TJSONData;
  JSONArray: TJSONArray;
  obj: TJSONObject;
  i: Integer;
  resposta : string;
begin

  Client := TFPHttpClient.Create(nil); // cria o objeto na memoria
  try
    resposta := Client.Get(
      'https://piloto-cbs.tributos.gov.br/servico/calculadora-consumo/api/calculadora/dados-abertos/ufs/municipios?siglaUf=' + UF
    );

    JsonData := GetJSON(resposta);    // converte  = o conteudo da resposta para JSONDATA
    JSONArray := TJSONArray(JsonData);  // converte o JSON DATA para ARRAY

    ComboBox2.Items.Clear;
     // manipula e interage o array
    for i := 0 to JSONArray.Count - 1 do
    begin
      obj := JSONArray.Items[i] as TJSONObject;  // transforma o array em objeto

      // Adiciona o nome visível e guarda o código como objeto associado
      ComboBox2.Items.AddObject(
        obj.FindPath('nome').AsString,
        TObject(obj.FindPath('codigo').AsInteger)
      );
    end;

  finally
    JsonData.Free;   // libera na memoria o JSONDATA
    Client.Free;       // libera na memoria o CLIENTE HTTP
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Client,ClientUF,ClientUniao: TFPHttpClient;
  resposta,respostaUF,respostaUniao : string;
  JsonData,JsonDataUF,JsonDataUniao : TJSONData;
  obj,objUF,objUniao: TJSONObject;
  codigoMunicipio: string;
begin
  if ComboBox2.ItemIndex < 0 then
  begin
    ShowMessage('Selecione uma cidade primeiro.');
    Exit;
  end;

  codigoMunicipio := IntToStr(Integer(ComboBox2.Items.Objects[ComboBox2.ItemIndex]));

  Client      := TFPHttpClient.Create(nil);
  ClientUF    := TFPHttpClient.Create(nil);
  ClientUniao := TFPHttpClient.Create(nil);
  try
    resposta := Client.Get(
      'https://piloto-cbs.tributos.gov.br/servico/calculadora-consumo/api/calculadora/dados-abertos/aliquota-municipio?codigoMunicipio='
      + codigoMunicipio +
      '&data=' + FormatDateTime('yyyy-mm-dd', Date)
    );
    respostaUF := ClientUF.Get(
      'https://piloto-cbs.tributos.gov.br/servico/calculadora-consumo/api/calculadora/dados-abertos/aliquota-uf?codigoUf='
      + codigoUF +
      '&data=' + FormatDateTime('yyyy-mm-dd', Date)
      );
    respostaUniao := ClientUniao.Get(
      'https://piloto-cbs.tributos.gov.br/servico/calculadora-consumo/api/calculadora/dados-abertos/aliquota-uniao?data='
      + FormatDateTime('yyyy-mm-dd', Date)
    );

    JsonData   := GetJSON(resposta);
    JsonDataUF := GetJSON(respostaUF);
    JsonDataUniao  := GetJSON(respostaUniao);
    obj        := JsonData as TJSONObject;
    objUF      := JsonDataUF as TJSONObject;
    objUniao   := JsonDataUniao as TJSONObject;

    Memo1.Lines.Clear;
    Memo1.Lines.Add('Estado: '+ UF);
    Memo1.Lines.Add('Cidade: ' + ComboBox2.Text);
    Memo1.Lines.Add('Código Municipal: ' + codigoMunicipio);
    Memo1.Lines.Add('Código Federal: ' + codigoUF);
    Memo1.Lines.Add('');

    if Assigned(obj.FindPath('aliquotaReferencia')) then
      Memo1.Lines.Add('Alíquota Referência IBS Municipal: ' +
        FloatToStr(obj.FindPath('aliquotaReferencia').AsFloat))
    else
      Memo1.Lines.Add('Alíquota Referência Municipal: não encontrada');

    if Assigned(obj.FindPath('aliquotaPropria')) then
      Memo1.Lines.Add('Alíquota Própria IBS Municipal: ' +
        FloatToStr(obj.FindPath('aliquotaPropria').AsFloat))
    else
      Memo1.Lines.Add('Alíquota Própria Municipal: não encontrada ');
    // estados
    if Assigned(objUF.FindPath('aliquotaReferencia')) then
      Memo1.Lines.Add('Alíquota Referência IBS Estadual: ' +
        FloatToStr(objUF.FindPath('aliquotaReferencia').AsFloat))
    else
      Memo1.Lines.Add('Alíquota Referência Estadual: não encontrada');

    if Assigned(objUF.FindPath('aliquotaPropria')) then
      Memo1.Lines.Add('Alíquota Própria IBS Estadual: ' +
        FloatToStr(objUF.FindPath('aliquotaPropria').AsFloat))
    else
      Memo1.Lines.Add('Alíquota Própria Estadual: não encontrada');
      // Uniao
    if Assigned(objUniao.FindPath('aliquotaReferencia')) then
      Memo1.Lines.Add('Alíquota Própria CBS União: ' +
        FloatToStr(objUniao.FindPath('aliquotaReferencia').AsFloat))
    else
      Memo1.Lines.Add('Alíquota Referência União: não encontrada');

  finally
    JsonData.Free;
    Client.Free;
    JsonDataUF.Free;
    ClientUF.Free;
    JsonDataUniao.Free;
    ClientUniao.Free;
  end;
end;


end.
