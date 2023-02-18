unit cpcgameslauncher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  IniPropStorage, ComCtrls, ExtCtrls, FileUtil, preferences, Grids, ComboEx,
  FileCtrl, DBCtrls, ValEdit, StrUtils;


type

  { TGamesLauncher }

  TGamesLauncher = class(TForm)
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
    GamesGrid: TStringGrid;
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: TConstraintSize);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
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


procedure TGamesLauncher.IniPropStorageRestoreProperties(Sender: TObject);
begin

end;

procedure TGamesLauncher.FormCreate(Sender: TObject);


begin


end;

procedure TGamesLauncher.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: TConstraintSize);
  var
     w :LongInt;

begin
  //math things to scale the tree to the window size
  w:=round(GamesLauncher.Width/4);
  GamesTree.Width:=w;
  w:=round(GamesLauncher.Height-(GamesTree.Top*4)); { todo -oCormac : Find a less terrible way to do this }
  GamesTree.Height:=w;
  GamesGrid.Left:=GamesTree.Width+GamesTree.Left+15;
  GamesGrid.Width:=(GamesLauncher.Width-GamesTree.Width)-32;

  //GamesGrid.AutoSizeColumn(0);
  GamesGrid.ColWidths[0]:=Round((GamesGrid.Width/100)*30); //Filename column is 30% of size
  GamesGrid.Height:=w;
end;

procedure TGamesLauncher.FormWindowStateChange(Sender: TObject);
var
   w :LongInt;

begin
  //math things to scale the tree to the window size
  w:=round(GamesLauncher.Width/4);
  GamesTree.Width:=w;
  w:=round(GamesLauncher.Height-(GamesTree.Top*4)); { todo -oCormac : Also find a less terrible way to do this too }
  GamesTree.Height:=w;
  GamesGrid.Left:=GamesTree.Width+GamesTree.Left+16;
  GamesGrid.Width:=(GamesLauncher.Width-GamesTree.Width)-32;

  //GamesGrid.AutoSizeColumn(0);
  GamesGrid.ColWidths[0]:=Round((GamesGrid.Width/100)*30); //Filename column is 30% of size
  GamesGrid.Height:=w;
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
  tmppath,
  dizline :string;
  dizfile :TextFile;
  dizcontents :string;
  diztmp :array of string;
  grdata :array[0..5] of string;
  n :integer;

begin
  GameFiles := TStringList.Create;
  //GamesDirectory := '/mnt/media/games/Amstrad\ CPC\ \[TOSEC\]\ 2017/Amstrad\ CPC\ -\ Games\ -\ \[DSK\]\ \(TOSEC-v2015-05-07_CM\)';
  GamesDirectory := '/home/cormac/Amstrad';
  GamesDirectory := '/media/cormac/2020-03-30-01-45-30-00/Arcade';

  try
    GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip;*.gz', true);
    //GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip', true, 16);
    //StatusBar1.SimpleText:=Format('Found %d files', [GameFiles.Count]);
    node:=GamesTree.TopItem;

    for loop:=0 to GameFiles.Count-1 do
    begin
        StatusBar1.SimpleText:=GameFiles.strings[loop];
        GamesTree.Items.AddChild(node,ExtractFileName(GameFiles.strings[loop]));
        //GamesTree.AlphaSort;
        tmppath := ExtractFilePath(GameFiles.strings[loop])+'file_id.diz';
        StatusBar1.SimpleText:=tmppath;
        //println(dizfile);
        if FileExists(tmppath) then
          begin
            AssignFile(dizfile, tmppath);
            reset(dizfile);
            while not eof(dizfile) do
            begin
                  readln(dizfile,dizcontents);
                  diztmp:=SplitString(dizcontents,':');
                  //StatusBar1.SimpleText:=diztmp[0];
                  for n:=0 to 5 do

                      grdata[n]:='';


                  case diztmp[0] of
                       'TITLE': grdata[0]:=diztmp[1];
                       'TYPE': grdata[1]:=diztmp[1];
                       'PUBLISHER': grdata[2]:=diztmp[1];
                       'YEAR': grdata[3]:=diztmp[1];
                       'LANGUAGE': grdata[4]:=diztmp[1];
                       'COMMENTS': grdata[5]:=diztmp[1];
                  end;
                  //GamesGrid.InsertRowWithValues(1,ExtractFileName(GameFiles.strings[loop]));
                  GamesGrid.InsertRowWithValues(1,grdata);
            end
          end



    end
    finally
      GamesGrid.SortColRow(true,0);
      GamesTree.AlphaSort;
      GameFiles.Free;
  end;

end;

end.

