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
    CommentDetails1: TMemo;
    FullGameFile: TLabeledEdit;
    GenreDetails1: TLabeledEdit;
    GameDetailsBox: TGroupBox;
    IniPropStorage: TIniPropStorage;
    Label2: TLabel;
    LanguageDetails1: TLabeledEdit;
    MainMenu1: TMainMenu;
    FileStuff: TMenuItem;
    Edit: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog1: TOpenDialog;
    ProgressBar1: TProgressBar;
    PublisherDetails1: TLabeledEdit;
    RunCommandDetails1: TLabeledEdit;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    GamesTree: TTreeView;
    GamesGrid: TStringGrid;
    TitleDetails1: TLabeledEdit;
    YearDetails1: TLabeledEdit;
    procedure FormConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: TConstraintSize);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure GamesGridClick(Sender: TObject);
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
          runcmd,
          comments :string;
        end;
    var
       totalgames :integer;
       games: array[0..19999] of GameDetails; //TOSEC is around 6500+ files, Should be enough for now { #todo : Make a "Max storage" reached type error message if we hit the upper limit }
       //games: array of GameDetails;
  end;

var
  GamesLauncher: TGamesLauncher;

implementation

{$R *.lfm}

{ TGamesLauncher }

function Capit(const s:string):string;

//Convert a string from any case to a first capital, then lower case string
//eg THIS IS A STRING becomes This Is A String.

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

procedure TGamesLauncher.FormCreate(Sender: TObject);


begin
  totalgames:=0;
  //ShowMessage(Format('Launcher started - totalgames=%d', [totalgames]));
  StatusBar1.Panels.Items[2].text:='';
  TitleDetails1.Text:='';
  GenreDetails1.Text:='';
  PublisherDetails1.Text:='';
  YearDetails1.Text:='';
  LanguageDetails1.Text:='';
  RunCommandDetails1.Text:='';
  FullGameFile.Text:='';
  //memo boxes are annoying but...
  CommentDetails1.Lines.Clear;


end;

procedure TGamesLauncher.FormPaint(Sender: TObject);

//Hide the annoying border around the groupbox.

  var  Region : TRegion;

  begin
  Region := TRegion.create;
  Region.AddRectangle(2,2,GameDetailsBox.Width-2,GameDetailsBox.Height-2);
  GameDetailsBox.SetShape (Region);
  Region.free;
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
  GamesGrid.Height:=w-GameDetailsBox.Height;
  GameDetailsBox.Top:=GamesGrid.Top+GamesGrid.Height+16;
  GameDetailsBox.Left:=GamesGrid.Left;


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
  GamesGrid.Height:=w-GameDetailsBox.Height;
  GameDetailsBox.Left:=GamesGrid.Left;
  GameDetailsBox.Top:=GamesGrid.Top+GamesGrid.Height+16;

end;

procedure TGamesLauncher.GamesGridClick(Sender: TObject);
var
   row :integer;
   s :string;

begin
  row:=GamesGrid.Row;
  s:=GamesGrid.Cells[0,row];
  StatusBar1.Panels.Items[2].text:=Format('Row=%s', [s]);
  TitleDetails1.Text:=GamesGrid.Cells[0,row];
  GenreDetails1.Text:=GamesGrid.Cells[1,row];
  PublisherDetails1.Text:=GamesGrid.Cells[2,row];
  YearDetails1.Text:=GamesGrid.Cells[3,row];
  LanguageDetails1.Text:=GamesGrid.Cells[4,row];
  RunCommandDetails1.Text:=GamesGrid.Cells[5,row];
  FullGameFile.Text:=GamesGrid.Cells[7,row];
  //memo boxes are annoying but...
  CommentDetails1.Lines.Clear;
  CommentDetails1.Lines.AddText(GamesGrid.Cells[6,row]);
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
  tmppath :string;
  dizfile :TextFile;
  dizcontents :string;
  diztmp :array[0..1] of string;
  grdata :array[0..7] of string;
  genres :array[0..100] of string;
  n :integer;

  //vars for deduping
  found :boolean;
  srch :string;

