unit HeaderFooterFormwithNavigation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.Forms, FMX.Dialogs, FMX.TabControl, System.Actions, FMX.ActnList,
  FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, XMLIntf, XMLDoc,
  Xml.xmldom, Data.Win.ADODB, Data.DB, StrUtils, Globals, FMX.Layouts,
  FMX.ListBox;

type
  THeaderFooterwithNavigation = class(TForm)
    ActionList1: TActionList;
    PreviousTabAction1: TPreviousTabAction;
    TitleAction: TControlAction;
    NextTabAction1: TNextTabAction;
    TopToolBar: TToolBar;
    btnBack: TSpeedButton;
    ToolBarLabel: TLabel;
    btnNext: TSpeedButton;
    TabControl1: TTabControl;
    TabItemAccount: TTabItem;
    TabItemChat: TTabItem;
    BottomToolBar: TToolBar;
    edtAccLogin: TEdit;
    edtAccPassword: TEdit;
    edtAccRLogin: TEdit;
    edtAccRPassword: TEdit;
    edtAccRPassword2: TEdit;
    edtAccRFirstName: TEdit;
    edtAccRLastName: TEdit;
    edtAccREmail: TEdit;
    btnAccLogin: TButton;
    btnAccRegister: TButton;
    lblAccLogin: TLabel;
    lblAccPassword: TLabel;
    lblAccLoginValidate: TLabel;
    lblAccRegisterValidate: TLabel;
    lblAccRLogin: TLabel;
    lblAccRPassword: TLabel;
    lblAccRPassword2: TLabel;
    lblAccRFirstName: TLabel;
    lblAccRLastName: TLabel;
    lblAccREmail: TLabel;
    lblAccLoginResponseValue: TLabel;
    lblAccLoginResponse: TLabel;
    lblAccRegisterResponse: TLabel;
    lblAccRegisterResponseValue: TLabel;
    lblAccLL: TLabel;
    ADOConnectionRAD: TADOConnection;
    ADOQuery: TADOQuery;
    ADOStoredProc: TADOStoredProc;
    XMLConfig: TXMLDocument;
    ADOStoredProc2: TADOStoredProc;
    imgBlockChat: TImageControl;
    TabItemContact: TTabItem;
    imgBlockHistory: TImageControl;
    lbxChatBox: TListBox;
    edtChatInput: TEdit;
    btnChatSend: TButton;
    Timer1: TTimer;
    lbxContactList: TListBox;
    edtContactLogin: TEdit;
    edtContactSearch: TEdit;
    lblContactLogin: TLabel;
    btnContactSearch: TButton;
    btnContactAdd: TButton;
    lblContactResult: TLabel;
    ADOQueryMsg: TADOQuery;
    ADOQueryUpdate: TADOQuery;
    btnContactGo: TButton;
    ChangeTabAction1: TChangeTabAction;
    Button1: TButton;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure TitleActionUpdate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtAccLoginClick(Sender: TObject);
    procedure edtAccRLoginClick(Sender: TObject);
    procedure btnAccLoginClick(Sender: TObject);
    procedure SetupUser(Login : String);
    procedure btnAccRegisterClick(Sender: TObject);
    procedure btnChatSendClick(Sender: TObject);
    procedure edtContactLoginChange(Sender: TObject);
    procedure btnContactAddClick(Sender: TObject);
    procedure AddContactToList (Login : String);
    procedure LoadContactList (UserID : Integer);
    procedure btnContactGoClick(Sender: TObject);
    procedure btnContactSearchClick(Sender: TObject);
    procedure LoadMsg (Sender, Receiver : Integer);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HeaderFooterwithNavigation: THeaderFooterwithNavigation;

implementation
//
{ Functions }
//
//
{ Validate intput for query }
//
Function ValidateStr(Text : String ) : Boolean;
Begin
  if ( Text <> '' ) AND not ContainsText(Text,';') then
  begin
    Result := true;
  end
  else
  begin
    Result := false;
  end;
