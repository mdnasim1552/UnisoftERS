<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_Login" CodeBehind="SELogin.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--[if lt IE 7 ]> <html class="ie6"> <![endif]-->
<!--[if IE 7 ]>    <html class="ie7"> <![endif]-->
<!--[if IE 8 ]>    <html class="ie8"> <![endif]-->
<!--[if IE 9 ]>    <html class="ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><html class=""><!-->

<!--<![endif]-->
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>HD Clinical - Solus Endoscopy Login</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <script type="text/javascript" src="../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../Scripts/global.js"></script>
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
    <link rel="icon" type="image/png" href="../images/icons/favicon.png" />

    <style type="text/css">

        .buttons {
            padding-top: 10px;
        }
    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">

</script>
    </telerik:RadCodeBlock>
</head>

<body class="loginBody">
    <form id="LoginForm" runat="server" defaultbutton="LoginCmd" defaultfocus="txtUserID">

        <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server">
        </telerik:RadStyleSheetManager>

        <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
            <Scripts>
                <%--<telerik:RadScriptReference Path="../Scripts/jquery-3.6.3.min.js" />--%>
                <telerik:RadScriptReference Path="../Scripts/Global.js" />
            </Scripts>
        </telerik:RadScriptManager>

        <telerik:RadScriptBlock ID="dsa" runat="server">
            <script type="text/javascript">


                function UserIdBlur(sender, eventArgs) {
                    if (sender.get_value() == "unisoft") {
                        //if (sender.get_value() != "") {
                        
                    }
                }

                $(document).ready(function () {
                    if ($('html').is('.ie6, .ie7, .ie8, .ie9')) {
                        alert("You are using an old version of internet explorer. Please upgrade to version IE 10 and above to use this application.");
                        window.location.replace("Security/BrowserUpgrade.aspx");
                    }

                    $('#<%=IPCheckYesButton.ClientID%>').on('click', function () {
                        $('#IPCheckDiv').hide();
                        $('#StaticIPCheckDiv').show();
                    });

                    $('#<%=StaticIPCheckYesButton.ClientID%>').on('click', function () { toggleStaticIPCheckDiv(1); });
                    $('#<%=StaticIPCheckNoButton.ClientID%>').on('click', function () { toggleStaticIPCheckDiv(0); });

                    $('#<%=ImagePortSelectionOk.ClientID%>').on('click', function () {
                        if ($('#NoImagePortsAvailable').is(":visible")) { return true; }

                        var cbImagePort = $find('<%=ImagePortsComboxBox.ClientID %>').get_selectedItem().get_value();
                        if (cbImagePort == '' || cbImagePort == '0') {
                            return false;
                        }
                    });

                    $('#<%=ImagePortSelectionCancel.ClientID%>').on('click', function () {
                        $('#IPCheckDiv').show();
                        $('#StaticIPCheckDiv').hide();
                        $('#ImagePortSelectionDiv').hide();
                    });

                    if (document.getElementById('licenseExpired').value != '') {
                        alert(document.getElementById('licenseExpired').value);
                    }

                    sendTimezoneOffset();
                });

                //function HandlePasswordTextBoxesInIE()
                //{
                //    if (navigator.appVersion.indexOf('Trident/') > 0 || navigator.appVersion.indexOf('Edge/') > 0) {
                //      //  $('input.PasswordText[type=text]').removeProp("type").prop("type", "password");
                //    }
                //}

                function sendTimezoneOffset() {
                    var timezoneOffset = new Date().getTimezoneOffset();
                    $.ajax({
                        type: "POST",
                        url: "SELogin.aspx/SetTimezoneOffset",
                        data: JSON.stringify({ timezoneOffset: timezoneOffset }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {

                        },
                        error: function (xhr, status, error) {
                            console.log("Error: " + error)
                        }
                    });
                }

                function toggleStaticIPCheckDiv(isStatic) {
                    $('#<%=hdStatic.ClientID%>').val(isStatic);

                    $('#StaticIPCheckDiv').hide();
                    $('#ImagePortSelectionDiv').show();
                    //check if image port drop down has items.. show and hide selecting div accordingly
                    if ($find('<%=ImagePortsComboxBox.ClientID%>').get_items().get_count() > 1) {
                        $('#NoImagePortsAvailable').hide();
                        $('#ImagePortsAvailable').show();
                    }
                    else {
                        $('#NoImagePortsAvailable').show();
                        $('#ImagePortsAvailable').hide();
                    }
                }

                function CloseWin() {
                    var window = $find('<%=RadWindow1.ClientID %>');
                    window.close();
                }

                var txtPass = document.getElementById("txtPassWD");
                if (txtPass == undefined || undefined == "") {

                }
                else {
                    var style = window.getComputedStyle(txtPass);
                    if (style != undefined) {
                        console.log(style);
                        if (style.webkitTextSecurity) {
                            //do nothing
                        } else {
                            txtPass.setAttribute("type", "password");
                        }
                    }
                }
                function OperatingHospitalChanged(sender, args) {
                    
                }
            </script>
        </telerik:RadScriptBlock>

      

        <telerik:RadNotification ID="RadNotification2" runat="server" VisibleOnPageLoad="false" Skin="Metro" Position="Center" Width="400" Height="150" BorderStyle="Ridge" BorderColor="Red" AutoCloseDelay="0" ShowCloseButton="true" TitleIcon="none" ContentIcon="Warning" EnableShadow="true" EnableRoundedCorners="true">
            <ContentTemplate>
            </ContentTemplate>
        </telerik:RadNotification>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
        </telerik:RadAjaxLoadingPanel>

        <div id="divLoginBox" class="loginBox" style="text-align: center;" runat="server">
            <%-- <div id="to_delete_this_div__hiding_line_only" style=" height:3px;width:300px; position:absolute;margin: 75px 0px 0px 1px;background-color:white; ">
             </div>--%>
            <div class="loginLicenseInfo" style="display: none;"></div>
            <div class="loginBoxTitle">
                <asp:Label ID="lblAppVersion" runat="server" Text="" Visible="true" />
            </div>

            <div style="width: 75%; display: inline-block; padding-bottom: 20px;">
                <div class="loginBoxContent" id="LoginWrapperDiv" runat="server">
                    <div runat="server" id="sysMessage" style="display: none; width: 100%;">
                        <div runat="server" id="txtSysMessageDiv" class="divSysMessage">
                            <asp:Label ID="txtSysMessage" runat="server" Text="Enter your username and password to login" />
                        </div>
                    </div>

                    <div id="LoginDiv" runat="server" style="width: 335px;">
                        <asp:Panel Style="padding-top: 20px; text-align: right;" ID="Panel1" runat="server" DefaultButton="LoginCmd">
                            <div id="trustDiv" runat="server" style="padding-top: 5px; text-align: right;">
                                <asp:Label ID="LabelTrust" runat="server" Text="">Trust:</asp:Label>
                                <telerik:RadComboBox ID="txtTrustName" runat="server" Skin="Metro" Width="205px" AutoPostBack="true" />
                            </div>
                            <div style="padding-top: 5px; text-align: right;" runat="server" id="usernamediv">
                                <div style="text-align: center;">
                                    <asp:Label ID="SecurityCodeLabel" runat="server" BackColor="#c20e24" Font-Bold="true" ForeColor="White"></asp:Label>
                                </div>
                                <asp:Label ID="lblUsername" runat="server" Text="">Username:</asp:Label>
                                <telerik:RadTextBox ID="txtUserID" runat="server" Width="205px" ClientEvents-OnBlur="UserIdBlur" Skin="Metro" />
                            </div>
                            <div style="padding-top: 5px; text-align: right;" runat="server" id="passworddiv">
                                <asp:Label ID="lblPassWD" runat="server" Text="">Password:</asp:Label>
                                <telerik:RadTextBox ID="txtPassWD" runat="server" Width="205px" Skin="Metro" AutoCompleteType="Disabled" CssClass="PasswordText" TextMode="Password" />
                            </div>
                            <div id="databasediv" runat="server" style="padding-top: 5px; text-align: right;">
                                <asp:Label ID="LabelDatabase" runat="server" Text="">Database name:</asp:Label>
                                <telerik:RadComboBox ID="txtDatabaseName" runat="server" Skin="Metro" Width="205px" AutoPostBack="true" OnSelectedIndexChanged="txtDatabaseName_SelectedIndexChanged" />
                            </div>
                            <div id="hospitaldiv" runat="server" style="padding-top: 5px; text-align: right;">
                                <asp:Label ID="Labelhospital" runat="server" Text="">Room/Hospital:</asp:Label>
                                <%--<telerik:RadComboBox ID="txtOperatingHospital" runat="server" Skin="Metro" Width="205px" />--%>

                                <telerik:RadMultiColumnComboBox runat="server" ID="txtOperatingHospital" Skin="Metro"
                                    Width="205px" RenderMode="Lightweight"
                                    Filter="contains" FilterFields="HospitalName, RoomName" DataKeyNames="RoomId"
                                    DataTextField="RoomName" DataValueField="RoomId" Height="200px">
                                    <ColumnsCollection>
                                        <telerik:MultiColumnComboBoxColumn Field="RoomName" Title="Room name" Width="120px" />
                                        <telerik:MultiColumnComboBoxColumn Field="HospitalName" Title="Operating hospital" Width="200px" />
                                    </ColumnsCollection>
                                    <ClientEvents OnSelect="OperatingHospitalChanged" />
                                </telerik:RadMultiColumnComboBox>
                                <asp:HiddenField ID="hfPortName" runat="server" Value="" />
                            </div>
                            <div style="padding-top: 15px;">
                                <div style="float: right;">
                                    <telerik:RadButton ID="LoginCmd" runat="server" Text="Login" Skin="Metro" Font-Bold="False" Font-Size="Medium"
                                        ButtonType="SkinnedButton" BorderStyle="Solid" BorderWidth="1" BorderColor="#25a0da" CssClass="rbPrimaryButton" RenderMode="Lightweight" />
                                </div>
                                <div runat="server" id="ResetDiv" style="float: right; padding-right: 10px;">
                                    <%--<telerik:RadButton ID="QuickLoginButton" runat="server" Text="Quick" Skin="WebBlue" ButtonType="SkinnedButton"/> &nbsp;--%>
                                    <telerik:RadButton ID="ResetCmd" runat="server" Text="Reset" Skin="Metro" Font-Bold="False" Font-Size="Medium" OnClick="PageReset"
                                        ButtonType="SkinnedButton" BorderStyle="Solid" BorderWidth="1" BorderColor="#d6d6d6" RenderMode="Lightweight" />
                                </div>
                            </div>
                        </asp:Panel>
                    </div>

                    <div id="PasswordResetDiv" runat="server" style="display: none">
                        <div style="padding-top: 20px; text-align: right;">
                            <asp:Label ID="Label1" runat="server" Text="">Username:</asp:Label>
                            <telerik:RadTextBox ID="PasswordResetUsernameRadTextBox" runat="server" Width="205px" Enabled="false" Skin="Metro" />
                        </div>
                        <div style="padding-top: 3px; text-align: right;">
                            <asp:Label ID="NewPasswordLabel" runat="server" Text="">New Password:</asp:Label>
                            <telerik:RadTextBox ID="NewPasswordRadTextBox" runat="server" Width="205px" Skin="Metro" AutoCompleteType="Disabled" CssClass="PasswordText" TextMode="Password" />
                        </div>
                        <div style="padding-top: 3px; text-align: right;">
                            <asp:Label ID="ConfirmPasswordLabel" runat="server" Text="">Confirm Password:</asp:Label>
                            <telerik:RadTextBox ID="ConfirmPasswordRadTextBox" runat="server" Width="205px" Skin="Metro" AutoCompleteType="Disabled" CssClass="PasswordText" TextMode="Password" />
                        </div>
                        <%-- <div style="padding-top: 3px; text-align: right;">
                            <asp:Label ID="Label3" runat="server" Text="">Operating Hospital:</asp:Label>
                            <telerik:RadComboBox ID="txtOperatingHospitalResetPass" runat="server" Skin="Windows7" Width="205px" OnClientKeyPressing=""  />
                            <% '<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtOperatingHospitalResetPass" ForeColor="Red" Font-Size="Smaller" BackColor="#ccffff"  ErrorMessage="Please select an Operating Hospital."></asp:RequiredFieldValidator>
                                %>
                        </div>--%>


                        <div style="padding-top: 15px;">
                            <div style="float: right;">
                                <telerik:RadButton ID="PasswordResetConfirmButton" runat="server" Text="Confirm" Skin="Metro" Font-Bold="False" Font-Size="Medium" ButtonType="SkinnedButton" />
                            </div>
                            <div style="float: right; padding-right: 10px;">
                                <telerik:RadButton ID="PasswordResetCancelButton" runat="server" Text="Cancel" Skin="Metro" Font-Bold="False" Font-Size="Medium" ButtonType="SkinnedButton" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="loginBoxCopyright">
                <asp:Label ID="lblCopyright" runat="server" Text=""></asp:Label><br />
                <a target="_blank" href="http://www.hd-clinical.com">
                    <asp:Label ID="lblWebURL" runat="server" Text="www.hd-clinical.com"></asp:Label>
                </a>
            </div>
        </div>

        <div class="loginShadowBox">
        </div>
        <asp:ObjectDataSource ID="ImagePortObjectDataSource" runat="server" SelectMethod="GetAvailableImagePorts" TypeName="UnisoftERS.DataAccess">
            <SelectParameters>
                <asp:ControlParameter Name="OperatingHospitalId" ControlID="txtOperatingHospital" PropertyName="Value" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <telerik:RadWindowManager runat="server" ShowContentDuringLoad="False" Style="z-index: 7001" Behaviors="Close" Skin="Metro" EnableShadow="True" Modal="True" Behavior="Close, Move" ReloadOnShow="True">
            <Windows>
                <telerik:RadWindow ID="ImagePortConfigurationRadWindow" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="450px" Height="190px" Title="ImagePort Configuration Check" VisibleStatusbar="false" Modal="true" Behaviors="None">
                    <ContentTemplate>
                        <div id="IPCheckDiv" style="text-align: center;">
                            <p>
                                <b>Welcome to Solus</b>
                                <br />
                                Is this PC ever going to be used in CONJUNCTION WITH ENDOSCOPY EQUIPMENT to capture images during the procedures?<br />
                                Click YES if it is, or click NO if this PC will be taking its endoscopy images from ANY endoscopy stack
                            </p>
                            <div>
                                <telerik:RadButton ID="IPCheckYesButton" runat="server" Text="Yes" AutoPostBack="false" />
                                &nbsp; &nbsp;
                                <telerik:RadButton ID="IPCheckNoButton" runat="server" Text="No" />
                            </div>
                        </div>
                        <div id="StaticIPCheckDiv" style="display: none; text-align: center;">
                            <p style="padding-bottom: 28px;">
                                <b>STATIC or DYNAMIC Image Capture setup</b>
                                <br />
                                <br />
                                Is this PC connected to the SAME single endoscopy stack EVERY TIME it is used?
                            </p>
                            <div class="buttons">
                                <asp:HiddenField ID="hdStatic" runat="server" Value="1" />
                                <telerik:RadButton ID="StaticIPCheckYesButton" runat="server" Text="Yes" AutoPostBack="false" />
                                &nbsp; &nbsp;
                                <telerik:RadButton ID="StaticIPCheckNoButton" runat="server" Text="No" AutoPostBack="false" />
                            </div>
                        </div>
                        <div id="ImagePortSelectionDiv" style="display: none; text-align: center;">
                            <div id="NoImagePortsAvailable">
                                <p style="padding-top: 20px; padding-bottom: 40px;">
                                    No image ports configured to link to.
                                </p>
                                <div class="buttons">
                                    <telerik:RadButton ID="NoImagePortButton" runat="server" Text="Ok" />
                                </div>
                            </div>
                            <div id="ImagePortsAvailable">
                                <p style="padding-bottom: 8px;">
                                    <b>Choose the ImagePort that is connected</b>
                                    <br />
                                    Please check the front of the endoscopy light box (or ImagePort itself) for the name of the device and select it from this list
                                </p>
                                ImagePort:&nbsp;
                                <telerik:RadComboBox ID="ImagePortsComboxBox" DataSourceID="ImagePortObjectDataSource" AppendDataBoundItems="true" Style="z-index: 999999;" runat="server" DataTextField="PortName" DataValueField="ImagePortId" Skin="Metro">
                                    <Items>
                                        <telerik:RadComboBoxItem Value="0" Text="Choose one" />
                                    </Items>
                                </telerik:RadComboBox>

                                <div class="buttons">
                                    <telerik:RadButton ID="ImagePortSelectionOk" runat="server" Text="Ok" />
                                    &nbsp; &nbsp;
                                    <telerik:RadButton ID="ImagePortSelectionCancel" runat="server" Text="Cancel" />
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="RadWindow1" runat="server" ReloadOnShow="true" KeepInScreenBounds="true" Width="400px" Height="150px" Title="Login confirmation" VisibleStatusbar="false" Modal="true">
                    <ContentTemplate>
                        <div>
                            <table id="table4" runat="server" cellspacing="0" cellpadding="0" border="0" style="margin: 5px; padding-bottom: 5px;">
                                <tr>
                                    <td align="center">
                                        <label id="isLockUserLabel" />
                                        <br />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv2" style="margin-left: 5px; height: 10px; padding-top: 20px; vertical-align: central;">
                                            <telerik:RadButton ID="RadButton1" runat="server" Text="Confirm" Skin="Metro" AutoPostBack="true" OnClick="ClearAndProceedToLogin" ButtonType="SkinnedButton" />
                                            <telerik:RadButton ID="RadButton2" runat="server" Text="Cancel" AutoPostBack="false" Skin="Metro" OnClientClicked="CloseWin" ButtonType="SkinnedButton" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
        <asp:HiddenField ID="licenseExpired" runat="server" />
    </form>
</body>
</html>
