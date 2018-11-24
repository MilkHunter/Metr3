unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TForm3 = class(TForm)
    btnAnalize: TBitBtn;
    OpenDialog: TOpenDialog;
    procedure btnAnalizeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation
uses
  Analize;

{$R *.dfm}

procedure TForm3.btnAnalizeClick(Sender: TObject);
var
  InFile: file of Char;
  AnalFile, TypesFile, IOProcFile, ReservedIdsFile: String;
begin
  OpenDialog.Execute();
  if OpenDialog.FileName <> '' then
  begin
    AnalFile  := OpenDialog.FileName;
    TypesFile := 'Types.txt';
    IOProcFile := 'IOProcedures.txt';
    ReservedIdsFile := 'Reserved.txt';
    AnalizeCode(AnalFile, TypesFile, IOProcFile, ReservedIdsFile);
  end
  else
    ShowMessage('Error was occured');
end;

end.