End;
//
{ Functions END }
//
//
{ Procedures }
//
{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.iPhone4in.fmx IOS}
//
{ Refresh }
//
procedure THeaderFooterwithNavigation.Timer1Timer(Sender: TObject);
begin
  if ( Globals.userID > 0 ) AND ( Globals.receiverID > 0 ) then
    LoadMsg(Globals.userID,Globals.receiverID);
end;
procedure THeaderFooterwithNavigation.Timer2Timer(Sender: TObject);
begin
  if ( Globals.userID > 0 ) then
    LoadContactList(Globals.userID);
end;

//
{ Navigation big nono }
//
procedure THeaderFooterwithNavigation.TitleActionUpdate(Sender: TObject);
begin
  if Sender is TCustomAction then
  begin
    if TabControl1.ActiveTab <> nil then
      TCustomAction(Sender).Text := TabControl1.ActiveTab.Text
    else
      TCustomAction(Sender).Text := '';
  end;
end;
//
{ Adding contact to list *reps }
//
procedure THeaderFooterwithNavigation.AddContactToList(Login : String);
var
  str : String;
  msgReceivedCounter : Integer;
begin
  if ValidateStr(Login) then
  begin
    msgReceivedCounter := 0;
    str := '';
    str := '[' + Login + '] ';

    ADOQuery.SQL.Clear;
    ADOQuery.SQL.Add('SELECT * FROM Users WHERE Login = ''' + Login + ''' ');
    ADOQuery.Open;

    if ( ADOQuery.FieldByName('LogoutDate').Value > 0 ) then
    begin
      str := str + 'Last seen ' + DateToStr(ADOQuery.FieldByName('LogoutDate').Value);
    end
    else
    begin
      str := str + ' Active ';
    end;

    if ( ADOQuery.FieldByName('ID').Value > 0 ) then
    begin
      Globals.receiverID := ADOQuery.FieldByName('ID').Value;
      ADOQueryMsg.SQL.Clear;
      ADOQueryMsg.SQL.Add('SELECT * FROM Msg WHERE FK_Receiver =' + Globals.userID.ToString + ' AND FK_Sender = ' + Globals.receiverID.ToString + ' AND FK_Status IN ( 1 , 2 ) ');
      ADOQueryMsg.Open;

      while not ADOQueryMsg.Eof do
      begin
        msgReceivedCounter := msgReceivedCounter + 1;

        ADOQueryUpdate.SQL.Clear;
        ADOQueryUpdate.SQL.Add('UPDATE Msg SET StatusDate = GETDATE() , FK_Status = 2 WHERE ID = ');
        ADOQueryUpdate.SQL.Add(ADOQueryMsg.FindField('ID').Value);
        ADOQueryUpdate.ExecSQL;
        ADOQueryMsg.Next;
      end;

      str := str + ' #' + msgReceivedCounter.ToString;
    end;

    lbxContactList.Items.Add(str);
  end;
end;
//
{ Login button }
//
procedure THeaderFooterwithNavigation.btnAccLoginClick(Sender: TObject);
var
  validate
  , validateLogin
  , validatePassword
  , validateResponse : boolean;
begin
  { Validation }
  validate := false;
  validateResponse := false;
  validateLogin := ValidateStr(edtAccLogin.Text);
  validatePassword := ValidateStr(edtAccPassword.Text);

  lblAccLoginValidate.Text := 'Validation : ';

  if validateLogin AND validatePassword then
    validate := true;

  if not validateLogin then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' login ' ;
    edtAccLogin.SetFocus;
  end;
  if not validatePassword then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' password ' ;
    edtAccPassword.SetFocus;
  end;

  { Validation - END }
  if validate then
  begin

    { Search for account }

    With ADOStoredProc do
    begin
      ProcedureName := 'Login' ;

      try
        Parameters.Refresh;
        Parameters.ParamByName('@pLogin').Value := edtAccLogin.Text;
        Parameters.ParamByName('@pPassword').Value := edtAccPassword.Text;
        Parameters.ParamByName('@response').Value := Null;
        ExecProc;
      finally
        lblAccLoginResponseValue.Text := 'Response : ' + Parameters.ParamByName('@response').Value ;

        if ( Parameters.ParamByName('@response').Value = 'Success' ) then
          validateResponse := true;
      end;

    end;

  end;
  { Login process }
  if validateResponse then
    SetupUser(edtAccLogin.Text);

end;
//
{ Register button click }
//
procedure THeaderFooterwithNavigation.btnAccRegisterClick(Sender: TObject);
var
  validate,
  validateLogin,
  validatePassword,
  validatePassword2,
  validateFirstName,
  validateLastName,
  validateEmail,
  validateResponse : Boolean;
begin

  { Validation }
  validate := false;
  validateResponse := false;

  validateLogin := ValidateStr(edtAccRLogin.Text);
  validatePassword := ValidateStr(edtAccRPassword.Text);
  validateFirstName := ValidateStr(edtAccRFirstName.Text);
  validateLastName := ValidateStr(edtAccRLastName.Text);
  validateEmail := ValidateStr(edtAccREmail.Text);

  if ( edtAccRPassword2.Text = edtAccRPassword.Text ) then
    validatePassword2 := true;

  if validateLogin AND validatePassword AND validatePassword2 AND validateFirstName AND validateLastName AND validateEmail then
    validate := true;

  lblAccRegisterValidate.Text := 'Validation : ';

  if not validateLogin then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' login ' ;
    edtAccLogin.SetFocus;
  end;
  if not validatePassword then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' password ' ;
    edtAccLogin.SetFocus;
  end;
  if not validatePassword2 then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' password2 ' ;
    edtAccLogin.SetFocus;
  end;
  if not validateFirstName then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' first name ' ;
    edtAccLogin.SetFocus;
  end;
  if not validateLastName then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' last name ' ;
    edtAccLogin.SetFocus;
  end;
  if not validateEmail then
  begin
    lblAccLoginValidate.Text := lblAccLoginValidate.Text + ' email ' ;
    edtAccLogin.SetFocus;
  end;

  { Validation END }

  if validate then
  begin
  { Register account }

    With ADOStoredProc2 do
    begin
      ProcedureName := 'AddUser' ;

      try
        Parameters.Refresh;
        Parameters.ParamByName('@pLogin').Value := edtAccRLogin.Text;
        Parameters.ParamByName('@pPassword').Value := edtAccRPassword.Text;
        Parameters.ParamByName('@pFirstName').Value := edtAccRFirstName.Text;
        Parameters.ParamByName('@pLastName').Value := edtAccRLastName.Text;
        Parameters.ParamByName('@pEmail').Value := edtAccREmail.Text;
        Parameters.ParamByName('@response').Value := Null;
        ExecProc;
      finally
        lblAccRegisterResponseValue.Text := 'Response : ' + Parameters.ParamByName('@response').Value ;

        if ( Parameters.ParamByName('@response').Value = 'Success' ) then
          validateResponse := true;
      end;

    end;


  end;

  { Login process }
  if validateResponse then
  begin

    ADOQuery.SQL.Clear;
    ADOQuery.SQL.Add('SELECT * FROM Users WHERE Login = ' + edtAccRLogin.Text );
    ADOQuery.Open;

    ADOQueryUpdate.SQL.Clear;
    ADOQueryUpdate.SQL.Add('INSERT INTO UserContacts (FK_User, FK_Contact) VALUES ( ' + ADOQuery.FieldByName('ID').Text + ' , 1 )' );
    ADOQueryUpdate.ExecSQL;

    SetupUser(edtAccRLogin.Text);
  end;

end;
procedure THeaderFooterwithNavigation.btnBackClick(Sender: TObject);
begin

end;

//
{ Send message button}
//
procedure THeaderFooterwithNavigation.btnChatSendClick(Sender: TObject);
begin
  if ValidateStr(edtChatInput.Text) then
  begin
    ADOQuery.SQL.Clear;
    ADOQuery.SQL.Add('INSERT INTO Msg (Text, FK_Status, FK_Sender, FK_Receiver) VALUES ( ''' + edtChatInput.Text + ''' , 1 , ' + Globals.userID.ToString + ' , ' + Globals.receiverID.ToString + ' ) ');
    if ( ADOQuery.ExecSQL = 1 ) then
      LoadMsg(Globals.userID,Globals.receiverID);
  end;
end;
//
{ Adding contact }
//
procedure THeaderFooterwithNavigation.btnContactAddClick(Sender: TObject);
var
  validate,
  validateLogin,
  validateUserLookup,
  validateInsert,
  validateUnique : Boolean;

  contactID, I : Integer;
begin

  { Validation }
  validate := false;
  validateUserLookup := false;
  validateUnique := false;
  validateLogin := ValidateStr( edtContactLogin.Text );

  if not validateLogin then
    lblContactResult.Text := 'Wrong login format';

  if validateLogin AND ( Globals.userID > 0 ) then
    validate := true;

  { Validation END}

  if validate then
  begin

    ADOQuery.SQL.Clear;
    ADOQuery.SQL.Add('SELECT * FROM Users WHERE Login = ''' + edtContactLogin.Text + ''' ');
    ADOQuery.Open;

    if ( ADOQuery.FieldByName('ID').Value > 0 ) then
    begin
      validateUserLookup := true;
      contactID := ADOQuery.FieldByName('ID').Value;
    end
    else
    begin
      lblContactResult.Text := 'User does not exists';
    end;

    for I := 0 to lbxContactList.Count - 1 do
      if not ContainsText(lbxContactList.ListItems[I].Text, edtContactLogin.Text) then
        validateUnique := true;

    if validateUnique then
    begin
      if validateUserLookup then
      begin
        ADOQuery.SQL.Clear;
        ADOQuery.SQL.Add('INSERT INTO UserContacts (FK_User, FK_Contact) VALUES ( ' + Globals.userID.ToString + ' , ' + contactID.ToString + ' )' );
        if ( ADOQuery.ExecSQL = 1 ) then
          validateInsert := true;
      end;
    end;
  end;

  if validateInsert then
  begin
    AddContactToList(edtContactLogin.Text);
    edtContactLogin.Text := '';
  end;


end;
//
{ Start chat with selected }
//
procedure THeaderFooterwithNavigation.btnContactGoClick(Sender: TObject);
var
  receiverLogin : String;
  position : Integer;
begin
  if lbxContactList.Selected.IsSelected then
  begin
    position := ansipos(']',lbxContactList.Selected.Text);

    receiverLogin := Copy(lbxContactList.Selected.Text, 2, ( position - 2 ));

    Globals.receiverLogin := receiverLogin;

    LoadMsg(Globals.userID,Globals.receiverID);

    ChangeTabAction1.Tab := TabItemChat;
    ChangeTabAction1.ExecuteTarget(Self);
  end;
end;
//
{ Search for specific login in contact list }
//
procedure THeaderFooterwithNavigation.btnContactSearchClick(Sender: TObject);
var
  I : Integer;
begin
  if ValidateStr(edtContactSearch.Text) then
  begin
    for I := 0 to lbxContactList.Count - 1 do
    begin
      if ContainsText(lbxContactList.ListItems[I].Text, edtContactSearch.Text) then
        lbxContactList.ListItems[I].IsSelected := true;
    end;
  end;
end;

procedure THeaderFooterwithNavigation.Button1Click(Sender: TObject);
var
  user : IXMLNode;
begin

  ADOQuery.SQL.Clear;
  ADOQuery.SQL.Add('UPDATE Users SET LogoutDate = GETDATE() WHERE ID = ' + Globals.userID.ToString);
  ADOQuery.ExecSQL;

  Globals.userID := 0;
  Globals.receiverID := 0;

  try
    user := XMLConfig.DocumentElement;

    lblAccLL.Text := 'Last logged : ' + user.ChildNodes['name'].Text + ' day : ' + user.ChildNodes['date'].Text ;
  finally

  end;

  btnAccLogin.Enabled := true;
  btnAccRegister.Enabled := true;
  lblAccLoginResponseValue.Text := 'Response : ';
  lblAccRegisterResponseValue.Text := 'Response : ';
  edtAccLogin.Text := '';
  edtAccPassword.Text := '';
  lbxChatBox.Items.Clear;
  lbxContactList.Items.Clear;

  ChangeTabAction1.Tab := TabItemAccount;
  ChangeTabAction1.ExecuteTarget(Self);

end;

//
{ Login edit enter }
//
procedure THeaderFooterwithNavigation.edtAccLoginClick(Sender: TObject);
begin
  edtAccPassword.Enabled := true;
  edtAccRPassword.Enabled := false;
  edtAccRPassword2.Enabled := false;
  edtAccRFirstName.Enabled := false;
  edtAccRLastName.Enabled := false;
  edtAccREmail.Enabled := false;
end;
//
{ Register edit enter }
//
procedure THeaderFooterwithNavigation.edtAccRLoginClick(Sender: TObject);
begin
  edtAccPassword.Enabled := false;
  edtAccRPassword.Enabled := true;
  edtAccRPassword2.Enabled := true;
  edtAccRFirstName.Enabled := true;
  edtAccRLastName.Enabled := true;
  edtAccREmail.Enabled := true;
end;


procedure THeaderFooterwithNavigation.edtContactLoginChange(Sender: TObject);
begin

end;

//
{ Form creation / Load xml config }
//
procedure THeaderFooterwithNavigation.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ADOQuery.SQL.Clear;
  ADOQuery.SQL.Add('UPDATE Users SET LogoutDate = GETDATE(), LoginDate = NULL WHERE Users.ID = '+ Globals.userID.ToString);
  ADOQuery.ExecSQL;
end;

procedure THeaderFooterwithNavigation.FormCreate(Sender: TObject);
var
  user : IXMLNode;
begin
  { This defines the default active tab at runtime }
  TabControl1.First(TTabTransition.None);

  try
    user := XMLConfig.DocumentElement;

    lblAccLL.Text := lblAccLL.Text + ' ' + user.ChildNodes['name'].Text + ' day : ' + user.ChildNodes['date'].Text ;
  finally

  end;

end;

procedure THeaderFooterwithNavigation.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) and (TabControl1.TabIndex <> 0) then
  begin
    TabControl1.First;
    Key := 0;
  end;
end;
//
{ Load contact list }
//
procedure THeaderFooterwithNavigation.LoadContactList(UserID: Integer);
begin
  ADOQuery.SQL.Clear;
  ADOQuery.SQL.Add('SELECT * FROM UserContacts WHERE FK_User = ' + Globals.userID.ToString);
  ADOQuery.Open;

  lbxContactList.Items.Clear;

  while not ADOQuery.Eof do
  begin
    ADOQueryUpdate.SQL.Clear;
    ADOQueryUpdate.SQL.Add('SELECT * FROM Users WHERE ID = ' + ADOQuery.FindField('FK_Contact').Text );
    ADOQueryUpdate.Open;

    AddContactToList(ADOQueryUpdate.FindField('Login').Value);

    ADOQuery.Next;
  end;

end;
//
{ Load messages }
//
procedure THeaderFooterwithNavigation.LoadMsg(Sender, Receiver: Integer);
var
  I, counter : Integer;
  tmp : Array of string;
begin

  if ( Sender > 0 ) AND ( Receiver > 0 ) AND ( Sender <> Receiver ) then
  begin

    ADOQuery.SQL.Clear;
    ADOQuery.SQL.Add('SELECT TOP 20 Text, Sender.Login as [From], Receiver.Login as [To] FROM Msg ' );
    ADOQuery.SQL.Add('INNER JOIN Users as Sender ON FK_Sender = Sender.ID ');
    ADOQuery.SQL.Add('INNER JOIN Users as Receiver ON FK_Receiver = Receiver.ID ');
    ADOQuery.SQL.Add('WHERE ( FK_Receiver = '+ Receiver.ToString +' AND FK_Sender = '+ Sender.ToString +' ) OR ( FK_Receiver = '+ Sender.ToString +' AND FK_Sender = '+ Receiver.ToString +' ) ORDER BY Msg.ID DESC ');
    ADOQuery.Open;

    lbxChatBox.Items.Clear;

    while not ADOQuery.Eof do
    begin
      lbxChatBox.Items.Add( '[' + ADOQuery.FieldByName('From').Text + '] : ' + ADOQuery.FieldByName('Text').Text );
      ADOQuery.Next;
    end;

    SetLength(tmp,lbxChatBox.Count);
    for I := 0 To lbxChatBox.Count - 1 do
      tmp[I] := lbxChatBox.ListItems[I].Text;

    counter := lbxChatBox.Count - 1;
    lbxChatBox.Items.Clear;

    for I := 0 to counter do
      lbxChatBox.Items.Add(tmp[counter - I]);

    ADOQueryUpdate.SQL.Clear;
    ADOQueryUpdate.SQL.Add('UPDATE Msg SET FK_Status = 3 WHERE FK_Status = 2 AND FK_Receiver = '+ Receiver.ToString + ' AND FK_Sender = '+ Sender.ToString);
    ADOQueryUpdate.ExecSQL;

  end;


end;

//
{ Setting up global variables connected to user account }
//
procedure THeaderFooterwithNavigation.SetupUser(Login: String);
var
  user : IXMLNode;
begin
  ADOQuery.SQL.Clear;
  ADOQuery.SQL.Add('SELECT TOP 1 * FROM Users WHERE Login = ''' + Login + ''' ');
  ADOQuery.Open;


  if ( ADOQuery.FindField('ID').Value > 0 ) then
  begin
    { Setting up global variables }
    Globals.userID := ADOQuery.FindField('ID').Value;
    Globals.userLogin := Login;
    Globals.userFirstName := ADOQuery.FindField('FirstName').Value;
    Globals.userLastName := ADOQuery.FindField('LastName').Value;
    Globals.userEmail := ADOQuery.FindField('Email').Value;
    Globals.loged := true;

    btnAccLogin.Enabled := false;
    btnAccRegister.Enabled := false;
    lblAccLL.Text := 'You are logged as : ' + Login ;

    { Update config xml }
    try
      user := XMLConfig.DocumentElement;

      user.ChildNodes['name'].Text := Login;
      user.ChildNodes['date'].Text := DateToStr(date);

      XMLConfig.SaveToFile('C:\Users\jwoli\Desktop\RAD\RAD\RAD\Config.xml');
    finally

    end;

    imgBlockChat.Visible := false;
    imgBlockHistory.Visible := false;

    ADOQueryUpdate.SQL.Clear;
    ADOQueryUpdate.SQL.Add('UPDATE Users SET LogoutDate = NULL, LoginDate = GETDATE() WHERE ID = ' + Globals.userID.ToString);
    ADOQueryUpdate.ExecSQL;

  end
  else
  begin
    lblAccLL.Text := 'Unknown error occured';
  end;


  ADOQuery.SQL.Clear;
  LoadContactList(Globals.userID);

  ChangeTabAction1.Tab := TabItemContact;
  ChangeTabAction1.ExecuteTarget(Self);

end;
//
{ Procedures END }
//
End.
