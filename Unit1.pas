unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, System.ZLib, Winapi.ShellAPI;


const
  cSourceFile = ''; // Sample: 'C:\Temp\SourceFile.txt';
  cOutputFile = ''; // Sample: 'C:\Temp\DestFile.txt.gz';

type
  TForm1 = class(TForm)
    Button3: TButton;
    Button4: TButton;
    Button1: TButton;
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function GZPack(const source, dest: string): boolean;
var
  sh: file;
  dh: gzFile;
  bf: array[0..4095] of Byte;  // 4 KB buffer
  len: uInt;
begin
  Result := False;
  len := 0;

  // Open the source file for reading
{$I-}
  AssignFile(sh, source);
  Reset(sh, 1);
{$I+}
  try
    // Open the output gzip file for writing
    dh := gzopen(PAnsiChar(AnsiString(dest)), 'wb');  // Use 'wb' for binary write mode
    if dh = nil then
    begin
      CloseFile(sh);
      Exit(False);
    end;

    try
      // Read from the source file in chunks and write compressed data
      repeat
        {$I-}
        BlockRead(sh, bf, SizeOf(bf), len);
        {$I+}
        if IOResult <> 0 then
        begin
          CloseFile(sh);
          gzclose(dh);
          Exit(False);
        end;

        // Write the buffer to the gzip file
        if len > 0 then
        begin
          if gzwrite(dh, bf, len) <> len then
          begin
            CloseFile(sh);
            gzclose(dh);
            Exit(False);
          end;
        end;
      until len = 0;

      // Flush and finalize the gzip file
      if gzflush(dh, Z_FINISH) <> Z_OK then
      begin
        CloseFile(sh);
        gzclose(dh);
        Exit(False);
      end;
    finally
      // Close the gzip file
      if gzclose(dh) = 0 then
        Result := True;
    end;
  finally
    CloseFile(sh);
  end;
end;

procedure CompressToGzip(const InputFile, OutputFile: string);
var
  Command: string;
begin
  // Command to run the 7-Zip command line tool for gzip compression
  Command := Format('.\tools\7z.exe a -tgzip "%s" "%s"', [OutputFile, InputFile]);

  // Execute the command
  ShellExecute(0, 'open', 'cmd.exe', PChar('/C ' + Command), nil, SW_HIDE);
end;

procedure CompressToGzipA(const InputFile, OutputFile: string);
var
  Command: string;
begin
  // Command for 7za.exe to compress to GZIP format
  Command := Format('.\tools\7za.exe a -tgzip "%s" "%s"', [OutputFile, InputFile]);

  // Run the command in a hidden window
  ShellExecute(0, 'open', 'cmd.exe', PChar('/C ' + Command), nil, SW_HIDE);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CompressToGzipA(cSourceFile, cOutputFile);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  CompressToGzip(cSourceFile, cOutputFile);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  GZPack(cSourceFile, cOutputFile);
end;

end.
