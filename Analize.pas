unit Analize;

interface
uses
  Structures;
type
  TIndex = Integer;
  TCharFile = TextFile;
  TLexeme = (lexNone, lexType, lexControl, lexOProc,lexOperator, lexIProc);

procedure AnalizeCode(const AnalFile, TypesFile, IOProcFile, ReservedIds: String);
procedure Skip_WhiteSpaces(var f: TCharFile);
procedure Handle_String(var f: TCharFile);
procedure Handle_Char(var f: TextFile);
procedure Handle_Sharp(var f: TextFile);
procedure FGetVariablesInfo(const fname: String; VariableList: TPVariablesList);

const
  A1 = 1;
  A2 = 2;
  A3 = 3;
  A4 = 0.5;
  NULLSTR = '';
  TESTFILENAME = 'test.txt';

var
  AvailableSymb: set of Char = ['A'..'Z','a'..'z','0'..'9'];
  Separators   : set of Char = [';',':','.',','];
  Operations   : set of Char = ['+','-','/','*','&','|','%','='];
  Alphabet     : pWideChar = '_''#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

implementation
uses
  ResultGrid, SysUtils;

procedure AnalizeCode(const AnalFile, TypesFile, IOProcFile, ReservedIds: String);
var
  TypesList: TPTypesList;
  IOProcList: TPIOProcList;
  ReservedIdsList: TPReservedIds;
  VariableList: TPVariablesList;
  VariableStack: TPVariablesStack;
  SegStack: TPSegmentStack;
  ch, LastChar: Char;
  TypeOfLineVar: TUseSense;
  str: String;
  f: TCharFile;
  LastLexeme: TLexeme;
  LastId: String;
  VarTemp: TPVariablesStack;
  TypeTemp: TPTypesList;
  ProcTemp: TPIOProcList;
  _Array: Boolean;
  OpenBracets: Byte;
  LineIndex: TIndex;
  LastIOProc: TIOProcType;
  Controlled, Funced: Boolean;
