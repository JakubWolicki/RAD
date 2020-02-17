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
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TitleActionUpdate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtAccLoginClick(Sender: TObject);
    procedure edtAccRLoginClick(Sender: TObject);
    procedure btnAccLoginClick(Sender: TObject);
    procedure SetupUser(Login : String);
    procedure btnAccRegisterClick(Sender: TObject);
    procedure btnChatSendClick(Sender: TObject);
    procedure edtChatInputKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
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
    SetupUser(edtAccRLogin.Text);

end;
//
{ Send message button}
//
procedure THeaderFooterwithNavigation.btnChatSendClick(Sender: TObject);
begin
  lbxChatBox.Items.Add( edtChatInput.Text );
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

//
{ Send message }
//
procedure THeaderFooterwithNavigation.edtChatInputKeyUp(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
end;

//
{ Form creation / Load xml config }
//
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
  end
  else
  begin
    lblAccLL.Text := 'Unknown error occured';
  end;


  ADOQuery.SQL.Clear;
end;
//
{ Procedures END }
//
End.
