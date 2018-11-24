unit Structures;

interface
type

  TUseSense = (P, M, C, T);
  // M is const and modifing variable.
  // P is inputed variable, that doesnt take part in programm.
  // C is control variable.
  // T is parasite variable.

  TIOProcType = (TNone, TInput, TOutput);

  TList = class
    public
 //     procedure push_back(const str: String);

  end;



  TPVariablesList = ^TVariablesList;
  TVariablesList = record
    content   : String;
    refCount  : Integer;
    Assign    : Boolean;
    Control   : Boolean;
    Inputed   : Boolean;
    Outputed  : Boolean;
    next      : TPVariablesList;
  end;

  TPVariablesStack = ^TVariablesStack;
  TVariablesStack = record
    _var   : TPVariablesList;
    prev   : TPVariablesStack;
  end;

  TPSegmentStack = ^TSegmentStack;
  TSegmentStack = record
    id       : String;
    ElemCount: Integer;
    VarList  : TPVariablesList;
    prev     : TPSegmentStack;
  end;

  TPTypesList = ^TTypesList;
  TTypesList = record
    content: String;
    next   : TPTypesList;
  end;

  TPReservedIds = ^TReservedIds;
  TReservedIds = record
    content: String;
    next   : TPReservedIds;
  end;

  TPIOProcList = ^TIOProcList;
  TIOProcList = record
    id   : String;
    _type: TIOProcType;
    next : TPIOProcList;
  end;

function  InitStandartTypes(const fname: String; var TypesList: TPTypesList): Boolean;
procedure List_Add(var ListHead: TPVariablesList; const id: String);  overload;
procedure List_Add(var ListHead: TPTypesList;const id: String); overload;
procedure List_Add(var ListHead: TPIOProcList;const id: String;const iotype: TIOProcType); overload;
procedure List_Add(var ListHead: TPReservedIds;const id: String); overload;
procedure List_pop_back(var ListHead: TPVariablesList); overload;
function  List_Find(const ListHead: TPVariablesList;
  const id: String): TPVariablesList; overload;
procedure List_Add(var ListHead: TPVariablesList; const _var: TPVariablesList); overload;
function List_Find(const ListHead: TPIOProcList; const id: String): TPIOProcList; overload;
function List_Find(const ListHead: TPReservedIds; const id: String): TPReservedIds; overload;
function  List_Find(const ListHead: TPTypesList;
  const id: String): TPTypesList; overload;
procedure IncRefCount(const _var: TPVariablesList); inline;
procedure ChangeVarInfo(const _var: TPVariablesList; const VarType: TUseSense);
procedure List_Init(var list: TPVariablesList);overload; inline;
procedure List_Init(var list: TPTypesList);overload; inline;
procedure Stack_Init(var stack: TPSegmentStack); overload;
procedure Stack_Init(var stack: TPVariablesStack); overload;
procedure push(var stack: TPSegmentStack;const id: String); overload;
procedure push(var stack: TPVariablesStack; const id: String); overload;
procedure pop(var stack: TPVariablesStack); overload;
procedure pop(var stack: TPSegmentStack); overload;
function Stack_Top(const stack: TPSegmentStack): TPVariablesList; overload;
procedure Stack_PopCount(var stack: TPVariablesStack; const Count: Integer) overload;
procedure InitIOProc(const fname: String; var list: TPIOProcList);
function Stack_Find(stack: TPVariablesStack; const id: String): TPVariablesStack; overload;
procedure InitReservedIds(const fname: String; var list: TPReservedIds);
//function Test_Types(listhead: TPTypesList; const DesItem: String): TPTypesList;

implementation

function InitStandartTypes(const fname: String; var TypesList: TPTypesList): Boolean; // Load from file all standart types
var
  f: TextFile;
  str: String;
  temp: TPTypesList;
begin
  AssignFile(f, fname);
  Reset(f);
  TypesList := nil;
  while not(EoF(f)) do
  begin
    Readln(f, str);
    List_Add(TypesList, str);
  end;
  Result := True;
  CloseFile(f);
end;


procedure List_Add(var ListHead: TPVariablesList; const _var: TPVariablesList);
var
  temp: TPVariablesList;
begin
  if ListHead = nil then
  begin
//    new(ListHead);
    ListHead := _var;
    ListHead.next := nil;
  end
  else
  begin
    temp := ListHead;
    while temp.next <> nil do
      temp := temp.next;
//    new(temp.next);
    temp.next := _var;
    temp.next.next := nil;
  end;
end;

procedure List_Add(var ListHead: TPVariablesList; const id: String);  // for Variables
var
  temp: TPVariablesList;
begin
  if ListHead = nil then
  begin
    new(ListHead);
    ListHead.content := id;
    ListHead.refCount := 0;
    ListHead.Assign := False;
    ListHead.Control := False;
    ListHead.Inputed := False;
    ListHead.Outputed := False;
    ListHead.next := nil;
  end
  else
  begin
    temp := ListHead;
    while temp.next <> nil do
      temp := temp.next;
    new(temp.next);
    temp.next.content := id;
    temp.next.refCount := 0;
    temp.next.Assign := False;
    temp.next.Control := False;
    temp.next.Inputed := False;
    temp.next.Outputed := False;
    temp.next.next := nil;
  end;
end;

procedure List_Add(var ListHead: TPTypesList;const id: String); // for Types
var
  temp: TPTypesList;
begin
  if ListHead = nil then
  begin
    new(ListHead);
    ListHead.content := id;
    ListHead.next := nil;
  end
  else
  begin
    temp := ListHead;
    while temp.next <> nil do
    temp := temp.next;
    new(temp.next);
    temp.next.content := id;
    temp.next.next := nil;
  end;
