<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_StartupSettings" CodeBehind="StartupSettings.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
                if ($("#<%=PatientListRadioButton.ClientID%>").is(':checked')) { $("#<%=PatientListRadioButtonTable.ClientID%>").show(); } else{$("#<%=PatientListRadioButtonTable.ClientID%>").hide();}
                
            });
            $(document).ready(function () {
                $("#<%=SearchCriteriaRadioButton.ClientID%>").click(function () {
                    $("#<%=PatientListRadioButtonTable.ClientID%>").hide();
                    $("#<%=PatientListRadioButtonTable.ClientID%> input:checkbox").prop('checked', false);
                    $("#<%=PatientListRadioButtonTable.ClientID%> input:radio").prop('checked', false);
                    $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionFromRadDateInput.ClientID%>").disable();
                }); 

                $("#<%=PatientListRadioButton.ClientID%>").click(function () {
                    $("#<%=PatientListRadioButtonTable.ClientID%>").show();
                    $("#<%=OptionAllRadioButton.ClientID%>").prop('checked', true); 
                    $("#<%=AllProcCheckBox.ClientID%>").prop('checked', true); 
                    });

                $("#<%=AllProcCheckBox.ClientID%>").click(function () {
                    if( $("#<%=AllProcCheckBox.ClientID%>").is(':checked')){ $('#procTD input:checkbox').not($("#<%=AllProcCheckBox.ClientID%>")).prop('checked', false);   } 
                });
                $('#procTD input:checkbox').not($("#<%=AllProcCheckBox.ClientID%>")).click(function () {
                    if ($(this).is(':checked')) {
                        if ($("#<%=AllProcCheckBox.ClientID%>").is(':checked')) { $("#<%=AllProcCheckBox.ClientID%>").prop('checked', false); }
                    }
                });
              

            });
            function onChange(sender) {
                OptionAllRadioButton
               if (sender.id == 'OptionOnlyLastRadioButton' && $("#<%=OptionOnlyLastRadioButton.ClientID%>").is(':checked')) {
                   $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").enable();
                   $find("<%=OptionFromRadDateInput.ClientID%>").disable();
                   $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
                }
                if (sender.id == 'OptionFromRadioButton' && $("#<%=OptionFromRadioButton.ClientID%>").is(':checked')) {
                    $find("<%=OptionFromRadDateInput.ClientID%>").enable(); 
                    $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
                }
                if (sender.id == 'OptionLastRadioButton' && $("#<%=OptionLastRadioButton.ClientID%>").is(':checked')) {
                    $find("<%=OptionLastRadNumericTextBox.ClientID%>").enable(); 
                    $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionFromRadDateInput.ClientID%>").disable();
                }
                if (sender.id == 'OptionAllRadioButton' && $("#<%=OptionAllRadioButton.ClientID%>").is(':checked')) {
                    $find("<%=OptionLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionOnlyLastRadNumericTextBox.ClientID%>").disable();
                    $find("<%=OptionFromRadDateInput.ClientID%>").disable();
                }
            }
        </script>
    </telerik:RadCodeBlock>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div class="optionsHeading">Application start up configuration</div>

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="580px">
                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <fieldset class="sysFieldset">
                                <legend><b>How do you want the software to appear at start up?</b></legend>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:RadioButton runat="server" ID="SearchCriteriaRadioButton" Text="Begin by prompting for search criteria" GroupName="begin" Checked="true" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:RadioButton runat="server" ID="PatientListRadioButton" Text="Begin by loading a list of patients" GroupName="begin" />
                                            <table id="PatientListRadioButtonTable" runat="server">
                                                <tr>
                                                    <td valign="top">
                                                        <fieldset style="height: 210px; width: 385px">
                                                            <p>
                                                                <asp:RadioButton runat="server" ID="OptionAllRadioButton" Text="all the patient in the database(the default)" GroupName="plist" Checked="true" onclick="javascript:onChange(this);" />
                                                            </p>
                                                            <p>
                                                                <asp:RadioButton runat="server" ID="OptionOnlyLastRadioButton" Text="only the last " GroupName="plist" onclick="javascript:onChange(this);" />
                                                                <telerik:RadNumericTextBox ID="OptionOnlyLastRadNumericTextBox" Enabled="false" runat="server" IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="1" Width="65px"
                                                                    MinValue="1" Value="100" MaxLength="7">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <label>patients</label>
                                                            </p>
                                                            <p>
                                                                <asp:RadioButton runat="server" ID="OptionFromRadioButton" Text="those patients added from " GroupName="plist" onclick="javascript:onChange(this);" />
                                                                <telerik:RadDateInput ID="OptionFromRadDateInput" runat="server" Enabled="false" DateFormat="dd/MM/yyyy" DisplayDateFormat="dd/MM/yyyy">
                                                                </telerik:RadDateInput>

                                                            </p>
                                                            <p>
                                                                <asp:RadioButton runat="server" ID="OptionLastRadioButton" Text="those patients added in the last " GroupName="plist" onclick="javascript:onChange(this);" />
                                                                <telerik:RadNumericTextBox ID="OptionLastRadNumericTextBox" Enabled="false" runat="server" IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="1" Width="35px"
                                                                    MinValue="0" Value="6" MaxLength="4">
                                                                    <NumberFormat DecimalDigits="0" />
                                                                </telerik:RadNumericTextBox>
                                                                <label>months</label>
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox runat="server" ID="DeadCheckBox" Text="Exclude patients who have died" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox runat="server" ID="OldProcCheckBox" Text="Exclude old procedures" />
                                                            </p>
                                                        </fieldset>
                                                    </td>
                                                    <td valign="top" id="procTD">
                                                        <fieldset style="height: 210px; width: 250px">
                                                            <p>
                                                                <asp:CheckBox ID="AllProcCheckBox" runat="server" Text="All procedures" Checked="true" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox ID="GastroCheckBox" runat="server" Text="gastroscopy" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox ID="ERCPCheckBox" runat="server" Text="ERCP" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox ID="ColonCheckBox" runat="server" Text="colon/sigmoidoscopy" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox ID="ProctoCheckBox" runat="server" Text="proctoscopy" />
                                                            </p>
                                                            <p>
                                                                <asp:CheckBox ID="CLOCheckBox" runat="server" Text="outstanding CLO test" />
                                                            </p>
                                                        </fieldset>
                                                    </td>
                                                </tr>
                                            </table>

                                        </td>
                                    </tr>
                                </table>

                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset>
                                <legend>When the list of patients is displayed</legend>
                                <p>
                                    <asp:RadioButton runat="server" ID="ReverseRadioButton"  Text="show them in reverse date order (the most recently added, appearing at the top of the list)" GroupName="dlist"  Checked="true"/>
                                </p>
                                <p>
                                    <asp:RadioButton runat="server" ID="AlphabetRadioButton" Text="show them in alphabetical order of surname" GroupName="dlist" />
                                </p>
                            </fieldset>
                        </td>
                    </tr>
                </table>
            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="43px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-top: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" OnClick="saveData" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <%--OnClientClicking="ConfirmSave"--%>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20"
                        AutoPostBack="false" Icon-PrimaryIconCssClass="telerikCancelButton" />
                    <%--OnClientClicked="RefreshPage"--%>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </form>
</body>
</html>