begin
  GameFiles := TStringList.Create;
  //GamesDirectory := '/mnt/media/games/Amstrad\ CPC\ \[TOSEC\]\ 2017/Amstrad\ CPC\ -\ Games\ -\ \[DSK\]\ \(TOSEC-v2015-05-07_CM\)';
  GamesDirectory := '/home/cormac/Amstrad';
  GamesDirectory := '/media/cormac/2020-03-30-01-45-30-00';

  try
    GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip;*.gz', true);
    //GameFiles := FindAllFiles(GamesDirectory, '*.dsk;*.zip', true, 16);
    //StatusBar1.SimpleText:=Format('Found %d files', [GameFiles.Count]);
    //node:=GamesTree.TopItem;

    
    //Lets make the progress bar the width of the games grid and place it on top
    ProgressBar1.Left:=GamesGrid.Left;
    ProgressBar1.Width:=GamesGrid.Width;
    ProgressBar1.Visible:=True;
    ProgressBar1.Top:=Round((GamesGrid.Top+GamesGrid.Height+ProgressBar1.Height)/2);
    ProgressBar1.Style:=pbstMarquee; //Because the next thing we are going to do is to enumerate the folder tree,
                                     //we'll get the progress bar to just do something so it doesn't look like it just hung up.
    ProgressBar1.Update;
    ProgressBar1.Style:=pbstNormal; //We're done with the unknown amount of stuff, lets make a normal progress bar
    Progressbar1.Max:=GameFiles.Count; //set our upper limit
    ProgressBar1.Update;
    GamesGrid.BeginUpdate;
    GamesTree.BeginUpdate;

    for loop:=0 to GameFiles.Count-1 do
      begin
          ProgressBar1.Position:=loop;
          ProgressBar1.Update;

          //de-dupe: If the game file and path doesn't exist, then process it, otherwise ignore.
          n:=GamesGrid.Cols[7].IndexOf(GameFiles.strings[loop]); //Search the filepath column for a match
          if n=-1 then
          begin
            tmppath := ExtractFilePath(GameFiles.strings[loop])+'file_id.diz';
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
                      if n>0 then
                        begin
                          diztmp[0]:=Trim(Copy(dizcontents,1,n-1));
                          diztmp[1]:=TrimLeft(Copy(dizcontents,n+1,Length(dizcontents)-n));
                          //  writeln(n, diztmp[0],diztmp[1]);
                          case diztmp[0] of
                               //Just useful stuff
                               'TITLE': grdata[0]:=UTF8String(Capit(diztmp[1]));
                               'TYPE': grdata[1]:=diztmp[1];
                               'COMPANY': grdata[2]:=UTF8String(Capit(diztmp[1]));
                               'YEAR': grdata[3]:=diztmp[1];
                               'LANGUAGE': grdata[4]:=diztmp[1];
                               'RUN COMMAND': grdata[5]:=diztmp[1];
                               'COMMENTS': grdata[6]:=diztmp[1];

                          end;
                        end;
                end;
                closefile(dizfile);
              end;
            //if no file_id.diz then just add the filename as the title.
            if grdata[0]='' then
              grdata[0]:=ExtractFileName(GameFiles.strings[loop]);

            //Hidden column is the path+filename
            grdata[7]:=GameFiles.strings[loop];

            //Push to the screen
            GamesGrid.InsertRowWithValues(1,grdata);

            //ShowMessage(Format('Import started - totalgames=%d', [totalgames]));
            games[totalgames].filename:=GameFiles.strings[loop];
            games[totalgames].title:=Capit(grdata[0]);
            games[totalgames].genre:=grdata[1];
            games[totalgames].company:=Capit(grdata[2]);
            games[totalgames].year:=grdata[3];
            games[totalgames].language:=grdata[4];
            games[totalgames].runcmd:=grdata[5];
            games[totalgames].comments:=grdata[6];

            //with GamesListWindow.Items.Add do begin
            //   Caption:=games[totalgames].title;
            //   SubItems.Add(games[totalgames].genre);
            //   SubItems.Add(games[totalgames].company);
            //   SubItems.Add(games[totalgames].year);
            //   SubItems.Add(games[totalgames].language);
            //   SubItems.Add(games[totalgames].runcmd);
            //   SubItems.Add(games[totalgames].comments);
            //   SubItems.Add(games[totalgames].filename);
            // end;

            //StatusBar1.SimpleText:=GameFiles.strings[loop];
            node:=GamesTree.TopItem;
            GamesTree.Items.AddChild(node,ExtractFileName(GameFiles.strings[loop]));

            //found:=False;
            //
            ////TODO: need to have a better way to track genres so we don't add 3000 copies of Arcade
            //for n:=0 to 100 do
            //    if genres[n]=games[totalgames].genre then found:=True;
            //if not found then
            //  begin
            //    node:=GamesTree.Items.FindNodeWithText('Genre');
            //    GamesTree.Items.AddChild(node,games[totalgames].genre);
            //    genres
            //  end;


            totalgames:=totalgames+1;


            //StatusBar1.Panels.Items[0].text:=Format('Import started - totalgames=%d', [totalgames]);
            //StatusBar1.Panels.Items[1].text :='asdsadsadada';
          end;
          end
    finally
      GamesGrid.SortColRow(true,0);
      GamesTree.AlphaSort;
      GameFiles.Free;
      //GamesGrid.Show;
      ProgressBar1.Visible:=False;
      GamesGrid.EndUpdate;
      GamesTree.EndUpdate;

      ProgressBar1.Visible:=False;

    end;
  end;
end.
