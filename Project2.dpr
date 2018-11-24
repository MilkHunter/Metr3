program Project2;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form3},
  Vcl.Themes,
  Vcl.Styles,
  Analize in 'Analize.pas',
  Structures in 'Structures.pas',
  ResultGrid in 'ResultGrid.pas' {frmResult};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TfrmResult, frmResult);
  Application.Run;
end.
