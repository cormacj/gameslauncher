unit cpcgameslauncher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  IniPropStorage, ComCtrls, ExtCtrls, FileUtil, preferences,
  unzip;


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
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    GamesTree: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure GamesListBoxClick(Sender: TObject);
    procedure IniPropStorageRestoreProperties(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
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
  StatusBar1.SimpleText:=a;

  //unzip.
end;

procedure TGamesLauncher.FormCreate(Sender: TObject);


begin


end;

procedure TGamesLauncher.IniPropStorageRestoreProperties(Sender: TObject);
begin

end;

procedure TGamesLauncher.MenuItem1Click(Sender: TObject);

begin
  HandlePrefs.visible:=True;
end;


procedure TGamesLauncher.MenuItem2Click(Sender: TObject);
begin
  halt;
end;

procedure TGamesLauncher.MenuItem4Click(Sender: TObject);

  var
  GameFiles: TStringList;
  GamesDirectory: string;
  loop :integer;
  node: TTreeNode;

begin
  GameFiles := TStringList.Create;
  //GamesDirectory := '/mnt/media/games/Amstrad\ CPC\ \[TOSEC\]\ 2017/Amstrad\ CPC\ -\ Games\ -\ \[DSK\]\ \(TOSEC-v2015-05-07_CM\)';
  GamesDirectory := '/home/cormac/Amstrad';

  try
    GameFiles := FindAllFiles(GamesDirectory, '*.zip;*.dsk', true);
    GamesListBox.Items.AddStrings(GameFiles);
    StatusBar1.SimpleText:=Format('Found %d files', [GameFiles.Count]);
    node:=GamesTree.TopItem;

    for loop:=0 to GameFiles.Count-1 do
    begin
        StatusBar1.SimpleText:=GameFiles.strings[loop];
        GamesTree.Items.Add(node,GameFiles.strings[loop]);
    end
    finally
    GameFiles.Free;
  end;

end;

end.

