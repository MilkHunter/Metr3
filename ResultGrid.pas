unit ResultGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids;

type
  TfrmResult = class(TForm)
    ResultGrid: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmResult: TfrmResult;

implementation

{$R *.dfm}

end.