begin
  AssignFile(f, AnalFile);
  Reset(f);
  LastChar := #0;
  LineIndex := 1;
  LastLexeme := lexNone;
  Controlled := False;
  Funced := False;
  InitStandartTypes(TypesFile, TypesList);
  InitIOProc(IOProcFile, IOProcList);
  InitReservedIds(ReservedIds, ReservedIdsList);
  Stack_Init(VariableStack);
  Stack_Init(SegStack);
  push(SegStack, NULLSTR);
  VariableList := nil;
  while not(EoF(f)) do
  begin
    str := '';
    ch := LastChar;
    if LastChar = ''  then
    begin
      Read(f,ch);
      LastChar := #0;
    end;
    if not(ch in ['0'..'9']) then  // check if its not identifier. Ex: 2Iden <- error
    begin
      while ch in AvailableSymb do
      begin
        str := str + ch;
        read(f, ch);
        LastId := str;
      end;
    end;
    if str <> '' then
    begin
      TypeTemp := List_Find(TypesList, str);
      ProcTemp := List_Find(IOProcList, str);
      if (str = 'while') or (str = 'for') or (str = 'do') or (str = 'if') or (str = 'switch') then
      begin
        Controlled := True;
        LastLexeme := lexControl;
      end
      else if (TypeTemp = nil) and (ProcTemp = nil) and (List_Find(ReservedIdsList, str) = nil) then // не тип и не процедура ввода/вывода и не зарезервированное слово
      begin
        VarTemp := Stack_Find(VariableStack, str);
        if LastLexeme = lexType then
        begin
          push(VariableStack, str);
          List_Add(VariableList, VariableStack._var);  // добавить в общий список переменных данную переменную
          List_Add(SegStack.VarList, VariableStack._var); // добавить в стек переменную
          inc(SegStack.ElemCount);
        end
        else if VarTemp <> nil then
        begin
          if LastLexeme = lexOProc then
          begin
            VarTemp._var.Outputed := True;
          end
          else if LastLexeme = lexIProc then
          begin
            VarTemp._var.Inputed := True;
          end
          else if LastLexeme = lexControl then
          begin
            VarTemp._var.Control := True;
          end;
          IncRefCount(VarTemp._var);
        end;
        LastChar := ch;
      end
      else
      begin
        if TypeTemp <> nil then
        begin
          LastLexeme := lexType;
        end
        else if ProcTemp <> nil then
        begin
          if ProcTemp._type = TInput then
            LastLexeme := lexIProc
          else
            LastLexeme := lexOProc;
        end
        else
          LastLexeme := lexNone;
      end;
    end
    else  // управлющие символы
    begin
      if ch = ')' then
      begin
        Controlled := False;
        LastLexeme := lexNone;
        LastChar := #0;
      end
      else if ch = '(' then
      begin
        if LastLexeme = lexType then  // if it was declaration of function
        begin
          pop(VariableStack);
          List_pop_back(VariableList);
          List_pop_back(SegStack.VarList);
          dec(SegStack.ElemCount);
          Funced := True;
          push(SegStack, NULLSTR);
        end;
        LastChar := #0;
      end
      else if ch = '''' then
      begin
        Handle_Char(f);
        LastChar := #0;
      end
      else if ch = '{' then
      begin
        if not(Funced) then
          push(SegStack, NULLSTR);
        LastChar := #0;
        Funced := False;
      end
      else if ch = '}' then
      begin
        pop(SegStack);
        Stack_PopCount(VariableStack, SegStack.ElemCount); // pop all segment variables
        LastChar := #0;
      end
      else if ch = ';' then
      begin
        LastLexeme := lexNone;
        LastChar := #0;
      end
      else if ch = '=' then
      begin
        read(f,ch);
        if ch <> '=' then
        begin
          VarTemp := Stack_Find(VariableStack, LastId);
          VarTemp._var.Assign := True;
          LastLexeme := lexNone;
          LastChar := ch;
        end
        else
          LastChar := #0;
      end
      else if (ch = '+') or (ch = '-') then // handle ++ and --
      begin
        read(f,ch);
        if ch <> '=' then
        begin
          VarTemp := Stack_Find(VariableStack, LastId);
          VarTemp._var.Assign := True;
          LastLexeme := lexNone;
          LastChar := ch;
        end
        else
          LastChar := #0;
      end
      else if (ch = '~') then
      begin
        // shiiiit...
      end
      else if ch = '"' then
      begin
        Handle_String(f);
        LastChar := #0;
      end
      else if ch = #10 then
      begin
        inc(LineIndex);
        LastChar := #0;
      end
      else
        LastChar := #0;

    end;
  end;
  CloseFile(f);
  FGetVariablesInfo(TESTFILENAME, VariableList);
end;

procedure Skip_WhiteSpaces(var f: TCharFile);
var
  ch: Char;
begin
//  ch := ' ';
//  while ch = ' ' do
//    Read(f, ch);
end;

procedure Handle_String(var f: TextFile);
var
  ch: Char;
begin
  ch := #0;
  while ch <> '"' do
    Read(f,ch);
end;

procedure Handle_Char(var f: TextFile);
var
  ch: Char;
begin
  read(f,ch);
  read(f,ch);
end;

procedure Handle_Sharp(var f: TextFile);
var
  ch: Char;
begin

end;


procedure FGetVariablesInfo(const fname: String; VariableList: TPVariablesList);
var
  f: TextFile;
begin
  AssignFile(f,fname);
  ReWrite(f);
  while VariableList <> nil do
  begin
    Writeln(f,VariableList.content,#13#10'refCount: ',VariableList.refCount,#13#10'Assign: ',VariableList.Assign,#13#10'Control: ',VariableList.Control,#13#10'Inputed: ',VariableList.Inputed,#13#10'OutPuted: ',VariableList.Outputed,#13#10);
    VariableList := VariableList.next;
  end;
  CloseFile(f);
end;

end.
