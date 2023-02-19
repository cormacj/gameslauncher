unit cpcgameslauncher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  IniPropStorage, ComCtrls, ExtCtrls, FileUtil, preferences, Grids, ComboEx,
  FileCtrl, DBCtrls, ValEdit, StrUtils, LazUTF8;


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
    type
        //here we define the details for the games we import
        GameDetails = record
          filename,
          title,
          genre,
          company,
          year,
          language,
          comments :string;
        end;
    var
       totalgames :integer;
       games: array[0..9999] of GameDetails; //TOSEC is around 6500+ files, may have to increase if I add spectrum/c64/dosbox TODO maybe?

  end;

var
  GamesLauncher: TGamesLauncher;

implementation

{$R *.lfm}

{ TGamesLauncher }

function Capit(const s:string):string;
var
  res,tmp,i,u,l :string;
  bits :array of string;
  size,n :integer;

begin
  res:='';
  if s<>'' then
  begin
    bits:=s.Split(' ',TStringSplitOptions.ExcludeEmpty);
    size:=Length(bits)-1;
    for n:=0 to size do
      begin
           tmp:=bits[n];
           u:=UpperCase(LeftStr(tmp,1));
           l:=LowerCase(RightStr(tmp,Length(tmp)-1));
           AppendStr(u,l);
           AppendStr(res,u);
           AppendStr(res,' ');
      end;
    end;
    Capit:=res;
  end;

procedure TGamesLauncher.IniPropStorageRestoreProperties(Sender: TObject);
begin

end;

procedure TGamesLauncher.FormCreate(Sender: TObject);


begin
  totalgames:=0;
  //ShowMessage(Format('Launcher started - totalgames=%d', [totalgames]));
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
  dizPcontents :Pchar;
  diztmp :array[0..5] of string;
  grdata :array[0..5] of string;
  n :integer;

begin
  GameFiles := TStringList.Create;
  //GamesDirectory := '/mnt/media/games/Amstrad\ CPC\ \[TOSEC\]\ 2017/Amstrad\ CPC\ -\ Games\ -\ \[DSK\]\ \(TOSEC-v2015-05-07_CM\)';
  GamesDirectory := '/home/cormac/Amstrad';
  GamesDirectory := '/media/cormac/2020-03-30-01-45-30-00';

  try
    GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip;*.gz', true);
    //GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip', true, 16);
    //StatusBar1.SimpleText:=Format('Found %d files', [GameFiles.Count]);
    node:=GamesTree.TopItem;

    for loop:=0 to GameFiles.Count-1 do
    begin
        StatusBar1.SimpleText:=GameFiles.strings[loop];
        GamesTree.Items.AddChild(node,ExtractFileName(GameFiles.strings[loop]));
        //grdata[0]:=ExtractFileName(GameFiles.strings[loop]);
        //grdata[1]:='zzzzzz';
        //GamesTree.AlphaSort;
        tmppath := ExtractFilePath(GameFiles.strings[loop])+'file_id.diz';
        StatusBar1.SimpleText:=tmppath;
        //println(dizfile);
        for n:=0 to 5 do
        begin
            grdata[n]:='';
        end;


        if FileExists(tmppath) then
          begin
            AssignFile(dizfile, tmppath);
            reset(dizfile);
            while not eof(dizfile) do
            begin
                //Let's break down a .diz file:
                //I'm assuming that the structure is something like:
                // random header
                // SOMETHING: TEXT
                // etc until end
                  readln(dizfile,dizcontents);
                  n:=Pos(':',dizcontents);
//                  writeln(n, dizcontents);
                  if n>0 then
                    begin
                      diztmp[0]:=Trim(Copy(dizcontents,1,n-1));
                      diztmp[1]:=TrimLeft(Copy(dizcontents,n+1,Length(dizcontents)-n));
                      //  writeln(n, diztmp[0],diztmp[1]);
                      case diztmp[0] of
                           'TITLE': grdata[0]:=UTF8String(Capit(diztmp[1]));
                           'TYPE': grdata[1]:=diztmp[1];
                           'COMPANY': grdata[2]:=UTF8String(Capit(diztmp[1]));
                           'YEAR': grdata[3]:=diztmp[1];
                           'LANGUAGE': grdata[4]:=diztmp[1];
                           'COMMENTS': grdata[5]:=diztmp[1];

                      end;
                    end;
              end;
              closefile(dizfile);
          end;
        if grdata[0]='' then
          grdata[0]:=GameFiles.strings[loop];
        GamesGrid.InsertRowWithValues(1,grdata);

        //ShowMessage(Format('Import started - totalgames=%d', [totalgames]));
        games[totalgames].filename:=GameFiles.strings[loop];
        games[totalgames].title:=Capit(grdata[0]);
        games[totalgames].genre:=grdata[1];
        games[totalgames].company:=Capit(grdata[2]);
        games[totalgames].year:=grdata[3];
        games[totalgames].language:=grdata[4];
        games[totalgames].comments:=grdata[5];
        totalgames:=totalgames+1;
        StatusBar1.Panels.Items[0].text:=Format('Import started - totalgames=%d', [totalgames]);
        StatusBar1.Panels.Items[1].text :='asdsadsadada';
    end
    finally
      GamesGrid.SortColRow(true,0);
      GamesTree.AlphaSort;
      GameFiles.Free;
    end;
  end;
end.
