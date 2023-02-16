unit preferences;
//Icon by <a href='https://iconpacks.net/?utm_source=link-attribution&utm_content=11488'>Iconpacks</a>

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileCtrl,
  ExtCtrls, ComCtrls;

type

  { THandlePrefs }

  THandlePrefs = class(TForm)
    DiskImage: TLabeledEdit;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure FormCreate(Sender: TObject);
    procedure DiscNameClick(Sender: TObject);
    procedure DiskImageChange(Sender: TObject);
  private

  public

  end;

var
  HandlePrefs: THandlePrefs;

implementation

{$R *.lfm}

{ THandlePrefs }

procedure THandlePrefs.DiskImageChange(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if fileExists(OpenDialog1.Filename) then
      DiskImage.Text:=OpenDialog1.Filename;
      //ShowMessage(OpenDialog1.Filename);
  end
else
  ShowMessage('No file selected');

end;


procedure THandlePrefs.FormCreate(Sender: TObject);
begin

end;

procedure THandlePrefs.DiscNameClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if fileExists(OpenDialog1.Filename) then
      DiskImage.Text:=OpenDialog1.Filename;
      //ShowMessage(OpenDialog1.Filename);
  end
else
  ShowMessage('No file selected');
end;

end.