end;

procedure List_Add(var ListHead: TPIOProcList; const id: String; const iotype: TIOProcType);
var
  temp: TPIOProcList;
begin
  if ListHead = nil then
  begin
    new(ListHead);
    ListHead.id := id;
    ListHead._type := iotype;
    ListHead.next := nil;
  end
  else
  begin
    temp := ListHead;
    while temp.next <> nil do
    temp := temp.next;
    new(temp.next);
    temp.next.id := id;
    temp.next._type := iotype;
    temp.next.next := nil;
  end;
end;

procedure List_Add(var ListHead: TPReservedIds;const id: String);
var
  temp: TPReservedIds;
begin
  if ListHead = nil then
  begin
    new(ListHead);
    ListHead.content := id;
    ListHead.next := nil;
  end
  else
  begin
    temp := ListHead;
    while temp.next <> nil do
      temp := temp.next;
    new(temp.next);
    temp.next.content := id;
    temp.next.next := nil;
  end;
end;

function List_Find(const ListHead: TPVariablesList; const id: String): TPVariablesList;
var
  temp: TPVariablesList;
begin
  temp := ListHead;
  while (temp <> nil) and (temp.content <> id)do
    temp := temp.next;
  Result := temp;
end;

function List_Find(const ListHead: TPIOProcList; const id: String): TPIOProcList;
var
  temp: TPIOProcList;
begin
  temp := ListHead;
  while (temp <> nil) and (temp.id <> id) do
    temp := temp.next;
  Result := temp;
end;


function List_Find(const ListHead: TPTypesList; const id: String): TPTypesList;
var
  temp: TPTypesList;
begin
  temp := ListHead;
  while (temp <> nil) and (temp.content <> id) do
    temp := temp.next;
  Result := temp;
end;

function List_Find(const ListHead: TPReservedIds; const id: String): TPReservedIds;
var
  temp: TPReservedIds;
begin
  temp := ListHead;
  while (temp <> nil) and (temp.content <> id) do
    temp := temp.next;
  Result := temp;
end;

procedure IncRefCount(const _var: TPVariablesList);
begin
  inc(_var.refCount);
end;

procedure ChangeVarInfo(const _var: TPVariablesList; const VarType: TUseSense);
begin
  IncRefCount(_var);
end;

procedure List_Init(var list: TPTypesList);
begin
  new(list);
  list := nil;
end;

procedure List_Init(var list: TPVariablesList);
begin
  new(list);
  list := nil;
end;

procedure push(var stack: TPSegmentStack;const id: String);
var
  temp: TPSegmentStack;
begin
  temp := stack;
  new(stack);
  stack.VarList := nil;
  stack.ElemCount := 0;
  stack.prev := temp;
end;

procedure pop(var stack: TPSegmentStack);
var
  temp: TPSegmentStack;
begin
  temp := stack;
  stack := stack.prev;
  Dispose(temp);
end;

procedure Stack_Init(var stack: TPSegmentStack);
begin
  new(stack);
  stack.id := '';
  stack.VarList := nil;
  stack.ElemCount := -1;
  stack.prev := nil;
end;

function Stack_Top(const stack: TPSegmentStack): TPVariablesList;
begin
  if stack <> nil then
    Result := stack.VarList;
end;

procedure InitIOProc( const fname: String; var list: TPIOProcList);
var
  f: TextFile;
  str: String;
  ch: Char;
begin
  AssignFile(f, fname);
  Reset(f);
  list := nil;
  while not(EoF(f)) do
  begin
    Readln(f, str);
    ch := str[length(str)];
    Delete(str,length(str),1);
    if ch = 'i' then
    begin
      List_Add(list, str, TInput);
    end
    else
      List_Add(list, str, TOutput);
  end;
  CloseFile(f);
end;

procedure List_pop_back(var ListHead: TPVariablesList);
var
  temp, last: TPVariablesList;
begin
  temp := ListHead;
  last := nil;
  while temp.next <> nil do
  begin
    last := temp;
    temp := temp.next;
  end;
  if ListHead = temp then
    ListHead := nil
  else
  begin
    last.next := nil;
  end;
end;

procedure Stack_Init(var stack: TPVariablesStack);
begin
  new(stack);
  new(stack._var);
  stack._var.content  := '0';
  stack._var.refCount := -1;
  stack._var.Assign   := False;
  stack._var.Control  := False;
  stack._var.Inputed  := False;
  stack._var.Outputed := False;
  stack.prev := nil;
end;

procedure push(var stack: TPVariablesStack; const id: String);
var
  temp: TPVariablesStack;
begin
  temp := stack;
  new(stack);
  new(stack._var);
  stack._var.content := id;
  stack._var.refCount := 0;
  stack._var.Assign := False;
  stack._var.Control := False;
  stack._var.Inputed := False;
  stack._var.Outputed := False;
  stack.prev := temp;
end;

procedure pop(var stack: TPVariablesStack);
var
  temp: TPVariablesStack;
begin
  temp := stack;
  stack := stack.prev;
  Dispose(temp);
end;

function Stack_Find(stack: TPVariablesStack; const id: String): TPVariablesStack;
begin
  while (stack <> nil) and (stack._var.content <> id) do
    stack := stack.prev;
  Result := stack;
end;

procedure Stack_PopCount(var stack: TPVariablesStack; const Count: Integer);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    pop(stack);
end;

procedure InitReservedIds(const fname: String; var list: TPReservedIds);
var
  f: TextFile;
  temp: String;
begin
  AssignFile(f, fname);
  Reset(f);
  while not(EoF(f)) do
  begin
    Readln(f, temp);
    List_Add(list, temp);
  end;
  CloseFile(f);
end;


end.
