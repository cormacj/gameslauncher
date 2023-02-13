unit cpcgameslauncher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  IniPropStorage, ComCtrls, ExtCtrls, FileUtil;


type

  { TGamesLauncher }

  TGamesLauncher = class(TForm)
    GamesListBox: TListBox;
    IniPropStorage: TIniPropStorage;
    MainMenu1: TMainMenu;
    FileStuff: TMenuItem;
    Edit: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure GamesListBoxClick(Sender: TObject);
    procedure IniPropStorageRestoreProperties(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
  private

  public

  end;

var
  GamesLauncher: TGamesLauncher;

implementation

{$R *.lfm}

{ TGamesLauncher }

procedure TGamesLauncher.GamesListBoxClick(Sender: TObject);
  var
  a :string;

begin
  a:=GamesListBox.GetSelectedText;
  StatusBar1.SimpleText:=a
end;

procedure TGamesLauncher.FormCreate(Sender: TObject);

  var
  PascalFiles: TStringList;
  GamesDirectory: String;

begin
  PascalFiles := TStringList.Create;
  //GamesDirectory := '/mnt/media/games/Amstrad\ CPC\ \[TOSEC\]\ 2017/Amstrad\ CPC\ -\ Games\ -\ \[DSK\]\ \(TOSEC-v2015-05-07_CM\)';
  GamesDirectory := '/home/cormac/Amstrad';

  try
    PascalFiles := FindAllFiles(GamesDirectory, '*.zip;*.dsk', true); //find e.g. all pascal sourcefiles
    GamesListBox.Items.AddStrings(PascalFiles);
    StatusBar1.SimpleText:=Format('Found %d files', [PascalFiles.Count]);
  finally
    PascalFiles.Free;
  end;

end;

procedure TGamesLauncher.IniPropStorageRestoreProperties(Sender: TObject);
begin

end;

procedure TGamesLauncher.MenuItem1Click(Sender: TObject);
begin
  //Prefs.Visible:=True;
end;

procedure TGamesLauncher.MenuItem2Click(Sender: TObject);
begin
  halt;
end;

end.

